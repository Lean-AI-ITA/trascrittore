# _setup_runner.ps1 — worker senza UI, scrive progress su file
param(
    [string]$LogFile,
    [string]$Action   # install | uninstall
)

$SISTEMA = Split-Path -Parent $MyInvocation.MyCommand.Path
$ROOT    = Split-Path -Parent $SISTEMA

function W-Step($pct, $msg) { "STEP|$pct|$msg"   | Add-Content $LogFile -Encoding ASCII }
function W-Ok($msg)         { "LOG|ok|$msg"       | Add-Content $LogFile -Encoding ASCII }
function W-Warn($msg)       { "LOG|warn|$msg"     | Add-Content $LogFile -Encoding ASCII }
function W-Err($msg)        { "LOG|err|$msg"      | Add-Content $LogFile -Encoding ASCII }
function W-Info($msg)       { "LOG|info|$msg"     | Add-Content $LogFile -Encoding ASCII }
function W-Done($what)      { "DONE|$what|ok"     | Add-Content $LogFile -Encoding ASCII }
function W-Fatal($msg)      { "ERROR|0|$msg"      | Add-Content $LogFile -Encoding ASCII }

# ── DISINSTALLA ───────────────────────────────────────────────────────────────
if ($Action -eq "uninstall") {
    try {
        W-Step 15 "Rimozione ambiente virtuale..."
        $envPath = Join-Path $ROOT "trascrittore_env"
        if (Test-Path $envPath) {
            Remove-Item $envPath -Recurse -Force
            W-Ok "Ambiente virtuale rimosso"
        } else { W-Info "Ambiente virtuale non trovato (gia rimosso?)" }

        W-Step 40 "Rimozione modelli AI..."
        $modelDir = Join-Path $ROOT "models"
        if (Test-Path $modelDir) {
            Remove-Item $modelDir -Recurse -Force
            W-Ok "Modelli AI rimossi"
        } else { W-Info "Cartella modelli non trovata" }

        W-Step 60 "Rimozione FFmpeg..."
        $ffPath = Join-Path $ROOT "ffmpeg.exe"
        if (Test-Path $ffPath) {
            Remove-Item $ffPath -Force
            W-Ok "ffmpeg.exe rimosso"
        } else { W-Info "ffmpeg.exe non presente" }

        W-Step 80 "Rimozione scorciatoie..."
        $lnkRoot = Join-Path $ROOT "Avvia Trascrittore.lnk"
        if (Test-Path $lnkRoot) { Remove-Item $lnkRoot -Force; W-Ok "Scorciatoia cartella rimossa" }
        $desk = [Environment]::GetFolderPath("Desktop")
        $lnkDesk = "$desk\Trascrittore AI.lnk"
        if (Test-Path $lnkDesk) { Remove-Item $lnkDesk -Force; W-Ok "Scorciatoia Desktop rimossa" }

        W-Step 100 "Disinstallazione completata"
        W-Ok "Rimosso tutto. I file sorgente sono stati mantenuti."
        W-Info "Puoi eliminare l'intera cartella se non ti serve piu."
        W-Done "uninstall"

    } catch { W-Fatal $_.Exception.Message }
    exit
}

