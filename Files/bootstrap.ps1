# bootstrap-script-loader
#
# Yann Duchateau
# 
# 2026-03-017 - 1.3.1
Set-ExecutionPolicy Unrestricted -Force -ErrorAction SilentlyContinue
import-module dism
import-module Appx

# Start Logging Installation
 function LOgCreate {
   $LogDate = get-date -format "MM-d-yy-HH" 
   $objShell = New-Object -ComObject Shell.Application  
   $objFolder = $objShell.Namespace(0xA) 
   $ErrorActionPreference = "silentlycontinue" 
                     
Start-Transcript -Path "C:\Windows\Logs\bootstrap$LogDate.ps1.log"

}
LOgCreate

$ErrorActionPreference = 'Continue';

Get-AppxPackage *getstarted* | Remove-AppxPackage
get-appxpackage *copilot* | remove-appxpackage
Get-AppxPackage -AllUsers | Where-Object {$_.Name -Like '*Microsoft.Copilot*'} | Remove-AppxPackage -AllUsers -ErrorAction Continue

# Disable-WindowsDefender during Windows Installation
function Disable-WindowsDefender {
    $MultilineComment = @"
	Windows Registry Editor Version 5.00

; Disable-WindowsDefender during Windows Installation
[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\Services\Sense]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\Services\WdBoot]
"Start"=dword:00000000

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\Services\WdFilter]
"Start"=dword:00000000

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\Services\WdNisDrv]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\Services\WdNisSvc]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\Services\WinDefend]
"Start"=dword:00000002

[HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows Defender Security Center\Notifications]
"enableNotifications"=dword:00000001
"enableEnhancedNotifications"=dword:00000001

[HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows Defender Security Center]

[HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows Defender Security Center\Notifications]
"enableNotifications"=dword:00000001
"enableEnhancedNotifications"=dword:00000001

[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender]
"DisableAntiSpyware"=dword:00000001
"DisableAntiVirus"=dword:00000001

[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender\Policy Manager]

[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection]
"DisableBehaviorMonitoring"=dword:00000001
"DisableIOAVProtection"=dword:00000001
"DisableOnAccessProtection"=dword:00000001
"DisableRealtimeMonitoring"=dword:00000001
"DisableScanOnRealtimeEnable"=dword:00000001

[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender\Reporting]
"DisableEnhancedNotifications"=dword:00000000

[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender\SpyNet]
"DisableBlockAtFirstSeen"=dword:00000001
"SpynetReporting"=dword:00000000
"SubmitSamplesConsent"=dword:00000000

"@
    Set-Content -Path "$env:TEMP\Disable_Windows_Defender.reg" -Value $MultilineComment -Force
    $path = "$env:TEMP\Disable_Windows_Defender.reg"
    (Get-Content $path) -replace "\?", "$" | Out-File $path
    Regedit.exe /S "$env:TEMP\Disable_Windows_Defender.reg"
    Write-Host "Windows Defender has been Disabled." -ForegroundColor Green
}
Disable-WindowsDefender

# Removes Shortcuts during Windows Installation
function Remove-Shortcuts {
    Remove-Item "C:\Users\Default\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\OneDrive.lnk" -ErrorAction SilentlyContinue
    Write-Host "Shortcuts has been Removed successfully." -ForegroundColor Green
}

# Sets Power Settings
function Set-PowerUserSettings {
    
    # Enable UAC and set the default prompt behavior
    cmd.exe /c reg.exe add HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v EnableLUA /t REG_DWORD /d 1 /f 2>&1 | Out-Null
    cmd.exe /c reg.exe add HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v ConsentPromptBehaviorAdmin /t REG_DWORD /d 2 /f 2>&1 | Out-Null
    Write-Host "UAC has been enabled successfully." -ForegroundColor Green
     Write-Host "Applying PowerUser Settings . . ."


    $MultilineComment = @"
	Windows Registry Editor Version 5.00

[HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer]
"NoStartMenuMorePrograms"=dword:00000001

[HKEY_CLASSES_ROOT\*\shell\TakeOwnership]
@="Take Ownership"
"HasLUAShield"=""
"NoWorkingDirectory"=""
"NeverDefault"=""

[HKEY_CLASSES_ROOT\*\shell\TakeOwnership\command]
@="powershell -windowstyle hidden -command \"Start-Process cmd -ArgumentList '/c takeown /f \\\"%1\\\" && icacls \\\"%1\\\" /grant *S-1-3-4:F /t /c /l & pause' -Verb runAs\""
"IsolatedCommand"="powershell -windowstyle hidden -command \"Start-Process cmd -ArgumentList '/c takeown /f \\\"%1\\\" && icacls \\\"%1\\\" /grant *S-1-3-4:F /t /c /l & pause' -Verb runAs\""

[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\System]
"EnableCdp"=dword:00000001

[HKCU\Software\Microsoft\Windows\CurrentVersion\CDP]
"CdpSessionUserAuthzPolicy"=dword:00000001

[HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\CDP]
"RomeSdkChannelUserAuthzPolicy"=dword:00000001

[HKCU\SOFTWARE\Microsoft\Office\Common\ClientTelemetry]
"DisableTelemetry"=dword:00000001
:: Set the registry value: Microsoft\Office\15.0\Common\ClientTelemetry
[HKCU\SOFTWARE\Microsoft\Office\15.0\Common\ClientTelemetry]
"DisableTelemetry"=dword:00000001
:: Set the registry value: Microsoft\Office\16.0\Common\ClientTelemetry
[HKCU\SOFTWARE\Microsoft\Office\16.0\Common\ClientTelemetry]
"DisableTelemetry"=dword:00000001
:: Set the registry value: Microsoft\Office\Common\ClientTelemetry
[HKCU\SOFTWARE\Microsoft\Office\Common\ClientTelemetry]
"VerboseLogging"=dword:00000003
:: Set the registry value: Microsoft\Office\15.0\Common\ClientTelemetry
[HKCU\SOFTWARE\Microsoft\Office\15.0\Common\ClientTelemetry]
"VerboseLogging"=dword:00000003
:: Set the registry value: \Microsoft\Office\16.0\Common\ClientTelemetry
[HKCU\SOFTWARE\Microsoft\Office\16.0\Common\ClientTelemetry]
"VerboseLogging"=dword:00000003
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Provisioning]
"FirstRunComplete"=dword:00000001
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Provisioning\AutopilotSettings]
"DisableAutopilotAgilityProductVersionTelemetry"=dword:00000001
"AgilityProductName"="Windows.Autopilot.x64"
"AllowedTimeDriftDeltaMinutes"=dword:00000005
"AutopilotDiagnosticsCurrentVersion"="1.0.0"
"AutopilotDiagnosticsOutputMocked"=dword:00000000
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Provisioning\Diagnostics]
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Provisioning\Diagnostics\Autopilot]
"IsAutoPilotDisabled"=dword:00000000
"CloudAssignedTenantDomain"=""
"CloudAssignedTenantUpn"=""
"CloudAssignedForcedEnrollment"=dword:00000000
"CloudAssignedTenantId"=""
"LatestAutopilotAgilityProductVersion"="10.0.26100.7462"
"CloudAssignedLanguage"=""
"CloudAssignedRegion"=""
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Provisioning\Diagnostics\Autopilot\DefaultEvaluationOrder]
"PolicySourceName_2"="AutoPilotPolicySource::Registry"
"PolicySourceName_8"="AutoPilotPolicySource::DdsZtd"
"PolicySourceName_4"="AutoPilotPolicySource::RipAndReuse"
"DefaultPolicyOrder"="2;8;4"
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Provisioning\AutopilotTpmEnhancedLogging]
"05F02597-FE85-4E67-8542-69567AB8FD4F"="Microsoft-Windows-LiveId"
"1D6540CE-A81B-4E74-AD35-EEF8463F97F5"="NGC_PoP"
"3A8D6942-B034-48e2-B314-F69C2B4655A3"="TPM"
"3b9dbf69-e9f0-5389-d054-a94bc30e33f7"="Microsoft.Windows.Security.NGC.Local"
"470baa67-2d7f-4c9c-8bf4-b1b3226f7b17"="TpmProvisioningTask"
"6D7051A0-9C83-5E52-CF8F-0ECAF5D5F6FD"="CryptCng"
"89F392FF-EE7C-56A3-3F61-2D5B31A36935"="Microsoft.Windows.Security.NGC.CS"
"9B223F67-67A1-5B53-9126-4593FE81DF25"="NGC_PoP_Key_And_Task"
"a935c211-645a-5f5a-4527-778da45bbba5"="Microsoft.Tpm.HealthAttestationCertificateTask"
[HKEY_LOCAL_MACHINE\SOFTWARE\Yann]
"post-setup-script"=-
"Windows Languages Packs"=-
"Microsoft Office 365 Apps for Home Premium (Offline)"=-
"first-logon-script"=-
"windows-customization-machine"=-
"software-customization"=-
"@
    # edit reg file
# Write the registry changes to a file and silently import it using regedit
    Set-Content -Path "$env:TEMP\Recommended_Privacy_Settings.reg" -Value $MultilineComment -Force
    Start-Process -FilePath "regedit.exe" -ArgumentList "/S `"$env:TEMP\Recommended_Privacy_Settings.reg`"" -NoNewWindow -Wait
        Write-Host "Recommended Privacy Settings Applied." -ForegroundColor Green
    }

# Restore default power plans and enable hibernate
function Set-DefaultPowerSetting {
  
    Set-Content -Path "$env:TEMP\Windows_Apps.reg" -Value $MultilineComment -Force -ErrorAction SilentlyContinue
    Regedit.exe /S "$env:TEMP\Windows_Apps.reg" -Force -ErrorAction SilentlyContinue
	    cmd /c "powercfg /hibernate on"

    # Registry modifications
    $regChanges = @(
        'HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings /v ShowLockOption /t REG_DWORD /d 1',
        'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings /v ShowSleepOption /t REG_DWORD /d 1',
        'HKLM\SYSTEM\ControlSet001\Control\Session Manager\Power /v HiberbootEnabled /t REG_DWORD /d 1',
        'HKLM\SYSTEM\ControlSet001\Control\Session Manager\Power /v HibernateEnabledDefault /t REG_DWORD /d 1',
        'HKLM\SYSTEM\ControlSet001\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\0cc5b647-c1df-4637-891a-dec35c318583 /v ValueMax /t REG_DWORD /d 100',
        'HKLM\System\ControlSet001\Control\Power\PowerSettings\2a737441-1930-4402-8d77-b2bebba308a3\0853a681-27c8-4100-a2fd-82013e970683 /v Attributes /t REG_DWORD /d 1',
        'HKLM\System\ControlSet001\Control\Power\PowerSettings\2a737441-1930-4402-8d77-b2bebba308a3\d4e98f31-5ffe-4ce1-be31-1b38b384c009 /v Attributes /t REG_DWORD /d 1'
    )

    foreach ($reg in $regChanges) {
        cmd /c "reg add $reg /f" -Force -ErrorAction Continue
    }

    Write-Host "Default Power Settings Applied." -ForegroundColor Green
    return
}

# Function to Apply the Recommended Privacy Settings
function Set-RecommendedPrivacySettings {
     
     Write-Host "Applying Recommended Privacy Settings . . ."


    $MultilineComment = @"
Windows Registry Editor Version 5.00

;Privacy and Security Settings
;Configure Windows Features - Remove various files folders startup entries and policies 

;Disable Account Info
[HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userAccountInformation]
"Value"="Allow"

;Location Tracking

;0 - Turned off and the User cannot turn it back on - 1 - Turned on but lets the Userchoose whether to use it. default - 2 - Turned on and the Usercan't turn it off.
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy]
"LetAppsAccessLocation"=dword:00000001

;Deny - Turned off and the User cannot turn it back on - Allow - Turned on but lets the Userchoose whether to use it. default
[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\Location]
"Value"="Allow"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location]
"Value"="Allow"

;0 - Location for this device is On;1 - Location for this device is Off
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors]
"DisableLocation"=dword:00000000

[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors]
"DisableLocationScripting"=dword:00000000

[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors]
"DisableSensors"=dword:00000000

[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors]
"DisableWindowsLocationProvider"=dword:00000000

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}]
"SensorPermissionState"=dword:00000001

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}]
"SensorPermissionState"=dword:00000001

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location]
"Value"="Allow"

[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\Location]
"Value"="Allow"

[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location]
"Value"="Allow"

[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location\7EE7776C.LinkedInforWindows_w1wdnht996qgy]
"Value"="Prompt"

[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location\Microsoft.BingNews_8wekyb3d8bbwe]
"Value"="Prompt"

[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location\Microsoft.BingWeather_8wekyb3d8bbwe]
"Value"="Prompt"

[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location\Microsoft.OutlookForWindows_8wekyb3d8bbwe]
"Value"="Prompt"

[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location\Microsoft.StartExperiencesApp_8wekyb3d8bbwe]
"Value"="Prompt"

[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location\Microsoft.Windows.Photos_8wekyb3d8bbwe]
"Value"="Prompt"

[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location\Microsoft.WindowsCamera_8wekyb3d8bbwe]
"Value"="Prompt"

[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location\MSTeams_8wekyb3d8bbwe]
"Value"="Allow"

[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location\NonPackaged]
"Value"="Allow"

;Enables Location Tracking fof Maps
[HKEY_LOCAL_MACHINE\SYSTEM\Maps]
"AutoUpdateEnabled"=dword:00000001

; Remove Share from Context Menu
[-HKEY_LOCAL_MACHINE\SOFTWARE\Classes\*\shellex\ContextMenuHandlers\ModernSharing]
[-HKEY_LOCAL_MACHINE\SOFTWARE\Classes\*\shellex\ContextMenuHandlers\Sharing]
[-HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Drive\shellex\ContextMenuHandlers\Sharing]
[-HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Drive\shellex\PropertySheetHandlers\Sharing]
[-HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Directory\background\shellex\ContextMenuHandlers\Sharing]
[-HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Directory\shellex\ContextMenuHandlers\Sharing]
[-HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Directory\shellex\CopyHookHandlers\Sharing]
[-HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Directory\shellex\PropertySheetHandlers\Sharing]

;App Updates Settings 
;Update apps automatically - 2 - Off - 4 - On
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsStore\WindowsUpdate]
"AutoDownload"=dword:00000004

;Specifies how the System responds when a user tries to install device driver files that are not digitally signed - 00 - Ignore - 01 - Warn - 02 - Block
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Driver Signing]
"Policy"="01"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Metadata]
"PreventDeviceMetadataFromNetwork"=0

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching]
"SearchOrderConfig"=dword:00000002

;Authorize device metadata retrieval from the Internet - Automatically download manufacturers apps and custom icons available for your devices
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Metadata]
"PreventDeviceMetadataFromNetwork"=dword:00000000

;Do you want Windows to download driver Software - 0 - Never - 1 - Always - 2 - Install driver Software if it is not found on my computer
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching]
"SearchOrderConfig"=dword:00000002

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching]
"SearchOrderConfig"=dword:00000002

;Specify search order for device driver source locations
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching]
"DontSearchWindowsUpdate"==dword:00000000

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching]
"DriverUpdateWizardWuSearchEnabled"=dword:00000001

;0 - Enable driver updates in Windows Update - 1 - Disable driver updates in Windows Update
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate]
"ExcludeWUDriversInQualityUpdate"=dword:00000000

;Avoid the driver signing enforcement for EV cert - SHA256 Microsoft Windows signed drivers which is further enforced via Secure Boot
[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control\CI\Policy]
"UpgradedSystem"=dword:00000000

;Windows Error Reporting

;Disable Microsoft Support Diagnostic Tool MSDT
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\ScriptedDiagnosticsProvider\Policy]
"DisableQueryRemoteServer"=dword:00000000

;Disable System Debugger Dr. Watson
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AeDebug]
"UserDebuggerHotKey"=dword:00000000
"Auto"="1"

;1 - Disable Windows Error Reporting WER
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PCHealth\ErrorReporting]
"DoReport"=dword:00000000
[HKCU\Software\Microsoft\Windows\Windows Error Reporting]
"Disabled"=dword:00000001
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\Windows Error Reporting]
"Disabled"=dword:00000001
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting]
"Disabled"=dword:00000001

;1 - Disable WER sending second-level data
[HKCU\Software\Microsoft\Windows\Windows Error Reporting]
"DontSendAdditionalData"=dword:00000001
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\Windows Error Reporting]
"DontSendAdditionalData"=dword:00000001

;1 - Disable WER crash dialogs popups

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PCHealth\ErrorReporting]
"ShowUI"=dword:00000000

[HKCU\Software\Microsoft\Windows\Windows Error Reporting]
"DontShowUI"=dword:00000001

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\Windows Error Reporting]
"DontShowUI"=dword:00000001

;1 - Disable WER logging

[HKCU\Software\Microsoft\Windows\Windows Error Reporting]
"LoggingDisabled"=dword:00000001

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\Windows Error Reporting]
"LoggingDisabled"=dword:00000001

;Windows Session 5 - 5 secs - Delay Chkdsk startup time at OS Boot
[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control\Session Manager]
"AutoChkTimeout"=dword:00000005

;0 - Establishes a standard size file-system cache of approximately 8 MB - 1 - Establishes a large system cache working set that can expand to physical memory minus 4 MB if needed
[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control\Session Manager\Memory Management]
"LargeSystemCache"=dword:00000001

;0 - Drivers and the kernel can be paged to disk as needed - 1 - Drivers and the kernel must remain in physical memory Default
[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control\Session Manager\Memory Management]
"DisablePagingExecutive"=dword:00000001

;0 - Limit the Amount of RAM Locked for I/O Operations - 1 - Override the Automatic value to 1GB Default
[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control\Session Manager\Memory Management]
"IoPageLockLimit"=dword:1073741824"

;0 - IRQ8 Normal Priority - 1 - IRQ8 Higher Priority Default
[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control\PriorityControl]
"IRQ8Priority"=dword:00000001

;0 - Disable Prefetch - 1 - Enable Prefetch when the application starts - 2 - Enable Prefetch when the device starts up - 3 - Enable Prefetch when the application or device starts up
[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control\Session Manager\Memory Management\PrefetchParameters]
"EnablePrefetcher"=dword:00000003

;0 - Disable SuperFetch - 1 - Enable SuperFetch when the application starts up - 2 - Enable SuperFetch when the device starts up - 3 - Enable SuperFetch when the application or device starts up
[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control\Session Manager\Memory Management\PrefetchParameters]
"EnableSuperfetch"=dword:00000003

;0 - Disable It - 1 - Default
[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control\Session Manager\Memory Management\PrefetchParameters]
"SfTracingState"=dword:00000001

[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\FileHistory]
"Disabled"=dword:00000001

;Change plan settings - Change advanced power settings - Hard disk - Turn off hard disk plugged in after
;0 - Never - 4294967295 - max value in seconds
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Power\PowerSettings\6738E2C4-E8A5-4A42-B16A-E040E769756E]
"ACSettingIndex"=dword:00000000

;Enable Hibernation - Enable Fast Startup Hybrid Boot - Enable Sleep and Power Buttons
;Change plan settings - Change advanced power settings - Hard disk - Turn off hard disk on battery after
;0 - Never - 4294967295 - max value in seconds

[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Power\PowerSettings\E69653CA-CF7F-4F05-AA73-CB833FA90AD4]
"DCSettingIndex"=dword:00000000

;0 - Disable Fast Startup for a Full Shutdown - 1 - Enable Fast Startup Hybrid Boot for a Hybrid Shutdown

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control\Session Manager\Power]
"HiberbootEnabled"=dword:00000001

;Choose where you can get apps from - Anywhere - PreferStore - StoreOnly

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer]
"AicEnabled"="Anywhere"

;Programs and Features Devices Autoplay

;0 - Use Autoplay - 1 Disable AutoPlay and AutoRun
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer]
"NoAutorun"=dword:00000000
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer]
"NoDriveTypeAutoRun"=dword:255

;Gaming 
;Disabling Game DVR 

;0 - Disable Game DVR - "Press Win + G to record a clip"
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\GameDVR]
"AllowgameDVR"=dword:00000000

[HKLM\System\ControlSet001\Services\BcastDVRUserService]
"Start"=dword:00000003
[HKLM\System\ControlSet001\Services\xbgm]
"Start"=dword:00000003

;Network and Internet 
;Change adapter options 

[HKEY_LOCAL_MACHINE\System\ControlSet001\Services\Tcpip6\Parameters]
"DisabledComponents"=dword:00000000

;0 - Disable LMHOSTS Lookup on all adapters - 1 - Enable
[HKEY_LOCAL_MACHINE\System\ControlSet001\Services\NetBT\Parameters]
"EnableLMHOSTS"=dword:00000001

;Privacy Settings

;Disable Cortana
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager\default\Experience\AllowCortana]
"value"=dword:00000000
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\SearchCompanion]
"DisableContentFileUpdates"=dword:00000001
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Search]
"AllowCloudSearch"=dword:00000000
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Search]
"AllowCortana"=dword:00000000
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Search]
"AllowCortanaAboveLock"=dword:00000000
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Search]
"AllowSearchToUseLocation"=dword:00000000
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Search]
"DisableWebSearch"=dword:00000001
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Search]
"DoNotUseWebResults"=dword:00000001
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Search]
"ConnectedSearchPrivacy"=dword:00000003
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Search]
"ConnectedSearchUseWeb"=dword:00000000
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Search]
"ConnectedSearchUseWebOverMeteredConnections"=dword:00000000

;Let apps use advertising ID to make ads more interesting to you based on your app usage
[HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo]
"Enabled"=dword:00000000

[HKLM\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo]
"DisabledByGroupPolicy"=dword:00000001

;Account info 

;Let apps access my name picture and other account info - 0 - Default - 1 - Enabled - 2 - Disabled
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy]
"LetAppsAccessAccountInfo"=dword:00000001

;Background apps 

;Let apps run in the background - 0 - Default - 1 - Enabled - 2 - Disabled
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy]
"LetAppsRunInBackground"=dword:00000001

;Calendar .

;Let Windows apps access contacts - 0 - Default - 1 - Enabled - 2 - Disabled
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy]
"LetAppsAccessCalendar"=dword:00000001

;Call history .

;Let apps access my call history - 0 - Default - 1 - Enabled - 2 - Disabled
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy]
"LetAppsAccessCallHistory"=dword:00000000

;Camera 

;Let apps use my camera - 0 - Default - 1 - Enabled - 2 - Disabled
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy]
"LetAppsAccessCamera"=dword:00000000
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy]
"LetAppsAccessCamera_ForceAllowTheseApps"=dword:00000000
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy]
"LetAppsAccessCamera_ForceDenyTheseApps"=dword:00000000
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy]
"LetAppsAccessCamera_UserInControlOfTheseApps"=dword:00000000

;Contacts .

;Let Windows apps access contacts - 0 - Default - 1 - Enabled - 2 - Disabled
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy]
"LetAppsAccessContacts"=dword:00000002

;Email 

;Let apps access and send email - 0 - Default - 1 - Enabled - 2 - Disabled
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy]
"LetAppsAccessEmail"=dword:00000001

;Feedback and diagnostics .

;Diagnostic and usage data - Select how much data you send to Microsoft - 0 - Security Not aplicable on Home/Pro it resets to Basic - 1 - Basic - 2 - Enhanced Hidden - 3 - Full

;Disables Telemetry
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection]
"AllowTelemetry"=dword:00000000

;Disables Telemetry and Feedback Notifications
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DataCollection]
"AllowTelemetry"=dword:00000000

"DoNotShowFeedbackNotifications"=dword:00000001
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection]
"AllowTelemetry"=dword:00000001

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels\Microsoft-Windows-Application-Experience/Program-Telemetry]
"Enabled"=dword:00000000

[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DataCollection]
"AllowTelemetry"=dword:00000000

[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DataCollection]
"DoNotShowFeedbackNotifications"=dword:00000001
0;1 - Do not let Microsoft provide more tailored experiences with relevant tips and recommendations by using your diagnostic data
[HKCU\Software\Microsoft\Windows\CurrentVersion\Privacy]
"TailoredExperiencesWithDiagnosticDataEnabled"=dword:00000000

;Feedback Frequency - Windows should ask for my feedback: 0 - Never - Removed - Automatically

[HKCU\Software\Microsoft\Siuf\Rules]
"NumberOfSIUFInPeriod"=dword:00000000

[HKCU\Software\Microsoft\Siuf\Rules]
"PeriodInNanoSeconds"=dword:00000000

;General 

;Do not Let apps use advertising ID to make ads more interesting to you based on your app usage
[HKCU\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo]
"Enabled"=dword:00000000
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo]
"Enabled"=dword:00000000
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo]
"DisabledByGroupPolicy"=dword:00000001

;Messaging 

;Let apps read or send messages text or MMS - 0 - Default - 1 - Enabled - 2 - Disabled
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy]
"LetAppsAccessMessaging"=dword:00000002

;Microphone 

;Let apps use my microphone - 0 - Default - 1 - Enabled - 2 - Disabled
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy]
"LetAppsAccessMicrophone"=dword:00000000

;Notifications 

;Let apps access my notifications - 0 - Default - 1 - Enabled - 2 - Disabled
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy]
"LetAppsAccessNotifications"=dword:00000000

;Other devices 

;Let apps automatically share and sync info with wireless devices that don't explicitly pair with your PC tablet or phone - 0 - Default - 1 - Enabled - 2 - Disabled
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy]
LetAppsSyncWithDevices=dword:00000002
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy]
"LetAppsAccessTrustedDevices"=dword:00000002

;Speech inking and typing

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Input]
"InputServiceEnabled"=dword:00000000
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Input]
"InputServiceEnabledForCCI"=dword:00000000
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\InputPersonalization]
"AllowInputPersonalization"=dword:00000000
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\InputPersonalization]
"RestrictImplicitInkCollection"=dword:00000001
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\InputPersonalization]
"RestrictImplicitTextCollection"=dword:00000001
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\HandwritingErrorReports]
"PreventHandwritingErrorReports"=dword:00000001
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\TabletPC]
"PreventHandwritingDataSharing"=dword:00000001

;Radios 

;Let apps control radios - 0 - Default - 1 - Enabled - 2 - Disabled
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy]
"LetAppsAccessRadios"=dword:00000002

;Tasks 

;Let apps access tasks - 0 - Default - 1 - Enabled - 2 - Disabled
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy]
"LetAppsAccessTasks"=dword:00000002

;System Settings Security

;0 - Disable Windows Script Host WSH for all users 1 - Enable Windows Script Host WSH for all users me.
[HKLM\SOFTWARE\Microsoft\Windows Script Host\Settings]
"Enabled"=dword:00000001

;Digest Security Provider is disabled by default but malware can enable it to recover the plain text passwords from the system’s memory
[HKLM\System\ControlSet001\Control\SecurityProviders\WDigest]
"UseLogonCredential"=dword:00000000

;No-one will be a member of the built-in group although it will still be visible in the Object Picker - 1 - all users logging on to a session on the server will be made a member of the TERMINAL SERVER USER group
[HKLM\System\ControlSet001\Control\Terminal Server]
"TSUserEnabled"=dword:00000000

;Remote Settings - Disable Remote Assistance
[HKEY_LOCAL_MACHINE\System\ControlSet001\Control\Remote Assistance]
"fAllowToGetHelp"=dword:00000000
[HKEY_LOCAL_MACHINE\System\ControlSet001\Control\Remote Assistance]
"fAllowFullControl"=dword:00000000
[HKLM\Software\Policies\Microsoft\Windows\WinRM\Service\WinRS]
"AllowRemoteShellAccess"=dword:00000000
[HKLM\Software\Policies\Microsoft\Windows NT\Terminal Services]
"fAllowToGetHelp"=dword:00000000
[HKLM\Software\Policies\Microsoft\Windows NT\Terminal Services]
"fAllowUnsolicited"=dword:00000000
[HKLM\Software\Policies\Microsoft\Windows NT\Terminal Services]
"fAllowUnsolicitedFullControl"=dword:00000000
[HKLM\Software\Policies\Microsoft\Windows NT\Terminal Services]
"fDenyTSConnections"=dword:00000001
[HKLM\Software\Policies\Microsoft\Windows NT\Terminal Services]
"TSAppCompat"=dword:00000000
[HKLM\Software\Policies\Microsoft\Windows NT\Terminal Services]
"TSEnabled"=dword:00000000
[HKLM\Software\Policies\Microsoft\Windows NT\Terminal Services]
"TSUserEnabled"=dword:00000000

;Advanced system settings - Performance - Advanced - Processor Scheduling
;0 - Foreground and background applications equally responsive - 1 - Foreground application more responsive than background - 2 - Best foreground application response time Default
;38 - Adjust for best performance of Programs - 24 - Adjust for best performance of Background Services

[HKEY_LOCAL_MACHINE\System\ControlSet001\Control\PriorityControl]
"Win32PrioritySeparation"=dword:00000038

;Advanced system settings - Startup and Recovery
;1 - Automatically Restart on System Failure
[HKEY_LOCAL_MACHINE\System\ControlSet001\Control\CrashControl]
"AutoReboot"=dword:00000001

;Disables Activity History
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\System]
"EnableActivityFeed"=dword:00000000
"PublishUserActivities"=dword:00000000
"UploadUserActivities"=dword:00000000

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\lfsvc\Service\Configuration]
"Status"=dword:00000000

;Disables Windows Ink Workspace
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\WindowsInkWorkspace]
"AllowWindowsInkWorkspace"=dword:00000000

;Disables the Advertising ID for All Users
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo]
"DisabledByGroupPolicy"=dword:00000001
"@
    # Write the registry changes to a file and silently import it using regedit
    Set-Content -Path "$env:TEMP\Recommended_Privacy_Settings.reg" -Value $MultilineComment -Force
    Start-Process -FilePath "regedit.exe" -ArgumentList "/S `"$env:TEMP\Recommended_Privacy_Settings.reg`"" -NoNewWindow -Wait
        Write-Host "Recommended Privacy Settings Applied." -ForegroundColor Green
    }

