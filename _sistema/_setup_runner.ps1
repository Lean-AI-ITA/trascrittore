# _setup_runner.ps1 — legge config da file, scrive log strutturato
$ErrorActionPreference = "Stop"

$cfgFile = "$env:TEMP\trascrittore_cfg.txt"
$LogFile = $null
$Action  = $null

# Leggi configurazione
if (Test-Path $cfgFile) {
    Get-Content $cfgFile | ForEach-Object {
        if ($_ -match "^LogFile=(.+)$") { $LogFile = $Matches[1].Trim() }
        if ($_ -match "^Action=(.+)$")  { $Action  = $Matches[1].Trim() }
    }
}

# Se manca il log file, scrivi su desktop per debug
if (-not $LogFile) {
    "Config non trovata o LogFile mancante" | Set-Content "$env:USERPROFILE\Desktop\trascrittore_debug.txt"
    exit 1
}

$SISTEMA = Split-Path -Parent $MyInvocation.MyCommand.Path
$ROOT    = Split-Path -Parent $SISTEMA

function W($line) {
    [System.IO.File]::AppendAllText($LogFile, "$line`r`n", [System.Text.Encoding]::ASCII)
}
function W-Step($pct, $msg) { W "STEP|$pct|$msg" }
function W-Ok($msg)         { W "LOG|ok|$msg"    }
function W-Warn($msg)       { W "LOG|warn|$msg"  }
function W-Err($msg)        { W "LOG|err|$msg"   }
function W-Info($msg)       { W "LOG|info|$msg"  }
function W-Done($what)      { W "DONE|$what|ok"  }
function W-Fatal($msg)      { W "ERROR|0|$msg"   }

# Conferma avvio
W-Ok "PowerShell avviato correttamente"
W-Info "Cartella base: $ROOT"

# ── DISINSTALLA ───────────────────────────────────────────────────────────────
if ($Action -eq "uninstall") {
    try {
        W-Step 15 "Rimozione ambiente virtuale..."
        $envPath = Join-Path $ROOT "trascrittore_env"
        if (Test-Path $envPath) {
            Remove-Item $envPath -Recurse -Force
            W-Ok "Ambiente virtuale rimosso"
        } else { W-Info "Ambiente virtuale non presente" }

        W-Step 40 "Rimozione modelli AI..."
        $modelDir = Join-Path $ROOT "models"
        if (Test-Path $modelDir) {
            Remove-Item $modelDir -Recurse -Force
            W-Ok "Modelli AI rimossi"
        } else { W-Info "Cartella modelli non presente" }

        W-Step 60 "Rimozione FFmpeg..."
        $ffPath = Join-Path $ROOT "ffmpeg.exe"
        if (Test-Path $ffPath) { Remove-Item $ffPath -Force; W-Ok "ffmpeg.exe rimosso" }
        else { W-Info "ffmpeg.exe non presente" }

        W-Step 80 "Rimozione scorciatoie..."
        $lnkRoot = Join-Path $ROOT "Avvia Trascrittore.lnk"
        if (Test-Path $lnkRoot) { Remove-Item $lnkRoot -Force; W-Ok "Scorciatoia cartella rimossa" }
        $desk = [Environment]::GetFolderPath("Desktop")
        if (Test-Path "$desk\Trascrittore AI.lnk") {
            Remove-Item "$desk\Trascrittore AI.lnk" -Force; W-Ok "Scorciatoia Desktop rimossa"
        }

        W-Step 100 "Disinstallazione completata"
        W-Ok "Rimosso tutto. I file sorgente sono stati mantenuti."
        W-Done "uninstall"
    } catch { W-Fatal $_.Exception.Message }
    exit
}

