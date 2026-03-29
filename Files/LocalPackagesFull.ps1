Set-ExecutionPolicy -Scope CurrentUser Unrestricted -Force -ErrorAction SilentlyContinue
Import-Module Appx
Import-Module Dism

# Start Logging Installation
 function LOgCreate {
$LogDate = get-date -format "MM-d-yy-HH" 
$objShell = New-Object -ComObject Shell.Application  
$objFolder = $objShell.Namespace(0xA) 
$ErrorActionPreference = "silentlycontinue" 
                     
Start-Transcript -Path "C:\Windows\Logs\LocalPackagesFull$LogDate.ps1.log"
}
LOgCreate

# Find Usb Installation path
function AppsFolderPath {
try {
    Get-Volume | % {
        $Volume = $_;
        if (
          ( $Volume.DriveType -eq "Removable" ) -and
          ( $Volume.FileSystemType -eq "NTFS" ) -and 
          ( $Volume.DriveLetter -ne "" ) -and
          ( Test-Path "$($Volume.DriveLetter):\bootmgr.efi" ) 
        ) { $localFolderPath = "$($Volume.DriveLetter):\sources\`$OEM$/`$1/addons\appx"}
    }
} 
catch {} if ( !$localFolderPath ) { Write-Host "Usb Disk not found!";return; $localFolderPath = "C:\Users\Public\Yann\appx\"; } 
            else { Write-Host "Packages found at $localFolderPath ";}
}

AppsFolderPath

Write-Host "Packages still found at $localFolderPath "

function installLocalPackages {
Add-AppxPackage -Path $localFolderPath\Microsoft.UI.Xaml.2.8_8.2501.31001.0_x64__8wekyb3d8bbwe.Appx
Add-AppxPackage -Path "$localFolderPath\Microsoft.UI.Xaml.x64.2.8.appx"
Add-AppxPackage -Path $localFolderPath\Microsoft.VCLibs.140.00.UWPDesktop_14.0.33728.0_x64__8wekyb3d8bbwe.Appx
Add-AppxPackage -Path $localFolderPath\Microsoft.VCLibs.140.00_14.0.33519.0_x64__8wekyb3d8bbwe.Appx
Add-AppxPackage -Path $localFolderPath\Microsoft.VCLibs.x64.14.00.appx
Add-AppxPackage -Path $localFolderPath\Microsoft.NET.Native.Framework.x64.2.2.appx
Add-AppxPackage -Path $localFolderPath\Microsoft.NET.Native.Runtime.x64.2.2.appx
Add-AppxPackage -Path $localFolderPath\Microsoft.NET.Native.Framework.2.2_2.2.29512.0_x64__8wekyb3d8bbwe.Appx
Add-AppxPackage -Path $localFolderPath\Microsoft.NET.Native.Runtime.2.2_2.2.28604.0_x64__8wekyb3d8bbwe.Appx
Add-AppxPackage -Path $localFolderPath\Microsoft.SecHealthUI_8wekyb3d8bbwe.x64.appx
Add-AppxPackage -Path $localFolderPath\Microsoft.Services.Store.Engagement.x64.appx
Add-AppxPackage -Path $localFolderPath\Microsoft.Services.Store.Engagement_10.0.23012.0_x64__8wekyb3d8bbwe.Appx
Add-AppxPackage -Path $localFolderPath\Microsoft.StartExperiencesApp_8wekyb3d8bbwe.msixbundle
Add-AppxPackage -Path $localFolderPath\Microsoft.StorePurchaseApp_8wekyb3d8bbwe.appxbundle
Add-AppxPackage -Path $localFolderPath\Microsoft.ApplicationCompatibilityEnhancements_8wekyb3d8bbwe.msixbundle
# The following command will install the PC Manager
Add-AppxPackage -Path $localFolderPath\Microsoft.MicrosoftPCManager_8wekyb3d8bbwe.msixbundle
# Dism /Online /Add-ProvisionedAppxPackage /packagepath:$localFolderPath\Microsoft.MicrosoftPCManager_8wekyb3d8bbwe.Msixbundle /SkipLicense
# Add-AppxPackage -Path $localFolderPath\AdobeSystemsIncorporated.AdobeCreativeCloudExpress_2.1.1.0_neutral_~_ynb6jyjzte8ga.AppxBundle
Add-AppxPackage -Path $localFolderPath\Microsoft.Windows.Photos_8wekyb3d8bbwe.msixbundle
Add-AppxPackage -Path $localFolderPath\Microsoft.WindowsAppRuntime.x64.1.7.msix
Add-AppxPackage -Path $localFolderPath\Microsoft.WindowsCalculator_8wekyb3d8bbwe.msixbundle
Add-AppxPackage -Path $localFolderPath\Microsoft.OutlookForWindows_x64.msix
Add-AppxPackage -Path $localFolderPath\MSTeams_8wekyb3d8bbwe.x64.msix
Add-AppxPackage -Path $localFolderPath\OutlookPWA.msix

$ErrorActionPreference = 'Continue';
}

# internet needed here o the Iso Image of OEM Features.
function installOnlinePackages {
# Installing Microsoft.Windows.StorageManagement
# DISM /Online /add-package /packagepath:"$localFolderPath\Microsoft-OneCore-ApplicationModel-Sync-Desktop-FOD-Package~31bf3856ad364e35~amd64~~.cab"
DISM /Online /add-package /packagepath:"$localFolderPath\Microsoft-OneCore-StorageManagement-FoD-Package~31bf3856ad364e35~wow64~~.cab"
# DISM /Online /add-package /packagepath:"$localFolderPath\Microsoft-OneCore-StorageManagement-FoD-Package~31bf3856ad364e35~amd64~~.cab"
# DISM /Online /add-package /packagepath:"$localFolderPath\Microsoft-Windows-StorageManagement-FoD-Package~31bf3856ad364e35~amd64~en-US~.cab"
DISM /Online /add-package /packagepath:"$localFolderPath\Microsoft-OneCore-StorageManagement-FoD-Package~31bf3856ad364e35~wow64~en-US~.cab"
# DISM /Online /add-package /packagepath:"$localFolderPath\Microsoft-OneCore-StorageManagement-FoD-Package~31bf3856ad364e35~amd64~de-DE~.cab"
DISM /Online /add-package /packagepath:"$localFolderPath\Microsoft-OneCore-StorageManagement-FoD-Package~31bf3856ad364e35~wow64~de-DE~.cab"
# DISM /Online /add-package /packagepath:"$localFolderPath\Microsoft-Windows-StorageManagement-FoD-Package~31bf3856ad364e35~amd64~de-DE~.cab"
DISM /Online /Add-Capability /CapabilityName:Microsoft.Onecore.StorageManagement~~~~0.0.1.0  /NoRestart

DISM /Online /add-package /packagepath:"$localFolderPath\Microsoft-Windows-FileServices-Tools-FoD-Package~31bf3856ad364e35~wow64~en-US~.cab"
# DISM /Online /add-package /packagepath:"$localFolderPath\Microsoft-Windows-FileServices-Tools-FoD-Package~31bf3856ad364e35~wow64~de-DE~.cab"
DISM /Online /add-package /packagepath:"$localFolderPath\Microsoft-Windows-GroupPolicy-Management-Tools-FoD-Package~31bf3856ad364e35~wow64~en-US~.cab"
# DISM /Online /add-package /packagepath:"$localFolderPath\Microsoft-Windows-GroupPolicy-Management-Tools-FoD-Package~31bf3856ad364e35~wow64~de-DE~.cab"
DISM /Online /add-package /packagepath:"$localFolderPath\Microsoft-Windows-Notepad-FoD-Package~31bf3856ad364e35~wow64~en-US~.cab"
# DISM /Online /add-package /packagepath:"$localFolderPath\Microsoft-Windows-Notepad-FoD-Package~31bf3856ad364e35~wow64~de-DE~.cab"
# DISM /Online /add-package /packagepath:"$localFolderPath\Microsoft-Windows-SystemInsights-Management-Tools-FOD-Package~31bf3856ad364e35~amd64~en-US~.cab"
# DISM /Online /add-package /packagepath:"$localFolderPath\Microsoft-Windows-SystemInsights-Management-Tools-FOD-Package~31bf3856ad364e35~amd64~de-DE~.cab"
DISM /Online /add-package /packagepath:"$localFolderPath\Microsoft-Windows-TPM-Diagnostics-FOD-Package~31bf3856ad364e35~wow64~en-US~.cab"

# Amd Packages
# DISM /Online /add-package /packagepath:"$localFolderPath\Microsoft-Windows-TPM-Diagnostics-FOD-Package~31bf3856ad364e35~wow64~de-DE~.cab"
# DISM /Online /add-package /packagepath:"$localFolderPath\Microsoft-Windows-PowerShell-ISE-FOD-Package~31bf3856ad364e35~amd64~en-US~.cab"
# DISM /Online /add-package /packagepath:"$localFolderPath\HyperV-OptionalFeature-VirtualMachinePlatform-Client-Disabled-FOD-Package~31bf3856ad364e35~amd64~en-US~.cab"
# DISM /Online /add-package /packagepath:"$localFolderPath\HyperV-OptionalFeature-VirtualMachinePlatform-Client-Disabled-FOD-Package~31bf3856ad364e35~amd64~de-DE~.cab"

# Install Legacy Console
DISM /Online /add-package /packagepath:"$localFolderPath\Microsoft-Windows-Console-Host-Legacy-FoD-Package~31bf3856ad364e35~amd64~en-US~.cab"
# DISM /Online /Enable-Feature /FeatureName:LegacyComponents /NoRestart
DISM /Online /Add-Capability /CapabilityName:Microsoft.Windows.Console.Legacy~~~~ /NoRestart
DISM /Online /Add-Capability /CapabilityName:VBSCRIPT /NoRestart 
DISM /Online /Add-Capability /CapabilityName:WMIC /NoRestart
DISM /Online /Enable-Feature /FeatureName:NetFX3 /NoRestart
DISM /Online /Add-Capability /CapabilityName:NetFX3 /NoRestart
DISM /Online /Enable-Feature /FeatureName:DirectPlay /NoRestart
# DISM /Online /add-package /packagepath:"$localFolderPath\Microsoft-Windows-Console-Host-Legacy-FoD-Package~31bf3856ad364e35~amd64~de-DE~.cab"
DISM /Online /add-package /packagepath:"$localFolderPath\Microsoft-Windows-VBSCRIPT-FoD-Package~31bf3856ad364e35~wow64~en-US~.cab"
DISM /Online /add-package /packagepath:"$localFolderPath\Microsoft-Windows-WMI-SNMP-Provider-Client-Package~31bf3856ad364e35~wow64~en-US~.cab"
DISM /Online /add-package /packagepath:"$localFolderPath\Microsoft-Windows-WMIC-FoD-Package~31bf3856ad364e35~wow64~en-US~.cab"
# DISM /Online /add-package /packagepath:"$localFolderPath\Microsoft-Windows-WMIC-FoD-Package~31bf3856ad364e35~wow64~de-DE~.cab"
# DISM /Online /add-package /packagepath:"$localFolderPath\Microsoft-Windows-Console-Host-Legacy-FoD-Package~31bf3856ad364e35~amd64~de-DE~.cab"
DISM /Online /add-package /packagepath:"$localFolderPath\Microsoft-Windows-VBSCRIPT-FoD-Package~31bf3856ad364e35~wow64~en-US~.cab"
DISM /Online /add-package /packagepath:"$localFolderPath\Microsoft-Windows-WMI-SNMP-Provider-Client-Package~31bf3856ad364e35~wow64~en-US~.cab"
DISM /Online /add-package /packagepath:"$localFolderPath\Microsoft-Windows-WMIC-FoD-Package~31bf3856ad364e35~wow64~en-US~.cab"
# DISM /Online /add-package /packagepath:"$localFolderPath\Microsoft-Windows-WMIC-FoD-Package~31bf3856ad364e35~wow64~de-DE~.cab"
DISM /Online /Add-Capability /CapabilityName:VBSCRIPT /NoRestart 
DISM /Online /Add-Capability /CapabilityName:WMIC /NoRestart

# Get-AppPackage Microsoft.SecHealthUI
powershell Add-WindowsCapability -Name Wallpapers -Online 
powershell Add-WindowsCapability -Name Hello -Online $
$ErrorActionPreference = 'Continue';
}

function SwissPackagesAmD {
# Switzerland Computer Specific
# DISM /Online /add-package /packagepath:"$localFolderPathMicrosoft-Windows-LanguageFeatures-Basic-de-ch-Package~31bf3856ad364e35~amd64~~.cab"
# DISM /Online /add-package /packagepath:"$localFolderPathMicrosoft-Windows-LanguageFeatures-TextToSpeech-de-ch-Package~31bf3856ad364e35~amd64~~.cab"
$ErrorActionPreference = 'Continue';
}

function removeCopilot {
get-appxpackage *copilot* | remove-appxpackage
Get-AppxPackage -AllUsers | Where-Object {$_.Name -Like '*Microsoft.Copilot*'} | Remove-AppxPackage -AllUsers -ErrorAction Continue
$ErrorActionPreference = 'Continue';
}
function AddCopilot {
# Add-AppxPackage -Path $localFolderPath\Microsoft.Copilot_1.25102.233.0_neutral_~_8wekyb3d8bbwe.AppxBundle
$ErrorActionPreference = 'Continue';
}

# Restore repair all packages
function RepairPackages {
Get-AppxPackage -allusers | foreach {Add-AppxPackage -register "$($_.InstallLocation)\appxmanifest.xml" -DisableDevelopmentMode}
Get-AppXPackage *WindowsStore* -AllUsers | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
# Add-AppxProvisionedPackage -Online -PackagePath "$localFolderPath\Microsoft.WindowsStore_8wekyb3d8bbwe.appxbundle" -LicensePath $localFolderPath\Microsoft.WindowsStore_8wekyb3d8bbwe.xml

Write-Host "All Packages are installed or repaired ! ";
$ErrorActionPreference = 'Continue';
}

AppsFolderPath
installLocalPackages
installOnlinePackages
# SwissPackagesAmD
removeCopilot
# AddCopilot
RepairPackages

Write-Host "Done; Please restart to apply changes"
Stop-Transcript;