# Start of Windows Update Functions
function Set-RecommendedUpdateSettings {

        Write-Host "Applying Recommended Windows Update Settings . . ."

    $MultilineComment = @"
Windows Registry Editor Version 5.00

; --Windows Update Settings--

; Disable Automatic Updates (Only Check for Updates Manually)
; Notify Before Downloading and Installing Updates
; Enable Notifications for Security Updates (Auto-Download)

[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU]
"NoAutoUpdate"=dword:00000000
"AUOptions"=dword:00000002
"AutoInstallMinorUpdates"=dword:00000000

; ................................... Windows update Options ............................. 

; Change active hours (18 hours) 8am to 17am - Windows Updates will not automatically restart your device during active hours 
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings]
"ActiveHoursStart"=dword:00000008

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings]
"ActiveHoursEnd"=dword:00000019

; Restart options - 1 - We'll show a reminder when we're going to restart. 
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings]
"RestartNotificationsAllowed"=dword:00000001

rem 0 - Do not deactivate Malicious Software Removal Tool offered via Windows Updates (MRT) 
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\MRT]
"DontOfferThroughWUAU"=dword:00000000

; . . . . . . . . . . . . . . . . . . Advanced options . . . . . . . . . . . . . . . . . . 

; how updates are delivered 
; 0 - Turns off Delivery Optimization 
; 1 - Gets or sends updates and apps to PCs on the same NAT only 
; 2 - Gets or sends updates and apps to PCs on the same local network domain
; 3 - Gets or sends updates and apps to PCs on the Internet 
; 99 - Simple download mode with no peering 
; 100 - Use BITS instead of Windows Update Delivery Optimization 
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config]
"DODownloadMode"=dword:00000001
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization]
"DODownloadMode"=dword:00000001
; Update apps automatically / 2 - Off / 4 - On 
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsStore\WindowsUpdate]
"AutoDownload"=dword:00000004

; Disables allowing downloads from other PCs (Delivery Optimization)
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization]
"DODownloadMode"=dword:00000000
"@
    Set-Content -Path "$env:TEMP\Recommended_Windows_Update_Settings.reg" -Value $MultilineComment -Force
    # import reg file
    Regedit.exe /S "$env:TEMP\Recommended_Windows_Update_Settings.reg"
    
        Write-Host "Recommended Windows Update Settings Applied." -ForegroundColor Green
}
# End of Windows Update Functions

# Start of Registry Optimizations
# Recommended Local Machine Registry Settings
function Set-RecommendedHKLMRegistry {
	
	        Write-Host "Applying Recommended Local Machine Registry Settings . . ."
    # Create Registry Keys
    $MultilineComment = @"
Windows Registry Editor Version 5.00

; Adds Take Ownership to the Right Click Context Menu for All Users
                
[-HKEY_CLASSES_ROOT\*\shell\TakeOwnership]
[-HKEY_CLASSES_ROOT\*\shell\runas]
          
[HKEY_CLASSES_ROOT\*\shell\TakeOwnership]
@="Take Ownership"
"Extended"=-
"HasLUAShield"=""
"NoWorkingDirectory"=""
"NeverDefault"=""
          
[HKEY_CLASSES_ROOT\*\shell\TakeOwnership\command]
@="powershell -windowstyle hidden -command \"Start-Process cmd -ArgumentList '/c takeown /f \\\"%1\\\" && icacls \\\"%1\\\" /grant *S-1-3-4:F /t /c /l & pause' -Verb runAs\""
"IsolatedCommand"= "powershell -windowstyle hidden -command \"Start-Process cmd -ArgumentList '/c takeown /f \\\"%1\\\" && icacls \\\"%1\\\" /grant *S-1-3-4:F /t /c /l & pause' -Verb runAs\""
               
[HKEY_CLASSES_ROOT\Directory\shell\TakeOwnership]
@="Take Ownership"
"AppliesTo"="NOT (System.ItemPathDisplay:=\"C:\\Users\" OR System.ItemPathDisplay:=\"C:\\ProgramData\" OR System.ItemPathDisplay:=\"C:\\Windows\" OR System.ItemPathDisplay:=\"C:\\Windows\\System32\" OR System.ItemPathDisplay:=\"C:\\Program Files\" OR System.ItemPathDisplay:=\"C:\\Program Files (x86)\")"
"Extended"=-
"HasLUAShield"=""
"NoWorkingDirectory"=""
"Position"="middle"
          
[HKEY_CLASSES_ROOT\Directory\shell\TakeOwnership\command]
@="powershell -windowstyle hidden -command \" = ( | choice).Substring(1,1); Start-Process cmd -ArgumentList ('/c takeown /f \\\"%1\\\" /r /d ' +  + ' && icacls \\\"%1\\\" /grant *S-1-3-4:F /t /c /l /q & pause') -Verb runAs\""
"IsolatedCommand"="powershell -windowstyle hidden -command \" = ( | choice).Substring(1,1); Start-Process cmd -ArgumentList ('/c takeown /f \\\"%1\\\" /r /d ' +  + ' && icacls \\\"%1\\\" /grant *S-1-3-4:F /t /c /l /q & pause') -Verb runAs\""
                
[HKEY_CLASSES_ROOT\Drive\shell\runas]
@="Take Ownership"
"Extended"=-
"HasLUAShield"=""
"NoWorkingDirectory"=""
"Position"="middle"
"AppliesTo"="NOT (System.ItemPathDisplay:=\"C:\\\")"
          
[HKEY_CLASSES_ROOT\Drive\shell\runas\command]
@="cmd.exe /c takeown /f \"%1\\\" /r /d y && icacls \"%1\\\" /grant *S-1-3-4:F /t /c & Pause"
"IsolatedCommand"="cmd.exe /c takeown /f \"%1\\\" /r /d y && icacls \"%1\\\" /grant *S-1-3-4:F /t /c & Pause"

; --Application and Feature Restrictions--

; Disable Windows Copilot system-wide
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot]
"TurnOffWindowsCopilot"=dword:00000001

[HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\WindowsAI]
"DisableAIDataAnalysis"=dword:00000001
"AllowRecallEnablement"=dword:00000000
"DisableClickToDo"=dword:00000001
"TurnOffSavingSnapshots"=dword:00000001
"DisableSettingsAgent"=dword:00000001

[HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\WindowsCopilot]
"TurnOffWindowsCopilot"=dword:00000001

[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot]
"TurnOffWindowsCopilot"=dword:00000001

[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Policies\Microsoft\Windows\WindowsCopilot]
"TurnOffWindowsCopilot"=dword:00000001

[HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\WindowsAI]
"DisableAIDataAnalysis"=dword:00000001
"AllowRecallEnablement"=dword:00000000
"DisableClickToDo"=dword:00000001
"TurnOffSavingSnapshots"=dword:00000001
"DisableSettingsAgent"=dword:00000001

[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Policies\Microsoft\Windows\WindowsAI]
"DisableAIDataAnalysis"=dword:00000001
"AllowRecallEnablement"=dword:00000000
"DisableClickToDo"=dword:00000001
"TurnOffSavingSnapshots"=dword:00000001
"DisableSettingsAgent"=dword:00000001

[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Policies\Microsoft\Edge]
"CopilotCDPPageContext"=dword:00000000
"CopilotPageContext"=dword:00000000
"HubsSidebarEnabled"=dword:00000001
"EdgeEntraCopilotPageContext"=dword:00000000
"Microsoft365CopilotChatIconEnabled"=dword:00000000
"EdgeHistoryAISearchEnabled"=dword:00000000
"ComposeInlineEnabled"=dword:00000000
"GenAILocalFoundationalModelSettings"=dword:00000000

; Prevents Dev Home Installation
[-HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsUpdate\Orchestrator\UScheduler_Oobe\DevHomeUpdate]

; Prevents New Outlook for Windows Installation
[-HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsUpdate\Orchestrator\UScheduler_Oobe\OutlookUpdate]

; Prevents Chat Auto Installation and Removes Chat Icon
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Communications]
"ConfigureChatAutoInstall"=dword:00000000

[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Chat]
"ChatIcon"=dword:00000003

; Disables Bitlocker Auto Encryption on Windows 11 24H2 and Onwards
[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control\BitLocker]
"PreventDeviceEncryption"=dword:00000001

[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\EnhancedStorageDevices]
"TCGSecurityActivationDisabled"=dword:00000001

; Disables Cortana
[HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\Windows Search]
"AllowCortana"=dword:00000000

; Set Registry Keys to Disable Wifi-Sense
[HKEY_LOCAL_MACHINE\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting]
"Value"=dword:00000000

[HKEY_LOCAL_MACHINE\Software\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots]
"Value"=dword:00000000

; Disable Tablet Mode
; Always go to desktop mode on sign-in
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\ImmersiveShell]
"TabletMode"=dword:00000000
"SignInMode"=dword:00000001

; Disable Xbox GameDVR
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\GameDVR]
"AllowGameDVR"=dword:00000000

; Enables OneDrive Automatic Backups of Important Folders (Documents, Pictures etc.)
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\OneDrive]
"KFMBlockOptIn"=-

; Disables the "Push To Install" feature in Windows
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\PushToInstall]
"DisablePushToInstall"=dword:00000000

; Enables Windows Consumer Features Like App Promotions etc.
; Enables Consumer Account State Content
; Enables Cloud Optimized Content
[HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\CloudContent]
"DisableWindowsConsumerFeatures"=-
"DisableConsumerAccountStateContent"=-
"DisableCloudOptimizedContent"=-

; Blocks the "Allow my organization to manage my device" and "No, sign in to this app only" pop-up message
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WorkplaceJoin]
"BlockAADWorkplaceJoin"=dword:00000001

; --Start Menu Customization--
; Removes All Pinned Apps from the Start Menu to Clean it Up
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager\current\device\Start]
"ConfigureStartPins"="{ \"pinnedList\": [] }"
"ConfigureStartPins_ProviderSet"=dword:00000001
"ConfigureStartPins_WinningProvider"="B5292708-1619-419B-9923-E5D9F3925E71"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager\providers\B5292708-1619-419B-9923-E5D9F3925E71\default\Device\Start]
"ConfigureStartPins"="{ \"pinnedList\": [] }"
"ConfigureStartPins_LastWrite"=dword:00000001

; --File System Settings--
; Enable Long File Paths with Up to 32,767 Characters
[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control\FileSystem]
"LongPathsEnabled"=dword:00000001

; --Multimedia and Gaming Performance--
; Gives Multimedia Applications like Games and Video Editing a Higher Priority
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile]
"SystemResponsiveness"=dword:00000000
"NetworkThrottlingIndex"=dword:0000000a

; Gives Graphics Cards a Higher Priority for Gaming
; Gives the CPU a Higher Priority for Gaming
; Gives Games a higher priority in the system's scheduling
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games]
"GPU Priority"=dword:00000008
"Priority"=dword:00000006
"Scheduling Category"="High"

; disable startup sound
[HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\BootAnimation]
"DisableStartupSound"=dword:00000001

[HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\EditionOverrides]
"UserSetting_DisableStartupSound"=dword:00000001

; disable device installation settings
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Metadata]
"PreventDeviceMetadataFromNetwork"=dword:00000001

; NETWORK AND INTERNET
; disable allow other network users to control or disable the shared internet connection
[HKEY_LOCAL_MACHINE\System\ControlSet001\Control\Network\SharedAccessConnection]
"EnableControl"=dword:00000000

; SYSTEM AND SECURITY
; adjust for best performance of programs
[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control\PriorityControl]
"Win32PrioritySeparation"=dword:00000026

; disable remote assistance
[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control\Remote Assistance]
"fAllowToGetHelp"=dword:00000000

; TROUBLESHOOTING
; disable automatic maintenance
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance]
"MaintenanceDisabled"=dword:00000001

; SECURITY AND MAINTENANCE
; disable report problems
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting]
"Disabled"=dword:00000001

; ACCOUNTS
; disable use my sign in info after restart
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System]
"DisableAutomaticRestartSignOn"=dword:00000001

; APPS
; disable archive apps 
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Appx]
"AllowAutomaticAppArchiving"=dword:00000000

; PERSONALIZATION
; Hides the Meet Now Button on the Taskbar
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer]
"HideSCAMeetNow"=dword:00000001
"NoStartMenuMFUprogramsList"=-
"NoInstrumentation"=-

; remove windows widgets from taskbar
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Dsh] 
"AllowNewsAndInterests"=dword:00000000

; remove news and interests from Taskbar
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds]
"EnableFeeds"=dword:00000000

; SYSTEM
; turn on hardware accelerated gpu scheduling
[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control\GraphicsDrivers]
"HwSchMode"=dword:00000002

; disable storage sense
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\StorageSense]
"AllowStorageSenseGlobal"=dword:00000001

; --OTHER--
; Update Microsoft Store apps automatically
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\WindowsStore]
"AutoDownload"=dword:00000004

; UWP APPS
; disable background apps
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy]
"LetAppsRunInBackground"=dword:00000002

; disable widgets
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager\default\NewsAndInterests\AllowNewsAndInterests]
"value"=dword:00000001

; NVIDIA
; enable old nvidia sharpening
[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\nvlddmkm\FTS]
"EnableGR535"=dword:00000001

; OTHER
; remove 3d objects
[-HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}]
[-HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}]

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{f874310e-b6b7-47dc-bc84-b9e6b38f5903}]
@="CLSID_MSGraphHomeFolder"
"HiddenByDefault"=-

[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{f874310e-b6b7-47dc-bc84-b9e6b38f5903}]
@="CLSID_MSGraphHomeFolder"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{088e3905-0323-4b02-9826-5d99428e115f}]
"HiddenByDefault"=-

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{1CF1260C-4DD0-4ebb-811F-33C572699FDE}]
"HiddenByDefault"=-

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{24ad3ad4-a569-4530-98e1-ab02f9417aa8}]
"HiddenByDefault"=-

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{374DE290-123F-4565-9164-39C4925E467B}]
"HiddenByDefault"=-

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3ADD1653-EB32-4cb0-BBD7-DFA0ABB5ACCA}]
"HiddenByDefault"=-

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}]
"HiddenByDefault"=-

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A0953C92-50DC-43bf-BE83-3742FED03C9C}]
"HiddenByDefault"=-

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A8CDFF1C-4878-43be-B5FD-F8091C1C60D0}]
"HiddenByDefault"=-

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}]
"HiddenByDefault"=-

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{d3162b92-9365-467a-956b-92703aca08af}]
"HiddenByDefault"=-

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a}]
"HiddenByDefault"=-

[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{088e3905-0323-4b02-9826-5d99428e115f}]
"HiddenByDefault"=-

[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{1CF1260C-4DD0-4ebb-811F-33C572699FDE}]
"HiddenByDefault"=-

[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{24ad3ad4-a569-4530-98e1-ab02f9417aa8}]
"HiddenByDefault"=-

[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{374DE290-123F-4565-9164-39C4925E467B}]
"HiddenByDefault"=-

[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3ADD1653-EB32-4cb0-BBD7-DFA0ABB5ACCA}]
"HiddenByDefault"=-

[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}]
"HiddenByDefault"=-

[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A0953C92-50DC-43bf-BE83-3742FED03C9C}]
"HiddenByDefault"=-

[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A8CDFF1C-4878-43be-B5FD-F8091C1C60D0}]
"HiddenByDefault"=-

[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}]
"HiddenByDefault"=-

[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{d3162b92-9365-467a-956b-92703aca08af}]
"HiddenByDefault"=-

[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a}]
"HiddenByDefault"=-

[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Policies\Microsoft\Windows\PowerShell]
EnableScripts=1

[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Policies\Microsoft\Windows\PowerShell]
ExecutionPolicy=Unrestricted'

[HKEY_USERS\.DEFAULT\Control Panel\Mouse]
"MouseSpeed"="1"
"MouseThreshold1"="6"
"MouseThreshold2"="10"
"@
    Set-Content -Path "$env:TEMP\Optimize_LocalMachine_Registry.reg" -Value $MultilineComment -Force
    # edit reg file
    $path = "$env:TEMP\Optimize_LocalMachine_Registry.reg"
    (Get-Content $path) -replace "\?", "$" | Out-File $path
    # import reg file
    Regedit.exe /S "$env:TEMP\Optimize_LocalMachine_Registry.reg"
    Write-Host "Recommended Local Machine Registry Settings Applied." -ForegroundColor Green
    
}

# Default Local Machine Registry Settings
function Set-DefaultHKLMRegistry {
		        Write-Host "Restoring Recommended Local Machine Registry Settings . . ."
    # create reg file
    $MultilineComment = @"
Windows Registry Editor Version 5.00

; --Revert Application and Feature Restrictions--

; Allows Dev Home Installation
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsUpdate\Orchestrator\UScheduler_Oobe\DevHomeUpdate]
@=""

; Allows New Outlook for Windows Installation
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsUpdate\Orchestrator\UScheduler_Oobe\OutlookUpdate]
@=""

; Reverts Chat Auto Installation and Restores Chat Icon
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Communications]
"ConfigureChatAutoInstall"=dword:00000001

[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Chat]
"ChatIcon"=dword:00000001

; Enables News and Interests
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Dsh]
"AllowNewsAndInterests"=-

; Enables BitLocker Auto Encryption on Windows 11 24H2 and Onwards
[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control\BitLocker]
"PreventDeviceEncryption"=-

[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\EnhancedStorageDevices]
"TCGSecurityActivationDisabled"=-

; Enables Cortana
[HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\Windows Search]
"AllowCortana"=-

; Shows the Meet Now Button on the Taskbar
; Shows Recently Added Apps in Start Menu
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer]
"HideSCAMeetNow"=-

; Re-enables WiFi-Sense
[HKEY_LOCAL_MACHINE\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting]
"Value"=dword:00000001

[HKEY_LOCAL_MACHINE\Software\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots]
"Value"=dword:00000001

; Enables Tablet Mode
; Default Sign-In Mode
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\ImmersiveShell]
"TabletMode"=dword:00000001
"SignInMode"=dword:00000000

; Enables Xbox GameDVR
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\GameDVR]
"AllowGameDVR"=-

; Enables OneDrive Automatic Backups of Important Folders (Documents, Pictures etc.)
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\OneDrive]
"KFMBlockOptIn"=-

; Enables "Push To Install" feature in Windows
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\PushToInstall]
"DisablePushToInstall"=-

; Enables Windows Consumer Features Like App Promotions etc.
; Enables Consumer Account State Content
; Enables Cloud Optimized Content
[HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\CloudContent]
"DisableWindowsConsumerFeatures"=-
"DisableConsumerAccountStateContent"=-
"DisableCloudOptimizedContent"=-

; Unblocks "Allow my organization to manage my device" pop-up message
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WorkplaceJoin]
"BlockAADWorkplaceJoin"=-

; --Revert Start Menu Customization--

; Restores Default Pinned Apps to the Start Menu
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager\current\device\Start]
"ConfigureStartPins"=-
"ConfigureStartPins_ProviderSet"=-
"ConfigureStartPins_WinningProvider"=-

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager\providers\B5292708-1619-419B-9923-E5D9F3925E71\default\Device\Start]
"ConfigureStartPins"=-
"ConfigureStartPins_LastWrite"=-

; --Revert File System Settings--

; Revert Long File Paths to Default (Disabled)
[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control\FileSystem]
"LongPathsEnabled"=dword:00000000

; --Revert Multimedia and Gaming Performance--

; Reverts Multimedia Applications' System Responsiveness and Network Throttling Index to Default Values
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile]
"SystemResponsiveness"=dword:00000014
"NetworkThrottlingIndex"=dword:ffffffff

; --Revert Gaming Performance--

