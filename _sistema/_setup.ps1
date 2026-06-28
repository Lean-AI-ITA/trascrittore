# _setup.ps1 — Trascrittore AI  (installa / disinstalla)
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase

$SISTEMA = Split-Path -Parent $MyInvocation.MyCommand.Path
$ROOT    = Split-Path -Parent $SISTEMA

# ── XAML ─────────────────────────────────────────────────────────────────────
[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Trascrittore AI" Height="540" Width="580"
        WindowStartupLocation="CenterScreen" ResizeMode="NoResize"
        Background="#0F0F23" Topmost="True">
  <Window.Resources>
    <Style TargetType="TextBlock">
      <Setter Property="Foreground" Value="#F8FAFC"/>
      <Setter Property="FontFamily" Value="Segoe UI"/>
    </Style>
    <Style x:Key="CardBtn" TargetType="Button">
      <Setter Property="BorderThickness" Value="0"/>
      <Setter Property="Cursor"          Value="Hand"/>
      <Setter Property="FontFamily"      Value="Segoe UI"/>
      <Setter Property="FontWeight"      Value="Bold"/>
      <Setter Property="FontSize"        Value="15"/>
      <Setter Property="Foreground"      Value="White"/>
    </Style>
  </Window.Resources>

  <Grid Margin="32">
    <Grid.RowDefinitions>
      <RowDefinition Height="Auto"/>
      <RowDefinition Height="*"/>
    </Grid.RowDefinitions>

    <!-- HEADER fisso -->
    <StackPanel Grid.Row="0" Margin="0,0,0,28">
      <TextBlock Text="Trascrittore AI" FontSize="26" FontWeight="Bold"
                 Foreground="#F97316"/>
      <TextBlock x:Name="SubTitle"
                 Text="Trascrivi video e audio in testo con intelligenza artificiale"
                 FontSize="11" Foreground="#8B8BA8" Margin="0,4,0,0"/>
    </StackPanel>

    <!-- PANNELLO SCELTA -->
    <Grid x:Name="PanelScelta" Grid.Row="1">
      <Grid.RowDefinitions>
        <RowDefinition Height="Auto"/>
        <RowDefinition Height="Auto"/>
        <RowDefinition Height="Auto"/>
        <RowDefinition Height="*"/>
      </Grid.RowDefinitions>

      <TextBlock Grid.Row="0" Text="Cosa vuoi fare?"
                 FontSize="16" FontWeight="SemiBold" Margin="0,0,0,20"/>

      <!-- Card INSTALLA -->
      <Border Grid.Row="1" Background="#1A1A35" CornerRadius="12"
              BorderBrush="#F97316" BorderThickness="1" Margin="0,0,0,16"
              Cursor="Hand" x:Name="CardInstalla">
        <Grid Margin="24,18">
          <Grid.ColumnDefinitions>
            <ColumnDefinition Width="Auto"/>
            <ColumnDefinition Width="*"/>
            <ColumnDefinition Width="Auto"/>
          </Grid.ColumnDefinitions>
          <TextBlock Grid.Column="0" Text="&#x25B6;" FontSize="28"
                     Foreground="#F97316" VerticalAlignment="Center" Margin="0,0,18,0"/>
          <StackPanel Grid.Column="1" VerticalAlignment="Center">
            <TextBlock Text="Installa Trascrittore AI" FontSize="15" FontWeight="Bold"/>
            <TextBlock Text="Scarica e configura tutto automaticamente" FontSize="11"
                       Foreground="#8B8BA8" Margin="0,4,0,0"/>
          </StackPanel>
          <TextBlock Grid.Column="2" Text="&#x276F;" FontSize="18"
                     Foreground="#F97316" VerticalAlignment="Center"/>
        </Grid>
      </Border>

      <!-- Card DISINSTALLA -->
      <Border Grid.Row="2" Background="#1A1A35" CornerRadius="12"
              BorderBrush="#2E2E5A" BorderThickness="1"
              Cursor="Hand" x:Name="CardDisinstalla">
        <Grid Margin="24,18">
          <Grid.ColumnDefinitions>
            <ColumnDefinition Width="Auto"/>
            <ColumnDefinition Width="*"/>
            <ColumnDefinition Width="Auto"/>
          </Grid.ColumnDefinitions>
          <TextBlock Grid.Column="0" Text="&#x1F5D1;" FontSize="24"
                     Foreground="#EF4444" VerticalAlignment="Center" Margin="0,0,18,0"/>
          <StackPanel Grid.Column="1" VerticalAlignment="Center">
            <TextBlock Text="Disinstalla" FontSize="15" FontWeight="Bold"/>
            <TextBlock Text="Rimuove ambiente virtuale, modelli e scorciatoie"
                       FontSize="11" Foreground="#8B8BA8" Margin="0,4,0,0"/>
          </StackPanel>
          <TextBlock Grid.Column="2" Text="&#x276F;" FontSize="18"
                     Foreground="#8B8BA8" VerticalAlignment="Center"/>
        </Grid>
      </Border>

      <!-- nota versione -->
      <TextBlock Grid.Row="3" Text="Powered by OpenAI Whisper  •  Funziona offline dopo la prima installazione"
                 FontSize="10" Foreground="#3A3A5C" VerticalAlignment="Bottom"
                 HorizontalAlignment="Center"/>
    </Grid>

    <!-- PANNELLO PROGRESS -->
    <Grid x:Name="PanelProgress" Grid.Row="1" Visibility="Collapsed">
      <Grid.RowDefinitions>
        <RowDefinition Height="Auto"/>
        <RowDefinition Height="Auto"/>
        <RowDefinition Height="Auto"/>
        <RowDefinition Height="*"/>
        <RowDefinition Height="Auto"/>
      </Grid.RowDefinitions>

      <TextBlock x:Name="StepLabel" Grid.Row="0"
                 Text="Avvio..." FontSize="13" FontWeight="SemiBold"
                 Foreground="#F8FAFC" Margin="0,0,0,10"/>

      <!-- Progress bar -->
      <Grid Grid.Row="1" Margin="0,0,0,18">
        <Rectangle Height="8" RadiusX="4" RadiusY="4" Fill="#22223F"/>
        <Rectangle x:Name="ProgressFill" Height="8" RadiusX="4" RadiusY="4"
                   Fill="#F97316" HorizontalAlignment="Left" Width="0"/>
      </Grid>

      <!-- Passi icona -->
      <ItemsControl x:Name="StepsPanel" Grid.Row="2" Margin="0,0,0,12">
        <ItemsControl.ItemTemplate>
          <DataTemplate>
            <TextBlock Text="{Binding}" FontSize="11" Foreground="#8B8BA8"
                       FontFamily="Consolas" Margin="0,1"/>
          </DataTemplate>
        </ItemsControl.ItemTemplate>
      </ItemsControl>

      <!-- Log -->
      <Border Grid.Row="3" Background="#1A1A35" CornerRadius="8"
              BorderBrush="#2E2E5A" BorderThickness="1">
        <ScrollViewer x:Name="LogScroll" VerticalScrollBarVisibility="Auto" Padding="12">
          <TextBlock x:Name="LogBox" FontFamily="Consolas" FontSize="11"
                     Foreground="#8B8BA8" TextWrapping="Wrap"/>
        </ScrollViewer>
      </Border>

      <!-- Pulsante finale -->
      <Button x:Name="BtnAvvia" Grid.Row="4" Margin="0,16,0,0"
              Height="48" FontSize="14" FontWeight="Bold"
              Content="AVVIA IL TRASCRITTORE"
              Background="#F97316" Foreground="White"
              BorderThickness="0" Cursor="Hand" Visibility="Collapsed">
        <Button.Template>
          <ControlTemplate TargetType="Button">
            <Border Background="{TemplateBinding Background}" CornerRadius="8" Padding="20,10">
              <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
            </Border>
          </ControlTemplate>
        </Button.Template>
      </Button>
    </Grid>

  </Grid>
</Window>
"@

$reader = New-Object System.Xml.XmlNodeReader $xaml
$window = [Windows.Markup.XamlReader]::Load($reader)

# Riferimenti elementi
$PanelScelta    = $window.FindName("PanelScelta")
$PanelProgress  = $window.FindName("PanelProgress")
$CardInstalla   = $window.FindName("CardInstalla")
$CardDisinstalla= $window.FindName("CardDisinstalla")
$StepLabel      = $window.FindName("StepLabel")
$ProgressFill   = $window.FindName("ProgressFill")
$LogBox         = $window.FindName("LogBox")
$LogScroll      = $window.FindName("LogScroll")
$BtnAvvia       = $window.FindName("BtnAvvia")
$SubTitle       = $window.FindName("SubTitle")
$TotalWidth     = 516

# ── Helper UI ─────────────────────────────────────────────────────────────────
function Show-Progress($msg, $pct) {
    $window.Dispatcher.Invoke([action]{
        $StepLabel.Text     = $msg
        $ProgressFill.Width = [int]($TotalWidth * $pct / 100)
    })
}

function Add-Log($msg, $color="#8B8BA8") {
    $window.Dispatcher.Invoke([action]{
        $run            = New-Object System.Windows.Documents.Run
        $run.Text       = "[$(Get-Date -f 'HH:mm:ss')]  $msg`n"
        $run.Foreground = [Windows.Media.BrushConverter]::new().ConvertFromString($color)
        $LogBox.Inlines.Add($run)
        $LogScroll.ScrollToEnd()
    })
}
function Log-Ok($m)   { Add-Log "OK   $m" "#22C55E" }
function Log-Warn($m) { Add-Log "!!   $m" "#F59E0B" }
function Log-Err($m)  { Add-Log "X    $m" "#EF4444" }
function Log-Info($m) { Add-Log "     $m" "#8B8BA8" }

function Switch-ToProgress($titolo) {
    $window.Dispatcher.Invoke([action]{
        $SubTitle.Text          = $titolo
        $PanelScelta.Visibility = "Collapsed"
        $PanelProgress.Visibility = "Visible"
    })
}

# ── INSTALLA ──────────────────────────────────────────────────────────────────
function Start-Installa {
    Switch-ToProgress "Installazione automatica in corso..."
    [System.Threading.Tasks.Task]::Run([action]{
        try {
            # STEP 1: Python
            Show-Progress "Controllo Python..." 5
            Log-Info "Cerco Python sul sistema..."
            $pyCmd = $null
            foreach ($c in @("python","python3","py")) {
                try {
                    $v = & $c --version 2>&1
                    if ($v -match "Python 3\.(\d+)" -and [int]$Matches[1] -ge 8) { $pyCmd = $c; break }
                } catch {}
            }
            if (-not $pyCmd) {
                Show-Progress "Scarico Python 3.11..." 10
                Log-Warn "Python non trovato — scarico installer (~25 MB)..."
                $pyUrl  = "https://www.python.org/ftp/python/3.11.9/python-3.11.9-amd64.exe"
                $pyInst = "$env:TEMP\python_trascrittore.exe"
                Invoke-WebRequest -Uri $pyUrl -OutFile $pyInst -UseBasicParsing
                Show-Progress "Installo Python 3.11..." 18
                Log-Info "Installo Python in silenzio (potrebbe richiedere 1-2 min)..."
                Start-Process $pyInst -ArgumentList "/quiet","InstallAllUsers=0","PrependPath=1","Include_pip=1","Include_tcltk=1" -Wait
                Remove-Item $pyInst -Force -ErrorAction SilentlyContinue
                $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" +
                            [System.Environment]::GetEnvironmentVariable("Path","User")
                foreach ($c in @("python","python3","py")) {
                    try { $v = & $c --version 2>&1; if ($v -match "Python 3") { $pyCmd = $c; break } } catch {}
                }
                if (-not $pyCmd) { throw "Installazione Python fallita. Riavvia il PC e riprova." }
                Log-Ok "Python installato: $v"
            } else {
                Log-Ok "Python trovato: $(& $pyCmd --version 2>&1)"
            }

            # STEP 2: Ambiente virtuale
            Show-Progress "Creo ambiente virtuale..." 28
            $envPath = Join-Path $ROOT "trascrittore_env"
            if (-not (Test-Path "$envPath\Scripts\python.exe")) {
                Log-Info "Creo ambiente virtuale isolato..."
                & $pyCmd -m venv $envPath 2>&1 | ForEach-Object { Log-Info $_ }
                Log-Ok "Ambiente virtuale creato"
            } else { Log-Ok "Ambiente virtuale gia presente" }

            $pip = "$envPath\Scripts\pip.exe"
            $py  = "$envPath\Scripts\python.exe"

            # STEP 3: faster-whisper
            Show-Progress "Installo motore AI (faster-whisper)..." 42
            if ((& $pip show faster-whisper 2>&1) -notmatch "Version") {
                Log-Info "Scarico faster-whisper (~200 MB) — solo questa volta..."
                & $pip install faster-whisper --quiet 2>&1 | ForEach-Object { Log-Info $_ }
                Log-Ok "faster-whisper installato"
            } else { Log-Ok "faster-whisper gia installato" }

            # STEP 4: ffmpeg
            Show-Progress "Controllo FFmpeg..." 62
            $ffPath = Join-Path $ROOT "ffmpeg.exe"
            if (-not (Test-Path $ffPath)) {
                Log-Warn "ffmpeg non trovato — scarico (~80 MB)..."
                Show-Progress "Scarico FFmpeg..." 65
                $zipPath = "$env:TEMP\ffmpeg_trascrittore.zip"
                $zipDir  = "$env:TEMP\ffmpeg_trascrittore_ext"
                Invoke-WebRequest "https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip" -OutFile $zipPath -UseBasicParsing
                Expand-Archive $zipPath $zipDir -Force
                $ffExe = Get-ChildItem $zipDir -Recurse -Filter "ffmpeg.exe" |
                         Where-Object { $_.DirectoryName -match "\\bin$" } | Select-Object -First 1
                Copy-Item $ffExe.FullName $ffPath
                Remove-Item $zipPath,$zipDir -Recurse -Force -ErrorAction SilentlyContinue
                Log-Ok "FFmpeg installato"
            } else { Log-Ok "FFmpeg gia presente" }

            # STEP 5: Modello AI
            Show-Progress "Scarico modello AI Whisper base (~150 MB)..." 78
            $modelDir = Join-Path $ROOT "models"
            if (-not (Test-Path "$modelDir\base\model.bin")) {
                Log-Info "Scarico modello Whisper base — solo questa volta..."
                & $py -c "
from faster_whisper import WhisperModel
WhisperModel('base', device='cpu', compute_type='int8', download_root=r'$modelDir')
print('OK')
" 2>&1 | ForEach-Object { Log-Info $_ }
                Log-Ok "Modello AI pronto"
            } else { Log-Ok "Modello AI gia presente" }

            # STEP 6: Scorciatoie
            Show-Progress "Creo scorciatoie..." 93
            $appScript = Join-Path $SISTEMA "trascrittore_portable.py"
            $wsh = New-Object -ComObject WScript.Shell

            $lnkRoot = Join-Path $ROOT "Avvia Trascrittore.lnk"
            $lk = $wsh.CreateShortcut($lnkRoot)
            $lk.TargetPath = $py; $lk.Arguments = "`"$appScript`""
            $lk.WorkingDirectory = $ROOT; $lk.Description = "Avvia Trascrittore AI"
            $lk.IconLocation = "$env:SystemRoot\System32\imageres.dll,109"; $lk.Save()

            $desk = [Environment]::GetFolderPath("Desktop")
            $lk2 = $wsh.CreateShortcut("$desk\Trascrittore AI.lnk")
            $lk2.TargetPath = $py; $lk2.Arguments = "`"$appScript`""
            $lk2.WorkingDirectory = $ROOT; $lk2.Description = "Trascrittore AI"
            $lk2.IconLocation = "$env:SystemRoot\System32\imageres.dll,109"; $lk2.Save()
            Log-Ok "Scorciatoie create (cartella + Desktop)"

            # FINE
            Show-Progress "Installazione completata!" 100
            Log-Ok "Tutto pronto! Usa la scorciatoia sul Desktop o nella cartella."
            $window.Dispatcher.Invoke([action]{ $BtnAvvia.Visibility = "Visible" })

        } catch {
            Log-Err "ERRORE: $_"
            Show-Progress "Errore durante l'installazione" 0
        }
    }) | Out-Null
}

# ── DISINSTALLA ───────────────────────────────────────────────────────────────
function Start-Disinstalla {
    Switch-ToProgress "Rimozione in corso..."
    $window.Dispatcher.Invoke([action]{
        $StepLabel.Foreground = [Windows.Media.BrushConverter]::new().ConvertFromString("#EF4444")
        $ProgressFill.Fill    = [Windows.Media.BrushConverter]::new().ConvertFromString("#EF4444")
        $BtnAvvia.Content     = "CHIUDI"
        $BtnAvvia.Background  = [Windows.Media.BrushConverter]::new().ConvertFromString("#EF4444")
    })
    [System.Threading.Tasks.Task]::Run([action]{
        try {
            # Rimuovi ambiente virtuale
            Show-Progress "Rimozione ambiente virtuale..." 20
            $envPath = Join-Path $ROOT "trascrittore_env"
            if (Test-Path $envPath) {
                Remove-Item $envPath -Recurse -Force
                Log-Ok "Ambiente virtuale rimosso"
            } else { Log-Info "Ambiente virtuale non presente" }

            # Rimuovi modelli AI
            Show-Progress "Rimozione modelli AI..." 45
            $modelDir = Join-Path $ROOT "models"
            if (Test-Path $modelDir) {
                Remove-Item $modelDir -Recurse -Force
                Log-Ok "Modelli AI rimossi"
            } else { Log-Info "Cartella modelli non presente" }

            # Rimuovi ffmpeg (solo se scaricato da noi — lascia se esisteva prima)
            Show-Progress "Rimozione FFmpeg..." 60
            $ffPath = Join-Path $ROOT "ffmpeg.exe"
            if (Test-Path $ffPath) {
                Remove-Item $ffPath -Force
                Log-Ok "ffmpeg.exe rimosso"
            } else { Log-Info "ffmpeg.exe non presente" }

            # Rimuovi scorciatoie
            Show-Progress "Rimozione scorciatoie..." 80
            $lnkRoot = Join-Path $ROOT "Avvia Trascrittore.lnk"
            if (Test-Path $lnkRoot) { Remove-Item $lnkRoot -Force; Log-Ok "Scorciatoia cartella rimossa" }
            $desk = [Environment]::GetFolderPath("Desktop")
            $lnkDesk = "$desk\Trascrittore AI.lnk"
            if (Test-Path $lnkDesk) { Remove-Item $lnkDesk -Force; Log-Ok "Scorciatoia Desktop rimossa" }

            Show-Progress "Disinstallazione completata" 100
            Log-Ok "Disinstallazione completata. I file sorgente sono stati mantenuti."
            Log-Info "Puoi eliminare l'intera cartella manualmente se non ti serve piu."
            $window.Dispatcher.Invoke([action]{ $BtnAvvia.Visibility = "Visible" })

        } catch {
            Log-Err "ERRORE: $_"
            Show-Progress "Errore durante la disinstallazione" 0
        }
    }) | Out-Null
}

# ── EVENTI ───────────────────────────────────────────────────────────────────
$CardInstalla.Add_MouseLeftButtonUp({ Start-Installa })
$CardDisinstalla.Add_MouseLeftButtonUp({ Start-Disinstalla })

$BtnAvvia.Add_Click({
    if ($BtnAvvia.Content -eq "CHIUDI") {
        $window.Close()
    } else {
        $py  = "$ROOT\trascrittore_env\Scripts\python.exe"
        $app = "$SISTEMA\trascrittore_portable.py"
        Start-Process $py -ArgumentList "`"$app`"" -WorkingDirectory $ROOT
        $window.Close()
    }
})

$window.Topmost = $true
$window.Add_Loaded({ $window.Activate() })
$window.ShowDialog() | Out-Null
