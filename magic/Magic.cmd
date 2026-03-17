
@echo off & mode con cols=75 lines=6 & Title Fin tests et copie scipts
::—————————————————————————————————————————————————————————————————————————————————————
:diskusb
IF EXIST c:\addons\pdfcreator.inf SET CLEFUSB=c:
IF EXIST c:\addons\pdfcreator.inf SET OEMS=addons
FOR %%i IN (D E F G H I J K L M N O P Q R S T U V W X Y Z) DO IF EXIST %%i:\bootmgr.efi SET CLEFUSB=%%i:
FOR %%i IN (D E F G H I J K L M N O P Q R S T U V W X Y Z) DO IF EXIST %%i:\bootmgr.efi SET OEMS=sources\$OEM$\$1\addons
:environment
FOR /F "tokens=3" %%l IN ('reg query "HKCU\Control Panel\Desktop" /v PreferredUILanguages ^| find "PreferredUILanguages"') DO set UILanguage=%%l
FOR /F "tokens=3" %%l IN ('reg query "HKCU\Control Panel\International\User Profile" /v Languages ^| find "Languages"') DO set UILanguage=%%l

Set Languages=%UILanguage:~0,5%
echo.
goto %Languages%

:fr-FR
set jour=%DATE:~7,2%
set mois=%DATE:~4,2%
set annee=%DATE:~10,4%
set heure=%TIME:~0,2%
set minute=%TIME:~3,2%
goto Debut

:en-US
set jour=%DATE:~7,2%
set mois=%DATE:~4,2%
set annee=%DATE:~10,4%
set heure=%TIME:~1,2%
set minute=%TIME:~3,2%
goto Debut

:de-CH
set jour=%DATE:~0,2%
set mois=%DATE:~3,4%
set annee=%DATE:~8,7%
set heure=%TIME:~0,2%
if "%time:~0,2%" == " " set heure=%time:~0,1%
set minute=%TIME:~3,2%
goto Debut

:de-DE
set jour=%DATE:~0,2%
set mois=%DATE:~3,4%
set annee=%DATE:~6,6%
set heure=%time:~0,5%
if "%time:~0,5%" == " " set heure=%time:~-1,5%
set minute=%TIME:~3,2%
:debut
Echo echo Computer Language is %Languages% Date is %jour%_%mois%_%annee%-%Heure%h%minute%
SET nom_fichier=%jour%_%mois%_%annee%.%Heure%h%minute%
echo -%Heure%-
echo -%minute%-
pause
SET APPS=%CLEFUSB%\%OEMS%
::=====================================================================================
echo USB Apps Folder %APPS%
echo.
::=====================================================================================
TITLE SYNCRONISATION %APPS% from USB Stick %CLEFUSB% from Computer %COMPUTERNAME%
SET MSSTORES=C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller_1.26.510.0_x64__8wekyb3d8bbwe
SET KEYRU=HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnceEx
SET HKLM=HKEY_LOCAL_MACHINE & SET HKS=HKEY_LOCAL_MACHINE\SOFTWARE & SET SETOS=%PROCESSOR_ARCHITECTURE%
SET ORDI=%COMPUTERNAME% & SET USES=HKCU\System & SET USERS=HKCU\Software & SET USEC=HKCU\Control
SET UNI=Microsoft\Windows\CurrentVersion\Uninstall & SET HF=windows11.0-kb & SET sw=HKLM\Software
SET ss=HKLM\System
::=====================================================================================
set Skript=NULL & set Kaction=NULL
ECHO %~nx0? |FIND.EXE /I ".cmd?" >nul & IF not errorlevel=1 SET src=%~nx0 & IF errorlevel=1 SET src=%~nx0
set Skript=%src:~0,-5%
set Kaction="Done EDGE Setup %APPS% at %heure%H%minute% " & set loag=%windir%\Logs\%Skript%.%nom_fichier%.log
::=====================================================================================
TITLE Script %Skript% Started at %nom_fichier% at %heure%H%minute%
echo Script file is %src% Name is %Skript% and Log Name is %loag% & echo.
echo Script file is %src% Job Name is %Skript% and Log Name is %loag% Script %src% Started at %heure%H%minute%>>%loag%
echo Computer name %ORDI% Script %Skript% USB is on %CLEFUSB%>>%loag%
echo Apps located on %APPS% and USB is on %CLEFUSB%>>%loag%
::—————————————————————————————————————————————————————————————————————————————————————
:isUsb
IF EXIST %CLEFUSB%\bootmgr.efi goto isAdmin
::=====================================================================================
echo error wrong usb not present or it is not bootable.>>%loag%
echo error wrong usb not present or it is not bootable.
goto error
::—————————————————————————————————————————————————————————————————————————————————————
:isAdmin
::=====================================================================================
TITLE Script %Skript% Started at %nom_fichier% at %heure%H%minute%
IF EXIST %loag% goto softs
echo Could not write the Log File.
goto isNotAdmin
::=====================================================================================
:softs
::=====================================================================================
echo ============================== Takeown Public Desktop ===============================>>%loag%
rem Take ownership of Public Desktop
takeown /s %COMPUTERNAME% /u Administrators /f "c:\Users\Public\Desktop" /A /R /D:J>>%loag%
takeown /s %COMPUTERNAME% /u Administrators /f "C:\Windows\Web\*" /A /R /D:J>>%loag%
icacls C:\Windows\Web\* /save %PUBLIC%\Desktop\ACLwinweb%COMPUTERNAME%.txt /T /C /L /Q  >> %loag%
%APPS%\subinacl.exe /errorlog="%loag%" /outputlog="%PUBLIC%\Desktop\ACLWinWeb%COMPUTERNAME%.acl" /subdirectories C:\Windows\Web\* /display=sddl

