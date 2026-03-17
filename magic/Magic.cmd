@ECHO OFF
REM Magic-script-loader 
REM Yann Duchateau

:variables
IF EXIST C:\sources\addons SET CLEFUSB=C:
FOR %%i IN (D E F G H I J K L M N O P Q R S T U V W X Y Z) DO IF EXIST %%i:\bootmgr.efi SET CLEFUSB=%%i:
SET SETOS=%PROCESSOR_ARCHITECTURE%
SET APPS=%CLEFUSB%\sources\$OEM$\$1\Addons
SET MOEM=%CLEFUSB%\Magic
SET OEMS=%CLEFUSB%\sources\$OEM$\$$\Setup\Scripts
SET OEMAPPS=%WINDIR%\Setup\
set Kaction="Full Magic Installation from %APPS% "
SET SETOS=%PROCESSOR_ARCHITECTURE%
goto :country

:debut
set heurecode=%jour%.%mois%.%annee%.%heure%H%minute%
set loag=%CLEFUSB%\Magic\Logs\Magic%heurecode%.log
set laog=%windir%\Logs\SOFTWARE\Magic%heurecode%.log
echo.
echo Root is: %CLEFUSB% Time is %heurecode%
echo.
goto isUsb

:isUsb
TITLE Magic Script %Kaction% Started at %timecode% on %COMPUTERNAME%
ECHO Magic Script %Kaction% Started at %timecode% on %COMPUTERNAME%
ECHO Magic Script %Kaction% Started at %timecode% on %COMPUTERNAME% >>%LAOG%
IF EXIST %CLEFUSB%\bootmgr.efi goto isAdmin
goto error

:isAdmin
TITLE Magic Script %Kaction% Started at %timecode% on %COMPUTERNAME%
IF EXIST %windir%\Logs\SOFTWARE\Magic%heurecode%.log goto Magic
goto isNotAdmin