; Reverts Graphics Cards Priority for Gaming to Default
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games]
"GPU Priority"=dword:00000002 ; Default value is 2

; Reverts CPU Priority for Gaming to Default
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games]
"Priority"=dword:00000002 ; Default value is 2

; Reverts Games Scheduling Category to Default
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games]
"Scheduling Category"="Medium" ; Default value is "Medium"

; Removes "Take Ownership" from Context Menu
[-HKEY_CLASSES_ROOT\*\shell\TakeOwnership]

[-HKEY_CLASSES_ROOT\*\shell\runas]

[-HKEY_CLASSES_ROOT\Directory\shell\TakeOwnership]

[-HKEY_CLASSES_ROOT\Drive\shell\runas]

; HARDWARE AND SOUND
; lock
[-HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings]

; sleep
[-HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings]

; startup sound
[HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\BootAnimation]
"DisableStartupSound"=dword:00000000

[HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\EditionOverrides]
"UserSetting_DisableStartupSound"=dword:00000000

; device installation settings
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Metadata]
"PreventDeviceMetadataFromNetwork"=dword:00000000

; NETWORK AND INTERNET
; allow other network users to control or disable the shared internet connection
[HKEY_LOCAL_MACHINE\System\ControlSet001\Control\Network\SharedAccessConnection]
"EnableControl"=dword:00000001

; SYSTEM AND SECURITY
; revert adjust for best performance of programs
[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control\PriorityControl]
"Win32PrioritySeparation"=dword:00000002

; remote assistance
[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control\Remote Assistance]
"fAllowToGetHelp"=dword:00000001

; TROUBLESHOOTING
; automatic maintenance
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance]
"MaintenanceDisabled"=-

; SECURITY AND MAINTENANCE
; report problems
[-HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting]

; ACCOUNTS
; use my sign in info after restart
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System]
"DisableAutomaticRestartSignOn"=-

; APPS
; archive apps
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Appx]
"AllowAutomaticAppArchiving"=-

; PERSONALIZATION

[-HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize]

; don't hide most used list in start menu
; show recently added apps
[-HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Explorer]

; news and interests
[-HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds]

; SYSTEM
; hardware accelerated gpu scheduling
[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control\GraphicsDrivers]
"HwSchMode"=-

; storage sense
[-HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\StorageSense]

; --OTHER--
; Enable update Microsoft Store apps automatically
[-HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\WindowsStore]

; --CAN'T DO NATIVELY--
; UWP APPS
; background apps
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy]
"LetAppsRunInBackground"=-

; widgets
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager\default\NewsAndInterests\AllowNewsAndInterests]
"value"=dword:00000001

; NVIDIA
; old nvidia sharpening
[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\nvlddmkm\FTS]
"EnableGR535"=dword:00000001

; OTHER
; 3d objects
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}]
[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}]

; Restores Home Folder
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{f874310e-b6b7-47dc-bc84-b9e6b38f5903}]
@="CLSID_MSGraphHomeFolder"

[HKEY_USERS\.DEFAULT\Control Panel\Mouse]
"MouseSpeed"="1"
"MouseThreshold1"="6"
"MouseThreshold2"="10"
"@
    Set-Content -Path "$env:TEMP\Restore_LocalMachine_Registry.reg" -Value $MultilineComment -Force
    # edit reg file
    $path = "$env:TEMP\Restore_LocalMachine_Registry.reg"
                (Get-Content $path) -replace "\?", "$" | Out-File $path
    # import reg file
    Regedit.exe /S "$env:TEMP\Restore_LocalMachine_Registry.reg"
    
    Write-Host "Default Local Machine Registry Settings Applied." -ForegroundColor Green
    
}

#Optimizing User Registry
function Set-RecommendedHKCURegistry {
    
    Write-Host "Optimizing User Registry . . ."

    # Set Wallpaper
    $WallpaperPath = "C:\Windows\Web\4K\Wallpaper\Windows\img0_1920x1200.jpg"
    $defaultWallpaperPath = "C:\Windows\Web\4K\Wallpaper\Windows\img0_1920x1200.jpg"
    $darkModeWallpaperPath = "C:\Windows\Web\4K\Wallpaper\Windows\img19_1920x1200.jpg"

    function Set-Wallpaper ($wallpaperPath) {
        reg.exe add "HKEY_CURRENT_USER\Control Panel\Desktop" /v Wallpaper="$wallpaperPath" /f | Out-Null
        # Notify the system of the change
        rundll32.exe user32.dll, UpdatePerUserSystemParameters
    }

    # Check Windows version
    $windowsVersion = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").CurrentBuild

    # Apply appropriate wallpaper based on Windows version or existence of dark mode wallpaper
    if ($windowsVersion -ge 22000) {
        # Assuming Windows 11 starts at build 22000
        if (Test-Path $darkModeWallpaperPath) {
            Set-Wallpaper -wallpaperPath $darkModeWallpaperPath
        }
    }
    else {
        # Apply default wallpaper for Windows 11
        Set-Wallpaper -wallpaperPath $defaultWallpaperPath
    }

    $MultilineComment = @"
Windows Registry Editor Version 5.00

; EASE OF ACCESS
; disable narrator
[HKEY_CURRENT_USER\Software\Microsoft\Narrator\NoRoam]
"DuckAudio"=dword:00000000
"WinEnterLaunchEnabled"=dword:00000000
"ScriptingEnabled"=dword:00000000
"OnlineServicesEnabled"=dword:00000000
"EchoToggleKeys"=dword:00000000

; disable narrator settings
[HKEY_CURRENT_USER\Software\Microsoft\Narrator]
"NarratorCursorHighlight"=dword:00000000
"CoupleNarratorCursorKeyboard"=dword:00000000
"IntonationPause"=dword:00000000
"ReadHints"=dword:00000000
"ErrorNotificationType"=dword:00000000
"EchoChars"=dword:00000000
"EchoWords"=dword:00000000

[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Narrator\NarratorHome]
"MinimizeType"=dword:00000000
"AutoStart"=dword:00000000

; disable ease of access settings 
[HKEY_CURRENT_USER\Software\Microsoft\Ease of Access]
"selfvoice"=dword:00000000
"selfscan"=dword:00000000

[HKEY_CURRENT_USER\Control Panel\Accessibility]
"Sound on Activation"=dword:00000000
"Warning Sounds"=dword:00000000

[HKEY_CURRENT_USER\Control Panel\Accessibility\HighContrast]
"Flags"="4194"

[HKEY_CURRENT_USER\Control Panel\Accessibility\Keyboard Response]
"Flags"="2"
"AutoRepeatRate"="0"
"AutoRepeatDelay"="0"

[HKEY_CURRENT_USER\Control Panel\Accessibility\MouseKeys]
"Flags"="130"
"MaximumSpeed"="39"
"TimeToMaximumSpeed"="3000"

[HKEY_CURRENT_USER\Control Panel\Accessibility\StickyKeys]
"Flags"="2"

[HKEY_CURRENT_USER\Control Panel\Accessibility\ToggleKeys]
"Flags"="34"

[HKEY_CURRENT_USER\Control Panel\Accessibility\SoundSentry]
"Flags"="0"
"FSTextEffect"="0"
"TextEffect"="0"
"WindowsEffect"="0"

[HKEY_CURRENT_USER\Control Panel\Accessibility\SlateLaunch]
"ATapp"=""
"LaunchAT"=dword:00000000

; CLOCK AND REGION
; disable notify me when the clock changes
[HKEY_CURRENT_USER\Control Panel\TimeDate]
"DstNotification"=dword:00000000

; APPEARANCE AND PERSONALIZATION
; open file explorer to this pc
; show file name extensions
; disable display file size information in folder tips
; disable show pop-up description for folder and desktop items
; disable show preview handlers in preview pane
; disable show status bar
; disable show sync provider notifications
; disable use sharing wizard
; disable animations in the taskbar
; enable show thumbnails instead of icons
; disable show translucent selection rectangle
; disable use drop shadows for icon labels on the desktop
; more pins personalization start
; disable show account-related notifications
; disable show recently opened items in start, jump lists and file explorer
; left taskbar alignment
; remove chat from taskbar
; remove task view from taskbar
; remove copilot from taskbar
; disable show recommendations for tips shortcuts new apps and more
; disable share any window from my taskbar
; disable snap window settings - SnapAssist to JointResize Entries
; alt tab open windows only
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
"LaunchTo"=dword:00000001
"HideFileExt"=dword:00000000
"FolderContentsInfoTip"=dword:00000000
"ShowInfoTip"=dword:00000000
"ShowPreviewHandlers"=dword:00000000
"ShowStatusBar"=dword:00000000
"ShowSyncProviderNotifications"=dword:00000000
"SharingWizardOn"=dword:00000000
"TaskbarAnimations"=dword:0
"IconsOnly"=dword:0
"ListviewAlphaSelect"=dword:0
"ListviewShadow"=dword:0
"Start_Layout"=dword:00000001
"Start_AccountNotifications"=dword:00000000
"Start_TrackDocs"=dword:00000000 
"TaskbarAl"=dword:00000000
"TaskbarMn"=dword:00000000
"ShowTaskViewButton"=dword:00000000
"ShowCopilotButton"=dword:00000000
"Start_IrisRecommendations"=dword:00000000
"TaskbarSn"=dword:00000000
"SnapAssist"=dword:00000000
"DITest"=dword:00000000
"EnableSnapBar"=dword:00000000
"EnableTaskGroups"=dword:00000000
"EnableSnapAssistFlyout"=dword:00000000
"SnapFill"=dword:00000000
"JointResize"=dword:00000000
"MultiTaskingAltTabFilter"=dword:00000003

; hide frequent folders in quick access
; disable show files from office.com
; show all taskbar icons on Windows 11
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer]
"ShowFrequent"=dword:00000000
"ShowCloudFilesInQuickAccess"=dword:00000000
"EnableAutoTray"=dword:00000000

; enable display full path in the title bar
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\CabinetState]
"FullPath"=dword:00000001

; HARDWARE AND SOUND
; sound communications do nothing
[HKEY_CURRENT_USER\Software\Microsoft\Multimedia\Audio]
"UserDuckingPreference"=dword:00000003

; Enable enhance pointer precision
; mouse fix (accel with epp on)
[HKEY_CURRENT_USER\Control Panel\Mouse]
"MouseSpeed"="1"
"MouseThreshold1"="6"
"MouseThreshold2"="10"
"MouseSensitivity"="10"
"SmoothMouseXCurve"=hex:\
	00,00,00,00,00,00,00,00,\
	C0,CC,0C,00,00,00,00,00,\
	80,99,19,00,00,00,00,00,\
	40,66,26,00,00,00,00,00,\
	00,33,33,00,00,00,00,00

"SmoothMouseYCurve"=hex:\
	00,00,00,00,00,00,00,00,\
	00,00,38,00,00,00,00,00,\
	00,00,70,00,00,00,00,00,\
	00,00,A8,00,00,00,00,00,\
	00,00,E0,00,00,00,00,00

; SYSTEM AND SECURITY
; set appearance options to 2 Default 3 custom
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects]
"VisualFXSetting"=dword:3

; disable animate controls and elements inside windows
; disable fade or slide menus into view
; disable fade or slide tooltips into view
; disable fade out menu items after clicking
; disable show shadows under mouse pointer
; disable show shadows under windows
; disable slide open combo boxes
; disable smooth-scroll list boxes
; enable smooth edges of screen fonts
; 100% dpi scaling
; disable fix scaling for apps
; disable menu show delay
[HKEY_CURRENT_USER\Control Panel\Desktop]
"UserPreferencesMask"=hex(2):90,12,03,80,10,00,00,00
"FontSmoothing"="2"
"LogPixels"=dword:00000060
"Win8DpiScaling"=dword:00000001
"EnablePerProcessSystemDPI"=dword:00000001
"MenuShowDelay"="200"

; --IMMERSIVE CONTROL PANEL--
; PRIVACY
; Enable show me notification in the settings app
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\SystemSettings\AccountNotifications]
"EnableAccountNotifications"=dword:00000001

; disable voice activation
[HKEY_CURRENT_USER\Software\Microsoft\Speech_OneCore\Settings\VoiceActivation\UserPreferenceForAllApps]
"AgentActivationEnabled"=dword:00000000

[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Speech_OneCore\Settings\VoiceActivation\UserPreferenceForAllApps]
"AgentActivationLastUsed"=dword:00000000

; Enable other devices 
[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\bluetoothSync]
"Value"="Allow"

; disable let websites show me locally relevant content by accessing my language list 
[HKEY_CURRENT_USER\Control Panel\International\User Profile]
"HttpAcceptLanguageOptOut"=dword:00000001

; disable let windows improve start and search results by tracking app launches  
[HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\EdgeUI]
"DisableMFUTracking"=dword:00000001

; disable personal inking and typing dictionary
[HKEY_CURRENT_USER\Software\Microsoft\InputPersonalization]
"RestrictImplicitInkCollection"=dword:00000001
"RestrictImplicitTextCollection"=dword:00000001

[HKEY_CURRENT_USER\Software\Microsoft\InputPersonalization\TrainedDataStore]
"HarvestContacts"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Personalization\Settings]
"AcceptedPrivacyPolicy"=dword:00000001

; feedback frequency never
[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Siuf\Rules]
"NumberOfSIUFInPeriod"=dword:00000000
"PeriodInNanoSeconds"=-

; SEARCH
; disable search highlights
; disable search history
; disable safe search
; disable cloud content search for work or school account
; disable cloud content search for microsoft account
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\SearchSettings]
"IsDynamicSearchBoxEnabled"=dword:00000001
"IsDeviceSearchHistoryEnabled"=dword:00000001
"SafeSearchMode"=dword:00000001
"IsAADCloudSearchEnabled"=dword:00000001
"IsMSACloudSearchEnabled"=dword:00000001

; EASE OF ACCESS
; disable magnifier settings 
[HKEY_CURRENT_USER\SOFTWARE\Microsoft\ScreenMagnifier]
"FollowCaret"=dword:00000000
"FollowNarrator"=dword:00000000
"FollowMouse"=dword:00000000
"FollowFocus"=dword:00000000

; GAMING
; disable game bar
[HKEY_CURRENT_USER\System\GameConfigStore]
"GameDVR_Enabled"=dword:00000000

; disable enable open xbox game bar using game controller
; enable game mode
[HKEY_CURRENT_USER\Software\Microsoft\GameBar]
"UseNexusForGameBarEnabled"=dword:00000000
"AutoGameModeEnabled"=dword:00000000

; other settings
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\GameDVR]
"AppCaptureEnabled"=dword:00000000
"AudioEncodingBitrate"=dword:0001f400
"AudioCaptureEnabled"=dword:00000000
"CustomVideoEncodingBitrate"=dword:003d0900
"CustomVideoEncodingHeight"=dword:000002d0
"CustomVideoEncodingWidth"=dword:00000500
"HistoricalBufferLength"=dword:0000001e
"HistoricalBufferLengthUnit"=dword:00000001
"HistoricalCaptureEnabled"=dword:00000000
"HistoricalCaptureOnBatteryAllowed"=dword:00000001
"HistoricalCaptureOnWirelessDisplayAllowed"=dword:00000001
"MaximumRecordLength"=hex(b):00,D0,88,C3,10,00,00,00
"VideoEncodingBitrateMode"=dword:00000002
"VideoEncodingResolutionMode"=dword:00000002
"VideoEncodingFrameRateMode"=dword:00000000
"EchoCancellationEnabled"=dword:00000001
"CursorCaptureEnabled"=dword:00000001
"VKToggleGameBar"=dword:00000000
"VKMToggleGameBar"=dword:00000000
"VKSaveHistoricalVideo"=dword:00000000
"VKMSaveHistoricalVideo"=dword:00000000
"VKToggleRecording"=dword:00000000
"VKMToggleRecording"=dword:00000000
"VKTakeScreenshot"=dword:00000000
"VKMTakeScreenshot"=dword:00000000
"VKToggleRecordingIndicator"=dword:00000000
"VKMToggleRecordingIndicator"=dword:00000000
"VKToggleMicrophoneCapture"=dword:00000000
"VKMToggleMicrophoneCapture"=dword:00000000
"VKToggleCameraCapture"=dword:00000000
"VKMToggleCameraCapture"=dword:00000000
"VKToggleBroadcast"=dword:00000000
"VKMToggleBroadcast"=dword:00000000
"MicrophoneCaptureEnabled"=dword:00000000
"SystemAudioGain"=hex(b):10,27,00,00,00,00,00,00
"MicrophoneGain"=hex(b):10,27,00,00,00,00,00,00

; TIME & LANGUAGE 
; disable show the voice typing mic button
; disable typing insights
[HKEY_CURRENT_USER\Software\Microsoft\input\Settings]
"IsVoiceTypingKeyEnabled"=dword:00000000
"InsightsEnabled"=dword:00000000

; disable capitalize the first letter of each sentence
; disable play key sounds as i type
; disable add a period after i double-tap the spacebar
; disable show key background
[HKEY_CURRENT_USER\Software\Microsoft\TabletTip\1.7]
"EnableAutoShiftEngage"=dword:00000000
"EnableKeyAudioFeedback"=dword:00000000
"EnableDoubleTapSpace"=dword:00000000
"IsKeyBackgroundEnabled"=dword:00000000

; PERSONALIZATION
; dark theme 
[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize]
"AppsUseLightTheme"=dword:00000001
"SystemUsesLightTheme"=dword:00000000
"EnableTransparency"=dword:00000001

; disable web search in start menu 
[HKEY_CURRENT_USER\SOFTWARE\Policies\Microsoft\Windows\Explorer]
"DisableSearchBoxSuggestions"=dword:00000000

; meet now
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer]
"NoStartMenuMFUprogramsList"=-
"NoInstrumentation"=-
"HideSCAMeetNow"=dword:00000001

; remove search from taskbar
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Search]
"SearchboxTaskbarMode"=dword:00000001

; disable use dynamic lighting on my devices
; disable compatible apps in the forground always control lighting
; Enable match my windows accent color
[HKEY_CURRENT_USER\Software\Microsoft\Lighting]
"AmbientLightingEnabled"=dword:00000000
"ControlledByForegroundApp"=dword:00000000
"UseSystemAccentColor"=dword:00000001

; DEVICES
; disable let windows manage my default printer
[HKEY_CURRENT_USER\Software\Microsoft\Windows NT\CurrentVersion\Windows]
"LegacyDefaultPrinterMode"=dword:00000001

; disable write with your fingertip
[HKEY_CURRENT_USER\Software\Microsoft\TabletTip\EmbeddedInkControl]
"EnableInkingWithTouch"=dword:00000000

; SYSTEM
[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\DWM]
"UseDpiScaling"=dword:00000001

; Enable variable refresh rate & enable optimizations for windowed games
[HKEY_CURRENT_USER\Software\Microsoft\DirectX\UserGpuPreferences]
"DirectXUserGlobalSettings"="SwapEffectUpgradeEnable=1;VRROptimizeEnable=0;"

; Enable notifications
; Enable Notifications on Lock Screen
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\PushNotifications]
"ToastEnabled"=dword:00000001
"LockScreenToastEnabled"=dword:00000001

; Enable Allow Notifications to Play Sounds
; Enable Notifications on Lock Screen
; Enable Show Reminders and VoIP Calls Notifications on Lock Screen
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings]
"NOC_GLOBAL_SETTING_ALLOW_NOTIFICATION_SOUND"=dword:00000001
"NOC_GLOBAL_SETTING_ALLOW_TOASTS_ABOVE_LOCK"=dword:00000001
"NOC_GLOBAL_SETTING_ALLOW_CRITICAL_TOASTS_ABOVE_LOCK"=dword:00000001

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.SecurityAndMaintenance]
"Enabled"=dword:00000001

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\windows.immersivecontrolpanel_cw5n1h2txyewy!microsoft.windows.immersivecontrolpanel]
"Enabled"=dword:00000001

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.CapabilityAccess]
"Enabled"=dword:00000001

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.StartupApp]
"Enabled"=dword:00000001

[HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\UserProfileEngagement]
"ScoobeSystemSettingEnabled"=dword:00000001

; disable suggested actions
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\SmartActionPlatform\SmartClipboard]
"Disabled"=dword:00000001

; battery options optimize for video quality
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\VideoSettings]
"VideoQualityOnBattery"=dword:00000001

; UWP Apps
; disable windows input experience preload
[HKEY_CURRENT_USER\Software\Microsoft\input]
"IsInputAppPreloadEnabled"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Dsh]
"IsPrelaunchEnabled"=dword:00000001

; disable copilot
[HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\WindowsCopilot]
"TurnOffWindowsCopilot"=dword:00000001

[HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\WindowsAI]
"DisableAIDataAnalysis"=dword:00000001
"AllowRecallEnablement"=dword:00000000
"DisableClickToDo"=dword:00000001
"TurnOffSavingSnapshots"=dword:00000001
"DisableSettingsAgent"=dword:00000001

[HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\WindowsCopilot]
"TurnOffWindowsCopilot"=dword:00000001

[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot]
"TurnOffWindowsCopilot"=dword:00000001

[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Policies\Microsoft\Windows\WindowsCopilot]
"TurnOffWindowsCopilot"=dword:00000001

[HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\WindowsAI]
"DisableAIDataAnalysis"=dword:00000001
"AllowRecallEnablement"=dword:00000000
"DisableClickToDo"=dword:00000001
"TurnOffSavingSnapshots"=dword:00000001
"DisableSettingsAgent"=dword:00000001

[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Policies\Microsoft\Windows\WindowsAI]
"DisableAIDataAnalysis"=dword:00000001
"AllowRecallEnablement"=dword:00000000
"DisableClickToDo"=dword:00000001
"TurnOffSavingSnapshots"=dword:00000001
"DisableSettingsAgent"=dword:00000001

[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Policies\Microsoft\Edge]
"CopilotCDPPageContext"=dword:00000000
"CopilotPageContext"=dword:00000000
"HubsSidebarEnabled"=dword:00000001
"EdgeEntraCopilotPageContext"=dword:00000000
"Microsoft365CopilotChatIconEnabled"=dword:00000000
"EdgeHistoryAISearchEnabled"=dword:00000000
"ComposeInlineEnabled"=dword:00000000
"GenAILocalFoundationalModelSettings"=dword:00000000

; ENABLE ADVERTISING & PROMOTIONAL
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager]
; enabled for any of the dynamic content to work
"ContentDeliveryAllowed"=dword:00000001
"FeatureManagementEnabled"=dword:00000001
"OemPreInstalledAppsEnabled"=dword:00000001
"PreInstalledAppsEnabled"=dword:00000001
"PreInstalledAppsEverEnabled"=dword:00000001
; enables the dynamic background picture instead of a static one
"RotatingLockScreenEnabled"=dword:00000001
; FUN FACTS
"RotatingLockScreenOverlayEnabled"=dword:00000001
"SubscribedContent-338387Enabled"=dword:00000001
"SilentInstalledAppsEnabled"=dword:00000000
"SlideshowEnabled"=dword:00000001
"SoftLandingEnabled"=dword:00000001
"SubscribedContent-310093Enabled"=dword:00000001
"SubscribedContent-314563Enabled"=dword:00000001
"SubscribedContent-338388Enabled"=dword:00000001
"SubscribedContent-338389Enabled"=dword:00000001
; suggested content
"SubscribedContent-338393Enabled"=dword:00000001
"SubscribedContent-353694Enabled"=dword:00000001
"SubscribedContent-353696Enabled"=dword:00000001
"SubscribedContent-353698Enabled"=dword:00000001
"SubscribedContentEnabled"=dword:00000001
"SystemPaneSuggestionsEnabled"=dword:00000001

; OTHER
; Add gallery
[HKEY_CURRENT_USER\Software\Classes\CLSID\{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}]
"System.IsPinnedToNameSpaceTree"=dword:00000001

; restore the classic context menu
[HKEY_CURRENT_USER\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32]
@=""

; Hides the Try New Outlook Button
[HKEY_CURRENT_USER\Software\Microsoft\Office\16.0\Outlook\Options\General]
"HideNewOutlookToggle"=dword:00000000

[HKEY_CURRENT_USER\Software\Policies]

[HKEY_CURRENT_USER\Software\Policies\Microsoft]

[HKEY_CURRENT_USER\Software\Policies\Microsoft\Dsh]
"AllowNewsAndInterests"=dword:00000001

[HKEY_CURRENT_USER\Software\Policies\Microsoft\InputPersonalization]
"AllowInputPersonalization"=dword:00000000

[HKEY_CURRENT_USER\Software\Policies\Microsoft\OneDrive]
"KFMBlockOptIn"=dword:00000001

[HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows]

[HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\AdvertisingInfo]
"enabledByGroupPolicy"=dword:00000000

[HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\AppPrivacy]
"LetAppsRunInBackground"=dword:00000001

[HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\CloudContent]
"enableTailoredExperiencesWithDiagnosticData"=dword:00000001

[HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\CurrentVersion]

[HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings]

[HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\5.0]

[HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\5.0\Cache]

[HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Cache]

[HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\DataCollection]
"AllowTelemetry"=dword:00000000
"DoNotShowFeedbackNotifications"=dword:00000001

[HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\DeliveryOptimization]
"DODownloadMode"=dword:00000063

[HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\EdgeUI]
"DisableMFUTracking"=dword:00000001

[HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\Explorer]
"DisableNotificationCenter"=dword:00000000
"DisableSearchBoxSuggestions"=dword:00000000
"HideRecommendedSection"=dword:00000001
"enableSearchBoxSuggestions"=dword:00000001
"HideSCAMeetNow"=dword:00000000

[HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\LocationAndSensors]
"enableLocation"=dword:00000001

[HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\StorageSense]
"AllowStorageSenseGlobal"=dword:00000001

[HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\System]
"PublishUserActivities"=dword:00000000

[HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\Windows Error Reporting]
"enabled"=dword:00000000

[HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\Windows Feeds]
"EnableFeeds"=dword:00000001

[HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\Windows Search]
"AllowCortana"=dword:00000001

[HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\WindowsAI]
"DisableAIDataAnalysis"=dword:00000001
"AllowRecallEnablement"=dword:00000000
"DisableClickToDo"=dword:00000001
"TurnOffSavingSnapshots"=dword:00000001
"DisableSettingsAgent"=dword:00000001

[HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\WindowsCopilot]
"TurnOffWindowsCopilot"=dword:00000001

[HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\WindowsAI]
"DisableAIDataAnalysis"=dword:00000001
"AllowRecallEnablement"=dword:00000000
"DisableClickToDo"=dword:00000001
"TurnOffSavingSnapshots"=dword:00000001
"DisableSettingsAgent"=dword:00000001

[HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\WindowsCopilot]
"TurnOffWindowsCopilot"=dword:00000001

[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot]
"TurnOffWindowsCopilot"=dword:00000001

[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Policies\Microsoft\Windows\WindowsCopilot]
"TurnOffWindowsCopilot"=dword:00000001

[HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\WindowsAI]
"DisableAIDataAnalysis"=dword:00000001
"AllowRecallEnablement"=dword:00000000
"DisableClickToDo"=dword:00000001
"TurnOffSavingSnapshots"=dword:00000001
"DisableSettingsAgent"=dword:00000001

[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Policies\Microsoft\Windows\WindowsAI]
"DisableAIDataAnalysis"=dword:00000001
"AllowRecallEnablement"=dword:00000000
"DisableClickToDo"=dword:00000001
"TurnOffSavingSnapshots"=dword:00000001
"DisableSettingsAgent"=dword:00000001

[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Policies\Microsoft\Edge]
"CopilotCDPPageContext"=dword:00000000
"CopilotPageContext"=dword:00000000
"HubsSidebarEnabled"=dword:00000001
"EdgeEntraCopilotPageContext"=dword:00000000
"Microsoft365CopilotChatIconEnabled"=dword:00000000
"EdgeHistoryAISearchEnabled"=dword:00000000
"ComposeInlineEnabled"=dword:00000000
"GenAILocalFoundationalModelSettings"=dword:00000000


[HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\WindowsUpdate]
"SetUpdateNotificationLevel"=dword:00000001
"ExcludeWUDriversInQualityUpdate"=dword:00000000

[HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\WindowsUpdate\AU]
"AUOptions"=dword:00000002
"NoAutoRebootWithLoggedOnUsers"=dword:00000000

[HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\WorkplaceJoin]
"BlockAADWorkplaceJoin"=dword:00000001

[HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows Defender Security Center]

[HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows Defender Security Center\Notifications]
"enableNotifications"=dword:00000001
"enableEnhancedNotifications"=dword:00000001

[HKEY_CURRENT_USER\Software\Policies\Microsoft\WindowsStore]
"AutoDownload"=dword:00000001

[HKEY_CURRENT_USER\Software\Policies\Power]

[HKEY_CURRENT_USER\Software\Policies\Power\PowerSettings]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Attachments]
"SaveZoneInformation"=dword:00000001

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\DataCollection]
"AllowTelemetry"=dword:00000001
"MaxTelemetryAllowed"=dword:00000001

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer]
"ConfirmFileDelete"=dword:00000001
"NoDriveTypeAutorun"=dword:000000ff
"HideSCAMeetNow"=-

[HKEY_CURRENT_USER\Control Panel]
"SettingsExtensionAppSnapshot"=hex:00,00,00,00,00,00,00,00

[HKEY_CURRENT_USER\Control Panel\Accessibility]
"MessageDuration"=dword:00000005
"MinimumHitRadius"=dword:00000000
"Sound on Activation"=dword:00000000
"Warning Sounds"=dword:00000000

[HKEY_CURRENT_USER\Control Panel\Accessibility\AudioDescription]
"Locale"=""
"On"="0"

[HKEY_CURRENT_USER\Control Panel\Accessibility\Blind Access]
"On"="0"

[HKEY_CURRENT_USER\Control Panel\Accessibility\HighContrast]
"Flags"="98"
"High Contrast Scheme"="Kontrast Weiß"
"Previous High Contrast Scheme MUI Value"="Kontrast Weiß"
"Previous High Contrast Scheme MUI Ptr"="@themeui.dll,-853"
"LastUpdatedThemeId"=dword:00000000

[HKEY_CURRENT_USER\Keyboard Layout\Preload]
"1"="00000407"
"2"="00000807"

[HKEY_CURRENT_USER\Control Panel\Accessibility\Keyboard Preference]
"On"="0"

[HKEY_CURRENT_USER\Control Panel\Accessibility\Keyboard Response]
"AutoRepeatDelay"="0"
"AutoRepeatRate"="0"
"BounceTime"="0"
"DelayBeforeAcceptance"="500"
"Flags"="2"
"Last BounceKey Setting"=dword:00000000
"Last Valid Delay"=dword:00000000
"Last Valid Repeat"=dword:00000000
"Last Valid Wait"=dword:000003e8

[HKEY_CURRENT_USER\Control Panel\Accessibility\MouseKeys]
"Flags"="130"
"MaximumSpeed"="39"
"TimeToMaximumSpeed"="3000"

[HKEY_CURRENT_USER\Control Panel\Accessibility\On]
"Locale"=dword:00000000
"On"=dword:00000000

[HKEY_CURRENT_USER\Control Panel\Accessibility\ShowSounds]
"On"="0"

[HKEY_CURRENT_USER\Control Panel\Accessibility\SlateLaunch]
"ATapp"=""
"LaunchAT"=dword:00000000

[HKEY_CURRENT_USER\Control Panel\Accessibility\SoundSentry]
"Flags"="0"
"FSTextEffect"="0"
"TextEffect"="0"
"WindowsEffect"="0"

[HKEY_CURRENT_USER\Control Panel\Accessibility\StickyKeys]
"Flags"="2"

[HKEY_CURRENT_USER\Control Panel\Accessibility\TimeOut]
"Flags"="2"
"TimeToWait"="300000"

[HKEY_CURRENT_USER\Control Panel\Accessibility\ToggleKeys]
"Flags"="34"

[HKEY_CURRENT_USER\Control Panel\Appearance]
"SchemeLangID"=hex:07,04
"NewCurrent"=""
"Current"=""

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\SearchSettings]
"WebSearchInstalledVersion"="1.1.43.0"
"HasSetWebSearchEnabledStateOnUpdate"=dword:00000001
"MRUWebProviderApplicationUserModelId"=""
"WebProviderLastNotificationBehavior"=dword:00000000
"WebProviderLastNotificationBehaviorTimestamp"=hex(b):5c,d4,08,92,2e,b2,dc,01
"CurrentWebAccountId"="00011D674C41F6BC"
"IsDynamicSearchBoxEnabled"=dword:00000001
"IsDeviceSearchHistoryEnabled"=dword:00000001
"SafeSearchMode"=dword:00000001
"IsAADCloudSearchEnabled"=dword:00000000
"IsMSACloudSearchEnabled"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\SearchSettings\Appearance]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\SearchSettings\Appearance\Current]
"current"="{00000000-0000-0000-0000-000000000000}"
"baseline"="{00000000-0000-0000-0000-000000000000}"

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\SearchSettings\Dynamic]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\SearchSettings\Dynamic\Current]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\SearchSettings\WebSearchProviders]
"Microsoft.BingSearch_8wekyb3d8bbwe!App"=-

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\SearchSettings\WebSearchProviders\Index]
"Microsoft.BingSearch_8wekyb3d8bbwe!App"=-

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\SearchSettings\WebSearchProviders\InstalledDates]
"Microsoft.BingSearch_8wekyb3d8bbwe!App"=-

[HKEY_CURRENT_USER\Control Panel\Colors]
"ActiveBorder"="180 180 180"
"ActiveTitle"="153 180 209"
"AppWorkspace"="171 171 171"
"Background"="0 0 0"
"ButtonAlternateFace"="0 0 0"
"ButtonDkShadow"="105 105 105"
"ButtonFace"="240 240 240"
"ButtonHilight"="255 255 255"
"ButtonLight"="227 227 227"
"ButtonShadow"="160 160 160"
"ButtonText"="0 0 0"
"GradientActiveTitle"="185 209 234"
"GradientInactiveTitle"="215 228 242"
"GrayText"="109 109 109"
"Hilight"="0 120 212"
"HilightText"="255 255 255"
"HotTrackingColor"="0 102 204"
"InactiveBorder"="244 247 252"
"InactiveTitle"="191 205 219"
"InactiveTitleText"="0 0 0"
"InfoText"="0 0 0"
"InfoWindow"="255 255 225"
"Menu"="240 240 240"
"MenuBar"="240 240 240"
"MenuHilight"="0 120 212"
"MenuText"="0 0 0"
"Scrollbar"="200 200 200"
"TitleText"="0 0 0"
"Window"="255 255 255"
"WindowFrame"="100 100 100"
"WindowText"="0 0 0"

[HKEY_CURRENT_USER\Control Panel\Cursors]
"AppStarting"="C:\\WINDOWS\\cursors\\aero_working.ani"
"Arrow"="C:\\WINDOWS\\cursors\\aero_arrow.cur"
"ContactVisualization"=dword:00000001
"Crosshair"=""
"CursorBaseSize"=dword:00000020
"GestureVisualization"=dword:0000001f
"Hand"="C:\\WINDOWS\\cursors\\aero_link.cur"
"Help"="C:\\WINDOWS\\cursors\\aero_helpsel.cur"
"IBeam"=""
"No"="C:\\WINDOWS\\cursors\\aero_unavail.cur"
"NWPen"="C:\\WINDOWS\\cursors\\aero_pen.cur"
"Scheme Source"=dword:00000002
"SizeAll"="C:\\WINDOWS\\cursors\\aero_move.cur"
"SizeNESW"="C:\\WINDOWS\\cursors\\aero_nesw.cur"
"SizeNS"="C:\\WINDOWS\\cursors\\aero_ns.cur"
"SizeNWSE"="C:\\WINDOWS\\cursors\\aero_nwse.cur"
"SizeWE"="C:\\WINDOWS\\cursors\\aero_ew.cur"
"UpArrow"="C:\\WINDOWS\\cursors\\aero_up.cur"
"Wait"="C:\\WINDOWS\\cursors\\aero_busy.ani"
@="Windows-Voreinstellung"

[HKEY_CURRENT_USER\Control Panel\Mouse]
"ActiveWindowTracking"=dword:00000001
"Beep"="No"
"DoubleClickHeight"="4"
"DoubleClickSpeed"="500"
"DoubleClickWidth"="4"
"ExtendedSounds"="Yes"
"MouseHoverHeight"="4"
"MouseHoverTime"="400"
"MouseHoverWidth"="4"
"MouseSensitivity"="10"
"MouseSpeed"="7"
"MouseThreshold1"="6"
"MouseThreshold2"="10"
"MouseTrails"="1"
"SmoothMouseXCurve"=hex:00,00,00,00,00,00,00,00,c0,cc,0c,00,00,00,00,00,80,99,\
  19,00,00,00,00,00,40,66,26,00,00,00,00,00,00,33,33,00,00,00,00,00
"SmoothMouseYCurve"=hex:00,00,00,00,00,00,00,00,00,00,38,00,00,00,00,00,00,00,\
  70,00,00,00,00,00,00,00,a8,00,00,00,00,00,00,00,e0,00,00,00,00,00
"SnapToDefaultButton"="1"
"SwapMouseButtons"="0"

[HKEY_CLASSES_ROOT\*\shell\TakeOwnership]
@="Take Ownership"
"HasLUAShield"=""
"NoWorkingDirectory"=""
"NeverDefault"=""

[HKEY_CLASSES_ROOT\*\shell\TakeOwnership\command]
@="powershell -windowstyle hidden -command \"Start-Process cmd -ArgumentList '/c takeown /f \\\"%1\\\" && icacls \\\"%1\\\" /grant *S-1-3-4:F /t /c /l & pause' -Verb runAs\""
"IsolatedCommand"="powershell -windowstyle hidden -command \"Start-Process cmd -ArgumentList '/c takeown /f \\\"%1\\\" && icacls \\\"%1\\\" /grant *S-1-3-4:F /t /c /l & pause' -Verb runAs\""

[HKEY_CURRENT_USER\Software\Microsoft\Lighting]
"AmbientLightingEnabled"=dword:00000000
"EffectDefaultsApplied"=dword:00000001
"EffectType"=dword:00000000
"Brightness"=dword:00000064
"Speed"=dword:00000007
"UseSystemAccentColor"=dword:00000001
"EffectMode"=dword:00000001
"Color"=dword:ffd47800
"Color2"=dword:ffffffff
"ControlledByForegroundApp"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\DWM]
"Composition"=dword:00000001
"AccentColor"=dword:ff0d685c
"ColorPrevalence"=dword:00000000
"ColorizationGlassAttribute"=dword:00000001
"EnableAeroPeek"=dword:00000001
"AlwaysHibernateThumbnails"=dword:00000001
"UseDpiScaling"=dword:00000001
"CompositionPolicy"=dword:00000001
"ColorizationColor"=dword:005c680d
"ColorizationColorBalance"=dword:fffffff3
"ColorizationAfterglow"=dword:005c680d
"ColorizationAfterglowBalance"=dword:0000000a
"ColorizationBlurBalance"=dword:00000067
"EnableWindowColorization"=dword:00000001

[HKEY_CURRENT_USER\Control Panel\Desktop]
"BlockSendInputResets"="0"
"CaretTimeout"=dword:00001388
"CaretWidth"=dword:00000001
"ClickLockTime"=dword:000004b0
"CoolSwitchColumns"="7"
"CoolSwitchRows"="3"
"CursorBlinkRate"="530"
"DockMoving"="1"
"DragFromMaximize"="1"
"DragFullWindows"="1"
"DragHeight"="4"
"DragWidth"="4"
"FocusBorderHeight"=dword:00000001
"FocusBorderWidth"=dword:00000001
"FontSmoothing"="2"
"FontSmoothingGamma"=dword:00000000
"FontSmoothingOrientation"=dword:00000001
"FontSmoothingType"=dword:00000002
"ForegroundFlashCount"=dword:00000007
"ForegroundLockTimeout"=dword:00030d40
"LeftOverlapChars"="3"
"MenuShowDelay"="200"
"MouseWheelRouting"=dword:00000002
"PaintDesktopVersion"=dword:00000000
"RightOverlapChars"="3"
"ScreenSaveActive"=dword:00000001
"SnapSizing"="1"
"TileWallpaper"="0"
"WallpaperOriginX"=dword:00000000
"WallpaperOriginY"=dword:00000000
"WallpaperStyle"=dword:00000002
"WheelScrollChars"="3"
"WheelScrollLines"="3"
"WindowArrangementActive"="1"
"Win8DpiScaling"=dword:00000001
"DpiScalingVer"=dword:00001000
"UserPreferencesMask"=hex:90,12,03,80,10,00,00,00
"MaxVirtualDesktopDimension"=dword:00000780
"MaxMonitorDimension"=dword:00000780
"TranscodedImageCount"=dword:00000001
"LastUpdated"=dword:ffffffff
"PreferredUILanguages"="de-DE"
"Pattern Upgrade"="TRUE"
"LockScreenAutoLockActive"="1"
"ScreenSaverIsSecure"=dword:00000001
"ScreenSaveTimeOut"=dword:000000fa
"AutoEndTasks"=dword:00000001
"HungAppTimeout"="4000"
"WaitToKillAppTimeout"="4000"
"LogPixels"=dword:00000060
"EnablePerProcessSystemDPI"=dword:00000001
"JPEGImportQuality"=dword:00000064
"DstNotification"=dword:00000001
"DelayLockInterval"=dword:00000000
"AutoColorization"=dword:00000001
"ImageColor"=dword:afd4e846

[HKEY_CURRENT_USER\Control Panel\Desktop\Colors]
"ActiveBorder"="212 208 200"
"ActiveTitle"="10 36 106"
"AppWorkSpace"="128 128 128"
"ButtonAlternateFace"="181 181 181"
"ButtonDkShadow"="64 64 64"
"ButtonFace"="212 208 200"
"ButtonHiLight"="255 255 255"
"ButtonLight"="212 208 200"
"ButtonShadow"="128 128 128"
"ButtonText"="0 0 0"
"GradientActiveTitle"="166 202 240"
"GradientInactiveTitle"="192 192 192"
"GrayText"="128 128 128"
"Hilight"="10 36 106"
"HilightText"="255 255 255"
"HotTrackingColor"="0 0 128"
"InactiveBorder"="212 208 200"
"InactiveTitle"="128 128 128"
"InactiveTitleText"="212 208 200"
"InfoText"="0 0 0"
"InfoWindow"="255 255 255"
"Menu"="212 208 200"
"MenuText"="0 0 0"
"Scrollbar"="212 208 200"
"TitleText"="255 255 255"
"Window"="255 255 255"
"WindowFrame"="0 0 0"
"WindowText"="0 0 0"

[HKEY_CURRENT_USER\Control Panel\Desktop\WindowMetrics]
"BorderWidth"="-15"
"CaptionFont"=hex:f4,ff,ff,ff,00,00,00,00,00,00,00,00,00,00,00,00,90,01,00,00,\
  00,00,00,01,00,00,05,00,53,00,65,00,67,00,6f,00,65,00,20,00,55,00,49,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
"CaptionHeight"="-330"
"CaptionWidth"="-330"
"IconFont"=hex:f4,ff,ff,ff,00,00,00,00,00,00,00,00,00,00,00,00,90,01,00,00,00,\
  00,00,01,00,00,05,00,53,00,65,00,67,00,6f,00,65,00,20,00,55,00,49,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
"IconTitleWrap"="1"
"MenuFont"=hex:f4,ff,ff,ff,00,00,00,00,00,00,00,00,00,00,00,00,90,01,00,00,00,\
  00,00,01,00,00,05,00,53,00,65,00,67,00,6f,00,65,00,20,00,55,00,49,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
"MenuHeight"="-285"
"MenuWidth"="-285"
"MessageFont"=hex:f4,ff,ff,ff,00,00,00,00,00,00,00,00,00,00,00,00,90,01,00,00,\
  00,00,00,01,00,00,05,00,53,00,65,00,67,00,6f,00,65,00,20,00,55,00,49,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
"ScrollHeight"="-255"
"ScrollWidth"="-255"
"Shell Icon Size"="32"
"SmCaptionFont"=hex:f4,ff,ff,ff,00,00,00,00,00,00,00,00,00,00,00,00,90,01,00,\
  00,00,00,00,01,00,00,05,00,53,00,65,00,67,00,6f,00,65,00,20,00,55,00,49,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
"SmCaptionHeight"="-330"
"SmCaptionWidth"="-330"
"StatusFont"=hex:f4,ff,ff,ff,00,00,00,00,00,00,00,00,00,00,00,00,90,01,00,00,\
  00,00,00,01,00,00,05,00,53,00,65,00,67,00,6f,00,65,00,20,00,55,00,49,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
"PaddedBorderWidth"="-60"
"AppliedDPI"=dword:00000060
"IconSpacing"="-1710"
"IconVerticalSpacing"="-1130"
"MinAnimate"="0"

[HKEY_CURRENT_USER\Control Panel\Desktop\MuiCached]
"MachinePreferredUILanguages"=hex(7):64,00,65,00,2d,00,44,00,45,00,00,00

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel]
"{59031a47-3f72-44a7-89c5-5595fe6b30ee}"=dword:00000000
"{20D04FE0-3AEA-1069-A2D8-08002B30309D}"=dword:00000000
"{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}"=dword:00000000
"{5399E694-6CE5-4D6C-8FCE-1D8870FDCBA0}"=dword:00000000
"{018D5C66-4533-4307-9B53-224DE2ED1FE6}"=dword:00000000
"{031E4825-7B94-4dc3-B131-E946B44C8DD5}"=dword:00000000
"{1CF1260C-4DD0-4ebb-811F-33C572699FDE}"=dword:00000000
"{208D2C60-3AEA-1069-A2D7-08002B30309D}"=dword:00000000
"{20D04FE0-3AEA-1069-A2D8-08002B30309D}"=dword:00000000
"{374DE290-123F-4565-9164-39C4925E467B}"=dword:00000000
"{3ADD1653-EB32-4cb0-BBD7-DFA0ABB5ACCA}"=dword:00000000
"{5399E694-6CE5-4D6C-8FCE-1D8870FDCBA0}"=dword:00000000
"{59031a47-3f72-44a7-89c5-5595fe6b30ee}"=dword:00000000
"{871C5380-42A0-1069-A2EA-08002B30309D}"=dword:00000000
"{9343812e-1c37-4a49-a12e-4b2d810d956b}"=dword:00000000
"{A0953C92-50DC-43bf-BE83-3742FED03C9C}"=dword:00000000
"{A8CDFF1C-4878-43be-B5FD-F8091C1C60D0}"=dword:00000000
"{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}"=dword:00000000
"{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}"=dword:00000000
"{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}"=dword:00000000
"{f874310e-b6b7-47dc-bc84-b9e6b38f5903}"=dword:00000000

[HKEY_CURRENT_USER\Control Panel\Input Method]
"Show Status"="1"

[HKEY_CURRENT_USER\Control Panel\Input Method\Hot Keys]

[HKEY_CURRENT_USER\Control Panel\Input Method\Hot Keys\00000010]
"Key Modifiers"=hex:02,c0,00,00
"Target IME"=hex:00,00,00,00
"Virtual Key"=hex:20,00,00,00

[HKEY_CURRENT_USER\Control Panel\Input Method\Hot Keys\00000011]
"Key Modifiers"=hex:04,c0,00,00
"Target IME"=hex:00,00,00,00
"Virtual Key"=hex:20,00,00,00

[HKEY_CURRENT_USER\Control Panel\Input Method\Hot Keys\00000012]
"Key Modifiers"=hex:02,c0,00,00
"Target IME"=hex:00,00,00,00
"Virtual Key"=hex:be,00,00,00

[HKEY_CURRENT_USER\Control Panel\Input Method\Hot Keys\00000070]
"Key Modifiers"=hex:02,c0,00,00
"Target IME"=hex:00,00,00,00
"Virtual Key"=hex:20,00,00,00

[HKEY_CURRENT_USER\Control Panel\Input Method\Hot Keys\00000071]
"Key Modifiers"=hex:04,c0,00,00
"Target IME"=hex:00,00,00,00
"Virtual Key"=hex:20,00,00,00

[HKEY_CURRENT_USER\Control Panel\Input Method\Hot Keys\00000072]
"Key Modifiers"=hex:03,c0,00,00
"Target IME"=hex:00,00,00,00
"Virtual Key"=hex:bc,00,00,00

[HKEY_CURRENT_USER\Control Panel\Input Method\Hot Keys\00000104]
"Key Modifiers"=hex:06,c0,00,00
"Target IME"=hex:11,04,01,e0
"Virtual Key"=hex:30,00,00,00

[HKEY_CURRENT_USER\Control Panel\Input Method\Hot Keys\00000200]
"Key Modifiers"=hex:03,c0,00,00
"Target IME"=hex:00,00,00,00
"Virtual Key"=hex:47,00,00,00

[HKEY_CURRENT_USER\Control Panel\Input Method\Hot Keys\00000201]
"Key Modifiers"=hex:03,c0,00,00
"Target IME"=hex:00,00,00,00
"Virtual Key"=hex:4b,00,00,00

[HKEY_CURRENT_USER\Control Panel\Input Method\Hot Keys\00000202]
"Key Modifiers"=hex:03,c0,00,00
"Target IME"=hex:00,00,00,00
"Virtual Key"=hex:4c,00,00,00

[HKEY_CURRENT_USER\Control Panel\Input Method\Hot Keys\00000203]
"Key Modifiers"=hex:03,c0,00,00
"Target IME"=hex:00,00,00,00
"Virtual Key"=hex:56,00,00,00

