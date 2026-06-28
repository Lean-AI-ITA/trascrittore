# _setup.ps1 — Setup automatico Trascrittore AI
# Lanciato da AVVIA.vbs (nella cartella root), mostra finestra WPF con progress

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase

$SISTEMA = Split-Path -Parent $MyInvocation.MyCommand.Path   # …/_sistema
$ROOT    = Split-Path -Parent $SISTEMA                        # cartella principale

# ── XAML della finestra ───────────────────────────────────────────────────────
[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Trascrittore AI — Configurazione" Height="480" Width="560"
        WindowStartupLocation="CenterScreen"
        ResizeMode="NoResize"
        Background="#0F0F23">
  <Window.Resources>
    <Style TargetType="TextBlock">
      <Setter Property="Foreground" Value="#F8FAFC"/>
      <Setter Property="FontFamily" Value="Segoe UI"/>
    </Style>
  </Window.Resources>
  <Grid Margin="32">
    <Grid.RowDefinitions>
      <RowDefinition Height="Auto"/>
      <RowDefinition Height="Auto"/>
      <RowDefinition Height="Auto"/>
      <RowDefinition Height="*"/>
      <RowDefinition Height="Auto"/>
    </Grid.RowDefinitions>

    <!-- Header -->
    <StackPanel Grid.Row="0" Margin="0,0,0,24">
      <TextBlock Text="Trascrittore AI" FontSize="22" FontWeight="Bold"
                 Foreground="#F97316"/>
      <TextBlock Text="Configurazione automatica — attendi qualche minuto"
                 FontSize="11" Foreground="#8B8BA8" Margin="0,4,0,0"/>
    </StackPanel>

    <!-- Step corrente -->
    <TextBlock x:Name="StepLabel" Grid.Row="1"
               Text="Inizializzazione..." FontSize="13" FontWeight="SemiBold"
               Foreground="#F8FAFC" Margin="0,0,0,8"/>

    <!-- Progress bar -->
    <Grid Grid.Row="2" Margin="0,0,0,20">
      <Rectangle Height="8" RadiusX="4" RadiusY="4" Fill="#22223F"/>
      <Rectangle x:Name="ProgressFill" Height="8" RadiusX="4" RadiusY="4"
                 Fill="#F97316" HorizontalAlignment="Left" Width="0"/>
    </Grid>

    <!-- Log scrollabile -->
    <Border Grid.Row="3" Background="#1A1A35" CornerRadius="8"
            BorderBrush="#2E2E5A" BorderThickness="1">
      <ScrollViewer x:Name="LogScroll" VerticalScrollBarVisibility="Auto" Padding="12">
        <TextBlock x:Name="LogBox" FontFamily="Consolas" FontSize="11"
                   Foreground="#8B8BA8" TextWrapping="Wrap"/>
      </ScrollViewer>
    </Border>

    <!-- Pulsante finale (nascosto finche non finisce) -->
    <Button x:Name="BtnAvvia" Grid.Row="4" Margin="0,20,0,0"
            Height="48" FontSize="14" FontWeight="Bold"
            Content="AVVIA IL TRASCRITTORE"
            Background="#F97316" Foreground="White"
            BorderThickness="0" Cursor="Hand"
            Visibility="Collapsed">
      <Button.Template>
        <ControlTemplate TargetType="Button">
          <Border Background="{TemplateBinding Background}"
                  CornerRadius="8" Padding="20,10">
            <ContentPresenter HorizontalAlignment="Center"
                              VerticalAlignment="Center"/>
          </Border>
        </ControlTemplate>
      </Button.Template>
    </Button>
  </Grid>
</Window>
"@

$reader = New-Object System.Xml.XmlNodeReader $xaml
$window = [Windows.Markup.XamlReader]::Load($reader)

$StepLabel    = $window.FindName("StepLabel")
$ProgressFill = $window.FindName("ProgressFill")
$LogBox       = $window.FindName("LogBox")
$LogScroll    = $window.FindName("LogScroll")
$BtnAvvia     = $window.FindName("BtnAvvia")
$TotalWidth   = 496

function Set-Step($msg, $pct) {
    $window.Dispatcher.Invoke([action]{
        $StepLabel.Text     = $msg
        $ProgressFill.Width = [int]($TotalWidth * $pct / 100)
    })
}

function Add-Log($msg, $color="#8B8BA8") {
    $window.Dispatcher.Invoke([action]{
        $run            = New-Object System.Windows.Documents.Run
        $run.Text       = "[$(Get-Date -f 'HH:mm:ss')] $msg`n"
        $run.Foreground = [Windows.Media.BrushConverter]::new().ConvertFromString($color)
        $LogBox.Inlines.Add($run)
        $LogScroll.ScrollToEnd()
    })
}

function Log-Ok($m)   { Add-Log "OK  $m" "#22C55E" }
function Log-Warn($m) { Add-Log "!!  $m" "#F59E0B" }
function Log-Err($m)  { Add-Log "X   $m" "#EF4444" }
function Log-Info($m) { Add-Log "    $m" "#8B8BA8" }

# ── SETUP in background ───────────────────────────────────────────────────────
$setupJob = [System.Threading.Tasks.Task]::Run([action]{
    try {

        # STEP 1: Python
        Set-Step "Controllo Python..." 5
        Log-Info "Cerco Python..."

        $pyCmd = $null
        foreach ($c in @("python","python3","py")) {
            try {
                $v = & $c --version 2>&1
                if ($v -match "Python 3\.(\d+)") {
                    $minor = [int]$Matches[1]
                    if ($minor -ge 8) { $pyCmd = $c; break }
                }
            } catch {}
        }

        if (-not $pyCmd) {
            Set-Step "Scarico Python 3.11..." 10
            Log-Warn "Python non trovato — scarico installer (~25 MB)..."

            $pyUrl  = "https://www.python.org/ftp/python/3.11.9/python-3.11.9-amd64.exe"
            $pyInst = "$env:TEMP\python_installer.exe"
            Invoke-WebRequest -Uri $pyUrl -OutFile $pyInst -UseBasicParsing

            Set-Step "Installo Python 3.11..." 18
            Log-Info "Installo Python silenziosamente..."
            Start-Process $pyInst -ArgumentList "/quiet","InstallAllUsers=0","PrependPath=1","Include_pip=1","Include_tcltk=1" -Wait
            Remove-Item $pyInst -Force

            $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" +
                        [System.Environment]::GetEnvironmentVariable("Path","User")

            foreach ($c in @("python","python3","py")) {
                try { $v = & $c --version 2>&1; if ($v -match "Python 3") { $pyCmd = $c; break } } catch {}
            }
            if (-not $pyCmd) { throw "Installazione Python fallita. Riavvia il PC e riprova." }
            Log-Ok "Python installato: $v"
        } else {
            $ver = & $pyCmd --version 2>&1
            Log-Ok "Python trovato: $ver"
        }

        # STEP 2: Ambiente virtuale
        Set-Step "Creo ambiente virtuale..." 25
        $envPath = Join-Path $ROOT "trascrittore_env"

        if (-not (Test-Path "$envPath\Scripts\python.exe")) {
            Log-Info "Creo ambiente virtuale..."
            & $pyCmd -m venv $envPath 2>&1 | ForEach-Object { Log-Info $_ }
            Log-Ok "Ambiente virtuale creato"
        } else {
            Log-Ok "Ambiente virtuale gia presente"
        }

        $pip = "$envPath\Scripts\pip.exe"
        $py  = "$envPath\Scripts\python.exe"

        # STEP 3: faster-whisper
        Set-Step "Installo motore AI (faster-whisper)..." 40
        $installed = & $pip show faster-whisper 2>&1
        if ($installed -notmatch "Version") {
            Log-Info "Scarico faster-whisper (~200 MB) — solo questa volta..."
            & $pip install faster-whisper --quiet 2>&1 | ForEach-Object { Log-Info $_ }
            Log-Ok "faster-whisper installato"
        } else {
            Log-Ok "faster-whisper gia installato"
        }

        # STEP 4: ffmpeg
        Set-Step "Controllo FFmpeg..." 65
        $ffmpegPath = Join-Path $ROOT "ffmpeg.exe"

        if (-not (Test-Path $ffmpegPath)) {
            Log-Warn "ffmpeg.exe non trovato — scarico (~80 MB)..."
            Set-Step "Scarico FFmpeg..." 68

            $zipUrl  = "https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip"
            $zipPath = "$env:TEMP\ffmpeg.zip"
            $zipDir  = "$env:TEMP\ffmpeg_extract"

            Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath -UseBasicParsing
            Expand-Archive -Path $zipPath -DestinationPath $zipDir -Force

            $ffExe = Get-ChildItem -Path $zipDir -Recurse -Filter "ffmpeg.exe" |
                     Where-Object { $_.DirectoryName -match "\\bin$" } |
                     Select-Object -First 1
            Copy-Item $ffExe.FullName $ffmpegPath

            Remove-Item $zipPath,$zipDir -Recurse -Force -ErrorAction SilentlyContinue
            Log-Ok "FFmpeg scaricato e pronto"
        } else {
            Log-Ok "FFmpeg gia presente"
        }

        # STEP 5: Modello AI
        Set-Step "Scarico modello AI (base)..." 80
        $modelDir = Join-Path $ROOT "models"

        $modelOk = Test-Path "$modelDir\base\model.bin"
        if (-not $modelOk) {
            Log-Info "Scarico modello Whisper base (~150 MB) — solo questa volta..."
            & $py -c "
from faster_whisper import WhisperModel
WhisperModel('base', device='cpu', compute_type='int8', download_root=r'$modelDir')
print('OK')
" 2>&1 | ForEach-Object { Log-Info $_ }
            Log-Ok "Modello AI pronto"
        } else {
            Log-Ok "Modello AI gia presente"
        }

        # STEP 6: Scorciatoie con icona
        Set-Step "Creo scorciatoie..." 93
        $appScript = Join-Path $SISTEMA "trascrittore_portable.py"
        $wsh       = New-Object -ComObject WScript.Shell

        # Scorciatoia nella cartella principale (accanto ad AVVIA.vbs)
        $lnkRoot = Join-Path $ROOT "Avvia Trascrittore.lnk"
        $link = $wsh.CreateShortcut($lnkRoot)
        $link.TargetPath       = $py
        $link.Arguments        = "`"$appScript`""
        $link.WorkingDirectory = $ROOT
        $link.Description      = "Avvia Trascrittore AI"
        $link.IconLocation     = "$env:SystemRoot\System32\imageres.dll,109"
        $link.Save()
        Log-Ok "Scorciatoia creata nella cartella principale"

        # Scorciatoia sul Desktop
        $desktop = [Environment]::GetFolderPath("Desktop")
        $lnkDesk = Join-Path $desktop "Trascrittore AI.lnk"
        $link2 = $wsh.CreateShortcut($lnkDesk)
        $link2.TargetPath       = $py
        $link2.Arguments        = "`"$appScript`""
        $link2.WorkingDirectory = $ROOT
        $link2.Description      = "Trascrittore AI"
        $link2.IconLocation     = "$env:SystemRoot\System32\imageres.dll,109"
        $link2.Save()
        Log-Ok "Scorciatoia creata sul Desktop"

        # DONE
        Set-Step "Tutto pronto!" 100
        Log-Ok "Configurazione completata!"
        Log-Info "Usa 'Avvia Trascrittore' nella cartella o sul Desktop."

        $window.Dispatcher.Invoke([action]{
            $BtnAvvia.Visibility = "Visible"
        })

    } catch {
        Log-Err "ERRORE: $_"
        Set-Step "Errore durante la configurazione" 0
        $window.Dispatcher.Invoke([action]{
            $StepLabel.Foreground = [Windows.Media.Brushes]::Red
        })
    }
})

# Click pulsante AVVIA
$BtnAvvia.Add_Click({
    $py  = "$ROOT\trascrittore_env\Scripts\python.exe"
    $app = "$SISTEMA\trascrittore_portable.py"
    Start-Process $py -ArgumentList "`"$app`"" -WorkingDirectory $ROOT
    $window.Close()
})

$window.ShowDialog() | Out-Null