echo ============================== Icacls Public Desktop ================================>>%loag%
TITLE ================================ Icacls Public Desktop ================================
icacls "c:\Users\Public\Desktop" /grant:r Administrators:(OI)(CI)F /T /C /L /Q >>%loag%
icacls "c:\Users\Public\Desktop" /grant %USERNAME%:(OI)(CI)F /T /C /L /Q >>%loag%
start.exe /wait /abovenormal %APPS%\subinacl.exe /subkeyreg HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation /grant=Administrators=f>>%loag%
start.exe /wait /abovenormal %APPS%\subinacl.exe /subkeyreg HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation /grant=Administratoren=f>>%loag%
echo ============================== Icacls Windows Web ================================>>%loag%
TITLE ================================ Icacls Windows Web ================================
icacls "C:\Windows\Web\" /grant:r Administrators:(OI)(CI)F /T /C /L /Q >>%loag%
icacls "C:\Windows\Web\" /grant %USERNAME%:(OI)(CI)F /T /C /L /Q >>%loag%
start /wait /abovenormal %APPS%\subinacl.exe /subkeyreg HKLM\SYSTEM /grant=Administrators=f>>%loag%
start /wait /abovenormal %APPS%\subinacl.exe /subkeyreg HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion /grant=%USERNAME%=f>>%loag%

:EndComment
echo %nom_fichier% Windows 11 %SETOS% 25H2 Install from USB Stick on %CLEFUSB%>>%loag%
TITLE %nom_fichier% Windows 11 %SETOS% 25H2 Install from USB Stick on %CLEFUSB%
rem Snapshot
TASKLIST /FI "USERNAME ne NT AUTHORITY\SYSTEM" /FI "STATUS eq running" /V  >>%loag%

echo --------------------------------------- Powershell Enabled ----------------------------------------->>%loag%
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Policies\Microsoft\Windows\PowerShell" /v "EnableScripts" /t REG_SZ /d "1" /f>>%loag%
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Policies\Microsoft\Windows\PowerShell" /v "ExecutionPolicy" /t REG_SZ /d "Unrestricted" /f>>%loag%

TITLE %jour%-%mois%-%annee%-%heure%H%minute% Windows 11 %SETOS% 25H2 Install from USB Stick on %CLEFUSB% - Cleaning Windows
echo %jour%-%mois%-%annee%-%heure%H%minute% Windows 11 %SETOS% 25H2 Install from USB Stick on %CLEFUSB% - Cleaning Windows>>%loag%
echo =================================== Cleaning Windows ==============================>>%loag%
echo --------------------------------------- System ----------------------------------------->>%loag%
REG ADD "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3" /t REG_DWORD /v 1A10 /f /d 0>>%loag%
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "%CLEFUSB%\magic\bootstrap.ps1" >%loag%>>%loag%

if exist "%windir%\Setup\Files\post-setup.ps1" goto features
echo Corporate post-setup failed
echo Corporate post-setup failed>>%loag%

:Corporate
rem Post Setup Files
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "%windir%\Setup\Files\post-setup.ps1" >%loag%>>%loag%
echo CORPORATE silent install >%loag%>>%loag%
echo ........................................ About .........................................>>%loag%
:features
echo =================================== Remove or Add various Windows Features ===================================>>%loag%
rem Now configuring Windows Features.
rem # Windows update services required for DISM
rem # "DISM /Online /Get-Features /format:table" shows installed features
rem # "Get-WindowsOptionalFeature -Online" shows installed features
rem # Possible AUTO-REBOOT if ran without admin privileges
rem # REBOOT RECOMMENDED
echo =========================== Modifying essential startup entries ==========================>>%loag%
echo =================================== Disable various Windows Features ===================================>>%loag%
TITLE Windows 11 %SETOS% 25h2 Install from USB Stick on %CLEFUSB% - Disable various Windows Features
powershell Remove-WindowsCapability -Name StepsRecorder -Online>>%loag%
powershell Remove-WindowsCapability -Name QuickAssist -Online>>%loag%
DISM /Online /Remove-Capability /CapabilityName:"App.WirelessDisplay.Connect~~~~0.0.1.0" /NoRestart>>%loag%
DISM /Online /Remove-Capability /CapabilityName:"App.StepsRecorder~~~~0.0.1.0" /NoRestart>>%loag%
DISM /Online /Remove-Capability /CapabilityName:"App.Support.QuickAssist~~~~0.0.1.0" /NoRestart>>%loag%
Dism /Online /Disable-Feature /Featurename:Recall /NoRestart>>%loag%
DISM /Online /Disable-Feature /FeatureName:"AppServerClient" /NoRestart>>%loag%
DISM /Online /Disable-Feature /FeatureName:"Analog.Holographic.Desktop~~~~0.0.1.0" /NoRestart>>%loag%
DISM /Online /Disable-Feature /FeatureName:"FaxServicesClientPackage" /NoRestart>>%loag%
DISM /Online /Disable-Feature /FeatureName:"Internet-Explorer-Optional-x64" /NoRestart>>%loag%
DISM /Online /Disable-Feature /FeatureName:"Internet-Explorer-Optional-amd64" /NoRestart>>%loag%
DISM /Online /Disable-Feature /FeatureName:"Microsoft-Hyper-V-All" /NoRestart>>%loag%
DISM /Online /Disable-Feature /FeatureName:"Microsoft-Hyper-V-Management-Clients" /NoRestart>>%loag%
DISM /Online /Disable-Feature /FeatureName:"Microsoft-Hyper-V-Management-PowerShell" /NoRestart>>%loag%
DISM /Online /Disable-Feature /FeatureName:"Microsoft-Hyper-V-Tools-All" /NoRestart>>%loag%
dism /Online /Disable-Feature /FeatureName:"Printing-Foundation-Features" /NoRestart
dism /Online /Disable-Feature /FeatureName:"Printing-Foundation-InternetPrinting-Client" /NoRestart>>%loag%
dism /Online /Disable-Feature /FeatureName:"Printing-Foundation-LPDPrintService" /NoRestart>>%loag%
dism /Online /Disable-Feature /FeatureName:"Printing-Foundation-LPRPortMonitor" /NoRestart>>%loag%
dism /Online /Disable-Feature /FeatureName:"Printing-XPSServices-Features" /NoRestart>>%loag%
DISM /Online /Disable-Feature /FeatureName:"Printing-Foundation-LPRPortMonitor" /NoRestart>>%loag%
DISM /Online /Disable-Feature /FeatureName:"RasCMAK.Client~~~~0.0.1.0" /NoRestart>>%loag%
DISM /Online /Disable-Feature /FeatureName:"SNMP.Client~~~~0.0.1.0" /NoRestart >>%loag%
DISM /Online /Disable-Feature /FeatureName:"WMI-SNMP-Provider.Client~~~~0.0.1.0" /NoRestart>>%loag%
sc stop "WSearch"
sc config "WSearch" start="auto"
Dism /online /Enable-Feature /FeatureName:"SearchEngine-Client-Package" /NoRestart>>%loag%
sc start "WSearch"
dism /Online /Disable-Feature /FeatureName:"TelnetClient" /NoRestart>>%loag%
dism /Online /Disable-Feature /FeatureName:"TFTP" /NoRestart>>%loag%
dism /Online /Disable-Feature /FeatureName:"TIFFIFilter" /NoRestart>>%loag%
dism /Online /Disable-Feature /FeatureName:"WorkFolders-Client" /NoRestart>>%loag%
DISM /Online /Disable-Feature /FeatureName:"Xps-Foundation-Xps-Viewer" /NoRestart>>%loag%
DISM /online /get-features /format:table | more>>%PUBLIC%\Desktop\loag\Features%nom_fichier%.txt
DISM /Online /Get-Features >>%PUBLIC%\Desktop\loag\Features%nom_fichier%.txt
DISM /Online /Get-Capabilities >>%PUBLIC%\Desktop\loag\Features%nom_fichier%.txt