[HKEY_CURRENT_USER\Control Panel\Keyboard]
"InitialKeyboardIndicators"="0"
"KeyboardDelay"="1"
"KeyboardSpeed"="31"

[HKEY_CURRENT_USER\Control Panel\Mouse]
"ActiveWindowTracking"=dword:00000001
"Beep"="No"
"DoubleClickHeight"="4"
"DoubleClickSpeed"="500"
"DoubleClickWidth"="4"
"ExtendedSounds"="No"
"MouseHoverHeight"="4"
"MouseHoverTime"="400"
"MouseHoverWidth"="4"
"MouseSensitivity"="10"
"MouseSpeed"="7"
"MouseThreshold1"="6"
"MouseThreshold2"="10"
"MouseTrails"="1"
"SmoothMouseXCurve"=hex:00,00,00,00,00,00,00,00,c0,cc,0c,00,00,00,00,00,80,99,\
  19,00,00,00,00,00,40,66,26,00,00,00,00,00,00,33,33,00,00,00,00,00
"SmoothMouseYCurve"=hex:00,00,00,00,00,00,00,00,00,00,38,00,00,00,00,00,00,00,\
  70,00,00,00,00,00,00,00,a8,00,00,00,00,00,00,00,e0,00,00,00,00,00
"SnapToDefaultButton"="1"
"SwapMouseButtons"="0"

[HKEY_CURRENT_USER\Control Panel\NotifyIconSettings]
"Version"=dword:00000003
"MigrationStatus"="Migration started"
"UIOrderList"=hex:4e,bb,b3,c8,6b,97,77,af,22,ad,3a,fa,07,03,1c,33,d9,3d,25,a9,\
  5b,c9,06,8e,b5,b8,62,d1,65,e1,00,3c,25,46,f1,0a,36,05,91,0d,87,d9,f7,41,e6,\
  c0,3a,77,3b,49,98,78,06,92,21,d0,80,b1,7c,22,4d,98,ab,cd,c6,b1,ae,a2,3c,b6,\
  98,b0,ea,ae,7d,ee,ae,da,98,a9,ea,10,6b,66,cb,1b,f4,e0,8e,d9,c6,44,77,d5,b2,\
  a1,16,e0,5b,c3,d2,7c,03,23,ae,1f,81,c7,2d,92,61,4d,67,dc,fb,d7,f6,ea,51,ac,\
  ed,ac,62,8d,80,c2,66,c9,ee,5f,01,85,4c,e3,46,ca,d8,31,8e,b7,fa,cb,25,17,67,\
  73,6d,7e,d9,56,ed,cd,75,db,2e,58,cc,53,aa,ad,1c,34,03,d6,51,00,f8,9f,ee,a1,\
  a4,73,60,3a,7a,60,87,e0,95,12,21,e8,25,32,10,ff,39,3f,7c,bb,fd,1a,21,5e,32,\
  e7,f3,ef,17,4b,8e,75,f8,63,10,3c,99,42,49,50,af,7f,d2,73,c3,fe,32,c7,9e,e4,\
  36,e3,04,b0,96,4d,0d,ab,93,b6,00,bc

[HKEY_CURRENT_USER\Control Panel\Personalization]

[HKEY_CURRENT_USER\Control Panel\Personalization\Desktop Slideshow]

[HKEY_CURRENT_USER\Control Panel\PowerCfg]
"CurrentPowerPolicy"="0"

[HKEY_CURRENT_USER\Control Panel\PowerCfg\GlobalPowerPolicy]
"Policies"=hex:01,00,00,00,00,00,00,00,03,00,00,00,10,00,00,00,00,00,00,00,03,\
  00,00,00,10,00,00,00,02,00,00,00,03,00,00,00,00,00,00,00,02,00,00,00,03,00,\
  00,00,00,00,00,00,02,00,00,00,01,00,00,00,00,00,00,00,02,00,00,00,01,00,00,\
  00,00,00,00,00,01,00,00,00,03,00,00,00,03,00,00,00,00,00,00,c0,01,00,00,00,\
  05,00,00,00,01,00,00,00,0a,00,00,00,00,00,00,00,03,00,00,00,01,00,00,00,01,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,16,00,00,00

[HKEY_CURRENT_USER\Control Panel\PowerCfg\PowerPolicies]

[HKEY_CURRENT_USER\Control Panel\PowerCfg\PowerPolicies\0]
"Description"="This scheme is suited to most home or desktop computers that are left plugged in all the time."
"Name"="Home/Office Desk"
"Policies"=hex:01,00,00,00,02,00,00,00,01,00,00,00,00,00,00,00,02,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,2c,01,00,00,32,32,00,03,04,00,00,00,04,00,\
  00,00,00,00,00,00,00,00,00,00,b0,04,00,00,2c,01,00,00,00,00,00,00,58,02,00,\
  00,01,01,64,50,64,64,00,00

[HKEY_CURRENT_USER\Control Panel\PowerCfg\PowerPolicies\1]
"Description"="This scheme is designed for extended battery life for portable computers on the road."
"Name"="Portable/Laptop"
"Policies"=hex:01,00,00,00,02,00,00,00,01,00,00,00,00,00,00,00,02,00,00,00,01,\
  00,00,00,00,00,00,00,b0,04,00,00,2c,01,00,00,32,32,03,03,04,00,00,00,04,00,\
  00,00,00,00,00,00,00,00,00,00,84,03,00,00,2c,01,00,00,08,07,00,00,2c,01,00,\
  00,01,01,64,50,64,64,00,00

[HKEY_CURRENT_USER\Control Panel\PowerCfg\PowerPolicies\2]
"Description"="This scheme keeps the monitor on for doing presentations."
"Name"="Presentation"
"Policies"=hex:01,00,00,00,02,00,00,00,01,00,00,00,00,00,00,00,02,00,00,00,01,\
  00,00,00,00,00,00,00,00,00,00,00,84,03,00,00,32,32,03,02,04,00,00,00,04,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,2c,01,00,\
  00,01,01,50,50,64,64,00,00

[HKEY_CURRENT_USER\Control Panel\PowerCfg\PowerPolicies\3]
"Description"="This scheme keeps the computer running so that it can be accessed from the network.  Use this scheme if you do not have network wakeup hardware."
"Name"="Always On"
"Policies"=hex:01,00,00,00,02,00,00,00,01,00,00,00,00,00,00,00,02,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,32,32,00,00,04,00,00,00,04,00,\
  00,00,00,00,00,00,00,00,00,00,b0,04,00,00,84,03,00,00,00,00,00,00,08,07,00,\
  00,00,01,64,64,64,64,00,00

[HKEY_CURRENT_USER\Control Panel\PowerCfg\PowerPolicies\4]
"Description"="This scheme keeps the computer on and optimizes it for high performance."
"Name"="Minimal Power Management"
"Policies"=hex:01,00,00,00,02,00,00,00,01,00,00,00,00,00,00,00,02,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,2c,01,00,00,32,32,03,03,04,00,00,00,04,00,\
  00,00,00,00,00,00,00,00,00,00,84,03,00,00,2c,01,00,00,00,00,00,00,84,03,00,\
  00,00,01,64,64,64,64,00,00

[HKEY_CURRENT_USER\Control Panel\PowerCfg\PowerPolicies\5]
"Description"="This scheme is extremely aggressive for saving power."
"Name"="Max Battery"
"Policies"=hex:01,00,00,00,02,00,00,00,01,00,00,00,00,00,00,00,02,00,00,00,05,\
  00,00,00,00,00,00,00,b0,04,00,00,78,00,00,00,32,32,03,02,04,00,00,00,04,00,\
  00,00,00,00,00,00,00,00,00,00,84,03,00,00,3c,00,00,00,00,00,00,00,b4,00,00,\
  00,01,01,64,32,64,64,00,00

[HKEY_CURRENT_USER\Control Panel\Quick Actions]

[HKEY_CURRENT_USER\Control Panel\Quick Actions\Control Center]
"PreviousControlCenterHeight"=hex(b):00,00,00,00,00,10,78,40
"UserLayoutPaginated"="[{\"Name\":\"Toggles\",\"QuickActions\":[{\"FriendlyName\":\"Microsoft.QuickAction.WiFi\"},{\"FriendlyName\":\"Microsoft.QuickAction.Bluetooth\"},{\"FriendlyName\":\"Microsoft.QuickAction.Cellular\"},{\"FriendlyName\":\"Microsoft.QuickAction.WindowsStudio\"},{\"FriendlyName\":\"Microsoft.QuickAction.AirplaneMode\"},{\"FriendlyName\":\"Microsoft.QuickAction.Accessibility\"},{\"FriendlyName\":\"Microsoft.QuickAction.Vpn\"},{\"FriendlyName\":\"Microsoft.QuickAction.RotationLock\"},{\"FriendlyName\":\"Microsoft.QuickAction.BatterySaver\"},{\"FriendlyName\":\"Microsoft.QuickAction.EnergySaverAcOnly\"},{\"FriendlyName\":\"Microsoft.QuickAction.LiveCaptions\"},{\"FriendlyName\":\"Microsoft.QuickAction.BlueLightReduction\"},{\"FriendlyName\":\"Microsoft.QuickAction.MobileHotspot\"},{\"FriendlyName\":\"Microsoft.QuickAction.NearShare\"},{\"FriendlyName\":\"Microsoft.QuickAction.ColorProfile\"},{\"FriendlyName\":\"Microsoft.QuickAction.Cast\"},{\"FriendlyName\":\"Microsoft.QuickAction.ProjectL2\"},{\"FriendlyName\":\"Microsoft.QuickAction.LocalBluetooth\"},{\"FriendlyName\":\"Microsoft.QuickAction.A9\"},{\"FriendlyName\":\"Microsoft.QuickAction.AudioSharing\"}]},{\"Name\":\"Sliders\",\"QuickActions\":[{\"FriendlyName\":\"Microsoft.QuickAction.Brightness\"},{\"FriendlyName\":\"Microsoft.QuickAction.VolumeNoTimer\"}]}]"

[HKEY_CURRENT_USER\Control Panel\Quick Actions\Pinned]

[HKEY_CURRENT_USER\Control Panel\Sound]
"Beep"="yes"
"ExtendedSounds"="yes"

[HKEY_CURRENT_USER\Control Panel\TimeDate]
"DstNotification"=dword:00000000

[HKEY_CURRENT_USER\Control Panel\TimeDate\AdditionalClocks]

[HKEY_CURRENT_USER\Control Panel\UnsupportedHardwareNotificationCache]
"SV2"=dword:00000001
"UnsupportedReason"=""

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
"Start_SearchFiles"=dword:00000002
"ServerAdminUI"=dword:00000001
"Hidden"=dword:00000001
"ShowCompColor"=dword:00000001
"HideFileExt"=dword:00000000
"DontPrettyPath"=dword:00000000
"ShowInfoTip"=dword:00000000
"HideIcons"=dword:00000000
"MapNetDrvBtn"=dword:00000000
"WebView"=dword:00000001
"Filter"=dword:00000000
"ShowSuperHidden"=dword:00000000
"SeparateProcess"=dword:00000001
"AutoCheckSelect"=dword:00000000
"IconsOnly"=dword:00000000
"ShowTypeOverlay"=dword:00000001
"ShowStatusBar"=dword:00000000
"ListviewAlphaSelect"=dword:00000001
"ListviewShadow"=dword:00000000
"TaskbarAnimations"=dword:00000000
"TaskbarSizeMove"=dword:00000000
"DisablePreviewDesktop"=dword:00000000
"TaskbarSmallIcons"=dword:00000001
"TaskbarAutoHideInTabletMode"=dword:00000001
"ShellMigrationLevel"=dword:00000003
"ReindexedProfile"=dword:00000001
"ProgrammableTaskbarStatus"=dword:00000002
"StartMenuInit"=dword:0000000d
"WinXMigrationLevel"=dword:00000001
"TaskbarStateLastRun"=hex:7e,a2,b5,69,00,00,00,00
"OTPTBImprSuccess"=dword:00000001
"StartShownOnUpgrade"=dword:00000001
"LaunchTo"=dword:00000001
"ShowCortanaButton"=dword:00000000
"TaskbarAl"=dword:00000001
"SharingWizardOn"=dword:00000000
"ShowTaskViewButton"=dword:00000001
"FolderContentsInfoTip"=dword:00000000
"ShowPreviewHandlers"=dword:00000000
"ShowSyncProviderNotifications"=dword:00000000
"Start_Layout"=dword:00000000
"Start_AccountNotifications"=dword:00000001
"Start_TrackDocs"=dword:00000000
"TaskbarMn"=dword:00000001
"ShowCopilotButton"=dword:00000000
"Start_IrisRecommendations"=dword:00000001
"TaskbarSn"=dword:00000000
"SnapAssist"=dword:00000000
"DITest"=dword:00000000
"EnableSnapBar"=dword:00000000
"EnableTaskGroups"=dword:00000000
"EnableSnapAssistFlyout"=dword:00000000
"SnapFill"=dword:00000000
"JointResize"=dword:00000000
"MultiTaskingAltTabFilter"=dword:00000003
"ShowNotificationIcon"=dword:00000001
"Start_TrackProgs"=dword:00000000
"HideMergeConflicts"=dword:00000001
"PersistBrowsers"=dword:00000001
"ShowDriveLettersFirst"=dword:00000001
"ShowEncryptCompressedColor"=dword:00000001
"TypeAhead"=dword:00000000
"NavPaneShowAllCloudStates"=dword:00000001
"NavPaneExpandToCurrentFolder"=dword:00000001
"NavPaneShowAllFolders"=dword:00000000
"TaskbarAcrylicOpacity"=dword:00000001
"UseCompactMode"=dword:00000000
"ShellViewReentered"=dword:00000001
"IsBatteryPercentageEnabled"=dword:00000001

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDeveloperSettings]
"TaskbarEndTask"=dword:00000001

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects]
"VisualFXSetting"=dword:00000003

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\AnimateMinMax]
"DefaultApplied"=dword:00000001

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\ComboBoxAnimation]
"DefaultApplied"=dword:00000001

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\ControlAnimations]
"DefaultApplied"=dword:00000001

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\CursorShadow]
"DefaultApplied"=dword:00000001

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\DragFullWindows]
"DefaultApplied"=dword:00000001

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\DropShadow]
"DefaultApplied"=dword:00000001

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\DWMAeroPeekEnabled]
"DefaultApplied"=dword:00000001

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\DWMEnabled]
"DefaultApplied"=dword:00000001

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\DWMSaveThumbnailEnabled]
"DefaultApplied"=dword:00000001

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\FontSmoothing]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\ListBoxSmoothScrolling]
"DefaultApplied"=dword:00000001

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\ListviewAlphaSelect]
"DefaultApplied"=dword:00000001

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\ListviewShadow]
"DefaultApplied"=dword:00000001

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\MenuAnimation]
"DefaultApplied"=dword:00000001

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\SelectionFade]
"DefaultApplied"=dword:00000001

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\TaskbarAnimations]
"DefaultApplied"=dword:00000001

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\Themes]
"DefaultApplied"=dword:00000001

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\ThumbnailsOrIcon]
"DefaultApplied"=dword:00000001

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\TooltipAnimation]
"DefaultApplied"=dword:00000001

[HKEY_CURRENT_USER\Software\RegisteredApplications]
"AppX9jtjmy20h3sc7d0fge82pv0n5m0hn1nf"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\MicrosoftWindows.Client.WebExperience_525.18101.90.9_x64__cw5n1h2txyewy\\Global.WidgetBoard\\Capabilities"
"AppX0pk59by1ns6e01rmke567rvnn0am6gg7"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\MicrosoftWindows.Client.WebExperience_525.18101.90.9_x64__cw5n1h2txyewy\\Widgets\\Capabilities"
"AppXyd77gezjaqx07qrz60vq8jkzd650195w"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\Microsoft.StartExperiencesApp_1.151.0.0_x64__8wekyb3d8bbwe\\MicrosoftStart\\Capabilities"
"OneDrive"="SOFTWARE\\Microsoft\\OneDrive\\Capabilities"
"AppXqvwkg9k9720mh53sx6hn1nt266gftgrg"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\MSTeams_25306.804.4102.7193_x64__8wekyb3d8bbwe\\MSTeams\\Capabilities"
"AppXqextz04sxgvyh3c7sxcj2ns2pjgw7fx4"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\Microsoft.DesktopAppInstaller_1.27.349.0_x64__8wekyb3d8bbwe\\winget\\Capabilities"
"AppXk45sn8qhwaj6ctndhznyeft20ntdxwm3"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\Microsoft.DesktopAppInstaller_1.27.349.0_x64__8wekyb3d8bbwe\\App\\Capabilities"
"AppXte104p99a33vd2119skh9vnz9dxwr26x"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\Microsoft.YourPhone_1.25112.35.0_x64__8wekyb3d8bbwe\\App\\Capabilities"
"AppXh49tdy9rg6hnspy93g8jwyg3zaxdjacz"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\MSTeams_25332.1210.4188.1171_x64__8wekyb3d8bbwe\\MSTeams\\Capabilities"
"AppX4y0dxwpt7b43y2d870hja9cts1a9bn3n"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\Microsoft.GamingApp_2512.1001.34.0_x64__8wekyb3d8bbwe\\Microsoft.Xbox.App\\Capabilities"
"AppXk2kyg55wtkvsfz2bqb8zj4hsdns4mc7q"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\Microsoft.ZuneMusic_11.2511.5.0_x64__8wekyb3d8bbwe\\Microsoft.ZuneMusic\\Capabilities"
"AppX1sq423mwjtrxm2h35j7g6skp2s76ceyc"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\MicrosoftWindows.CrossDevice_1.25112.60.0_x64__cw5n1h2txyewy\\FilesUXHostApp\\Capabilities"
"AppXqbgj9tn3nrccr2pw14gqnv9ta6qgn5nm"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\MicrosoftWindows.CrossDevice_1.25112.60.0_x64__cw5n1h2txyewy\\SettingsUXHostApp\\Capabilities"
"Firefox-308046B0AF4A39CB"="Software\\Clients\\StartMenuInternet\\Firefox-308046B0AF4A39CB\\Capabilities"
"AppXayqgxnr17bar2w3twqvegbfbf9qd76v6"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\Microsoft.StartExperiencesApp_1.195.0.0_x64__8wekyb3d8bbwe\\MicrosoftStart\\Capabilities"
"AppXe68kvad7z12rktjf39qbmx4sx4sxpts3"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\Microsoft.YourPhone_1.25112.36.0_x64__8wekyb3d8bbwe\\App\\Capabilities"
"AppXeb01ztcb53664q48h4jgegg4erqrggxh"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\Microsoft.DesktopAppInstaller_1.27.460.0_x64__8wekyb3d8bbwe\\winget\\Capabilities"
"AppXb0752qw57s2xq6p14vycra98mwpx71hz"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\Microsoft.DesktopAppInstaller_1.27.460.0_x64__8wekyb3d8bbwe\\ProtocolShim\\Capabilities"
"AppX5jxm559ngthnh52569jgs7xr3vryg0ac"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\Microsoft.DesktopAppInstaller_1.27.460.0_x64__8wekyb3d8bbwe\\App\\Capabilities"
"AppXhhfz863p67v9gpeenq0snhgfpb08nav9"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\MSTeams_26005.204.4249.1621_x64__8wekyb3d8bbwe\\MSTeams\\Capabilities"
"AppX776yny73kmp3v6fe24tpeqkjjzqgcgjp"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\MicrosoftWindows.CrossDevice_1.26011.30.0_x64__cw5n1h2txyewy\\FilesUXHostApp\\Capabilities"
"AppX64fncp4nf0jnhkyzwafkf3vrckbnc0w9"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\MicrosoftWindows.CrossDevice_1.26011.30.0_x64__cw5n1h2txyewy\\SettingsUXHostApp\\Capabilities"
"AppXm8xpfanjdx7g4c86k4hgs0rfnqwvjdh6"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\Microsoft.Windows.DevHome_0.1700.597.0_x64__8wekyb3d8bbwe\\App\\Capabilities"
"AppX6assjf8fvdyg3z1jb79ze331zrnx4g85"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\Microsoft.XboxSpeechToTextOverlay_1.111.30001.0_x64__8wekyb3d8bbwe\\App\\Capabilities"
"AppXx3gda88y8dm628gq56w86kzn348ssn1a"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\MicrosoftCorporationII.QuickAssist_2.0.35.0_x64__8wekyb3d8bbwe\\App\\Capabilities"
"AppXn7gcrf5pjpdwcybvvzg9tfyxwrpsztx8"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\Microsoft.BingWeather_4.54.63029.0_x64__8wekyb3d8bbwe\\App\\Capabilities"
"AppXpg1xyh63qfg7twm168w8ce11mh61ry9t"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\Microsoft.BingNews_4.55.62231.0_x64__8wekyb3d8bbwe\\AppexNews\\Capabilities"
"AppXgzzfreat371nkms9k7gpb45n6ha46qgn"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\Microsoft.Xbox.TCUI_1.24.10001.0_x64__8wekyb3d8bbwe\\Microsoft.Xbox.TCUI\\Capabilities"
"AppX0vtfm4w7hmaz4hbazwmnq9agxn35fpfk"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\Microsoft.WindowsCamera_2025.2510.2.0_x64__8wekyb3d8bbwe\\App\\Capabilities"
"AppXcs524rvw9xj87xt4wj51sqe5cd2h69eb"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\Microsoft.XboxIdentityProvider_12.130.16001.0_x64__8wekyb3d8bbwe\\Microsoft.XboxIdentityProvider\\Capabilities"
"AppXbw22wrwawcmtzwas1fxbtdp03b2hb3eq"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\Microsoft.WindowsCalculator_11.2508.4.0_x64__8wekyb3d8bbwe\\App\\Capabilities"
"AppXdd07k9f0ewya0acqvayev3afrw1y1v1b"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\AD2F1837.HPSystemInformation_8.10.49.0_x64__v10z8vjag6ke6\\App\\Capabilities"
"AppXenxq3g6a116da4re0tbwqggtv2cbfqcb"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\Microsoft.GetHelp_10.2409.33293.0_x64__8wekyb3d8bbwe\\App\\Capabilities"
"AppX2whnw5tsxmt2x5p1qz6pzzq8c0p0ern8"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\AD2F1837.HPPrivacySettings_1.4.17.0_x64__v10z8vjag6ke6\\App\\Capabilities"
"AppX0nqt9ya1hkz4zvd2m2ntte26p8hpkx28"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\Microsoft.OutlookForWindows_1.2026.120.300_x64__8wekyb3d8bbwe\\Microsoft.OutlookforWindows\\Capabilities"
"AppXdbp18q92wqja7fq61bq1dxt1tsvxp840"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\Microsoft.MicrosoftSolitaireCollection_4.25.1130.0_x64__8wekyb3d8bbwe\\App\\Capabilities"
"AppXkwkxf26vfw2g2tcft4dp0mgfy8hzkjmr"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\Microsoft.StorePurchaseApp_22512.1401.1.0_x64__8wekyb3d8bbwe\\App\\Capabilities"
"AppX5wm6qjn68aqfwzdcca8qs73jr8eav4pk"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\Microsoft.WindowsAlarms_1.1.85.0_x64__8wekyb3d8bbwe\\App\\Capabilities"
"AppX493333wbyrwpxbdzz2mkqvezkm3k2pcn"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\MicrosoftWindows.Client.WebExperience_526.1202.40.0_x64__cw5n1h2txyewy\\Global.WidgetBoard\\Capabilities"
"AppXq13jt2kawcz4f7jq7197nsw46f7t7krs"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\MicrosoftWindows.Client.WebExperience_526.1202.40.0_x64__cw5n1h2txyewy\\Widgets\\Capabilities"
"AppXgh4ryxp11e17perynzap0bgjgdynbzkw"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\Microsoft.WindowsSoundRecorder_1.1.86.0_x64__8wekyb3d8bbwe\\App\\Capabilities"
"AppXdgd4vt15g1awvzqs742xdz8fkrfekssv"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\Clipchamp.Clipchamp_4.5.10220.0_x64__yxz26nhyzhsrt\\App\\Capabilities"
"AppXpy4m3tcg3xf0n91k4131evfk6gy52e4p"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\Microsoft.SecHealthUI_1000.29510.1001.0_x64__8wekyb3d8bbwe\\SecHealthUI\\Capabilities"
"AppXn2ykayk5z4vx3tc12e5ba8q099mxf4jf"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\AD2F1837.HPSupportAssistant_9.51.14.0_x64__v10z8vjag6ke6\\AD2F1837.HPSupportAssistant\\Capabilities"
"AppXkncxtqr76z8vmv3py7y2wtgev4nb09a3"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\Microsoft.GamingApp_2602.1001.5.0_x64__8wekyb3d8bbwe\\Microsoft.Xbox.App\\Capabilities"
"AppXzj709k8axskj0enfwn28mvk629aqep6n"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\Microsoft.GamingApp_2602.1001.5.0_x64__8wekyb3d8bbwe\\Microsoft.Xbox.AppL\\Capabilities"
"AppX06nanp4zn2ad4m07dc07hn4nv371prq3"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\Microsoft.WindowsFeedbackHub_1.2602.13304.0_x64__8wekyb3d8bbwe\\App\\Capabilities"
"AppXx2441qd0mz5e0qfag784ygkfa75rh050"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\Microsoft.PowerAutomateDesktop_1.0.2062.0_x64__8wekyb3d8bbwe\\PAD.Console\\Capabilities"
"AppXfaa8g497vz21f1vjvqhn7s8mt1tc8830"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\Microsoft.XboxGamingOverlay_7.326.2102.0_x64__8wekyb3d8bbwe\\App\\Capabilities"
"AppXpyeez0szkzv67k9qpj8nm4rn6s8121y6"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\Microsoft.Paint_11.2601.401.0_x64__8wekyb3d8bbwe\\App\\Capabilities"
"AppX3rk31cat1xrwzk1b57tcek7z63fx95h7"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\Microsoft.ZuneMusic_11.2601.11.0_x64__8wekyb3d8bbwe\\Microsoft.ZuneMusic\\Capabilities"
"AppXvj0fjfnexsg94qz0wv5mt5vch6agy6xc"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\Microsoft.ScreenSketch_11.2601.0.0_x64__8wekyb3d8bbwe\\App\\Capabilities"
"AppX9de18byvxt0zbdtmh5p0r76ta9nsqz75"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\Microsoft.StartExperiencesApp_1.241.0.0_x64__8wekyb3d8bbwe\\MicrosoftStart\\Capabilities"
"AppXqmtwh95d25y07rga3940b1h8bpwgd85a"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\Microsoft.WindowsNotepad_11.2512.26.0_x64__8wekyb3d8bbwe\\App\\Capabilities"
"AppXpxn4n78a9402f2d4grxckw28dwex9q6x"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\Microsoft.Windows.Photos_2026.11020.20001.0_x64__8wekyb3d8bbwe\\App\\Capabilities"
"AppXs835zaq5g4q8bc32jkjmvrd0t1mh3vcd"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\Microsoft.Todos_0.172.6603.0_x64__8wekyb3d8bbwe\\App\\Capabilities"
"AppXh71nrzbrmbhbvtqz5tk3ckk9hhdje7tq"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\Microsoft.6365217CE6EB4_102.2511.3002.0_x64__8wekyb3d8bbwe\\App\\Capabilities"
"AppXq2dmr3tpb41rdx2rezbeaareesfs046k"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\MicrosoftTeams_25227.501.3887.7600_x64__8wekyb3d8bbwe\\MicrosoftTeams\\Capabilities"
"AppX7b0gdyyngfwe8tks6kkb7fdzfykrywgt"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\Microsoft.MSIXPackagingTool_1.2024.405.0_x64__8wekyb3d8bbwe\\Msix.App\\Capabilities"
"AppX712zn8m91hea9dtj1nr9hp834593fh8s"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\Microsoft.CommandPalette_0.8.10263.0_x64__8wekyb3d8bbwe\\App\\Capabilities"
"AppX561zmt96c3r796t6px2q931k0yj3aap5"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\Microsoft.CompanyPortal_11.2.1753.0_x64__8wekyb3d8bbwe\\App\\Capabilities"
"AppX8cm2d9zkgp5ev1n1jtqt02hygv8n1pk9"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\Microsoft.WindowsStore_22601.1401.6.0_x64__8wekyb3d8bbwe\\App\\Capabilities"
"AppXx7wvh0w8rvak6bh3sxxqdr4fpppafm26"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\Microsoft.YourPhone_1.26012.101.0_x64__8wekyb3d8bbwe\\App\\Capabilities"
"AppX99r8zv79szrqvpf0jynjdcxcszyp8pd2"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\Microsoft.DesktopAppInstaller_1.28.220.0_x64__8wekyb3d8bbwe\\winget\\Capabilities"
"AppXbetg05v5v5jke0vnbtk81w6h541kejbh"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\Microsoft.DesktopAppInstaller_1.28.220.0_x64__8wekyb3d8bbwe\\ProtocolShim\\Capabilities"
"AppX7m5xkg51hafw8mehwcq4az1xrxm0chvf"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\Microsoft.DesktopAppInstaller_1.28.220.0_x64__8wekyb3d8bbwe\\App\\Capabilities"
"AppXxs2c17khywj52vrhjgabes0b0qy0gnrr"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\MicrosoftWindows.CrossDevice_1.26012.79.0_x64__cw5n1h2txyewy\\FilesUXHostApp\\Capabilities"
"AppXprf6srj8w6ynkes8jbkwjdnwv15ca06x"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\MicrosoftWindows.CrossDevice_1.26012.79.0_x64__cw5n1h2txyewy\\SettingsUXHostApp\\Capabilities"
"AppXj5jfdfsj2rtete93aznbasbdd4hx8478"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\MSTeams_26032.208.4399.5_x64__8wekyb3d8bbwe\\MSTeams\\Capabilities"