:Magic
TITLE Magic Script %Kaction% Started at %timecode% on %COMPUTERNAME%
ECHO Magic Script %Kaction% Started at %timecode% on %COMPUTERNAME% 
ECHO Magic Script %Kaction% Started at %timecode% on %COMPUTERNAME% >>%LOAG%
echo Starting.....
pause
:EndComment
echo =========================== Takeown Essential Folders ============================= >>%LOAG%
rem Take ownership of Public Desktop
takeown /s %COMPUTERNAME% /u Administrators /f "c:\Users\Public\Desktop" /A /R /D:J >>%loag%
takeown /s %COMPUTERNAME% /u Administrators /f "C:\Windows\Web\*" /A /R /D:J >>%LOAG%
takeown /f "%ProgramData%\Microsoft\Windows\Start Menu\Programs\Startup" /a /r /D Y >>%LOAG%
icacls C:\Windows\Web\* /save C:\WINDOWS\Logs\ACLwinweb%COMPUTERNAME%.txt /T /C /L /Q  >>%loag%
subinacl /errorlog="C:\WINDOWS\Logs\ACLWinWeb%COMPUTERNAME%error.txt" /outputlog="C:\WINDOWS\Logs\ACLWinWeb%COMPUTERNAME%.acl" /subdirectories C:\Windows\Web\* /display=sddl >>%LOAG%
echo ============================ Icacls Public Desktop ================================ >>%LOAG%
icacls "c:\Users\Public\Desktop" /grant:r Administrators:(OI)(CI)F /T /C /L /Q  >>%LOAG%
icacls "c:\Users\Public\Desktop" /grant %USERNAME%:(OI)(CI)F /T /C /L /Q  >>%LOAG%
echo ============================== Icacls Windows Web ================================ >>%LOAG%
icacls "C:\Windows\Web\*" /grant:r Administrators:(OI)(CI)F /T /C /L /Q  >>%LOAG%
icacls "C:\Windows\Web\*" /grant %USERNAME%:(OI)(CI)F /T /C /L /Q  >>%LOAG%
echo ============================ IcaclsStartup Folders =============================== >>%LOAG%
icacls "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup" /inheritance:r /grant:r Administrators:(OI)(CI)F /t /l /q /c >>%LOAG%
icacls "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup" /grant %USERNAME%:(OI)(CI)F /T /C /L /Q  >>%LOAG%
icacls "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup" /grant LAPSAdministrator:(OI)(CI)F /T /C /L /Q  >>%LOAG%
echo =============================== SubinAcl Registry ================================ >>%LOAG%
subinacl /subkeyreg HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation /grant=Administrators=f >>%LOAG%
subinacl /subkeyreg HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation /grant=Administratoren=f >>%LOAG%
subinacl /subkeyreg HKLM\SYSTEM /grant=Administrators=f >>%LOAG%
subinacl /subkeyreg HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion /grant=%USERNAME%=f >>%LOAG%
echo =========================== Takeown Essential Folders ============================= >>%LOAG%
rem Snapshot Runnning Processes
TASKLIST /FI "USERNAME ne NT AUTHORITY\SYSTEM" /FI "STATUS eq running" /V   >>%LOAG%
echo -------------------------------- Powershell Enabled ------------------------------ >>%loag%
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Policies\Microsoft\Windows\PowerShell" /v "EnableScripts" /t REG_SZ /d "1" /f >>%loag%
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Policies\Microsoft\Windows\PowerShell" /v "ExecutionPolicy" /t REG_SZ /d "Unrestricted" /f >>%loag%
echo %jour%-%mois%-%annee%-%heure%H%minute% Windows 11 %SETOS% 25H2 Install from USB Stick on %CLEFUSB% - Cleaning Windows >>%LOAG%
echo ================================ Cleaning Windows ================================ >>%loag%
echo ------------------------------------- System ------------------------------------- >>%loag%
REG ADD "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3" /t REG_DWORD /v 1A10 /f /d 0 >>%LOAG%
echo CORPORATE silent install >%loag%
powershell.exe -ExecutionPolicy Bypass -Command "%CLEFUSB%\magic\bootstrap.ps1" >%loag% >>%loag%
if exist "%windir%\Setup\Files\post-setup.ps1" goto features
echo Corporate post-setup failed
echo Corporate post-setup failed >>%loag%
:Corporate
rem Post Setup Files
powershell.exe -ExecutionPolicy Bypass -Command "%windir%\Setup\Files\post-setup.ps1">%loag% >>%loag%
:features
echo ================================ Windows Features ================================ >>%loag%
rem Now configuring Windows Features.
rem # Windows update services required for DISM
rem # "DISM /Online /Get-Features /format:table" shows installed features
rem # "Get-WindowsOptionalFeature -Online" shows installed features
rem # Possible AUTO-REBOOT if ran without admin privileges
rem # REBOOT RECOMMENDED
echo ======================== Disable various Windows Features ======================== >>%loag%
powershell Remove-WindowsCapability -Name StepsRecorder -Online >>%loag%
powershell Remove-WindowsCapability -Name QuickAssist -Online >>%loag%
DISM /Online /Remove-Capability /CapabilityName:"App.WirelessDisplay.Connect~~~~0.0.1.0" /NoRestart >>%loag%
DISM /Online /Remove-Capability /CapabilityName:"App.StepsRecorder~~~~0.0.1.0" /NoRestart >>%loag%
DISM /Online /Remove-Capability /CapabilityName:"App.Support.QuickAssist~~~~0.0.1.0" /NoRestart >>%loag%
Dism /Online /Disable-Feature /Featurename:Recall /NoRestart >>%loag%
DISM /Online /Disable-Feature /FeatureName:"AppServerClient" /NoRestart >>%loag%
DISM /Online /Disable-Feature /FeatureName:"Analog.Holographic.Desktop~~~~0.0.1.0" /NoRestart >>%loag%
DISM /Online /Disable-Feature /FeatureName:"FaxServicesClientPackage" /NoRestart >>%loag%
DISM /Online /Disable-Feature /FeatureName:"Internet-Explorer-Optional-x64" /NoRestart >>%loag%
DISM /Online /Disable-Feature /FeatureName:"Internet-Explorer-Optional-amd64" /NoRestart >>%loag%
DISM /Online /Disable-Feature /FeatureName:"Microsoft-Hyper-V-All" /NoRestart >>%loag%
DISM /Online /Disable-Feature /FeatureName:"Microsoft-Hyper-V-Management-Clients" /NoRestart >>%loag%
DISM /Online /Disable-Feature /FeatureName:"Microsoft-Hyper-V-Management-PowerShell" /NoRestart >>%loag%
DISM /Online /Disable-Feature /FeatureName:"Microsoft-Hyper-V-Tools-All" /NoRestart >>%loag%
dism /Online /Disable-Feature /FeatureName:"Printing-Foundation-Features" /NoRestart
dism /Online /Disable-Feature /FeatureName:"Printing-Foundation-InternetPrinting-Client" /NoRestart >>%loag%
dism /Online /Disable-Feature /FeatureName:"Printing-Foundation-LPDPrintService" /NoRestart >>%loag%
dism /Online /Disable-Feature /FeatureName:"Printing-Foundation-LPRPortMonitor" /NoRestart >>%loag%
dism /Online /Disable-Feature /FeatureName:"Printing-XPSServices-Features" /NoRestart >>%loag%
DISM /Online /Disable-Feature /FeatureName:"Printing-Foundation-LPRPortMonitor" /NoRestart >>%loag%
DISM /Online /Disable-Feature /FeatureName:"RasCMAK.Client~~~~0.0.1.0" /NoRestart >>%loag%
DISM /Online /Disable-Feature /FeatureName:"SNMP.Client~~~~0.0.1.0" /NoRestart >>%loag%
DISM /Online /Disable-Feature /FeatureName:"WMI-SNMP-Provider.Client~~~~0.0.1.0" /NoRestart >>%loag%
sc stop "WSearch"
sc config "WSearch" start="auto"
Dism /online /Enable-Feature /FeatureName:"SearchEngine-Client-Package" /NoRestart >>%loag%
sc start "WSearch"
dism /Online /Disable-Feature /FeatureName:"TelnetClient" /NoRestart >>%loag%
dism /Online /Disable-Feature /FeatureName:"TFTP" /NoRestart >>%loag%
dism /Online /Disable-Feature /FeatureName:"TIFFIFilter" /NoRestart >>%loag%
dism /Online /Disable-Feature /FeatureName:"WorkFolders-Client" /NoRestart >>%loag%
DISM /Online /Disable-Feature /FeatureName:"Xps-Foundation-Xps-Viewer" /NoRestart >>%loag%
DISM /online /get-features /format:table | more >>%PUBLIC%\Desktop\Features.txt
DISM /Online /Get-Features>>%PUBLIC%\Desktop\Features2.txt >>%loag%
DISM /Online /Get-Capabilities>%PUBLIC%\Desktop\Capabilities.txt >>%loag%
rem ================================ Windows Settings ===================================
rem ------------------------------------ System -----------------------------------------
rem . . . . . . . . . . . . . . . Additional power settings . . . . . . . . . . . . . . 
rem --------------------------- Firewall and network protection -------------------------
rem Enable Windows Firewall / AllProfiles / CurrentProfile / DomainProfile / PrivateProfile / PublicProfile
rem https://technet.microsoft.com/en-us/library/cc771920(v=ws.10).aspx
netsh advfirewall set allprofiles state on
rem Block all inbound network traffic and all outbound except allowed apps
netsh advfirewall set DomainProfile firewallpolicy allowinboundalways,allowinbound
netsh advfirewall set PublicProfile firewallpolicy allowinboundalways,allowinbound
netsh advfirewall set PrivateProfile firewallpolicy allowinbound,allowinbound
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
schtasks /Change /TN "Microsoft\Windows\Windows Error Reporting\QueueReporting" /Disable
echo Disable WinRm  >>%loag%
rem Disable WinRm
reg add HKLM\SYSTEM\CurrentControlSet\Services\RemoteRegistry" /v "Start" /t REG_DWORD /d "3" /f >>%loag%
reg add HKLM\SYSTEM\CurrentControlSet\Services\SNMPTRAP" /v "Start" /t REG_DWORD /d "3" /f >>%loag%
reg add HKLM\SYSTEM\CurrentControlSet\Services\WinRM" /v "Start" /t REG_DWORD /d "3" /f >>%loag%
net localgroup Administrators /add networkservice >>%loag%
net localgroup Administrators /add localservice >>%loag%
rem Repair WMI
rem Disable Remote Assistance Winrn and SNMP services for monitoring
sc config SNMPTRAP start= demand >>%loag%
sc config RemoteRegistry start= demand >>%loag%
sc config WinRm start= demand >>%loag%
rem System Protection - Enable System restore and Set the size
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\SystemRestore" /v "DisableSR" /f >>%loag%
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\SystemRestore" /v "DisableConfig" /f >>%loag%
reg add HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\SystemRestore" /v "DisableSR" /t REG_DWORD /d "0" /f >>%loag%
reg add HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SPP\Clients" /v " {09F7EDC5-294E-4180-AF6A-FB0E6A0E9513}" /t REG_MULTI_SZ /d "1" /f >>%loag%
schtasks /Change /TN "Microsoft\Windows\SystemRestore\SR" /Enable >>%loag%
echo ----------------------------------- Time and language ---------------------------------- >>%loag%
echo ..................................... Date and time .................................... >>%loag%
echo Time Zone - Western Europe Standard Time
tzutil /s "W. Europe Standard Time" >>%loag%
echo ..................................... Regional Settings ................................. >>%loag%
rem 244 - Set Location to United States
reg.exe ADD "HKLM\mount\Microsoft\Windows\CurrentVersion\Control Panel\DeviceRegion" /v DeviceRegion /t REG_DWORD /d 244 /f >>%loag%
reg add "HKCU\Control Panel\International\User Profile\en-US" /v "0409:00000409" /t REG_SZ /d "1" /f >>%loag%
reg add "HKCU\Control Panel\International\Geo" /v "Name" /t REG_SZ /d "US" /f >>%loag%
reg add "HKCU\Control Panel\International\Geo" /v "Nation" /t REG_SZ /d "244" /f >>%loag%
reg add "HKCU\Control Panel\International" /v "iCountry" /t REG_SZ /d "36" /f >>%loag%
reg add "HKCU\Control Panel\International" /v "Locale" /t REG_SZ /d "00000409" /f >>%loag%
reg add "HKCU\Control Panel\International" /v "LocaleName" /t REG_SZ /d "en-US" /f >>%loag%
reg add "HKCU\Control Panel\International" /v "sCurrency" /t REG_SZ /d "USD" /f >>%loag%
add "HKCU\Control Panel\International\🌎🌏🌍" /v "Calendar" /t REG_SZ /d "Gregorian" /f >>%loag%
echo Set device setup region to Switzerland (GeoID 223) >>%loag%
reg.exe ADD "HKLM\mount\Microsoft\Windows\CurrentVersion\Control Panel\DeviceRegion" /v DeviceRegion /t REG_DWORD /d 223 /f >>%loag%
reg add "HKCU\Control Panel\International\User Profile\de-CH" /v "0807:00000807" /t REG_SZ /d "1" /f >>%loag%
reg add "HKCU\Control Panel\International\User Profile" /v "Languages" /t REG_SZ /d "de-CH" /f >>%loag%
reg add "HKCU\Control Panel\International\Geo" /v "Name" /t REG_SZ /d "CH" /f >>%loag%
reg add "HKCU\Control Panel\International\Geo" /v "Nation" /t REG_SZ /d "223" /f >>%loag%
reg add "HKCU\Control Panel\International" /v "iCountry" /t REG_SZ /d "41" /f >>%loag%
reg add "HKCU\Control Panel\International" /v "Locale" /t REG_SZ /d "00000807" /f >>%loag%
reg add "HKCU\Control Panel\International" /v "LocaleName" /t REG_SZ /d "de-CH" /f >>%loag%
reg add "HKCU\Control Panel\International" /v "sCurrency" /t REG_SZ /d "CHF" /f >>%loag%
rem reg add "HKCU\Control Panel\International\🌎🌏🌍" /v "Calendar" /t REG_SZ /d "Gregorian" /f >>%loag%
echo . . . . . . . . . . . . Additional date, time, and regional settings . . . . . . . . . . . >>%loag%
rem Set Formats to Metric
reg add "HKCU\Control Panel\International" /v "iDigits" /t REG_SZ /d "2" /f >>%loag%
reg add "HKCU\Control Panel\International" /v "iLZero" /t REG_SZ /d "1" /f >>%loag%
reg add "HKCU\Control Panel\International" /v "iMeasure" /t REG_SZ /d "0" /f >>%loag%
reg add "HKCU\Control Panel\International" /v "iNegNumber" /t REG_SZ /d "1" /f >>%loag%
reg add "HKCU\Control Panel\International" /v "iPaperSize" /t REG_SZ /d "1" /f >>%loag%
reg add "HKCU\Control Panel\International" /v "iTLZero" /t REG_SZ /d "1" /f >>%loag%
reg add "HKCU\Control Panel\International" /v "sDecimal" /t REG_SZ /d "," /f >>%loag%
reg add "HKCU\Control Panel\International" /v "sNativeDigits" /t REG_SZ /d "0123456789" /f >>%loag%
reg add "HKCU\Control Panel\International" /v "sNegativeSign" /t REG_SZ /d "-" /f >>%loag%
reg add "HKCU\Control Panel\International" /v "sPositiveSign" /t REG_SZ /d "" /f >>%loag%
reg add "HKCU\Control Panel\International" /v "NumShape" /t REG_SZ /d "1" /f >>%loag%
rem Set Time to 24h / Monday
reg add "HKCU\Control Panel\International" /v "iCalendarType" /t REG_SZ /d "1" /f >>%loag%
reg add "HKCU\Control Panel\International" /v "iDate" /t REG_SZ /d "1" /f >>%loag%
reg add "HKCU\Control Panel\International" /v "iFirstDayOfWeek" /t REG_SZ /d "0" /f >>%loag%
reg add "HKCU\Control Panel\International" /v "iFirstWeekOfYear" /t REG_SZ /d "0" /f >>%loag%
reg add "HKCU\Control Panel\International" /v "iTime" /t REG_SZ /d "1" /f >>%loag%
reg add "HKCU\Control Panel\International" /v "iTimePrefix" /t REG_SZ /d "0" /f >>%loag%
reg add "HKCU\Control Panel\International" /v "sDate" /t REG_SZ /d "-" /f >>%loag%
reg add "HKCU\Control Panel\International" /v "sList" /t REG_SZ /d "," /f >>%loag%
reg add "HKCU\Control Panel\International" /v "sLongDate" /t REG_SZ /d "d MMMM, yyyy" /f >>%loag%
reg add "HKCU\Control Panel\International" /v "sMonDecimalSep" /t REG_SZ /d "." /f >>%loag%
reg add "HKCU\Control Panel\International" /v "sMonGrouping" /t REG_SZ /d "3;0" /f >>%loag%
reg add "HKCU\Control Panel\International" /v "sMonThousandSep" /t REG_SZ /d "," /f >>%loag%
reg add "HKCU\Control Panel\International" /v "sShortDate" /t REG_SZ /d "dd-MMM-yy" /f >>%loag%
reg add "HKCU\Control Panel\International" /v "sTime" /t REG_SZ /d ":" /f >>%loag%
reg add "HKCU\Control Panel\International" /v "sTimeFormat" /t REG_SZ /d "HH:mm:ss" /f >>%loag%
reg add "HKCU\Control Panel\International" /v "sShortTime" /t REG_SZ /d "HH:mm" /f >>%loag%
reg add "HKCU\Control Panel\International" /v "sYearMonth" /t REG_SZ /d "MMMM yyyy" /f >>%loag%
rem Enable IPv6
netsh int ipv6 isatap set state enable >>%loag%
netsh int teredo set state default >>%loag%
netsh interface ipv6 6to4 set state state=enable undoonstop=enable >>%loag%
sc config XblAuthManager start= demand >>%loag%
sc config XblGameSave start= demand >>%loag%
sc config XboxGipSvc start= demand >>%loag%
sc config XboxNetApiSvc start= demand >>%loag%
schtasks /Change /TN "Microsoft\XblGameSave\XblGameSaveTask" /Disable >>%loag%
echo =============================== Windows update Settings ================================ >>%loag%
Echo ----------------------------------- Update and security -------------------------------- >>%loag%
Echo ........................................ Backup ........................................ >>%loag%
rem 1 - Disable File History (Creating previous versions of files/Windows Backup) >>%loag%
echo ==================================== Windows Shell ===================================== >>%loag%
echo Add Reset permissions to Shell/Manually Reset permissions/Take Ownership >>%loag%
rem http://lallouslab.net/2013/08/26/resetting-ntfs-files-permission-in-windows-graphical-utility
echo -------------------------------------- App Settings ---------------------------------------- >>%loag%
echo ==================================== Windows Waypoint ================================== >>%loag%
xcopy /S /H /R /D /Y %TEMP%\*.log %PUBLIC%\Desktop\loag\
echo =================================== Settings Changes Done =================================== >>%loag%
echo =================================== Pre-Setup Done =================================== >>%loag%
netsh advfirewall set CurrentProfile state off >%loag% >>%loag%
echo ---------------------------------------- Privacy --------------------------------------- >%loag% >>%loag%
reg add "%sw%\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v "Enabled" /t REG_DWORD /d "0" /f >%loag% >>%loag%
reg add "%sw%\Policies\Microsoft\Windows\AdvertisingInfo" /v "DisabledByGroupPolicy" /t REG_DWORD /d "1" /f >%loag% >>%loag%
rem ================================ Windows Filesystem ===============================
rem Disabling 8dot3 name creation for all volumes on the system
rem 0 - Enables 8dot3 name creation for all volumes on the system / 1 - Disables 8dot3 name creation for all volumes on the system 
rem 2 - Sets 8dot3 name creation on a per volume basis / 3 - Disables 8dot3 name creation for all volumes except the system volume
fsutil.exe 8dot3name set W: 1 >>%loag%
fsutil.exe 8dot3name strip /s /f C:\ >>%loag%
fsutil 8dot3name scan c:\ >>%loag%
fsutil behavior set disable8dot3 1 >>%loag%
rem 1 - When listing directories, NTFS does not update the last-access timestamp, and it does not record time stamp updates in the NTFS log
fsutil behavior set disablelastaccess 0x1 >>%loag%
echo ===================================  BitLocker =================================== >>%loag%
rem Enable-BitLocker -MountPoint "C:" -EncryptionMethod Aes256 -AdAccountOrGroup "%ORDI%\%USERNAME%" -AdAccountOrGroupProtector
rem fsutil behavior set disabledeletenotify 1 >%loag% >>%loag%
rem 0 - Disable the Encrypting File System (EFS) (Customized) >%loag% >>%loag%
fsutil behavior set disableencryption 0 >%loag% >>%loag%
rem 0 - Disable the log for NTFS File System (EFS) corruption check >%loag% >>%loag%
fsutil behavior set bugcheckoncorrupt 0 >%loag% >>%loag%
rem 1 - Disable the file compression for NTFS File System>%loag% >>%loag%
fsutil behavior set disablecompression 1>%loag% >>%loag%
fsutil behavior set disablelastaccess 1 >%loag% >>%loag%
fsutil behavior set disablewriteautotiering 0 >%loag% >>%loag%
fsutil behavior set encryptpagingfile 0 >%loag% >>%loag%
rem 0 - Enable the TRIM FOR NTFS ssd File System (EFS) (Customized) >%loag% >>%loag%
fsutil behavior set disabledeletenotify 0 >%loag% >>%loag%
vssadmin Resize ShadowStorage /For=C: /On=C: /Maxsize=5GB >>%loag%
rem sc config wbengine start= auto >>%loag%
rem sc config swprv start= auto >>%loag%
rem sc config vds start= auto >>%loag%
sc config VSS start= auto >>%loag%
goto end

