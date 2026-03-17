# post-setup-script-loader 
#
# Yann Duchateau
#
# 02.02.2024 - 1.3
Set-ExecutionPolicy Unrestricted -Force -ErrorAction SilentlyContinue
import-module dism
import-module Appx

# Start Logging Installation
 function LOgCreate {
   $LogDate = get-date -format "MM-d-yy-HH" 
   $objShell = New-Object -ComObject Shell.Application  
   $objFolder = $objShell.Namespace(0xA) 
   $ErrorActionPreference = "silentlycontinue" 
                     
Start-Transcript -Path "C:\Windows\Logs\post-setup$LogDate.ps1.log"

}
LOgCreate

# Find post-setup Folder
$postsetup = $False;
try {
    Get-Volume | % {
        $Volume = $_;
        if ( 

          ( $Volume.FileSystemType -eq "NTFS" ) -and 
          ( $Volume.DriveLetter -ne "" ) -and
          ( Test-Path "$($Volume.DriveLetter):\Windows\Setup\Files\post-setup.zip" ) 

        ) { $postsetup = "$($Volume.DriveLetter):\Windows\Setup\Files\post-setup.zip"; }
    }
} 
catch {}

if ( !$postsetup ) { Write-Host "Post Setup not found!"; return; } 
else { Write-Host "Postsetup found at $postsetup"; }

Write-Host 'Expand-Archive -Force "$post-setup" "C:\Windows\Setup\post-setup"'
Expand-Archive -Force "$postsetup" "C:\Windows\Setup\post-setup"
Write-Host 'Start-Process -FilePath "C:\Windows\Setup\post-setup\Deploy-Application.exe" -Wait -NoNewWindow'
Start-Process -FilePath "C:\Windows\Setup\post-setup\Deploy-Application.exe" -Wait -NoNewWindow

$ErrorActionPreference = 'Continue';
# Write-Host 'Start-Process -FilePath "C:\Windows\Setup\post-setup\Deploy-Application.ps1" -Wait -NoNewWindow'
# Start-Process -FilePath "C:\Windows\Setup\post-setup\Deploy-Application.ps1" -Wait -NoNewWindow

Write-Host "Done;"
Stop-Transcript;