[HKEY_CURRENT_USER\Software\RegisteredApplications\PackagedApps]
"Microsoft.Windows.DevHome_8wekyb3d8bbwe!App"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\Microsoft.Windows.DevHome_0.1700.597.0_x64__8wekyb3d8bbwe\\App\\Capabilities"
"Microsoft.XboxSpeechToTextOverlay_8wekyb3d8bbwe!App"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\Microsoft.XboxSpeechToTextOverlay_1.111.30001.0_x64__8wekyb3d8bbwe\\App\\Capabilities"
"MicrosoftCorporationII.QuickAssist_8wekyb3d8bbwe!App"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\MicrosoftCorporationII.QuickAssist_2.0.35.0_x64__8wekyb3d8bbwe\\App\\Capabilities"
"Microsoft.BingWeather_8wekyb3d8bbwe!App"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\Microsoft.BingWeather_4.54.63029.0_x64__8wekyb3d8bbwe\\App\\Capabilities"
"Microsoft.BingNews_8wekyb3d8bbwe!AppexNews"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\Microsoft.BingNews_4.55.62231.0_x64__8wekyb3d8bbwe\\AppexNews\\Capabilities"
"Microsoft.Xbox.TCUI_8wekyb3d8bbwe!Microsoft.Xbox.TCUI"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\Microsoft.Xbox.TCUI_1.24.10001.0_x64__8wekyb3d8bbwe\\Microsoft.Xbox.TCUI\\Capabilities"
"Microsoft.WindowsCamera_8wekyb3d8bbwe!App"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\Microsoft.WindowsCamera_2025.2510.2.0_x64__8wekyb3d8bbwe\\App\\Capabilities"
"Microsoft.XboxIdentityProvider_8wekyb3d8bbwe!Microsoft.XboxIdentityProvider"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\Microsoft.XboxIdentityProvider_12.130.16001.0_x64__8wekyb3d8bbwe\\Microsoft.XboxIdentityProvider\\Capabilities"
"Microsoft.WindowsCalculator_8wekyb3d8bbwe!App"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\Microsoft.WindowsCalculator_11.2508.4.0_x64__8wekyb3d8bbwe\\App\\Capabilities"
"AD2F1837.HPSystemInformation_v10z8vjag6ke6!App"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\AD2F1837.HPSystemInformation_8.10.49.0_x64__v10z8vjag6ke6\\App\\Capabilities"
"Microsoft.GetHelp_8wekyb3d8bbwe!App"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\Microsoft.GetHelp_10.2409.33293.0_x64__8wekyb3d8bbwe\\App\\Capabilities"
"AD2F1837.HPPrivacySettings_v10z8vjag6ke6!App"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\AD2F1837.HPPrivacySettings_1.4.17.0_x64__v10z8vjag6ke6\\App\\Capabilities"
"Microsoft.OutlookForWindows_8wekyb3d8bbwe!Microsoft.OutlookforWindows"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\Microsoft.OutlookForWindows_1.2026.120.300_x64__8wekyb3d8bbwe\\Microsoft.OutlookforWindows\\Capabilities"
"Microsoft.MicrosoftSolitaireCollection_8wekyb3d8bbwe!App"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\Microsoft.MicrosoftSolitaireCollection_4.25.1130.0_x64__8wekyb3d8bbwe\\App\\Capabilities"
"Microsoft.StorePurchaseApp_8wekyb3d8bbwe!App"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\Microsoft.StorePurchaseApp_22512.1401.1.0_x64__8wekyb3d8bbwe\\App\\Capabilities"
"Microsoft.WindowsAlarms_8wekyb3d8bbwe!App"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\Microsoft.WindowsAlarms_1.1.85.0_x64__8wekyb3d8bbwe\\App\\Capabilities"
"MicrosoftWindows.Client.WebExperience_cw5n1h2txyewy!Global.WidgetBoard"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\MicrosoftWindows.Client.WebExperience_526.1202.40.0_x64__cw5n1h2txyewy\\Global.WidgetBoard\\Capabilities"
"MicrosoftWindows.Client.WebExperience_cw5n1h2txyewy!Widgets"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\MicrosoftWindows.Client.WebExperience_526.1202.40.0_x64__cw5n1h2txyewy\\Widgets\\Capabilities"
"Microsoft.WindowsSoundRecorder_8wekyb3d8bbwe!App"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\Microsoft.WindowsSoundRecorder_1.1.86.0_x64__8wekyb3d8bbwe\\App\\Capabilities"
"Clipchamp.Clipchamp_yxz26nhyzhsrt!App"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\Clipchamp.Clipchamp_4.5.10220.0_x64__yxz26nhyzhsrt\\App\\Capabilities"
"Microsoft.SecHealthUI_8wekyb3d8bbwe!SecHealthUI"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\Microsoft.SecHealthUI_1000.29510.1001.0_x64__8wekyb3d8bbwe\\SecHealthUI\\Capabilities"
"AD2F1837.HPSupportAssistant_v10z8vjag6ke6!AD2F1837.HPSupportAssistant"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\AD2F1837.HPSupportAssistant_9.51.14.0_x64__v10z8vjag6ke6\\AD2F1837.HPSupportAssistant\\Capabilities"
"Microsoft.GamingApp_8wekyb3d8bbwe!Microsoft.Xbox.App"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\Microsoft.GamingApp_2602.1001.5.0_x64__8wekyb3d8bbwe\\Microsoft.Xbox.App\\Capabilities"
"Microsoft.GamingApp_8wekyb3d8bbwe!Microsoft.Xbox.AppL"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\Microsoft.GamingApp_2602.1001.5.0_x64__8wekyb3d8bbwe\\Microsoft.Xbox.AppL\\Capabilities"
"Microsoft.WindowsFeedbackHub_8wekyb3d8bbwe!App"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\Microsoft.WindowsFeedbackHub_1.2602.13304.0_x64__8wekyb3d8bbwe\\App\\Capabilities"
"Microsoft.PowerAutomateDesktop_8wekyb3d8bbwe!PAD.Console"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\Microsoft.PowerAutomateDesktop_1.0.2062.0_x64__8wekyb3d8bbwe\\PAD.Console\\Capabilities"
"Microsoft.XboxGamingOverlay_8wekyb3d8bbwe!App"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\Microsoft.XboxGamingOverlay_7.326.2102.0_x64__8wekyb3d8bbwe\\App\\Capabilities"
"Microsoft.Paint_8wekyb3d8bbwe!App"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\Microsoft.Paint_11.2601.401.0_x64__8wekyb3d8bbwe\\App\\Capabilities"
"Microsoft.ZuneMusic_8wekyb3d8bbwe!Microsoft.ZuneMusic"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\Microsoft.ZuneMusic_11.2601.11.0_x64__8wekyb3d8bbwe\\Microsoft.ZuneMusic\\Capabilities"
"Microsoft.ScreenSketch_8wekyb3d8bbwe!App"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\Microsoft.ScreenSketch_11.2601.0.0_x64__8wekyb3d8bbwe\\App\\Capabilities"
"Microsoft.StartExperiencesApp_8wekyb3d8bbwe!MicrosoftStart"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\Microsoft.StartExperiencesApp_1.241.0.0_x64__8wekyb3d8bbwe\\MicrosoftStart\\Capabilities"
"Microsoft.WindowsNotepad_8wekyb3d8bbwe!App"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\Microsoft.WindowsNotepad_11.2512.26.0_x64__8wekyb3d8bbwe\\App\\Capabilities"
"Microsoft.Windows.Photos_8wekyb3d8bbwe!App"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\Microsoft.Windows.Photos_2026.11020.20001.0_x64__8wekyb3d8bbwe\\App\\Capabilities"
"Microsoft.Todos_8wekyb3d8bbwe!App"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\Microsoft.Todos_0.172.6603.0_x64__8wekyb3d8bbwe\\App\\Capabilities"
"Microsoft.6365217CE6EB4_8wekyb3d8bbwe!App"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\Microsoft.6365217CE6EB4_102.2511.3002.0_x64__8wekyb3d8bbwe\\App\\Capabilities"
"MicrosoftTeams_8wekyb3d8bbwe!MicrosoftTeams"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\MicrosoftTeams_25227.501.3887.7600_x64__8wekyb3d8bbwe\\MicrosoftTeams\\Capabilities"
"Microsoft.MSIXPackagingTool_8wekyb3d8bbwe!Msix.App"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\Microsoft.MSIXPackagingTool_1.2024.405.0_x64__8wekyb3d8bbwe\\Msix.App\\Capabilities"
"Microsoft.CommandPalette_8wekyb3d8bbwe!App"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\Microsoft.CommandPalette_0.8.10263.0_x64__8wekyb3d8bbwe\\App\\Capabilities"
"Microsoft.CompanyPortal_8wekyb3d8bbwe!App"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\Microsoft.CompanyPortal_11.2.1753.0_x64__8wekyb3d8bbwe\\App\\Capabilities"
"Microsoft.WindowsStore_8wekyb3d8bbwe!App"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\Microsoft.WindowsStore_22601.1401.6.0_x64__8wekyb3d8bbwe\\App\\Capabilities"
"Microsoft.YourPhone_8wekyb3d8bbwe!App"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\Microsoft.YourPhone_1.26012.101.0_x64__8wekyb3d8bbwe\\App\\Capabilities"
"Microsoft.DesktopAppInstaller_8wekyb3d8bbwe!winget"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\Microsoft.DesktopAppInstaller_1.28.220.0_x64__8wekyb3d8bbwe\\winget\\Capabilities"
"Microsoft.DesktopAppInstaller_8wekyb3d8bbwe!ProtocolShim"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\Microsoft.DesktopAppInstaller_1.28.220.0_x64__8wekyb3d8bbwe\\ProtocolShim\\Capabilities"
"Microsoft.DesktopAppInstaller_8wekyb3d8bbwe!App"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\Microsoft.DesktopAppInstaller_1.28.220.0_x64__8wekyb3d8bbwe\\App\\Capabilities"
"MicrosoftWindows.CrossDevice_cw5n1h2txyewy!FilesUXHostApp"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\MicrosoftWindows.CrossDevice_1.26012.79.0_x64__cw5n1h2txyewy\\FilesUXHostApp\\Capabilities"
"MicrosoftWindows.CrossDevice_cw5n1h2txyewy!SettingsUXHostApp"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\MicrosoftWindows.CrossDevice_1.26012.79.0_x64__cw5n1h2txyewy\\SettingsUXHostApp\\Capabilities"
"MSTeams_8wekyb3d8bbwe!MSTeams"="Software\\Classes\\Local Settings\\Software\\Microsoft\\Windows\\CurrentVersion\\AppModel\\Repository\\Packages\\MSTeams_26032.208.4399.5_x64__8wekyb3d8bbwe\\MSTeams\\Capabilities"

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Lock Screen]
"LockAppAumId"="Microsoft.LockApp_cw5n1h2txyewy!WindowsDefaultLockScreen"
"FirstLockAfterOSInstall"="26100.ge_release.240331-1435"
"IsNewUserOrFirstLockSinceUpgradeFromWin10OrLower"=dword:00000001
"LockInstanceType"=dword:00000003
"HasMigratedDetailedStatus"=dword:00000001
"PreplacedWidgetsAttempted"=dword:00000000
"SlideshowEnabled"=dword:00000001
"TileMigrated"=dword:00000003
"SlideshowSourceDirectoriesSet"=dword:00000001
"SlideshowDirectoryPath1"="pHAFA8BUg/E0gouOpBhoYjAArADMdmBAvMkOcBAAAAAAAAAAAAAAAAAAAAAAAAAeAEDAAAAAA8GXJrQEAU1clJ3cAQGAJAABA8uvBiVq68GXJrgLAAAAz9DAAAAAOAAAAAAAAAAAAoDAAAAAA0q6pCQVAMHAlBgcAMHAAAAQAMHAoBQZAwGAsBwMAIDAuAAZAwGAsBALA0CAyAQMAgDAxAwMAAAAUAAUAEDAAAAAA0GXcFGEAkXYu5WMAwDAJAABA8uvQu1MY1GXiFmLAAAAQgcBAAAALAAAAAAAAAAAAAAAAAAAAcj+rCQeAEGAuBgbAEDAAAAFAoFAxAAAAAAAvxlBLFDBP5WZEJXa2VGAAIEAJAABA8uvQuFuZ9GXGskLAAAAZSsDAAAADAAAAAAAaAHAQCAAAAAAAsjwqCwTA4GAlBARAIHApBgdAUGAAAAGAgJAxAAAAAAAtxF1DGBBJ1WYnV2cAAgdAkAAEAw7+C5WPnVbc1GYuAAAAY7vOAAAAUAAAAAAAoBYAAJPAAAAAAAG4RIAJBQbAEGAnBQZAMHAAAAQAcHApBgbAQGAvBwdAMHAuAwcAQHAvBgcAEGAnBQZA4CAkBAbAwGAsAQLAIDAxAwNAcDA5AAAAYBAMAAAAkCAv7LCAYBAAAA"
"SlideshowDirectoryPath2"="2AAFA8BVlgkHDQ5eD3UsxkuR0yUjVDCAAAgGA4+u+PCAAABAf6KkpuDoA6El8mpEXDVQEAAAAAA"
"SlideshowEnabledOnBattery"=dword:00000001
"SlideshowIncludeCameraRoll"=dword:00000001

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Lock Screen\Creative]
"LockImageFlags"=dword:00000000
"CreativeId"=""
"PortraitAssetPath"=""
"LandscapeAssetPath"=""
"DescriptionText"=""
"ActionText"=""
"ActionUri"=""
"PlacementId"=""
"LockScreenOptions"=dword:00000001
"ClickthroughToken"=""
"ImpressionToken"=""
"HotspotImageFolderPath"=""
"CreativeJson"=""

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Lock Screen\FeedManager]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Lock Screen\FeedManager\Feeds]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Lock Screen\FeedManager\Selected]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager]
"FeatureManagementEnabled"=dword:00000001
"OemPreInstalledAppsEnabled"=dword:00000001
"PreInstalledAppsEnabled"=dword:00000001
"RotatingLockScreenEnabled"=dword:00000001
"RotatingLockScreenOverlayEnabled"=dword:00000001
"SilentInstalledAppsEnabled"=dword:00000001
"SoftLandingEnabled"=dword:00000001
"SystemPaneSuggestionsEnabled"=dword:00000001
"IdentityProvider"="{ED4515F3-DA33-4717-9228-3D8668614BE6}"
"SubscribedContent-LocksreenEnabled"=dword:00000001
"ContentDeliveryAllowed"=dword:00000001
"SubscribedContent-338389Enabled"=dword:00000001
"SubscribedContent-338387Enabled"=dword:00000001
"SoftLandingEnabled "=dword:00000001
"PreInstalledAppsEverEnabled"=dword:00000001
"SlideshowEnabled"=dword:00000001
"SubscribedContent-310093Enabled"=dword:00000001
"SubscribedContent-314563Enabled"=dword:00000001
"SubscribedContent-338388Enabled"=dword:00000001
"SubscribedContent-338393Enabled"=dword:00000001
"SubscribedContent-353694Enabled"=dword:00000001
"SubscribedContent-353696Enabled"=dword:00000001
"SubscribedContent-353698Enabled"=dword:00000001
"SubscribedContentEnabled"=dword:00000001

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\CreativeEventCache]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\CreativeEventCache\SubscribedContent-338387]
"1773325884`533181175`0`dded36edda8f4564bd7003c440a16fbf`82800`338387`134190090850000000-0-/?eventName=impression"=hex(b):64,\
  f5,3a,db,2d,b2,dc,01
"LastCreativeBatchId"="1773325884"
"1773325884`533181175`0`dded36edda8f4564bd7003c440a16fbf`82800`338387`134190090850000000-0-//item[0]?eventName=impression"=hex(b):15,\
  44,3b,db,2d,b2,dc,01
"1773325884`533181175`0`dded36edda8f4564bd7003c440a16fbf`82800`338387`134190090850000000-0-//item[2]?eventName=impression"=hex(b):a3,\
  a3,3b,db,2d,b2,dc,01
"1773325884`533181175`0`dded36edda8f4564bd7003c440a16fbf`82800`338387`134190090850000000-0-//item[1]?eventName=impression"=hex(b):14,\
  ef,3b,db,2d,b2,dc,01

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\CreativeEvents]
@=dword:00000001

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\CreativeEvents\FeatureManagement]
@=dword:00000001

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\CreativeEvents\SubscribedContent-202914]
@=dword:00000001

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\CreativeEvents\SubscribedContent-280810]
@=dword:00000001

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\CreativeEvents\SubscribedContent-280811]
@=dword:00000001

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\CreativeEvents\SubscribedContent-280815]
@=dword:00000001

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\CreativeEvents\SubscribedContent-310091]
@=dword:00000001

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\CreativeEvents\SubscribedContent-310093]
@=dword:00000001

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\CreativeEvents\SubscribedContent-338387]
@=dword:00000001

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\CreativeEvents\SubscribedContent-338389]
@=dword:00000001

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\CreativeEvents\SubscribedContent-353694]
@=dword:00000001

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\CreativeEvents\SubscribedContent-353698]
@=dword:00000001

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\CreativeEvents\SubscribedContent-88000045]
@=dword:00000001

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\CreativeEvents\SubscribedContent-88000161]
@=dword:00000001

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\CreativeEvents\SubscribedContent-88000163]
@=dword:00000001

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\CreativeEvents\SubscribedContent-88000165]
@=dword:00000001

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\CreativeEvents\SubscribedContent-Locksreen]
@=dword:00000001

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\Health]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\Health\Placement-10]
"HealthEvaluation"=hex:04,00,00,00,00,00,00,00,35,d9,ac,bc,5d,b4,dc,01,02,00,\
  02,00,00,00,00,00,89,b7,a2,c6,7b,6e,dc,01,24,11,00,00
@=hex:04,00,00,00,fd,7f,00,00,30,59,a2,3a,29,b2,dc,01,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
"PlacementReported"=hex:04,00,00,00,00,00,00,00,6c,86,39,bc,5d,b4,dc,01,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\Health\Placement-8]
"HealthEvaluation"=hex:04,00,00,00,00,00,00,00,57,97,9d,bc,5d,b4,dc,01,02,00,\
  02,00,00,00,00,00,3b,8f,7c,c6,7b,6e,dc,01,11,11,00,00

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\Health\Placement-SubscribedContent-202914]
@=hex:04,00,00,00,00,00,00,00,db,53,ef,b2,3b,81,dc,01,0a,57,50,aa,36,b2,dc,01,\
  5f,48,42,27,9f,80,dc,01,00,00,00,00,00,00,00,00,e2,9d,1f,b3,3b,81,dc,01,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,01,01,00,00
"HealthEvaluation"=hex:04,00,00,00,00,00,00,00,3d,25,9f,bc,5d,b4,dc,01,02,00,\
  02,00,00,00,00,00,03,34,7e,c6,7b,6e,dc,01,47,11,00,00

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\Health\Placement-SubscribedContent-280810]
@=hex:04,00,00,00,00,00,00,00,8c,81,91,a9,a9,b0,dc,01,f3,ed,e6,7c,34,b2,dc,01,\
  b3,c8,4a,68,30,b2,dc,01,00,00,00,00,00,00,00,00,79,38,45,25,2e,b2,dc,01,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,01,00,\
  00,00,01,00,00,00,00,00,00,00,00,00,00,00,01,00,00,00
"HealthEvaluation"=hex:04,00,00,00,00,00,00,00,07,93,a1,bc,5d,b4,dc,01,02,00,\
  02,00,00,00,00,00,bc,d7,76,11,7d,6e,dc,01,69,11,00,00

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\Health\Placement-SubscribedContent-280811]
@=hex:04,00,00,00,00,00,00,00,98,86,32,92,a9,b0,dc,01,f3,ed,e6,7c,34,b2,dc,01,\
  25,08,52,68,30,b2,dc,01,00,00,00,00,00,00,00,00,70,5f,45,25,2e,b2,dc,01,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,01,00,\
  00,00,01,00,00,00,00,00,00,00,00,00,00,00,01,00,00,00
