@echo off
setlocal

set PACKAGE=com.example.poolify_app
set DB_PATH=/data/user/0/%PACKAGE%/databases/resort_reservation.db
set OUT_FILE=%~dp0exported_db.db

echo Pulling live Android database...
adb exec-out run-as %PACKAGE% cat %DB_PATH% > "%OUT_FILE%"

if errorlevel 1 (
  echo.
  echo Failed to pull database. Make sure the phone is connected and the debug app is installed.
  exit /b 1
)

echo Done: "%OUT_FILE%"
echo Reopen or refresh DB Browser to see the latest users and reservations.
