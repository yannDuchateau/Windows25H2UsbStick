# InstallAll script-loader 
# 
# yann duchateau
#
# 03.05.2026 - 1.3.1
Set-ExecutionPolicy Unrestricted -Force -ErrorAction SilentlyContinue
import-module dism
import-module Appx

$LogDate = get-date -format "MM-d-yy-HH" 
$objShell = New-Object -ComObject Shell.Application  
$objFolder = $objShell.Namespace(0xA) 
$ErrorActionPreference = "silentlycontinue"
$automatedFixPack.RequiresElevation = "True"
                     
Start-Transcript -Path "C:\Windows\Logs\InstallAll$LogDate.ps1.log"

vfunction NeedElevation {
    if ($automatedFixPack.RequiresElevation -eq $true -and $architecture -ne 5)
    {
        $identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
        $principal = New-Object System.Security.Principal.WindowsPrincipal -ArgumentList $identity
        if (-not $($principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)))
        {
            Write-AutomatedFixExecutionLog -Path $AutomatedFixExecutionLog -Level "error" `
                -Message "The Automated Fix solution requires to run in the elevated Administrator account."
    }
  }
}

$architecture = -1
$proc = @(Get-WmiObject Win32_Processor -ErrorAction SilentlyContinue)
if ($proc -ne $null -and $proc.Count -gt 0)
{
    $architecture = $proc[0].Architecture
}
write-host $architecture

if ([System.Environment]::OSVersion.Version -lt [System.Version]"10.0.26200.0")
{
    write-host "The AutomatedFixUnattended script can only work on the Windows 11"
    return
}

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

if ( !(Test-Path -Path "C:\Users\Public\Yann" ) ) {
    New-Item -Path "C:\Users\Public" -Name "Yann" -ItemType "Directory" | Out-Null;
} 
Expand-Archive -Force "$MagicStick" "C:\Users\Public\Yann\magic";
Set-Location -Path "C:\Users\Public\Yann\magic";
$ErrorActionPreference = 'Continue';

Write-Host 'Expand-Archive -Force "$postsetup" "C:\Windows\Setup\post-setup"'
Expand-Archive -Force "$postsetup" "C:\Windows\Setup\post-setup";
 $ErrorActionPreference = 'Continue';

Write-Host 'Start-Process -FilePath "C:\Windows\Setup\post-setup\Deploy-Application.exe" -Wait -NoNewWindow'
Start-Process -FilePath "C:\Windows\Setup\post-setup\Deploy-Application.exe" -Wait -NoNewWindow
$ErrorActionPreference = 'SilentlyContinue'

# Write-Host "C:\Windows\Setup\post-setup\Deploy-Application.ps1"
# & "C:\Windows\Setup\post-setup\Deploy-Application.ps1"
# $ErrorActionPreference = 'Continue'

Write-Host 'Start-Process -FilePath "C:\Users\Public\Yann\magic\Files\first-logon-script\Invoke-AppDeployToolkit.exe" -Wait -NoNewWindow'
Start-Process -FilePath "C:\Users\Public\Yann\magic\Files\first-logon-script\Invoke-AppDeployToolkit.exe" -Wait -NoNewWindow
$ErrorActionPreference = 'SilentlyContinue'

# Write-Host 'Start-Process -FilePath "C:\Users\Public\Yann\magic\Files\first-logon-script\Invoke-AppDeployToolkit.ps1" -Wait -NoNewWindow'
# Start-Process -FilePath "C:\Users\Public\Yann\magic\Files\first-logon-script\Invoke-AppDeployToolkit.ps1" -Wait -NoNewWindow
# $ErrorActionPreference = 'Continue';

Write-Host "C:\Users\Public\Yann\magic\Invoke-AppDeployToolkit.exe"
& "C:\Users\Public\Yann\magic\Invoke-AppDeployToolkit.exe"
$ErrorActionPreference = 'SilentlyContinue'

# Write-Host "C:\Users\Public\Yann\magic\Invoke-AppDeployToolkit.ps1"
# & "C:\Users\Public\Yann\magic\Invoke-AppDeployToolkit.ps1"
$ErrorActionPreference = 'Continue'

Write-Host "Done;"
Stop-Transcript;
