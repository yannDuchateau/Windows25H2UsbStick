REM setupComplete-script-loader 
REM Yann Duchateau
REM 2026-03-17 - 1.13.0

@ECHO OFF
rem finding USB Stick
IF EXIST C:\sources\addons SET CLEFUSB=C:
FOR %%i IN (D E F G H I J K L M N O P Q R S T U V W X Y Z) DO IF EXIST %%i:\bootmgr.efi SET CLEFUSB=%%i:
SET SETOS=%PROCESSOR_ARCHITECTURE%
set loag=%WINDIR%\Logs\SetupComplete.log
rem Packages Setup Files for Corporate Windows
rem SET APPS=%CLEFUSB%\sources\$OEM$\$1\Addons
rem home.zip Compressed Setup Files for Corporate Windows
rem SET MOEM=%CLEFUSB%\Magic
SET OEMS=%CLEFUSB%\sources\$OEM$\$$\Setup\Files
SET OEMAPPS=%WINDIR%\Setup\Files
rem Improve Public Folders
takeown /s "%COMPUTERNAME%" /u Administrators /f "%PUBLIC%" /R /D Y
rem Copy OEM Setup Files
xcopy "%OEMS%" "%OEMAPPS%" /H /R /D /Y /S /C /I /F /G /K /COMPRESS >%loag%
rem Launches OEM Setup File
echo powershell.exe -nop -ep bypass %OEMAPPS%\bootstrap.ps1>>%loag%
powershell.exe -nop -ep bypass %OEMAPPS%\bootstrap.ps1>>%loag%
rem Setup Dedicated MS Packages Files for Corporate Windows.
rem echo powershell.exe -nop -ep bypass %OEMAPPS%\LocalPackagesFull.ps1>>%loag%
rem powershell.exe -nop -ep bypass %OEMAPPS%\LocalPackagesFull.ps1>>%loag%
:end