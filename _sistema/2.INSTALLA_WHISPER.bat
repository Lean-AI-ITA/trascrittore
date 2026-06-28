@echo off
title Installa Whisper
echo ========================================
echo    INSTALLAZIONE WHISPER - ITALIANO
echo ========================================
echo.

echo Controllo se l'ambiente virtuale esiste...
if not exist "trascrittore_env" (
    echo ❌ ERRORE: Ambiente virtuale non trovato!
    echo.
    echo Esegui prima 1.CREA_AMBIENTE_PULITO.bat
    echo.
    pause
    exit /b 1
)

echo ✅ Ambiente trovato
echo.
echo Attivo l'ambiente virtuale...
call trascrittore_env\Scripts\activate.bat
echo.

echo === INSTALLAZIONE WHISPER ===
echo Installo Whisper...
echo 🌍 Il sistema è configurato per l'ITALIANO
pip install openai-whisper
echo.

echo === VERIFICA INSTALLAZIONE ===
python -c "import whisper; print('✅ WHISPER INSTALLATO CORRETTAMENTE')"
echo.

echo === CONTROLLO FFMPEG ===
if exist "ffmpeg.exe" (
    echo ✅ FFmpeg.exe trovato nella cartella corrente
) else (
    echo ⚠️  FFmpeg.exe non trovato nella cartella
    echo.  
    echo 📥 Scarica ffmpeg.exe e mettilo in questa cartella
    echo 📍 https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip
    echo.
)

echo.
echo ========================================
echo    INSTALLAZIONE COMPLETATA!
echo ========================================
echo.
echo ✅ Sistema pronto per trascrizioni in ITALIANO
echo.
echo Ora:
echo 1. Assicurati che ffmpeg.exe sia nella cartella
echo 2. Esegui 3.AVVIO_TRASCRITTORE.bat
echo.
pause