# ── INSTALLA ──────────────────────────────────────────────────────────────────
try {
    # STEP 1: Python
    W-Step 5 "Controllo Python..."
    $pyCmd = $null
    foreach ($c in @("python","python3","py")) {
        try {
            $v = & $c --version 2>&1
            if ($v -match "Python 3\.(\d+)" -and [int]$Matches[1] -ge 8) { $pyCmd = $c; break }
        } catch {}
    }

    if (-not $pyCmd) {
        W-Step 10 "Python non trovato — scarico..."
        W-Warn "Scarico Python 3.11 (~25 MB)..."
        $pyUrl  = "https://www.python.org/ftp/python/3.11.9/python-3.11.9-amd64.exe"
        $pyInst = "$env:TEMP\python_setup.exe"
        Invoke-WebRequest -Uri $pyUrl -OutFile $pyInst -UseBasicParsing
        W-Step 17 "Installo Python 3.11..."
        W-Info "Installazione silenziosa (1-2 min)..."
        Start-Process $pyInst -ArgumentList "/quiet","InstallAllUsers=0","PrependPath=1","Include_pip=1","Include_tcltk=1" -Wait
        Remove-Item $pyInst -Force -ErrorAction SilentlyContinue
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" +
                    [System.Environment]::GetEnvironmentVariable("Path","User")
        foreach ($c in @("python","python3","py")) {
            try { $v = & $c --version 2>&1; if ($v -match "Python 3") { $pyCmd = $c; break } } catch {}
        }
        if (-not $pyCmd) { throw "Python installato ma non trovato. Riavvia il PC e riprova." }
        W-Ok "Python installato: $v"
    } else {
        W-Ok "Python trovato: $(& $pyCmd --version 2>&1)"
    }

    # STEP 2: Venv
    W-Step 26 "Creo ambiente virtuale..."
    $envPath = Join-Path $ROOT "trascrittore_env"
    if (-not (Test-Path "$envPath\Scripts\python.exe")) {
        & $pyCmd -m venv $envPath 2>&1 | ForEach-Object { W-Info "$_" }
        W-Ok "Ambiente virtuale creato"
    } else { W-Ok "Ambiente virtuale gia presente" }

    $pip = "$envPath\Scripts\pip.exe"
    $py  = "$envPath\Scripts\python.exe"

    # STEP 3: faster-whisper
    W-Step 40 "Installo faster-whisper..."
    if ((& $pip show faster-whisper 2>&1) -notmatch "Version") {
        W-Info "Scarico faster-whisper (~200 MB)..."
        & $pip install faster-whisper --quiet 2>&1 | ForEach-Object { W-Info "$_" }
        W-Ok "faster-whisper installato"
    } else { W-Ok "faster-whisper gia presente" }

    # STEP 4: ffmpeg
    W-Step 62 "Controllo FFmpeg..."
    $ffPath = Join-Path $ROOT "ffmpeg.exe"
    if (-not (Test-Path $ffPath)) {
        W-Warn "Scarico FFmpeg (~80 MB)..."
        W-Step 65 "Download FFmpeg..."
        $zipPath = "$env:TEMP\ffmpeg_setup.zip"
        $zipDir  = "$env:TEMP\ffmpeg_setup_ext"
        Invoke-WebRequest "https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip" -OutFile $zipPath -UseBasicParsing
        W-Info "Estraggo FFmpeg..."
        Expand-Archive $zipPath $zipDir -Force
        $ffExe = Get-ChildItem $zipDir -Recurse -Filter "ffmpeg.exe" |
                 Where-Object { $_.DirectoryName -match "\\bin$" } | Select-Object -First 1
        Copy-Item $ffExe.FullName $ffPath
        Remove-Item $zipPath,$zipDir -Recurse -Force -ErrorAction SilentlyContinue
        W-Ok "FFmpeg installato"
    } else { W-Ok "FFmpeg gia presente" }

    # STEP 5: Modello Whisper
    W-Step 78 "Scarico modello AI Whisper base..."
    $modelDir = Join-Path $ROOT "models"
    if (-not (Test-Path "$modelDir\base\model.bin")) {
        W-Info "Scarico modello base (~150 MB)..."
        & $py -c "from faster_whisper import WhisperModel; WhisperModel('base', device='cpu', compute_type='int8', download_root=r'$modelDir')" 2>&1 |
            ForEach-Object { W-Info "$_" }
        W-Ok "Modello AI pronto"
    } else { W-Ok "Modello AI gia presente" }

    # STEP 6: Scorciatoie
    W-Step 93 "Creo scorciatoie..."
    $appScript = Join-Path $SISTEMA "trascrittore_portable.py"
    $wsh = New-Object -ComObject WScript.Shell

    $lk = $wsh.CreateShortcut((Join-Path $ROOT "Avvia Trascrittore.lnk"))
    $lk.TargetPath = $py; $lk.Arguments = "`"$appScript`""; $lk.WorkingDirectory = $ROOT
    $lk.IconLocation = "$env:SystemRoot\System32\imageres.dll,109"; $lk.Save()

    $lk2 = $wsh.CreateShortcut("$([Environment]::GetFolderPath('Desktop'))\Trascrittore AI.lnk")
    $lk2.TargetPath = $py; $lk2.Arguments = "`"$appScript`""; $lk2.WorkingDirectory = $ROOT
    $lk2.IconLocation = "$env:SystemRoot\System32\imageres.dll,109"; $lk2.Save()
    W-Ok "Scorciatoie create (cartella + Desktop)"

    W-Step 100 "Installazione completata!"
    W-Ok "Tutto pronto. Avvio il trascrittore..."
    W-Done "install"

} catch { W-Fatal $_.Exception.Message }