# ── INSTALLA ──────────────────────────────────────────────────────────────────
try {
    # STEP 1: Python
    W-Step 5 "Controllo Python..."
    W-Info "Cerco Python installato sul sistema..."
    $pyCmd = $null
    foreach ($c in @("python","python3","py")) {
        try {
            $v = & $c --version 2>&1
            if ($v -match "Python 3\.(\d+)" -and [int]$Matches[1] -ge 8) { $pyCmd = $c; break }
        } catch {}
    }

    if (-not $pyCmd) {
        W-Step 10 "Python non trovato — scarico installer..."
        W-Warn "Python non trovato. Scarico Python 3.11 (~25 MB)..."
        $pyUrl  = "https://www.python.org/ftp/python/3.11.9/python-3.11.9-amd64.exe"
        $pyInst = "$env:TEMP\python_trascrittore_setup.exe"
        Invoke-WebRequest -Uri $pyUrl -OutFile $pyInst -UseBasicParsing
        W-Info "Installer scaricato. Installo in silenzio (1-2 min)..."
        W-Step 16 "Installo Python 3.11..."
        Start-Process $pyInst -ArgumentList "/quiet","InstallAllUsers=0","PrependPath=1","Include_pip=1","Include_tcltk=1" -Wait
        Remove-Item $pyInst -Force -ErrorAction SilentlyContinue
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" +
                    [System.Environment]::GetEnvironmentVariable("Path","User")
        foreach ($c in @("python","python3","py")) {
            try { $v = & $c --version 2>&1; if ($v -match "Python 3") { $pyCmd = $c; break } } catch {}
        }
        if (-not $pyCmd) { throw "Python installato ma non trovato nel PATH. Riavvia il PC e riprova." }
        W-Ok "Python 3.11 installato con successo"
    } else {
        W-Ok "Python trovato: $(& $pyCmd --version 2>&1)"
    }

    # STEP 2: Ambiente virtuale
    W-Step 26 "Creo ambiente virtuale isolato..."
    $envPath = Join-Path $ROOT "trascrittore_env"
    if (-not (Test-Path "$envPath\Scripts\python.exe")) {
        W-Info "Creo ambiente virtuale in trascrittore_env\ ..."
        & $pyCmd -m venv $envPath 2>&1 | ForEach-Object { W-Info "$_" }
        W-Ok "Ambiente virtuale creato"
    } else {
        W-Ok "Ambiente virtuale gia presente — salto"
    }

    $pip = "$envPath\Scripts\pip.exe"
    $py  = "$envPath\Scripts\python.exe"

    # STEP 3: faster-whisper
    W-Step 40 "Installo motore AI faster-whisper..."
    if ((& $pip show faster-whisper 2>&1) -notmatch "Version") {
        W-Info "Scarico faster-whisper e dipendenze (~200 MB) — solo questa volta..."
        & $pip install faster-whisper --quiet 2>&1 | ForEach-Object {
            if ($_ -match "Successfully") { W-Ok "$_" } else { W-Info "$_" }
        }
        W-Ok "faster-whisper installato"
    } else {
        W-Ok "faster-whisper gia installato — salto"
    }

    # STEP 4: ffmpeg
    W-Step 62 "Controllo FFmpeg..."
    $ffPath = Join-Path $ROOT "ffmpeg.exe"
    if (-not (Test-Path $ffPath)) {
        W-Warn "FFmpeg non trovato — scarico (~80 MB)..."
        W-Step 65 "Scarico FFmpeg..."
        $zipPath = "$env:TEMP\ffmpeg_trascrittore.zip"
        $zipDir  = "$env:TEMP\ffmpeg_trascrittore_ext"
        Invoke-WebRequest "https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip" -OutFile $zipPath -UseBasicParsing
        W-Info "Download completato. Estraggo..."
        Expand-Archive $zipPath $zipDir -Force
        $ffExe = Get-ChildItem $zipDir -Recurse -Filter "ffmpeg.exe" |
                 Where-Object { $_.DirectoryName -match "\\bin$" } | Select-Object -First 1
        Copy-Item $ffExe.FullName $ffPath
        Remove-Item $zipPath,$zipDir -Recurse -Force -ErrorAction SilentlyContinue
        W-Ok "FFmpeg installato"
    } else {
        W-Ok "FFmpeg gia presente — salto"
    }

    # STEP 5: Modello Whisper
    W-Step 78 "Scarico modello AI Whisper base..."
    $modelDir = Join-Path $ROOT "models"
    if (-not (Test-Path "$modelDir\base\model.bin")) {
        W-Info "Scarico modello Whisper base (~150 MB) — solo questa volta..."
        & $py -c @"
from faster_whisper import WhisperModel
import sys
m = WhisperModel('base', device='cpu', compute_type='int8', download_root=r'$modelDir')
print('Modello caricato OK')
"@ 2>&1 | ForEach-Object {
            if ($_ -match "OK") { W-Ok "$_" } else { W-Info "$_" }
        }
        W-Ok "Modello AI pronto"
    } else {
        W-Ok "Modello AI gia presente — salto"
    }

    # STEP 6: Scorciatoie
    W-Step 93 "Creo scorciatoie con icona..."
    $appScript = Join-Path $SISTEMA "trascrittore_portable.py"
    $wsh = New-Object -ComObject WScript.Shell

    $lnkRoot = Join-Path $ROOT "Avvia Trascrittore.lnk"
    $lk = $wsh.CreateShortcut($lnkRoot)
    $lk.TargetPath = $py; $lk.Arguments = "`"$appScript`""
    $lk.WorkingDirectory = $ROOT; $lk.Description = "Avvia Trascrittore AI"
    $lk.IconLocation = "$env:SystemRoot\System32\imageres.dll,109"
    $lk.Save()

    $desk = [Environment]::GetFolderPath("Desktop")
    $lk2 = $wsh.CreateShortcut("$desk\Trascrittore AI.lnk")
    $lk2.TargetPath = $py; $lk2.Arguments = "`"$appScript`""
    $lk2.WorkingDirectory = $ROOT; $lk2.Description = "Trascrittore AI"
    $lk2.IconLocation = "$env:SystemRoot\System32\imageres.dll,109"
    $lk2.Save()
    W-Ok "Scorciatoie create (cartella principale + Desktop)"

    # FINE
    W-Step 100 "Installazione completata!"
    W-Ok "Tutto pronto! Usa il pulsante qui sotto o la scorciatoia sul Desktop."
    W-Done "install"

} catch {
    W-Fatal $_.Exception.Message
}
