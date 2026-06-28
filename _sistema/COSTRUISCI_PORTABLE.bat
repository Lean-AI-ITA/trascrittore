@echo off
title Costruisci Trascrittore Portable
echo ============================================================
echo   COSTRUTTORE TRASCRITTORE AI - VERSIONE PORTABLE
echo   Questo script va eseguito UNA SOLA VOLTA sul tuo PC
echo ============================================================
echo.

:: Controlla Python
python --version >nul 2>&1
if not %errorlevel%==0 (
    echo ERRORE: Python non trovato. Installalo prima.
    pause & exit /b 1
)

:: Installa dipendenze di build
echo [1/5] Installo dipendenze...
pip install faster-whisper pyinstaller --quiet
if not %errorlevel%==0 (
    echo ERRORE durante installazione dipendenze.
    pause & exit /b 1
)

:: Pre-scarica il modello AI
echo [2/5] Scarico modello AI (base) - circa 150 MB, solo questa volta...
if not exist "models\base" (
    python -c "from faster_whisper import WhisperModel; WhisperModel('base', device='cpu', compute_type='int8', download_root='models')"
    if not %errorlevel%==0 (
        echo ERRORE durante download modello.
        pause & exit /b 1
    )
) else (
    echo     Modello gia' presente, salto download.
)

:: Verifica ffmpeg.exe
echo [3/5] Verifico ffmpeg.exe...
if not exist "ffmpeg.exe" (
    echo.
    echo ATTENZIONE: ffmpeg.exe non trovato in questa cartella!
    echo Scaricalo da: https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip
    echo Estrai solo ffmpeg.exe dalla cartella bin\ e mettilo qui, poi riesegui.
    echo.
    pause & exit /b 1
)
echo     ffmpeg.exe trovato.

:: Crea icona VBS launcher (per ora)
echo [4/5] Creo launcher con icona...

:: Build con PyInstaller
echo [5/5] Costruisco l'app portable con PyInstaller...
pyinstaller trascrittore.spec --noconfirm --clean
if not %errorlevel%==0 (
    echo ERRORE durante la build PyInstaller.
    pause & exit /b 1
)

:: Crea cartella TRASCRIZIONI nell'output
if not exist "dist\Trascrittore\TRASCRIZIONI" mkdir "dist\Trascrittore\TRASCRIZIONI"

:: Crea collegamento .vbs nella dist
echo Set oWS = WScript.CreateObject("WScript.Shell") > "%TEMP%\crea_collegamento.vbs"
echo sLinkFile = "%CD%\dist\Trascrittore\Avvia Trascrittore.lnk" >> "%TEMP%\crea_collegamento.vbs"
echo Set oLink = oWS.CreateShortcut(sLinkFile) >> "%TEMP%\crea_collegamento.vbs"
echo oLink.TargetPath = "%CD%\dist\Trascrittore\Trascrittore.exe" >> "%TEMP%\crea_collegamento.vbs"
echo oLink.WorkingDirectory = "%CD%\dist\Trascrittore" >> "%TEMP%\crea_collegamento.vbs"
echo oLink.Description = "Trascrittore AI Portable" >> "%TEMP%\crea_collegamento.vbs"
echo oLink.Save >> "%TEMP%\crea_collegamento.vbs"
cscript //nologo "%TEMP%\crea_collegamento.vbs"

echo.
echo ============================================================
echo   BUILD COMPLETATA!
echo ============================================================
echo.
echo La cartella portable e' in:
echo   dist\Trascrittore\
echo.
echo Contiene:
echo   Trascrittore.exe         - l'applicazione
echo   Avvia Trascrittore.lnk  - collegamento con icona
echo   ffmpeg.exe               - convertitore audio/video
echo   models\                  - modello AI offline
echo   TRASCRIZIONI\            - dove vengono salvati i testi
echo.
echo Copia l'intera cartella dist\Trascrittore\ sulla chiavetta USB.
echo Per avviare: doppio click su "Avvia Trascrittore.lnk"
echo.
pause
