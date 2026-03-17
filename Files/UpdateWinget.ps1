#average
Set-ExecutionPolicy Unrestricted
# Start Logging Installation
 function LOgCreate {
   $LogDate = get-date -format "MM-d-yy-HH" 
   $objShell = New-Object -ComObject Shell.Application  
   $objFolder = $objShell.Namespace(0xA) 
   $ErrorActionPreference = "silentlycontinue" 
                     
Start-Transcript -Path "$env:PUBLIC\Desktop\Logs\UpdateWinget2.ps1.txt" -Force

}
LOgCreate

$progressPreference = 'SilentlyContinue'

# Find Usb Installation path
function AppsFolderPath {
$localFolderPath = $False;
try {
    Get-Volume | % {
        $Volume = $_;
        if (
          ( $Volume.DriveType -eq "Removable" ) -and
          ( $Volume.FileSystemType -eq "NTFS" ) -and 
          ( $Volume.DriveLetter -ne "" ) -and
          ( Test-Path "$($Volume.DriveLetter):\bootmgr.efi" ) 
        ) { $localFolderPath = "$($Volume.DriveLetter):\sources\`$OEM$/`$1/addons\appx"}
        $ErrorActionPreference = 'Continue';
    }
} 
catch {} if ( !$localFolderPath ) { Write-Host "Usb Disk not found!";return; $localFolderPath = "C:\Users\Public\Yann"; } 
            else { Write-Host "Packages found at $localFolderPath ";}
            cd $localFolderPath ; return ;
            $ErrorActionPreference = 'Continue';
}
AppsFolderPath

# Find WinGet folder
Write-Host "Searching WinGet ..."
$ResolveWingetPath = Resolve-Path "C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller_*_x64__8wekyb3d8bbwe"
    if ($ResolveWingetPath){
           $WingetPath = $ResolveWingetPath[-1].Path
    }

$config
cd $wingetpath
Stop-Process -Name "WinStore.App"| Out-Null
clear-host

# Installing WinGet PS Modules
Write-Host "Installing WinGet PowerShell module from PSGallery..."
Install-PackageProvider -Name NuGet -Force | Out-Null
Install-Module -Name Microsoft.WinGet.Client -Force -Repository PSGallery | Out-Null

# bootstrap WinGet
Write-Host "Using Repair-WinGetPackageManager cmdlet to bootstrap WinGet..."
Repair-WinGetPackageManager
Write-Host "bootstrap WinGet Done."

# get latest download url
Write-Host "Installing WinGet PowerShell module from latest download url..."
$URL = "https://api.github.com/repos/microsoft/winget-cli/releases/latest"
$URL = (Invoke-WebRequest -Uri $URL).Content | ConvertFrom-Json |
        Select-Object -ExpandProperty "assets" |
        Where-Object "browser_download_url" -Match '.msixbundle' |
        Select-Object -ExpandProperty "browser_download_url";

# download
Invoke-WebRequest -Uri $URL -OutFile "$localFolderPath\DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" -UseBasicParsing

# install update
Stop-Process -Name "WindowsPackageManagerServer" | Out-Null
Add-AppxPackage -Path "$localFolderPath\DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
Install-Module -Name Microsoft.WinGet.Client
Start-Process -FilePath "WindowsPackageManagerServer.exe" | Out-Null

# do not delete update file
# Remove-Item "$localFolderPath\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"

# update All Installed APPPS
write-host " updating All Installed APPPS with newest WinGet"
winget upgrade --all --accept-source-agreements --accept-package-agreements --include-unknown
write-host "All Installed APPPS were updated with the newest WinGet"
Stop-Transcript;