"HealthEvaluation"=hex:04,00,00,00,00,00,00,00,07,93,a1,bc,5d,b4,dc,01,02,00,\
  02,00,00,00,00,00,e9,a1,b5,11,7d,6e,dc,01,68,11,00,00

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\Health\Placement-SubscribedContent-280815]
@=hex:04,00,00,00,fd,7f,00,00,41,bc,fe,81,a9,b0,dc,01,0a,57,50,aa,36,b2,dc,01,\
  cb,13,81,82,ec,af,e7,01,00,00,00,00,00,00,00,00,8d,e1,a9,a8,a9,b0,dc,01,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,01,00,\
  00,00,01,00,00,00,00,00,00,00,00,00,00,00,01,00,00,00
"HealthEvaluation"=hex:04,00,00,00,00,00,00,00,07,93,a1,bc,5d,b4,dc,01,02,00,\
  02,00,00,00,00,00,8c,93,7f,c6,7b,6e,dc,01,35,11,00,00

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\Health\Placement-SubscribedContent-310091]
@=hex:04,00,00,00,fd,7f,00,00,23,f3,9c,48,2e,b2,dc,01,86,d4,85,72,f7,b2,dc,01,\
  1d,f9,f9,99,2e,bd,dc,01,00,00,00,00,00,00,00,00,9b,37,29,61,2e,b2,dc,01,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,01,00,\
  00,00,01,00,00,00,00,00,00,00,00,00,00,00,01,00,00,00
"HealthEvaluation"=hex:04,00,00,00,00,00,00,00,97,00,a4,bc,5d,b4,dc,01,02,00,\
  02,00,00,00,00,00,65,bb,7f,44,3a,a7,dc,01,13,11,00,00

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\Health\Placement-SubscribedContent-310093]
"HealthEvaluation"=hex:04,00,00,00,00,00,00,00,12,5a,a4,bc,5d,b4,dc,01,02,00,\
  02,00,00,00,00,00,52,33,95,c6,7b,6e,dc,01,24,11,00,00

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\Health\Placement-SubscribedContent-338387]
@=hex:04,00,00,00,fd,7f,00,00,b0,dc,d1,e7,2c,b2,dc,01,a6,7f,75,61,ae,b2,dc,01,\
  ad,6d,8c,a4,ee,b2,dc,01,a9,85,25,a9,a9,b0,dc,01,82,da,e5,25,2d,b2,dc,01,86,\
  e7,3e,dc,2d,b2,dc,01,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,03,00,\
  00,00,03,00,00,00,00,00,00,00,00,00,00,00,01,00,00,00
"HealthEvaluation"=hex:04,00,00,00,00,00,00,00,0e,e3,a5,bc,5d,b4,dc,01,02,00,\
  02,00,00,00,00,00,b2,b3,82,a6,c6,ab,dc,01,25,05,00,00
"PlacementReported"=hex:04,00,00,00,6f,01,00,00,a3,a3,3b,db,2d,b2,dc,01,a3,a3,\
  3b,db,2d,b2,dc,01,80,dc,7d,39,2d,bd,dc,01,00,00,00,00

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\Health\Placement-SubscribedContent-338389]
@=hex:04,00,00,00,fd,7f,00,00,d4,e7,ff,79,6d,a7,dc,01,3d,40,5f,dd,8e,a7,dc,01,\
  e4,7b,0e,7a,6d,a7,dc,01,00,00,00,00,00,00,00,00,ce,27,d3,86,6d,a7,dc,01,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,01,01,00,00
"HealthEvaluation"=hex:04,00,00,00,00,00,00,00,a1,31,a6,bc,5d,b4,dc,01,02,00,\
  02,00,00,00,00,00,e0,6c,98,c6,7b,6e,dc,01,60,11,00,00

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\Health\Placement-SubscribedContent-353694]
@=hex:04,00,00,00,fd,7f,00,00,41,f7,f7,b2,3b,81,dc,01,0a,57,50,aa,36,b2,dc,01,\
  14,e6,11,b3,3b,81,dc,01,00,00,00,00,00,00,00,00,00,7b,e3,ba,3b,81,dc,01,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,01,01,00,00
"HealthEvaluation"=hex:04,00,00,00,00,00,00,00,60,ec,a6,bc,5d,b4,dc,01,02,00,\
  02,00,00,00,00,00,aa,ec,99,c6,7b,6e,dc,01,40,11,00,00

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\Health\Placement-SubscribedContent-353698]
@=hex:04,00,00,00,fd,7f,00,00,36,5b,1d,5d,07,7f,dc,01,0a,57,50,aa,36,b2,dc,01,\
  5d,d4,c9,82,ec,af,e7,01,00,00,00,00,00,00,00,00,88,09,5d,71,07,7f,dc,01,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,01,00,\
  00,00,01,00,00,00,00,00,00,00,00,00,00,00,01,00,00,00
"HealthEvaluation"=hex:04,00,00,00,00,00,00,00,37,96,a7,bc,5d,b4,dc,01,02,00,\
  02,00,00,00,00,00,cc,75,9b,c6,7b,6e,dc,01,28,11,00,00

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\Health\Placement-SubscribedContent-88000045]
@=hex:04,00,00,00,fd,7f,00,00,04,fa,31,92,a9,b0,dc,01,0a,57,50,aa,36,b2,dc,01,\
  33,cd,da,82,ec,af,e7,01,00,00,00,00,00,00,00,00,c3,df,cf,a8,a9,b0,dc,01,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,01,00,\
  00,00,01,00,00,00,00,00,00,00,00,00,00,00,01,00,00,00
"HealthEvaluation"=hex:04,00,00,00,00,00,00,00,39,32,a9,bc,5d,b4,dc,01,02,00,\
  02,00,00,00,00,00,85,f4,9c,c6,7b,6e,dc,01,34,11,00,00

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\Health\Placement-SubscribedContent-88000161]
@=hex:04,00,00,00,fd,7f,00,00,40,0c,fc,81,a9,b0,dc,01,0a,57,50,aa,36,b2,dc,01,\
  77,8e,60,68,30,b2,dc,01,00,00,00,00,00,00,00,00,68,11,45,25,2e,b2,dc,01,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,01,00,\
  00,00,01,00,00,00,00,00,00,00,00,00,00,00,01,00,00,00
"HealthEvaluation"=hex:04,00,00,00,00,00,00,00,90,7d,aa,bc,5d,b4,dc,01,02,00,\
  02,00,00,00,00,00,a1,73,9e,c6,7b,6e,dc,01,6a,11,00,00

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\Health\Placement-SubscribedContent-88000163]
@=hex:04,00,00,00,fd,7f,00,00,04,fa,31,92,a9,b0,dc,01,0a,57,50,aa,36,b2,dc,01,\
  20,d8,67,68,30,b2,dc,01,00,00,00,00,00,00,00,00,d3,22,46,25,2e,b2,dc,01,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,01,00,\
  00,00,01,00,00,00,00,00,00,00,00,00,00,00,01,00,00,00
"HealthEvaluation"=hex:04,00,00,00,00,00,00,00,f2,55,ab,bc,5d,b4,dc,01,02,00,\
  02,00,00,00,00,00,ea,fd,9f,c6,7b,6e,dc,01,6a,11,00,00

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\Health\Placement-SubscribedContent-88000165]
@=hex:04,00,00,00,fd,7f,00,00,67,92,31,92,a9,b0,dc,01,0a,57,50,aa,36,b2,dc,01,\
  ec,95,71,68,30,b2,dc,01,00,00,00,00,00,00,00,00,e8,49,46,25,2e,b2,dc,01,00,\
  00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,01,00,\
  00,00,01,00,00,00,00,00,00,00,00,00,00,00,01,00,00,00
"HealthEvaluation"=hex:04,00,00,00,00,00,00,00,f2,55,ab,bc,5d,b4,dc,01,02,00,\
  02,00,00,00,00,00,06,7d,a1,c6,7b,6e,dc,01,6a,11,00,00

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\Health\Placement-SubscribedContent-Locksreen]
"HealthEvaluation"=hex:04,00,00,00,00,00,00,00,35,d9,ac,bc,5d,b4,dc,01,02,00,\
  02,00,00,00,00,00,89,b7,a2,c6,7b,6e,dc,01,24,11,00,00

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\Renderers]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\Renderers\SubscribedContent-310091]
"Version"="2"

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\Renderers\SubscribedContent-310092]
"Version"="2"

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\Renderers\SubscribedContent-338380]
"Version"="2"

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\Renderers\SubscribedContent-338381]
"Version"="2"

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\Renderers\SubscribedContent-338387]
"Version"="2"

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\Renderers\SubscribedContent-338388]
"Version"="2"

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\Subscriptions]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\Subscriptions\202914]
"LastAccessed"=hex(b):8a,40,fa,16,2c,b2,dc,01
"ContentId"=""
"ShortContentId"=""
"Availability"=dword:00000000
"HasContent"=dword:00000000
"UpdateDrivenByExpiration"=dword:00000001

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\Subscriptions\280810]
"SubscriptionContext"="sc-kfm=14&sc-quota=6"
"SubscriptionEligibilityTags"="14&6"
"LastAccessed"=hex(b):ef,4d,0c,c3,07,b4,dc,01
"AccelerateCacheRefreshLastDetected"=hex(b):6e,75,14,59,fe,b3,dc,01
"AccelerateUpdatePlacementLastDetected"=hex(b):6e,75,14,59,fe,b3,dc,01
"AccelerateUpdatePlacementLastHandled"=hex(b):60,bf,3e,68,30,b2,dc,01
"ContentId"="6228604010`673555555556172954`5`6672433n21p19870n24864q3q48qr816`159355`735365`682726299555555555"
"ShortContentId"="1127988a76c64325a79319d8d93de361"
"Availability"=dword:00000002
"HasContent"=dword:00000001
"UpdateDrivenByExpiration"=dword:00000001
"LastUpdated"=hex(b):87,25,8c,c1,a9,b0,dc,01

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\Subscriptions\280811]
"SubscriptionContext"="sc-kfm=14&sc-quota=6"
"SubscriptionEligibilityTags"="14&6"
"LastAccessed"=hex(b):ca,9c,0c,c3,07,b4,dc,01
"AccelerateCacheRefreshLastDetected"=hex(b):6e,75,14,59,fe,b3,dc,01
"AccelerateUpdatePlacementLastDetected"=hex(b):6e,75,14,59,fe,b3,dc,01
"AccelerateUpdatePlacementLastHandled"=hex(b):b3,c8,4a,68,30,b2,dc,01
"ContentId"="6228604071`673555555556172954`5`sq5r988n305192nsnqn55404nsr8q81o`159355`735366`682726299555555555"
"ShortContentId"="fd0e433a850647afada00959afe3d36b"
"Availability"=dword:00000002
"HasContent"=dword:00000001
"UpdateDrivenByExpiration"=dword:00000001
"LastUpdated"=hex(b):e4,fd,37,a8,a9,b0,dc,01

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\Subscriptions\280815]
"LastAccessed"=hex(b):23,23,e8,16,2c,b2,dc,01
"ContentId"="6228604944`673555555556172954`5`57150qn2s20498o6o8n6q52nn47rnq4n`159355`735360`682726299555555555"
"ShortContentId"="02605da7f75943b1b3a1d07aa92ead9a"
"Availability"=dword:00000002
"HasContent"=dword:00000001
"UpdateDrivenByExpiration"=dword:00000001
"LastUpdated"=hex(b):02,6d,6b,a8,a9,b0,dc,01

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\Subscriptions\310091]
"LastAccessed"=hex(b):7b,ff,cf,16,2c,b2,dc,01
"ContentId"="6228871921`44444444`5`n1q3810o8s419r77nq37945403o2s56p`76155`865546`689645541225555555"
"ShortContentId"="a6d8365b3f964e22ad82490958b7f01c"
"Availability"=dword:00000002
"HasContent"=dword:00000001
"UpdateDrivenByExpiration"=dword:00000001
"LastUpdated"=hex(b):69,0f,1d,61,2e,b2,dc,01

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\Subscriptions\338387]
"SubscriptionContext"="sc-mode=1"
"AccelerateCacheRefreshLastDetected"=hex(b):ad,64,0f,ef,64,b4,dc,01
"LastAccessed"=hex(b):ad,64,0f,ef,64,b4,dc,01
"ContentId"="6228870339`088636620`5`qqrq81rqqn3s9019oq2558p995n61sos`37355`883832`689645545305555555"
"ShortContentId"="dded36edda8f4564bd7003c440a16fbf"
"Availability"=dword:00000002
"HasContent"=dword:00000001
"UpdateDrivenByExpiration"=dword:00000001
"LastUpdated"=hex(b):8a,e2,c8,25,2d,b2,dc,01

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\Subscriptions\353694]
"LastAccessed"=hex(b):c5,5a,25,17,2c,b2,dc,01
"ContentId"=""
"ShortContentId"=""
"Availability"=dword:00000001
"HasContent"=dword:00000000
"UpdateDrivenByExpiration"=dword:00000001

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\Subscriptions\353698]
"LastAccessed"=hex(b):f0,77,3a,17,2c,b2,dc,01
"ContentId"="6212257706`673555555556172954`5`0o307n0nsss293554ss7o5q5oo2r6sr3`159355`808143`682726299555555555"
"ShortContentId"="5b852a5afff748009ff2b0d0bb7e1fe8"
"Availability"=dword:00000002
"HasContent"=dword:00000001
"UpdateDrivenByExpiration"=dword:00000000
"LastUpdated"=hex(b):09,7d,49,71,07,7f,dc,01

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\Subscriptions\88000045]
"LastAccessed"=hex(b):26,6b,4b,17,2c,b2,dc,01
"ContentId"="6228604071`673555555556172954`5`q7o09opsq0o0915nn244q1782nqqno72`159355`33555590`682726299555555555"
"ShortContentId"="d2b54bcfd5b5460aa799d6237addab27"
"Availability"=dword:00000002
"HasContent"=dword:00000001
"UpdateDrivenByExpiration"=dword:00000001
"LastUpdated"=hex(b):66,92,a9,a8,a9,b0,dc,01

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\Subscriptions\88000161]
"LastAccessed"=hex(b):ca,9c,0c,c3,07,b4,dc,01
"SubscriptionContext"="sc-kfm=14&sc-quota=6"
"SubscriptionEligibilityTags"="14&6"
"AccelerateCacheRefreshLastDetected"=hex(b):12,f1,14,59,fe,b3,dc,01
"AccelerateUpdatePlacementLastDetected"=hex(b):12,f1,14,59,fe,b3,dc,01
"AccelerateUpdatePlacementLastHandled"=hex(b):c3,d3,56,68,30,b2,dc,01
"ContentId"="6228604944`673555555556172954`5`746042p36n2893r0o70178s15077o666`159355`33555616`682726299555555555"
"ShortContentId"="291597c81a7348e5b25623f60522b111"
"Availability"=dword:00000002
"HasContent"=dword:00000001
"UpdateDrivenByExpiration"=dword:00000001
"LastUpdated"=hex(b):d7,bd,ba,82,a9,b0,dc,01

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\Subscriptions\88000163]
"LastAccessed"=hex(b):ca,9c,0c,c3,07,b4,dc,01
"SubscriptionContext"="sc-kfm=14&sc-quota=6"
"SubscriptionEligibilityTags"="14&6"
"AccelerateCacheRefreshLastDetected"=hex(b):6f,db,15,59,fe,b3,dc,01
"AccelerateUpdatePlacementLastDetected"=hex(b):6f,db,15,59,fe,b3,dc,01
"AccelerateUpdatePlacementLastHandled"=hex(b):77,8e,60,68,30,b2,dc,01
"ContentId"="6228604071`673555555556172954`5`4rnn5875o5329o6746458q5o856899no`159355`33555618`682726299555555555"
"ShortContentId"="9eaa0320b0874b1291903d0b301344ab"
"Availability"=dword:00000002
"HasContent"=dword:00000001
"UpdateDrivenByExpiration"=dword:00000001
"LastUpdated"=hex(b):60,c1,b1,a8,a9,b0,dc,01

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\Subscriptions\88000165]
"LastAccessed"=hex(b):ca,9c,0c,c3,07,b4,dc,01
"SubscriptionContext"="sc-kfm=14&sc-quota=6"
"SubscriptionEligibilityTags"="14&6"
"AccelerateCacheRefreshLastDetected"=hex(b):1d,2a,16,59,fe,b3,dc,01
"AccelerateUpdatePlacementLastDetected"=hex(b):1d,2a,16,59,fe,b3,dc,01
"AccelerateUpdatePlacementLastHandled"=hex(b):bc,48,6a,68,30,b2,dc,01
"ContentId"="6228604071`673555555556172954`5`276062qp0qq293p3oqp020773567nq75`159355`33555610`682726299555555555"
"ShortContentId"="721517dc5dd748c8bdc575228012ad20"
"Availability"=dword:00000002
"HasContent"=dword:00000001
"UpdateDrivenByExpiration"=dword:00000001
"LastUpdated"=hex(b):49,44,ac,a8,a9,b0,dc,01

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\Subscriptions\Locksreen]
"AccelerateUpdatePlacementLastDetected"=hex(b):64,9c,37,a1,7b,6e,dc,01
"ContentId"=""
"ShortContentId"=""
"Availability"=dword:00000002
"HasContent"=dword:00000001
"UpdateDrivenByExpiration"=dword:00000000