TITLE Windows 11 %SETOS% 25h2 Install from USB Stick on %CLEFUSB% - Configuring Windows Features

TITLE Windows 11 %SETOS% 25h2 Install from USB Stick on %CLEFUSB% - Configuring Windows Power Options
rem =================================== Windows Settings ===================================
rem --------------------------------------- System -----------------------------------------
rem .................................... Power and sleep .....................................

powercfg -setactive 381b4222-f694-41f0-9685-ff5bb260df2e
powercfg -h on
powercfg -setacvalueindex 381b4222-f694-41f0-9685-ff5bb260df2e fea3413e-7e05-4911-9a71-700331f1c294 0e796bdb-100d-47d6-a2d5-f7d2daa51f51 1
powercfg -setdcvalueindex 381b4222-f694-41f0-9685-ff5bb260df2e fea3413e-7e05-4911-9a71-700331f1c294 0e796bdb-100d-47d6-a2d5-f7d2daa51f51 1
powercfg -setacvalueindex 381b4222-f694-41f0-9685-ff5bb260df2e 0012ee47-9041-4b5d-9b77-535fba8b1442 6738e2c4-e8a5-4a42-b16a-e040e769756e 0
powercfg -setdcvalueindex 381b4222-f694-41f0-9685-ff5bb260df2e 0012ee47-9041-4b5d-9b77-535fba8b1442 6738e2c4-e8a5-4a42-b16a-e040e769756e 300
powercfg -setacvalueindex 381b4222-f694-41f0-9685-ff5bb260df2e 02f815b5-a5cf-4c84-bf20-649d1f75d3d8 4c793e7d-a264-42e1-87d3-7a0d2f523ccd 1
powercfg -setdcvalueindex 381b4222-f694-41f0-9685-ff5bb260df2e 02f815b5-a5cf-4c84-bf20-649d1f75d3d8 4c793e7d-a264-42e1-87d3-7a0d2f523ccd 0
powercfg -setacvalueindex 381b4222-f694-41f0-9685-ff5bb260df2e 0d7dbae2-4294-402a-ba8e-26777e8488cd 309dce9b-bef4-4119-9921-a851fb12f0f4 0
powercfg -setdcvalueindex 381b4222-f694-41f0-9685-ff5bb260df2e 0d7dbae2-4294-402a-ba8e-26777e8488cd 309dce9b-bef4-4119-9921-a851fb12f0f4 1
powercfg -setacvalueindex 381b4222-f694-41f0-9685-ff5bb260df2e 19cbb8fa-5279-450e-9fac-8a3d5fedd0c1 12bbebe6-58d6-4636-95bb-3217ef867c1a 0
powercfg -setdcvalueindex 381b4222-f694-41f0-9685-ff5bb260df2e 19cbb8fa-5279-450e-9fac-8a3d5fedd0c1 12bbebe6-58d6-4636-95bb-3217ef867c1a 3
powercfg -setacvalueindex 381b4222-f694-41f0-9685-ff5bb260df2e 238c9fa8-0aad-41ed-83f4-97be242c8f20 29f6c1db-86da-48c5-9fdb-f2b67b1f44da 0
powercfg -setdcvalueindex 381b4222-f694-41f0-9685-ff5bb260df2e 238c9fa8-0aad-41ed-83f4-97be242c8f20 29f6c1db-86da-48c5-9fdb-f2b67b1f44da 900
powercfg -setacvalueindex 381b4222-f694-41f0-9685-ff5bb260df2e 238c9fa8-0aad-41ed-83f4-97be242c8f20 94ac6d29-73ce-41a6-809f-6363ba21b47e 1
powercfg -setdcvalueindex 381b4222-f694-41f0-9685-ff5bb260df2e 238c9fa8-0aad-41ed-83f4-97be242c8f20 94ac6d29-73ce-41a6-809f-6363ba21b47e 1
powercfg -setacvalueindex 381b4222-f694-41f0-9685-ff5bb260df2e 238c9fa8-0aad-41ed-83f4-97be242c8f20 9d7815a6-7ee4-497e-8888-515a05f02364 3600
powercfg -setdcvalueindex 381b4222-f694-41f0-9685-ff5bb260df2e 238c9fa8-0aad-41ed-83f4-97be242c8f20 9d7815a6-7ee4-497e-8888-515a05f02364 1800
powercfg -setacvalueindex 381b4222-f694-41f0-9685-ff5bb260df2e 238c9fa8-0aad-41ed-83f4-97be242c8f20 bd3b718a-0680-4d9d-8ab2-e1d2b4ac806d 1
powercfg -setdcvalueindex 381b4222-f694-41f0-9685-ff5bb260df2e 238c9fa8-0aad-41ed-83f4-97be242c8f20 bd3b718a-0680-4d9d-8ab2-e1d2b4ac806d 1
powercfg -setacvalueindex 381b4222-f694-41f0-9685-ff5bb260df2e 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 1
powercfg -setdcvalueindex 381b4222-f694-41f0-9685-ff5bb260df2e 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 1
powercfg -setacvalueindex 381b4222-f694-41f0-9685-ff5bb260df2e 4f971e89-eebd-4455-a8de-9e59040e7347 5ca83367-6e45-459f-a27b-476b1d01c936 2
powercfg -setdcvalueindex 381b4222-f694-41f0-9685-ff5bb260df2e 4f971e89-eebd-4455-a8de-9e59040e7347 5ca83367-6e45-459f-a27b-476b1d01c936 2
powercfg -setacvalueindex 381b4222-f694-41f0-9685-ff5bb260df2e 4f971e89-eebd-4455-a8de-9e59040e7347 7648efa3-dd9c-4e3e-b566-50f929386280 3
powercfg -setdcvalueindex 381b4222-f694-41f0-9685-ff5bb260df2e 4f971e89-eebd-4455-a8de-9e59040e7347 7648efa3-dd9c-4e3e-b566-50f929386280 3
powercfg -setacvalueindex 381b4222-f694-41f0-9685-ff5bb260df2e 4f971e89-eebd-4455-a8de-9e59040e7347 96996bc0-ad50-47ec-923b-6f41874dd9eb 1
powercfg -setdcvalueindex 381b4222-f694-41f0-9685-ff5bb260df2e 4f971e89-eebd-4455-a8de-9e59040e7347 96996bc0-ad50-47ec-923b-6f41874dd9eb 1
powercfg -setacvalueindex 381b4222-f694-41f0-9685-ff5bb260df2e 4f971e89-eebd-4455-a8de-9e59040e7347 a7066653-8d6c-40a8-910e-a1f54b84c7e5 2
powercfg -setdcvalueindex 381b4222-f694-41f0-9685-ff5bb260df2e 4f971e89-eebd-4455-a8de-9e59040e7347 a7066653-8d6c-40a8-910e-a1f54b84c7e5 2
powercfg -setacvalueindex 381b4222-f694-41f0-9685-ff5bb260df2e 501a4d13-42af-4429-9fd1-a8218c268e20 ee12f906-d277-404b-b6da-e5fa1a576df5 1
powercfg -setdcvalueindex 381b4222-f694-41f0-9685-ff5bb260df2e 501a4d13-42af-4429-9fd1-a8218c268e20 ee12f906-d277-404b-b6da-e5fa1a576df5 2
powercfg -setacvalueindex 381b4222-f694-41f0-9685-ff5bb260df2e 54533251-82be-4824-96c1-47b60b740d00 893dee8e-2bef-41e0-89c6-b55d0929964c 1
powercfg -setdcvalueindex 381b4222-f694-41f0-9685-ff5bb260df2e 54533251-82be-4824-96c1-47b60b740d00 893dee8e-2bef-41e0-89c6-b55d0929964c 1
powercfg -setacvalueindex 381b4222-f694-41f0-9685-ff5bb260df2e 54533251-82be-4824-96c1-47b60b740d00 bc5038f7-23e0-4960-96da-33abaf5935ec 100
powercfg -setdcvalueindex 381b4222-f694-41f0-9685-ff5bb260df2e 54533251-82be-4824-96c1-47b60b740d00 bc5038f7-23e0-4960-96da-33abaf5935ec 100
powercfg -setacvalueindex 381b4222-f694-41f0-9685-ff5bb260df2e 54533251-82be-4824-96c1-47b60b740d00 94d3a615-a899-4ac5-ae2b-e4d8f634367f 1
powercfg -setdcvalueindex 381b4222-f694-41f0-9685-ff5bb260df2e 54533251-82be-4824-96c1-47b60b740d00 94d3a615-a899-4ac5-ae2b-e4d8f634367f 1
powercfg -setacvalueindex 381b4222-f694-41f0-9685-ff5bb260df2e 7516b95f-f776-4464-8c53-06167f40cc99 fbd9aa66-9553-4097-ba44-ed6e9d65eab8 1
powercfg -setdcvalueindex 381b4222-f694-41f0-9685-ff5bb260df2e 7516b95f-f776-4464-8c53-06167f40cc99 fbd9aa66-9553-4097-ba44-ed6e9d65eab8 1
powercfg -setacvalueindex 381b4222-f694-41f0-9685-ff5bb260df2e 7516b95f-f776-4464-8c53-06167f40cc99 17aaa29b-8b43-4b94-aafe-35f64daaf1ee 0
powercfg -setdcvalueindex 381b4222-f694-41f0-9685-ff5bb260df2e 7516b95f-f776-4464-8c53-06167f40cc99 17aaa29b-8b43-4b94-aafe-35f64daaf1ee 300
powercfg -setacvalueindex 381b4222-f694-41f0-9685-ff5bb260df2e 7516b95f-f776-4464-8c53-06167f40cc99 3c0bc021-c8a8-4e07-a973-6b14cbcb2b7e 0
powercfg -setdcvalueindex 381b4222-f694-41f0-9685-ff5bb260df2e 7516b95f-f776-4464-8c53-06167f40cc99 3c0bc021-c8a8-4e07-a973-6b14cbcb2b7e 600
powercfg -setacvalueindex 381b4222-f694-41f0-9685-ff5bb260df2e 7516b95f-f776-4464-8c53-06167f40cc99 aded5e82-b909-4619-9949-f5d71dac0bcb 100
powercfg -setdcvalueindex 381b4222-f694-41f0-9685-ff5bb260df2e 7516b95f-f776-4464-8c53-06167f40cc99 aded5e82-b909-4619-9949-f5d71dac0bcb 75
powercfg -setacvalueindex 381b4222-f694-41f0-9685-ff5bb260df2e 7516b95f-f776-4464-8c53-06167f40cc99 f1fbfde2-a960-4165-9f88-50667911ce96 75
powercfg -setdcvalueindex 381b4222-f694-41f0-9685-ff5bb260df2e 7516b95f-f776-4464-8c53-06167f40cc99 f1fbfde2-a960-4165-9f88-50667911ce96 50
powercfg -setacvalueindex 381b4222-f694-41f0-9685-ff5bb260df2e 9596fb26-9850-41fd-ac3e-f7c3c00afd4b 03680956-93bc-4294-bba6-4e0f09bb717f 2
powercfg -setdcvalueindex 381b4222-f694-41f0-9685-ff5bb260df2e 9596fb26-9850-41fd-ac3e-f7c3c00afd4b 03680956-93bc-4294-bba6-4e0f09bb717f 2
powercfg -setacvalueindex 381b4222-f694-41f0-9685-ff5bb260df2e 9596fb26-9850-41fd-ac3e-f7c3c00afd4b 34c7b99f-9a6d-4b3c-8dc7-b6693b78cef4 1
powercfg -setdcvalueindex 381b4222-f694-41f0-9685-ff5bb260df2e 9596fb26-9850-41fd-ac3e-f7c3c00afd4b 34c7b99f-9a6d-4b3c-8dc7-b6693b78cef4 1
powercfg -setacvalueindex 381b4222-f694-41f0-9685-ff5bb260df2e e73a048d-bf27-4f12-9731-8b2076e8891f 637ea02f-bbcb-4015-8e2c-a1c7b9c0b546 3
powercfg -setdcvalueindex 381b4222-f694-41f0-9685-ff5bb260df2e e73a048d-bf27-4f12-9731-8b2076e8891f 637ea02f-bbcb-4015-8e2c-a1c7b9c0b546 3
powercfg -setacvalueindex 381b4222-f694-41f0-9685-ff5bb260df2e e73a048d-bf27-4f12-9731-8b2076e8891f 9a66d8d7-4ff7-4ef9-b5a2-5a326ca2a469 7
powercfg -setdcvalueindex 381b4222-f694-41f0-9685-ff5bb260df2e e73a048d-bf27-4f12-9731-8b2076e8891f 9a66d8d7-4ff7-4ef9-b5a2-5a326ca2a469 7
powercfg -setacvalueindex 381b4222-f694-41f0-9685-ff5bb260df2e e73a048d-bf27-4f12-9731-8b2076e8891f 8183ba9a-e910-48da-8769-14ae6dc1170a 10
powercfg -setdcvalueindex 381b4222-f694-41f0-9685-ff5bb260df2e e73a048d-bf27-4f12-9731-8b2076e8891f 8183ba9a-e910-48da-8769-14ae6dc1170a 10
powercfg -setacvalueindex 381b4222-f694-41f0-9685-ff5bb260df2e e73a048d-bf27-4f12-9731-8b2076e8891f bcded951-187b-4d05-bccc-f7e51960c258 1
powercfg -setdcvalueindex 381b4222-f694-41f0-9685-ff5bb260df2e e73a048d-bf27-4f12-9731-8b2076e8891f bcded951-187b-4d05-bccc-f7e51960c258 1
powercfg -setacvalueindex 381b4222-f694-41f0-9685-ff5bb260df2e e73a048d-bf27-4f12-9731-8b2076e8891f d8742dcb-3e6a-4b3c-b3fe-374623cdcf06 2
powercfg -setdcvalueindex 381b4222-f694-41f0-9685-ff5bb260df2e e73a048d-bf27-4f12-9731-8b2076e8891f d8742dcb-3e6a-4b3c-b3fe-374623cdcf06 2
powercfg -setacvalueindex 381b4222-f694-41f0-9685-ff5bb260df2e e73a048d-bf27-4f12-9731-8b2076e8891f f3c5027d-cd16-4930-aa6b-90db844a8f00 3
powercfg -setdcvalueindex 381b4222-f694-41f0-9685-ff5bb260df2e e73a048d-bf27-4f12-9731-8b2076e8891f f3c5027d-cd16-4930-aa6b-90db844a8f00 3
powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61
rem Your Power Plan has been configured

