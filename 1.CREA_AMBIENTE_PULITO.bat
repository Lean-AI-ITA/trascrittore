@echo off
title Crea Ambiente Pulito
echo ========================================
echo    CREAZIONE AMBIENTE PULITO
echo ========================================
echo.

echo Controllo Python...
python --version >nul 2>&1
if not %errorlevel% == 0 (
    echo ❌ Python non trovato!
    echo Esegui prima 0.CONTROLLO_PYTHON.bat
    echo.
    pause
    exit /b 1
)

echo Elimino il vecchio ambiente se esiste...
rmdir /s /q trascrittore_env 2>nul
echo.

echo Creo un nuovo ambiente virtuale pulito...
python -m venv trascrittore_env
echo.

echo ✅ Ambiente pulito creato!
echo.
echo Ora esegui 2.INSTALLA_WHISPER.bat
echo.
pause