[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\DesktopSpotlight]
"DefaultCreatives"="[{\"f\":\"raf\",\"v\":\"1.0\",\"rdr\":[{\"c\":\"CDMLite\",\"u\":\"DesktopSpotlightSurface\"}],\"ad\":{\"landscapeImage\":{\"asset\":\"C:\\\\WINDOWS\\\\SystemApps\\\\MicrosoftWindows.Client.CBS_cw5n1h2txyewy\\\\DesktopSpotlight\\\\Assets\\\\Images\\\\image_0.jpg\"},\"portraitImage\":{\"asset\":\"C:\\\\WINDOWS\\\\SystemApps\\\\MicrosoftWindows.Client.CBS_cw5n1h2txyewy\\\\DesktopSpotlight\\\\Assets\\\\Images\\\\image_0.jpg\"},\"iconLabel\":\"Informationen zu diesem Bild\",\"iconHoverText\":\"Nusa Penida Island, Indonesien\\r\\n© Miniloc / iStock / Getty Images Plus\\r\\nRechtsklick, um mehr zu erfahren\",\"title\":\"Weniger? Sagt wer?\",\"description\":\"In den schärenreichen Gewässern der Javasee nördlich von Australien liegen die Kleinen Sunda-Inseln. Obwohl diese Inselkette kleiner ist als die Großen Sunda-Inseln, zu denen so bekannte Namen wie Java, Sumatra und Borneo gehören, gibt es auf den Kleinen Sunda-Inseln doch einige bekannte Orte. Bali gehört dazu, ebenso wie Lombok und Timor. Eine der kleineren Inseln des Archipels, Komodo, ist vielleicht auch wegen der übergroßen Echsen bekannt, die dort leben.\",\"copyright\":\"© miniloc / iStock / Getty Images Plus\",\"likeGlyph\":\"\",\"dislikeGlyph\":\"\",\"ctaText\":\"Weitere Informationen\",\"ctaUri\":\"https://www.bing.com/spotlight?spotlightId=MantaBayNusaPenidaIslandBali&q=Lesser+Sunda+Islands&FORM=MC13ER\",\"relatedContent\":[{\"glyph\":\"\",\"label\":\"Ordnen Sie es zu\",\"actionUri\":\"https://www.bing.com/maps?osid=68b5adf3-0a1e-4655-91ed-ce0ec049c728&cp=-5.965754~96.503906&lvl=3&pi=0&imgid=aec3fdd6-b2cb-49e0-9b63-8135f1bebb05&v=2&sV=2&FORM=MC13ES\"},{\"glyph\":\"\",\"label\":\"Weitere Fotos anzeigen\",\"actionUri\":\"https://www.bing.com/images/search?q=Lesser+Sunda+Islands&qft=+filterui:photo-photo&FORM=MC13ET\"},{\"glyph\":\"\",\"label\":\"Inseln von Indonesien\",\"actionUri\":\"https://www.bing.com/search?q=how+many+islands+does+indonesia+have%3F&FORM=MC13EV\"},{\"glyph\":\"\",\"label\":\"Nusa Penida erkunden\",\"actionUri\":\"https://www.bing.com/travel/place-information?q=Pulau+Nusa+Penida&SID=d3c337ab-a4fb-c574-1af9-9647cae0be8b&FORM=MC13EU\"}],\"relatedHotspots\":[{\"glyph\":\"\",\"label\":\"\",\"actionUri\":\"\"},{\"glyph\":\"\",\"label\":\"\"}],\"entityId\":\"100\"},\"tracking\":{\"baseUri\":\"https://ris.api.iris.microsoft.com/v1/a/{ACTION}?PID=425827255&CID=100&PG=IRIS000001.0000000820&&region=US&lang=EN-US&EID={EID}&ASID={ASID}&TIME={DATETIME}\"},\"prm\":{\"_id\":\"100\",\"_imp\":\"https://arc.msn.com/v3/Delivery/Events/Impression?PID=425827255&CID=100&BID=82185994&PG=IRIS000001.0000000820&LOCALE=EN-US&COUNTRY=US&ASID={ASID}\",\"_flight\":\"\"}},{\"f\":\"raf\",\"v\":\"1.0\",\"rdr\":[{\"c\":\"CDMLite\",\"u\":\"DesktopSpotlightSurface\"}],\"ad\":{\"landscapeImage\":{\"asset\":\"C:\\\\WINDOWS\\\\SystemApps\\\\MicrosoftWindows.Client.CBS_cw5n1h2txyewy\\\\DesktopSpotlight\\\\Assets\\\\Images\\\\image_1.jpg\"},\"portraitImage\":{\"asset\":\"C:\\\\WINDOWS\\\\SystemApps\\\\MicrosoftWindows.Client.CBS_cw5n1h2txyewy\\\\DesktopSpotlight\\\\Assets\\\\Images\\\\image_1.jpg\"},\"iconLabel\":\"Informationen zu diesem Bild\",\"iconHoverText\":\"Ronda, Spanien\\r\\n© Marcp_dmoz on Flickr / Getty Images\\r\\nRechtsklick, um mehr zu erfahren\",\"title\":\"Die geteilte Stadt\",\"description\":\"Antike Zivilisationen nutzten diesen Bergvorsprung im Süden der Iberischen Halbinsel als strategischen Standort für befestigte Siedlungen. Römer, Mauren und Westgoten trugen alle zu der modernen spanischen Stadt bei, die wir heute Ronda nennen.\",\"copyright\":\"© Marcp_dmoz on Flickr / Getty Images\",\"likeGlyph\":\"\",\"dislikeGlyph\":\"\",\"ctaText\":\"Weitere Informationen\",\"ctaUri\":\"https://www.bing.com/spotlight?spotlightId=ParadordeRonda&q=ronda+spain&FORM=MC13ER\",\"relatedContent\":[{\"glyph\":\"\",\"label\":\"Ordnen Sie es zu\",\"actionUri\":\"https://www.bing.com/maps/?v=2&cp=39.169878~-3.930976&lvl=5&sty=b&q=Ronda%2C%20Spain&FORM=MC13ES\"},{\"glyph\":\"\",\"label\":\"Weitere Fotos anzeigen\",\"actionUri\":\"https://www.bing.com/images/search?q=ronda+spain+images&FORM=MC13ET\"},{\"glyph\":\"\",\"label\":\"Brücken von Spanien\",\"actionUri\":\"https://www.bing.com/search?q=bridges+of+spain&FORM=MC13EU\"},{\"glyph\":\"\",\"label\":\"Andalusien erkunden\",\"actionUri\":\"https://www.bing.com/travel/place-information?q=Andalusia&SID=b009454b-b921-1477-fbf3-ea4c66d409b5&FORM=MC13EV\"}],\"relatedHotspots\":[{\"glyph\":\"\",\"label\":\"\",\"actionUri\":\"\"},{\"glyph\":\"\",\"label\":\"\",\"actionUri\":\"\"}],\"entityId\":\"101\"},\"tracking\":{\"baseUri\":\"https://ris.api.iris.microsoft.com/v1/a/{ACTION}?PID=425827258&CID=101&PG=IRIS000001.0000000820&&region=US&lang=EN-US&EID={EID}&ASID={ASID}&TIME={DATETIME}\"},\"prm\":{\"_id\":\"101\",\"_imp\":\"https://arc.msn.com/v3/Delivery/Events/Impression?PID=425827258&CID=101&BID=218005266&PG=IRIS000001.0000000820&LOCALE=EN-US&COUNTRY=US&ASID={ASID}\",\"_flight\":\"\"}},{\"f\":\"raf\",\"v\":\"1.0\",\"rdr\":[{\"c\":\"CDMLite\",\"u\":\"DesktopSpotlightSurface\"}],\"ad\":{\"landscapeImage\":{\"asset\":\"C:\\\\WINDOWS\\\\SystemApps\\\\MicrosoftWindows.Client.CBS_cw5n1h2txyewy\\\\DesktopSpotlight\\\\Assets\\\\Images\\\\image_2.jpg\"},\"portraitImage\":{\"asset\":\"C:\\\\WINDOWS\\\\SystemApps\\\\MicrosoftWindows.Client.CBS_cw5n1h2txyewy\\\\DesktopSpotlight\\\\Assets\\\\Images\\\\image_2.jpg\"},\"iconLabel\":\"Informationen zu diesem Bild\",\"iconHoverText\":\"Eine Hafenmole in Korinthia, Griechenland\\r\\nilias beros/ 500px Prime / Getty Images\\r\\nKlicken Sie rechts, um mehr zu erfahren\",\"title\":\"Über glatte Meere blicken\",\"description\":\"Korinthia ist eine regionale Einheit Griechenlands und liegt in der Region Peloponnes. Das sind die trockenen geografischen Fakten, aber das historische Erbe der Region ist eine viel interessantere Geschichte. Schon vor Tausenden von Jahren kämpften die Weltmächte um die Kontrolle über dieses Gebiet. Die meisten hatten es auf den strategisch wichtigen Isthmus von Korinth abgesehen, der die Halbinsel Peloponnes mit dem griechischen Festland verbindet. Die alten Griechen versuchten, eine Passage durch die Landbrücke zu schlagen (wo ist Zeus, wenn man ihn braucht?), um die Durchquerung der 8.320 Quadratmeilen großen Halbinsel zu erleichtern. Erst 1893 holte die Technik den Ehrgeiz ein und es wurde ein Kanal für den Seeverkehr gegraben. Die darauf folgende Entwicklung der Region hat dazu geführt, dass Teile von Korinthia zu Vorstädten von Athen geworden sind.\",\"copyright\":\"ilias beros/ 500px Prime / Getty Images\",\"likeGlyph\":\"\",\"dislikeGlyph\":\"\",\"ctaText\":\"Weitere Informationen\",\"ctaUri\":\"https://www.bing.com/spotlight?spotlightId=PierSeascapeKorinthia&q=corinthia+greece&FORM=MC13ER\",\"relatedContent\":[{\"glyph\":\"\",\"label\":\"Ordnen Sie es zu\",\"actionUri\":\"https://www.bing.com/maps?osid=de105ea7-c2f9-4aa6-b09c-c9739b2d50e6&cp=38.828499~15.952622&lvl=5.357272&pi=0&imgid=91173d4c-6afb-4721-8820-9c8b71afd1ea&v=2&sV=2&form=S00027&FORM=MC13ES\"},{\"glyph\":\"\",\"label\":\"Weitere Fotos anzeigen\",\"actionUri\":\"https://www.bing.com/images/search?&q=Corinthia%2c+Greece&qft=+filterui:photo-photo&FORM=MC13ET\"},{\"glyph\":\"\",\"label\":\"Infos über das antike Korinth\",\"actionUri\":\"https://www.bing.com/search?q=ancient+corinth&FORM=MC13EU\"},{\"glyph\":\"\",\"label\":\"Korinthia erkunden\",\"actionUri\":\"https://www.bing.com/travel/place-information?q=Corinthia&SID=559a7fd6-0c81-fd93-c1ff-7812f9fcc7d8&FORM=MC13EV\"}],\"relatedHotspots\":[{\"glyph\":\"\",\"label\":\"\",\"actionUri\":\"\"},{\"glyph\":\"\",\"label\":\"\",\"actionUri\":\"\"}],\"entityId\":\"102\"},\"tracking\":{\"baseUri\":\"https://ris.api.iris.microsoft.com/v1/a/{ACTION}?PID=425827259&CID=102&PG=IRIS000001.0000000820&&region=US&lang=EN-US&EID={EID}&ASID={ASID}&TIME={DATETIME}\"},\"prm\":{\"_id\":\"102\",\"_imp\":\"https://arc.msn.com/v3/Delivery/Events/Impression?PID=425827259&CID=102&BID=284608017&PG=IRIS000001.0000000820&LOCALE=EN-US&COUNTRY=US&ASID={ASID}\",\"_flight\":\"\"}},{\"f\":\"raf\",\"v\":\"1.0\",\"rdr\":[{\"c\":\"CDMLite\",\"u\":\"DesktopSpotlightSurface\"}],\"ad\":{\"landscapeImage\":{\"asset\":\"C:\\\\WINDOWS\\\\SystemApps\\\\MicrosoftWindows.Client.CBS_cw5n1h2txyewy\\\\DesktopSpotlight\\\\Assets\\\\Images\\\\image_3.jpg\"},\"portraitImage\":{\"asset\":\"C:\\\\WINDOWS\\\\SystemApps\\\\MicrosoftWindows.Client.CBS_cw5n1h2txyewy\\\\DesktopSpotlight\\\\Assets\\\\Images\\\\image_3.jpg\"},\"iconLabel\":\"Informationen zu diesem Bild\",\"iconHoverText\":\"Sagano Bamboo Forest, Kyoto, Japan\\r\\n© Piriya Photography /Moment /Getty Images\\r\\nRechtsklick, um mehr zu erfahren.\",\"title\":\"Ein Spaziergang durch den Bambuswald\",\"description\":\"Auch wenn sich die Besucher dieses Ortes wie in einer anderen Welt fühlen, sind sie doch nur einen Steinwurf vom städtischen Treiben entfernt. Gleich hinter dem westlichen Rand von Kyoto, Japan, liegt der Bezirk Arashiyama. Die Gegend ist bekannt für wunderschöne Naturlandschaften und Attraktionen, darunter der Sagano-Bambuswald. Ein Spaziergang auf den Pfaden des Waldes ist nicht nur ein visueller Genuss, wenn das Tageslicht durch die tausenden grünen Bambusstämme fällt, sondern auch ein Genuss für die Ohren. Wenn der Wind durch den Wald weht, erzeugt er ein unverwechselbares Geräusch, das oft als einer der einprägsamsten Aspekte des Waldes genannt wird.\",\"copyright\":\"© Piriya Photography / Moment / Getty Images\",\"likeGlyph\":\"\",\"dislikeGlyph\":\"\",\"ctaText\":\"Weitere Informationen\",\"ctaUri\":\"https://www.bing.com/spotlight?spotlightId=BambooForestArashiyama&q=sagano+bamboo+forest%2C+arashiyama&FORM=MC13ER\",\"relatedContent\":[{\"glyph\":\"\",\"label\":\"Ordnen Sie es zu\",\"actionUri\":\"https://www.bing.com/maps?osid=edd3910d-30e4-4faf-aad8-b43f1332ba62&cp=37.245355~92.776154&lvl=4&v=2&sV=2&FORM=MC13ES\"},{\"glyph\":\"\",\"label\":\"Weitere Fotos anzeigen\",\"actionUri\":\"https://www.bing.com/images/search?q=Sagano+Bamboo+Forest%2c+Arashiyama%2c+Japan+images&FORM=MC13ET\"},{\"glyph\":\"\",\"label\":\"Bambusfakten\",\"actionUri\":\"https://www.bing.com/search?q=bamboo&FORM=MC13EU\"},{\"glyph\":\"\",\"label\":\"Kyoto erkunden\",\"actionUri\":\"https://www.bing.com/travel/place-information?q=Kyoto&SID=016f8629-d61d-3045-0068-c8fcefa64237&FORM=MC13EV\"}],\"relatedHotspots\":[{\"glyph\":\"\",\"label\":\"\",\"actionUri\":\"\"},{\"glyph\":\"\",\"label\":\"\"}],\"entityId\":\"103\"},\"tracking\":{\"baseUri\":\"https://ris.api.iris.microsoft.com/v1/a/{ACTION}?PID=425827260&CID=103&PG=IRIS000001.0000000820&&region=US&lang=EN-US&EID={EID}&ASID={ASID}&TIME={DATETIME}\"},\"prm\":{\"_id\":\"103\",\"_imp\":\"https://arc.msn.com/v3/Delivery/Events/Impression?PID=425827260&CID=103&BID=1605631696&PG=IRIS000001.0000000820&LOCALE=EN-US&COUNTRY=US&ASID={ASID}\",\"_flight\":\"\"}}]"
"ImagesUsed"=dword:0000000f
"WallpaperRefresh"="2026-03-15T09:33:17Z"
"State"="{
  \"Version\":0,
  \"RetrieveIrisContentSuccess\":true,
  \"RetrieveIrisContentStatusCode\":200,
  \"RetrieveIrisContentSuccessDate\":\"2026-03-04T11:03:53Z\",
  \"RetrieveIrisContentLastAttemptDate\":\"2026-03-04T11:03:53Z\",
  \"RetrieveIrisContentRetryCount\":0,
  \"RetrieveIrisContentRetryDate\":\"2026-03-05T11:03:53Z\",
  \"RetryTaskCount\":0,
  \"LastTriggerType\":3,
  \"LastBackgroundTaskRunDate\":\"2026-03-15T10:29:41Z\"
}"
"Configuration"="2026-02-27T03:53:34Z"
"ImagesPreference"="{}"
"Rotation"="2026-03-15T09:23:14Z"
"UpdateTimer"="2026-03-10T16:18:12Z"
"Maintenance"="2026-03-15T10:29:42Z"
"RegistrationStatusCheck"="2026-03-11T16:31:39Z"

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\DesktopSpotlight\Creatives]
"ImageIndex"=dword:00000003

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\DesktopSpotlight\Settings]
"EnabledState"=dword:00000001
"SpotlightDisabledReason"=dword:00000064
"SpotlightIconIdShown"="%SystemRoot%\\system32\\imageres.dll,-8201"
"OneTimeUpgrade"=dword:00000001
"PeriodicUpgrade"=hex(b):3f,c3,6a,bd,39,a7,dc,01
"IsRestoreLogon"=dword:00000001
"IsDisabledByCommercialControl"=dword:00000000
"SpotlightNotOnboardedReason"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications]
"Migrated"=dword:00000004

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\AD2F1837.HPPrivacySettings_v10z8vjag6ke6]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\AD2F1837.HPSupportAssistant_v10z8vjag6ke6]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\AD2F1837.HPSystemInformation_v10z8vjag6ke6]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\AdobeAcrobatReaderCoreApp_pc75e8sa7ep4e]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\aimgr_8wekyb3d8bbwe]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\AppUp.IntelGraphicsExperience_8j3eq9eme6ctt]
"NCBEnabled"=dword:00000001

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\AppUp.ThunderboltControlCenter_8j3eq9eme6ctt]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Clipchamp.Clipchamp_yxz26nhyzhsrt]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.6365217CE6EB4_8wekyb3d8bbwe]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.BingNews_8wekyb3d8bbwe]
"NCBEnabled"=dword:00000001

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.BingSearch_8wekyb3d8bbwe]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.BingWeather_8wekyb3d8bbwe]
"NCBEnabled"=dword:00000001
"DisabledByUser"=dword:00000000
"Disabled"=dword:00000000
"IgnoreBatterySaver"=dword:00000000
"SleepDisabled"=dword:00000000
"SleepIgnoreBatterySaver"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.CommandPalette_8wekyb3d8bbwe]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.CompanyPortal_8wekyb3d8bbwe]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe]
"NCBEnabled"=dword:00000001

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Edge.GameAssist_8wekyb3d8bbwe]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.GamingApp_8wekyb3d8bbwe]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.GetHelp_8wekyb3d8bbwe]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.MicrosoftEdge.Stable_8wekyb3d8bbwe]
"NCBEnabled"=dword:00000001

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.MicrosoftPCManager_8wekyb3d8bbwe]
"NCBEnabled"=dword:00000001

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.MicrosoftSolitaireCollection_8wekyb3d8bbwe]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.MicrosoftStickyNotes_8wekyb3d8bbwe]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.MSIXPackagingTool_8wekyb3d8bbwe]
"NCBEnabled"=dword:00000001

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.NET.Native.Framework.1.3_8wekyb3d8bbwe]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.NET.Native.Framework.2.1_8wekyb3d8bbwe]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.NET.Native.Framework.2.2_8wekyb3d8bbwe]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.NET.Native.Runtime.1.4_8wekyb3d8bbwe]
"NCBEnabled"=dword:00000001

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.NET.Native.Runtime.2.1_8wekyb3d8bbwe]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.NET.Native.Runtime.2.2_8wekyb3d8bbwe]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Office.ActionsServer_8wekyb3d8bbwe]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.OfficePushNotificationUtility_8wekyb3d8bbwe]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.OneDriveSync_8wekyb3d8bbwe]
"NCBEnabled"=dword:00000001
"DisabledByUser"=dword:00000000
"Disabled"=dword:00000000
"IgnoreBatterySaver"=dword:00000000
"SleepDisabled"=dword:00000000
"SleepIgnoreBatterySaver"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.OutlookForWindows_8wekyb3d8bbwe]
"NCBEnabled"=dword:00000001

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Paint_8wekyb3d8bbwe]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.PowerAutomateDesktop_8wekyb3d8bbwe]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.PowerToys.FileLocksmithContextMenu_8wekyb3d8bbwe]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.PowerToys.ImageResizerContextMenu_8wekyb3d8bbwe]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.PowerToys.PowerRenameContextMenu_8wekyb3d8bbwe]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.PowerToys.SparseApp_8wekyb3d8bbwe]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.ScreenSketch_8wekyb3d8bbwe]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.SecHealthUI_8wekyb3d8bbwe]
"NCBEnabled"=dword:00000001
"DisabledByUser"=dword:00000000
"Disabled"=dword:00000000
"IgnoreBatterySaver"=dword:00000000
"SleepDisabled"=dword:00000000
"SleepIgnoreBatterySaver"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Services.Store.Engagement_8wekyb3d8bbwe]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.StartExperiencesApp_8wekyb3d8bbwe]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.StorePurchaseApp_8wekyb3d8bbwe]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Todos_8wekyb3d8bbwe]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.UI.Xaml.2.7_8wekyb3d8bbwe]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.UI.Xaml.2.8_8wekyb3d8bbwe]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.VCLibs.140.00.UWPDesktop_8wekyb3d8bbwe]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.VCLibs.140.00_8wekyb3d8bbwe]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.WidgetsPlatformRuntime_8wekyb3d8bbwe]
"NCBEnabled"=dword:00000001
"DisabledByUser"=dword:00000000
"Disabled"=dword:00000000
"IgnoreBatterySaver"=dword:00000000
"SleepDisabled"=dword:00000000
"SleepIgnoreBatterySaver"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.WinAppRuntime.DDLM.8000.675.1142.0-x6_8wekyb3d8bbwe]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.WinAppRuntime.DDLM.8000.675.1142.0-x8_8wekyb3d8bbwe]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.DevHome_8wekyb3d8bbwe]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.NarratorQuickStart_8wekyb3d8bbwe]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Windows.Photos_8wekyb3d8bbwe]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.WindowsAlarms_8wekyb3d8bbwe]
"NCBEnabled"=dword:00000001

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.WindowsAppRuntime.1.4_8wekyb3d8bbwe]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.WindowsAppRuntime.1.5_8wekyb3d8bbwe]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.WindowsAppRuntime.1.6_8wekyb3d8bbwe]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.WindowsAppRuntime.1.7_8wekyb3d8bbwe]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.WindowsAppRuntime.1.8_8wekyb3d8bbwe]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.WindowsCalculator_8wekyb3d8bbwe]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.WindowsCamera_8wekyb3d8bbwe]
"DisabledByUser"=dword:00000001
"Disabled"=dword:00000000
"IgnoreBatterySaver"=dword:00000000
"SleepDisabled"=dword:00000001
"SleepIgnoreBatterySaver"=dword:00000000

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.WindowsFeedbackHub_8wekyb3d8bbwe]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.WindowsNotepad_8wekyb3d8bbwe]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.WindowsSoundRecorder_8wekyb3d8bbwe]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.WindowsStore_8wekyb3d8bbwe]
"NCBEnabled"=dword:00000001

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.WindowsTerminal_8wekyb3d8bbwe]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.Xbox.TCUI_8wekyb3d8bbwe]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.XboxGamingOverlay_8wekyb3d8bbwe]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.XboxIdentityProvider_8wekyb3d8bbwe]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.XboxSpeechToTextOverlay_8wekyb3d8bbwe]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.YourPhone_8wekyb3d8bbwe]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\Microsoft.ZuneMusic_8wekyb3d8bbwe]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\MicrosoftCorporationII.QuickAssist_8wekyb3d8bbwe]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\MicrosoftCorporationII.WinAppRuntime.Main.1.8_8wekyb3d8bbwe]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\MicrosoftCorporationII.WinAppRuntime.Singleton_8wekyb3d8bbwe]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\MicrosoftTeams_8wekyb3d8bbwe]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\MicrosoftWindows.Client.CBS_cw5n1h2txyewy]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\MicrosoftWindows.Client.WebExperience_cw5n1h2txyewy]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\MicrosoftWindows.CrossDevice_cw5n1h2txyewy]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\MSTeams_8wekyb3d8bbwe]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\NotepadPlusPlus_2247w0b46hfww]

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\SynapticsIncorporated.SynHPCommercialDApp_807d65c4rvak2]

"@
    Set-Content -Path "$env:TEMP\Optimize_User_Registry.reg" -Value $MultilineComment -Force
    Regedit.exe /S "$env:TEMP\Optimize_User_Registry.reg"
    
    Write-Host "Recommended User Registry Settings Applied." -ForegroundColor Green
    
}

# Clears WU
function Set-Wupdatecleaned {
    Start-Process cmd -ArgumentList '/s,/c,net stop usosvc 
                                        & net stop wuauserv 
                                        & del %systemroot%\SoftwareDistribution\DataStore\Logs\edb.log 
                                        & del /f /q C:\ProgramData\USOPrivate\UpdateStore\* 
                                        & net start usosvc 
                                        & net start wuauserv 
                                        & UsoClient.exe RefreshSettings' -Verb runAs
                                        Write-Host "Windows Update cleaned." -ForegroundColor Green
}
# End of Registry Optimizations

# Check Files are on Usb Stick
function Get-UsbStickDrive {
    # Find MagicStick drive
    $MagicStick = $False;
    try {
    Get-Volume | % {
        $Volume = $_;
        if ( 

          ( $Volume.DriveType -eq "Removable" ) -and
          ( $Volume.FileSystemType -eq "NTFS" ) -and 
          ( $Volume.DriveLetter -ne "" ) -and
          ( Test-Path "$($Volume.DriveLetter):\magic\home.zip" ) 

        ) { $MagicStick = "$($Volume.DriveLetter):\magic\home.zip"; }
    }
}
catch {}

    if ( !$MagicStick ) { Write-Host "MagicStick not found!" -ForegroundColor Red; return; } 
    else { Write-Host "MagicStick found at $MagicStick" -ForegroundColor Green; }

    if ( !(Test-Path -Path "C:\Users\Public\Yann" ) ) {
    New-Item -Path "C:\Users\Public" -Name "Yann" -ItemType "Directory" | Out-Null;
    } 
    Expand-Archive -Force "$MagicStick" "C:\Users\Public\Yann\magic";
    Set-Location -Path "C:\Users\Public\Yann\magic";
    Write-Host "All Softwares are Prepared." -ForegroundColor Green
} 
# Copied Files from Usb Stick to Setup Folder

# Yann Setup is launched.
function StartYannSetup {
# Find post-setup Folder
$postsetup = $False;
try {
    Get-Volume | % {
        $Volume = $_;
        if ( 

          ( $Volume.FileSystemType -eq "NTFS" ) -and 
          ( $Volume.DriveLetter -eq "C" ) -and
          ( $Volume.DriveType -eq "Fixed" ) -and
          ( Test-Path "$($Volume.DriveLetter):\windows\Setup\Files\post-setup.zip" )

        ) { $postsetup =  "$($Volume.DriveLetter):\windows\Setup\Files\post-setup.zip"; }
    }
} 
catch {}

if ( !$postsetup ) { Write-Host "post setup not found!"; return; } 
else { Write-Host "post setup found at $postsetup"; }

Write-Host 'Expand-Archive -Force "$postsetup" "C:\Windows\Setup\Files\post-setup"'
Expand-Archive -Force "$postsetup" "C:\Windows\Setup\Files\post-setup";
 $ErrorActionPreference = 'Continue';

Write-Host 'Start-Process -FilePath "C:\Windows\Setup\post-setup\Files\Deploy-Application.exe" -Wait -NoNewWindow'
Start-Process -FilePath "C:\Windows\Setup\Files\post-setup\Deploy-Application.exe" -Wait -NoNewWindow
$ErrorActionPreference = 'Continue'

Write-Host 'Start-Process -FilePath "C:\Users\Public\Yann\magic\Invoke-AppDeployToolkit.exe" -Wait -NoNewWindow'
Start-Process -FilePath "C:\Users\Public\Yann\magic\Invoke-AppDeployToolkit.exe" -Wait -NoNewWindow
$ErrorActionPreference = 'Continue'

} 

# Find Usb Installation path
function AppsUsbFolderPath {
$UsbFolderPath = $False;
try {
    Get-Volume | % {
        $Volume = $_;
        if (
          ( $Volume.DriveType -eq "Removable" ) -and
          ( $Volume.FileSystemType -eq "NTFS" ) -and 
          ( $Volume.DriveLetter -ne "" ) -and
          ( Test-Path "$($Volume.DriveLetter):\bootmgr.efi" ) 
        ) { $UsbFolderPath = "$($Volume.DriveLetter):\sources\`$OEM$/`$`$/Setup\Files\TaskBar.zip" ; cd "$($Volume.DriveLetter):\sources\`$OEM$/`$`$/Setup\Files\"}
        $ErrorActionPreference = 'Continue';
    }
} 
catch {} if ( !$UsbFolderPath ) { Write-Host "Usb Disk not found!";return; $UsbFolderPath = "C:\Windows\Setup\Files\"; } 
            else { Write-Host "Archive $UsbFolderPath found ";}
            $ErrorActionPreference = 'Continue';
            Expand-Archive -Force "$UsbFolderPath" "c:\Users\Yann1\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch\User Pinned" ;
            Write-Host "Taskbar Prepared." -ForegroundColor Green ; @($UsbFolderPath)  ; return ;
}

# Function to Enable Windows Defender
function Enable-WindowsDefender {
    $MultilineComment = @"
; Enables Windows Defender to start in Windows Security
[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\Services\Sense]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\Services\WdBoot]
"Start"=dword:00000000

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\Services\WdFilter]
"Start"=dword:00000000

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\Services\WdNisDrv]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\Services\WdNisSvc]
"Start"=dword:00000003

[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\Services\WinDefend]
"Start"=dword:00000002

[HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows Defender Security Center\Notifications]
"enableNotifications"=dword:00000001
"enableEnhancedNotifications"=dword:00000001

[HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows Defender Security Center]

[HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows Defender Security Center\Notifications]
"enableNotifications"=dword:00000001
"enableEnhancedNotifications"=dword:00000001

[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender]
"DisableAntiSpyware"=dword:00000000
"DisableAntiVirus"=dword:00000000

[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender\Policy Manager]

[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection]
"DisableBehaviorMonitoring"=dword:00000000
"DisableIOAVProtection"=dword:00000000
"DisableOnAccessProtection"=dword:00000000
"DisableRealtimeMonitoring"=dword:00000000
"DisableScanOnRealtimeEnable"=dword:00000000

[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender\Reporting]
"DisableEnhancedNotifications"=dword:00000000

[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender\SpyNet]
"DisableBlockAtFirstSeen"=dword:00000000
"SpynetReporting"=dword:00000001
"SubmitSamplesConsent"=dword:00000001
"@
    Set-Content -Path "$env:TEMP\Enable_Windows_Defender.reg" -Value $MultilineComment -Force
    $path = "$env:TEMP\Enable_Windows_Defender.reg"
    (Get-Content $path) -replace "\?", "$" | Out-File $path
    Regedit.exe /S "$env:TEMP\Enable_Windows_Defender.reg"
    Write-Host "Windows Defender has been enabled." -ForegroundColor Green
}

Remove-Shortcuts
Set-PowerUserSettings
Set-RecommendedPrivacySettings
Set-RecommendedUpdateSettings
Set-RecommendedHKLMRegistry
#Set-DefaultHKLMRegistry
Set-RecommendedHKCURegistry
Set-Wupdatecleaned
Get-UsbStickDrive
StartYannSetup
AppsUsbFolderPath
Enable-WindowsDefender

Write-Host "Done; Please restart to apply changes"
Stop-Transcript;