rem . . . . . . . . . . . . . . . . Additional power settings . . . . . . . . . . . . . . .

rem Improve Startup Folders (Gamer Mode)
takeown /f "%ProgramData%\Microsoft\Windows\Start Menu\Programs\Startup" /a /r /D Y
icacls "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup" /inheritance:r /grant:r Administrators:(OI)(CI)F /t /l /q /c

rem --------------------------- Firewall and network protection ---------------------------

rem Enable Windows Firewall / AllProfiles / CurrentProfile / DomainProfile / PrivateProfile / PublicProfile
rem https://technet.microsoft.com/en-us/library/cc771920(v=ws.10).aspx
netsh advfirewall set allprofiles state off

rem Block all inbound network traffic and all outbound except allowed apps
netsh advfirewall set DomainProfile firewallpolicy blockinboundalways,blockoutbound
netsh advfirewall set PublicProfile firewallpolicy blockinboundalways,blockoutbound
netsh advfirewall set PrivateProfile firewallpolicy blockinbound,blockoutbound

rem Windows Firewall Rules
netsh advfirewall firewall add rule name="Svchost DNS" dir=out action=allow protocol=UDP remoteip=Any remoteport=53,5353 program="%WINDIR%\System32\svchost.exe"
netsh advfirewall firewall add rule name="Svchost TCP" dir=out action=allow protocol=TCP remoteport=80,443 program="%WINDIR%\System32\svchost.exe"
netsh advfirewall firewall add rule name="Svchost UDP" dir=out action=allow protocol=TCP remoteport=80,443,3544,56723 program="%WINDIR%\System32\svchost.exe"
netsh advfirewall firewall add rule name="MS Edge TCP" dir=out action=allow protocol=TCP remoteport=80,443 program="C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
netsh advfirewall firewall add rule name="EDGE DNS" dir=out action=allow protocol=UDP remoteip=Any remoteport=443 program="C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
netsh advfirewall firewall add rule name="EDGE UDP" dir=out action=allow protocol=UDP remoteip=Any remoteport=443,5353 program="C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
netsh advfirewall firewall add rule name="OneDrive DNS" dir=out action=allow protocol=UDP remoteip=Any remoteport=53 program="%LocalAppData%\Microsoft\OneDrive\OneDrive.exe"
netsh advfirewall firewall add rule name="OneDrive TCP" dir=out action=allow protocol=TCP remoteport=80,443 program="%LocalAppData%\Microsoft\OneDrive\OneDrive.exe"
netsh advfirewall firewall add rule name="TeamViewer DNS" dir=out action=allow protocol=UDP remoteip=Any remoteport=53 program="%ProgramFiles(x86)%\TeamViewer\TeamViewer.exe"
netsh advfirewall firewall add rule name="TeamViewer UDP" dir=out action=allow protocol=UDP remoteport=5938 program="%ProgramFiles(x86)%\TeamViewer\TeamViewer.exe"
netsh advfirewall firewall add rule name="TeamViewer TCP" dir=out action=allow protocol=TCP remoteport=80,443,5938 program="%ProgramFiles(x86)%\TeamViewer\TeamViewer.exe"
netsh advfirewall firewall add rule name="Update Time DNS" dir=out action=allow protocol=UDP remoteip=Any remoteport=53 program="%ONEDRIVE%\PROGS\Windows Repair Toolbox\Downloads\Custom Tools\Added Custom Tools\UpdateTime.exe"
netsh advfirewall firewall add rule name="Update Time UDP" dir=out action=allow protocol=UDP remoteip=Any remoteport=123 program="%ONEDRIVE%\PROGS\Windows Repair Toolbox\Downloads\Custom Tools\Added Custom Tools\UpdateTime.exe"
netsh advfirewall firewall add rule name="WRT DNS" dir=out action=allow protocol=UDP remoteip=Any remoteport=53 program="%ONEDRIVE%\PROGS\Windows Repair Toolbox\Windows_Repair_Toolbox.exe"

