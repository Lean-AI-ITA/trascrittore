@echo off
title Avvia Trascrittore - Italiano
echo ========================================
echo    AVVIO TRASCRITTORE - ITALIANO
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
echo Controllo se ffmpeg.exe esiste...
if not exist "ffmpeg.exe" (
    echo ❌ ERRORE: ffmpeg.exe non trovato!
    echo.
    echo Metti ffmpeg.exe in questa cartella
    echo.
    pause
    exit /b 1
)

echo ✅ FFmpeg trovato
echo.
echo Attivo l'ambiente virtuale...
call trascrittore_env\Scripts\activate.bat
echo.

echo 🌍 Sistema configurato per trascrizioni in ITALIANO
echo 📝 Supporta video e audio
echo.
echo Avvio il trascrittore...
echo.
python trascrittore.py

echo.
echo Trascrittore chiuso.
pause