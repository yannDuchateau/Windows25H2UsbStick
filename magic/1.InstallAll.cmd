@ECHO OFF
cd /d %~dp0 >nul
pause
echo powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "C:\Windows\Setup\post-setup\Files\bootstrap.ps1"
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "C:\Windows\Setup\post-setup\Files\bootstrap.ps1"
pause