schtasks /Change /TN "Microsoft\Windows\Windows Error Reporting\QueueReporting" /Disable>>%loag%


echo Repair WinRm>>%loag%
rem Enable WinRm
reg add "HKLM\SYSTEM\CurrentControlSet\Services\RemoteRegistry" /v "Start" /t REG_DWORD /d "3" /f>>%loag%
reg add "HKLM\SYSTEM\CurrentControlSet\Services\SNMPTRAP" /v "Start" /t REG_DWORD /d "3" /f>>%loag%
reg add "HKLM\SYSTEM\CurrentControlSet\Services\WinRM" /v "Start" /t REG_DWORD /d "3" /f>>%loag%
net localgroup Administrators /add networkservice>>%loag%
net localgroup Administrators /add localservice>>%loag%
rem Repair WMI
rem ________________________________________________________________________________________
rem Disable Remote Assistance Winrn and SNMP services for monitoring
sc config SNMPTRAP start= demand>>%loag%
sc config RemoteRegistry start= demand>>%loag%
sc config WinRm start= demand>>%loag%
rem System Protection - Enable System restore and Set the size
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\SystemRestore" /v "DisableSR" /f>>%loag%
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\SystemRestore" /v "DisableConfig" /f>>%loag%
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\SystemRestore" /v "DisableSR" /t REG_DWORD /d "0" /f>>%loag%
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SPP\Clients" /v " {09F7EDC5-294E-4180-AF6A-FB0E6A0E9513}" /t REG_MULTI_SZ /d "1" /f>>%loag%
schtasks /Change /TN "Microsoft\Windows\SystemRestore\SR" /Enable>>%loag%

