@echo off
setlocal

set PACKAGE=com.example.poolify_app
set DB_PATH=/data/user/0/%PACKAGE%/databases/resort_reservation.db
set OUT_FILE=%~dp0exported_db.db
set TEMP_FILE=%~dp0exported_db.tmp

echo Live DB sync is running.
echo Keep this window open while testing registration/reservations.
echo In DB Browser, click Refresh / Reload Database from Disk after each test.
echo.

:sync
adb exec-out run-as %PACKAGE% cat %DB_PATH% > "%TEMP_FILE%" 2>nul
if exist "%TEMP_FILE%" (
  copy /Y "%TEMP_FILE%" "%OUT_FILE%" >nul
  del "%TEMP_FILE%" >nul 2>nul
  echo Synced %date% %time%
) else (
  echo Waiting for phone/app database...
)
timeout /t 1 /nobreak >nul
goto sync
