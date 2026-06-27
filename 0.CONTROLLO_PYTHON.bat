@echo off
title Controllo Python
echo ========================================
echo    CONTROLLO INSTALLAZIONE PYTHON
echo ========================================
echo.

echo Verifico la presenza di Python...
python --version >nul 2>&1
if %errorlevel% == 0 (
    echo ✅ Python trovato!
    python --version
    echo.
    echo Puoi procedere con l'installazione.
    echo.
    pause
    exit /b 0
)

echo ❌ Python non trovato o non nel PATH!
echo.
echo ========================================
echo    INSTALLAZIONE PYTHON
echo ========================================
echo.
echo Per installare Python:
echo.
echo 1. Vai su: https://www.python.org/downloads/
echo 2. Scarica l'ultima versione (3.8+)
echo 3. DURANTE L'INSTALLAZIONE:
echo    - ✅ Spunta "Add Python to PATH"
echo    - ✅ Clicca "Install Now"
echo.
echo 4. Dopo l'installazione, RIAVVIA IL PC
echo 5. Poi riesegui questo script
echo.
echo ========================================
echo IMPORTANTE: RIAVVIA IL PC dopo l'installazione!
echo ========================================
echo.
pause
exit /b 1