TITLE Windows 11 %SETOS% 25h2 Install from USB Stick on %CLEFUSB% - Configuring Windows Filesystem
rem ================================ Windows Filesystem ===============================
rem Disabling 8dot3 name creation for all volumes on the system
rem 0 - Enables 8dot3 name creation for all volumes on the system / 1 - Disables 8dot3 name creation for all volumes on the system 
rem 2 - Sets 8dot3 name creation on a per volume basis / 3 - Disables 8dot3 name creation for all volumes except the system volume
fsutil.exe 8dot3name set W: 1
fsutil.exe 8dot3name strip /s /f C:\
fsutil 8dot3name scan c:\
fsutil behavior set disable8dot3 1

rem 1 - When listing directories, NTFS does not update the last-access timestamp, and it does not record time stamp updates in the NTFS log
fsutil behavior set disablelastaccess 0x1>>%loag%

vssadmin Resize ShadowStorage /For=C: /On=C: /Maxsize=5GB>>%loag%
rem sc config wbengine start= auto>>%loag%
rem sc config swprv start= auto>>%loag%
rem sc config vds start= auto>>%loag%
sc config VSS start= auto>>%loag%

TITLE Windows 11 %SETOS% 25h2 Install from USB Stick on %CLEFUSB% - Configuring Time and Language

echo ----------------------------------- Time and language ---------------------------------->>%loag%
echo ..................................... Date and time ....................................>>%loag%

echo Time Zone - Western Europe Standard Time
tzutil /s "W. Europe Standard Time" >>%loag%

echo ..................................... Regional Settings .................................>>%loag%

