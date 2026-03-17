# InstallMammut script-loader 
# 
# Luca Weidmann and Yann duchateau
#
# 03.05.2026 - 1.31
Set-ExecutionPolicy Unrestricted -Force -ErrorAction SilentlyContinue
import-module dism
import-module Appx

$LogDate = get-date -format "MM-d-yy-HH" 
$objShell = New-Object -ComObject Shell.Application  
$objFolder = $objShell.Namespace(0xA) 
$ErrorActionPreference = "silentlycontinue" 
                     
Start-Transcript -Path "C:\Windows\Logs\InstallMammut$LogDate.ps1.log"

# Find MagicStick drive
$MagicStick = $False;
try {
    Get-Volume | % {
        $Volume = $_;
        if ( 

          ( $Volume.DriveType -eq "Removable" ) -and
          ( $Volume.FileSystemType -eq "NTFS" ) -and 
          ( $Volume.DriveLetter -ne "" ) -and
          ( Test-Path "$($Volume.DriveLetter):\magic\magic.zip" ) 

        ) { $MagicStick = "$($Volume.DriveLetter):\magic\magic.zip"; }
    }
} 
catch {}

clear-host

# Find post-setup Folder
$postsetup = $False;
try {
    Get-Volume | % {
        $Volume = $_;
        if ( 

          ( $Volume.FileSystemType -eq "NTFS" ) -and 
          ( $Volume.DriveLetter -ne "" ) -and
          ( $Volume.DriveType -eq "Removable" ) -and
          ( Test-Path "$($Volume.DriveLetter):\magic\post-setup.zip" ) 

        ) { $postsetup =  "$($Volume.DriveLetter):\magic\post-setup.zip"; }
    }
} 
catch {}

clear-host

if ( !$MagicStick ) { Write-Host "MagicStick not found!"; return; } 
else { Write-Host "MagicStick found at $MagicStick"; }

if ( !$postsetup ) { Write-Host "post setup not found!"; return; } 
else { Write-Host "post setup found at $postsetup"; }

if ( !(Test-Path -Path "C:\Users\Public\Mammut" ) ) {
    New-Item -Path "C:\Users\Public" -Name "Mammut" -ItemType "Directory" | Out-Null;
} 
Expand-Archive -Force "$MagicStick" "C:\Users\Public\Mammut\magic";
Set-Location -Path "C:\Users\Public\Mammut\magic";

Write-Host 'Expand-Archive -Force "$postsetup" "C:\Windows\Setup\post-setup"'
Expand-Archive -Force "$postsetup" "C:\Windows\Setup\post-setup";

Write-Host "C:\Users\Public\Mammut\magic\Files\first-logon-script\Invoke-AppDeployToolkit.ps1"
& "C:\Users\Public\Mammut\magic\Files\first-logon-script\Invoke-AppDeployToolkit.ps1"

# Write-Host 'Start-Process -FilePath "C:\Users\Public\Mammut\magic\Files\first-logon-script\Invoke-AppDeployToolkit.exe" -Wait -NoNewWindow'
# Start-Process -FilePath "C:\Users\Public\Mammut\magic\Files\first-logon-script\Invoke-AppDeployToolkit.exe" -Wait -NoNewWindow

Write-Host "C:\Users\Public\Mammut\magic\Invoke-AppDeployToolkit.ps1"
& "C:\Users\Public\Mammut\magic\Invoke-AppDeployToolkit.ps1"

$ErrorActionPreference = 'Continue';

Write-Host 'Start-Process -FilePath "C:\Windows\Setup\post-setup\Deploy-Application.exe" -Wait -NoNewWindow'
Start-Process -FilePath "C:\Windows\Setup\post-setup\Deploy-Application.exe" -Wait -NoNewWindow

$ErrorActionPreference = 'Continue';

Write-Host "Done;"
Stop-Transcript;