:country
FOR /F "tokens=3" %%l IN ('reg query "HKCU\Control Panel\Desktop" /v PreferredUILanguages ^| find "PreferredUILanguages"') DO set UILanguage=%%l
FOR /F "tokens=3" %%l IN ('reg query "HKCU\Control Panel\International\User Profile" /v Languages ^| find "Languages"') DO set UILanguage=%%l

Set Languages=%UILanguage:~0,5%
echo Computer Language is %Languages%
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
set mois=%DATE:~3,2%
set annee=%DATE:~6,6%
set heure=%TIME:~0,2%
if "%time:~0,1%" == " " set heure=%time:~-1,1%
set minute=%TIME:~3,2%
goto Debut

:de-DE
set jour=%DATE:~0,2%
set mois=%DATE:~3,2%
set annee=%DATE:~6,6%
set heure=%time:~0,2%
if "%time:~0,1%" == " " set heure=%time:~-1,1%
set minute=%TIME:~3,2%
goto Debut

:IsNotAdmin
TITLE Please Execute this Script with Admin Credentials
echo You Must Execute this Script from the usb stick with Admin Credentials.
pause
goto fin
:error
TITLE Date : %timecode% ERROR or NO USB KEY PRESENT
echo Date %timecode% ERROR or no usb keyecho no usb key or no admin rights >>%loag%
pause
goto fin
:Reboot
TITLE REBOOT - REBOOT - REBOOT - REBOOT - REBOOT - REBOOT - REBOOT - REBOOT - REBOOT - REBOOT
timeout /t 5
shutdown /r /f /t 0
:end
TITLE %Kaction% SUCCESSFULLY DONE with %APPS% from USB Stick %CLEFUSB% to Computer %COMPUTERNAME%
echo %Kaction% Done
echo %Kaction% Done  >>%loag%
start notepad.exe %loag%
SET /P QUESTION=Reboot computer now? (Y/N):
If /I %QUESTION%==Y goto reboot
echo Will not reboot. Now exiting command prompt.
:fin
pause