rem 244 - Set Location to United States
rem reg add "HKCU\Control Panel\International\User Profile\en-US" /v "0409:00000409" /t REG_SZ /d "1" /f>>%loag%
rem reg add "HKCU\Control Panel\International\Geo" /v "Name" /t REG_SZ /d "US" /f>>%loag%
rem reg add "HKCU\Control Panel\International\Geo" /v "Nation" /t REG_SZ /d "244" /f>>%loag%
rem reg add "HKCU\Control Panel\International" /v "iCountry" /t REG_SZ /d "36" /f>>%loag%
rem reg add "HKCU\Control Panel\International" /v "Locale" /t REG_SZ /d "00000409" /f>>%loag%
rem reg add "HKCU\Control Panel\International" /v "LocaleName" /t REG_SZ /d "en-US" /f>>%loag%
rem reg add "HKCU\Control Panel\International" /v "sCurrency" /t REG_SZ /d "USD" /f>>%loag%
reg add "HKCU\Control Panel\International\🌎🌏🌍" /v "Calendar" /t REG_SZ /d "Gregorian" /f>>%loag%

rem Set device setup region to Switzerland (GeoID 223)
reg.exe ADD "HKLM\mount\Microsoft\Windows\CurrentVersion\Control Panel\DeviceRegion" /v DeviceRegion /t REG_DWORD /d 223 /f>>%loag%
reg add "HKCU\Control Panel\International\User Profile\de-CH" /v "0807:00000807" /t REG_SZ /d "1" /f>>%loag%
reg add "HKCU\Control Panel\International\User Profile" /v "Languages" /t REG_SZ /d "de-CH" /f>>%loag%
reg add "HKCU\Control Panel\International\Geo" /v "Name" /t REG_SZ /d "CH" /f>>%loag%
reg add "HKCU\Control Panel\International\Geo" /v "Nation" /t REG_SZ /d "223" /f>>%loag%
reg add "HKCU\Control Panel\International" /v "iCountry" /t REG_SZ /d "41" /f>>%loag%
reg add "HKCU\Control Panel\International" /v "Locale" /t REG_SZ /d "00000807" /f>>%loag%
reg add "HKCU\Control Panel\International" /v "LocaleName" /t REG_SZ /d "de-CH" /f>>%loag%
reg add "HKCU\Control Panel\International" /v "sCurrency" /t REG_SZ /d "CHF" /f>>%loag%
rem reg add "HKCU\Control Panel\International\🌎🌏🌍" /v "Calendar" /t REG_SZ /d "Gregorian" /f>>%loag%

echo . . . . . . . . . . . . Additional date, time, and regional settings . . . . . . . . . . .>>%loag%

rem Set Formats to Metric
rem reg add "HKCU\Control Panel\International" /v "iDigits" /t REG_SZ /d "2" /f>>%loag%
rem reg add "HKCU\Control Panel\International" /v "iLZero" /t REG_SZ /d "1" /f>>%loag%
rem reg add "HKCU\Control Panel\International" /v "iMeasure" /t REG_SZ /d "0" /f>>%loag%
rem reg add "HKCU\Control Panel\International" /v "iNegNumber" /t REG_SZ /d "1" /f>>%loag%
rem reg add "HKCU\Control Panel\International" /v "iPaperSize" /t REG_SZ /d "1" /f>>%loag%
rem reg add "HKCU\Control Panel\International" /v "iTLZero" /t REG_SZ /d "1" /f>>%loag%
rem reg add "HKCU\Control Panel\International" /v "sDecimal" /t REG_SZ /d "," /f>>%loag%
rem reg add "HKCU\Control Panel\International" /v "sNativeDigits" /t REG_SZ /d "0123456789" /f>>%loag%
rem reg add "HKCU\Control Panel\International" /v "sNegativeSign" /t REG_SZ /d "-" /f>>%loag%
rem reg add "HKCU\Control Panel\International" /v "sPositiveSign" /t REG_SZ /d "" /f>>%loag%
rem reg add "HKCU\Control Panel\International" /v "NumShape" /t REG_SZ /d "1" /f>>%loag%

rem Set Time to 24h / Monday
rem reg add "HKCU\Control Panel\International" /v "iCalendarType" /t REG_SZ /d "1" /f>>%loag%
rem reg add "HKCU\Control Panel\International" /v "iDate" /t REG_SZ /d "1" /f>>%loag%
rem reg add "HKCU\Control Panel\International" /v "iFirstDayOfWeek" /t REG_SZ /d "0" /f>>%loag%
rem reg add "HKCU\Control Panel\International" /v "iFirstWeekOfYear" /t REG_SZ /d "0" /f>>%loag%
rem reg add "HKCU\Control Panel\International" /v "iTime" /t REG_SZ /d "1" /f>>%loag%
rem reg add "HKCU\Control Panel\International" /v "iTimePrefix" /t REG_SZ /d "0" /f>>%loag%
rem reg add "HKCU\Control Panel\International" /v "sDate" /t REG_SZ /d "-" /f>>%loag%
rem reg add "HKCU\Control Panel\International" /v "sList" /t REG_SZ /d "," /f>>%loag%
rem reg add "HKCU\Control Panel\International" /v "sLongDate" /t REG_SZ /d "d MMMM, yyyy" /f>>%loag%
rem reg add "HKCU\Control Panel\International" /v "sMonDecimalSep" /t REG_SZ /d "." /f>>%loag%
rem reg add "HKCU\Control Panel\International" /v "sMonGrouping" /t REG_SZ /d "3;0" /f>>%loag%
rem reg add "HKCU\Control Panel\International" /v "sMonThousandSep" /t REG_SZ /d "," /f>>%loag%
rem reg add "HKCU\Control Panel\International" /v "sShortDate" /t REG_SZ /d "dd-MMM-yy" /f>>%loag%
rem reg add "HKCU\Control Panel\International" /v "sTime" /t REG_SZ /d ":" /f>>%loag%
rem reg add "HKCU\Control Panel\International" /v "sTimeFormat" /t REG_SZ /d "HH:mm:ss" /f>>%loag%
rem reg add "HKCU\Control Panel\International" /v "sShortTime" /t REG_SZ /d "HH:mm" /f>>%loag%
rem reg add "HKCU\Control Panel\International" /v "sYearMonth" /t REG_SZ /d "MMMM yyyy" /f>>%loag%


rem Enable IPv6
netsh int ipv6 isatap set state enable
netsh int teredo set state default
netsh interface ipv6 6to4 set state state=enable undoonstop=enable
sc config XblAuthManager start= demand
sc config XblGameSave start= demand
sc config XboxGipSvc start= demand
sc config XboxNetApiSvc start= demand
schtasks /Change /TN "Microsoft\XblGameSave\XblGameSaveTask" /Disable


TITLE Windows 11 %SETOS% 25h2 Install from USB Stick on %CLEFUSB% - Configuring Windows Update

echo =============================== Windows update Settings ================================>>%loag%
Echo ----------------------------------- Update and security -------------------------------->>%loag%
Echo ........................................ Backup ........................................>>%loag%

rem 1 - Disable File History (Creating previous versions of files/Windows Backup)>>%loag%

echo ==================================== Windows Shell =====================================>>%loag%
echo Add Reset permissions to Shell/Manually Reset permissions/Take Ownership>>%loag%
rem http://lallouslab.net/2013/08/26/resetting-ntfs-files-permission-in-windows-graphical-utility

echo Take Ownership>>%loag%
echo Add "Take Ownership" Option in Files and Folders Context Menu in Windows>>%loag%
reg add "HKCR\*\shell\runas" /ve /t REG_SZ /d "Take ownership" /f>>%loag%
reg add "HKCR\*\shell\runas" /v "HasLUAShield" /t REG_SZ /d "" /f>>%loag%
reg add "HKCR\*\shell\runas" /v "NoWorkingDirectory" /t REG_SZ /d "" /f>>%loag%
reg add "HKCR\*\shell\runas\command" /ve /t REG_SZ /d "cmd.exe /c takeown /f \"%%1\" && icacls \"%%1\" /grant administrators:F" /f>>%loag%
reg add "HKCR\*\shell\runas\command" /v "IsolatedCommand" /t REG_SZ /d "cmd.exe /c takeown /f \"%%1\" && icacls \"%%1\" /grant administrators:F" /f>>%loag%
reg add "HKCR\Directory\shell\runas" /ve /t REG_SZ /d "Take ownership" /f>>%loag%
reg add "HKCR\Directory\shell\runas" /v "HasLUAShield" /t REG_SZ /d "" /f>>%loag%
reg add "HKCR\Directory\shell\runas" /v "NoWorkingDirectory" /t REG_SZ /d "" /f>>%loag%
reg add "HKCR\Directory\shell\runas\command" /ve /t REG_SZ /d "cmd.exe /c takeown /f \"%%1\" /r && icacls \"%%1\" /grant administrators:F /t" /f>>%loag%
reg add "HKCR\Directory\shell\runas\command" /v "IsolatedCommand" /t REG_SZ /d "cmd.exe /c takeown /f \"%%1\" /r && icacls \"%%1\" /grant administrators:F /t" /f>>%loag%

echo Remove Share from Context Menu>>%loag%
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Classes\*\shellex\ContextMenuHandlers\ModernSharing" /f>>%loag%
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Classes\*\shellex\ContextMenuHandlers\Sharing" /f>>%loag%
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Drive\shellex\ContextMenuHandlers\Sharing" /f>>%loag%
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Drive\shellex\PropertySheetHandlers\Sharing" /f>>%loag%
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Directory\background\shellex\ContextMenuHandlers\Sharing" /f>>%loag%
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Directory\shellex\ContextMenuHandlers\Sharing" /f>>%loag%
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Directory\shellex\CopyHookHandlers\Sharing" /f>>%loag%
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Directory\shellex\PropertySheetHandlers\Sharing" /f>>%loag%

echo -------------------------------------- App Settings ---------------------------------------->>%loag%

TITLE Windows 11 %SETOS% 25h2 Install from USB Stick on %CLEFUSB% - Cleaning Windows Waypoints
echo ==================================== Windows Waypoint ==================================>>%loag%
xcopy /S /H /R /D /Y %TEMP%\*.log %PUBLIC%\Desktop\loag\
echo =================================== Settings Changes Done ===================================>>%loag%
TITLE Windows 11 %SETOS% 25h2 Install from USB Stick on %CLEFUSB% - Windows PreSetup Done
echo =================================== Pre-Setup Done ===================================>>%loag%
pause
::—————————————————————————————————————————————————————————————————————————————————————
goto end
:IsNotAdmin
::=====================================================================================
TITLE Please Execute this Script with Admin Credentials
echo You Must Execute this Script from the usb stick with Admin Credentials.
pause
goto fin
::—————————————————————————————————————————————————————————————————————————————————————
:error
::=====================================================================================
TITLE NO USB KEY PRESENT
echo no usb key or no admin rights
echo no usb key or no admin rights>>%loag%
pause
goto fin
::—————————————————————————————————————————————————————————————————————————————————————
:Reboot
TITLE REBOOT - REBOOT - REBOOT - REBOOT - REBOOT - REBOOT - REBOOT - REBOOT - REBOOT - REBOOT
timeout /t 5
shutdown /r /f /t 0
::—————————————————————————————————————————————————————————————————————————————————————
:end
::=====================================================================================
TITLE SYNC SUCCESSFULLY DONE with %APPS% from USB Stick %CLEFUSB% to Computer %ORDI%
echo %Kaction%
echo %Kaction%>>%loag%
start notepad.exe %loag%
SET /P QUESTION=Reboot computer now? (Y/N):
If /I %QUESTION%==Y goto reboot
echo Will not reboot. Now exiting command prompt.
::—————————————————————————————————————————————————————————————————————————————————————
:fin
echo Done at %DATE:~0,2%/%DATE:~3,2%/%DATE:~6,6%-%heure:~0,2%H%TIME:~3,2%>>%loag%
start notepad.exe %loag%
endlocal
