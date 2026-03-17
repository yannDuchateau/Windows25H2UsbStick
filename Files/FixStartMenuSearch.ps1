# Restart Windows search service
Write-Host "Restarting Windows search service..."
Stop-Service -Name "WSearch" -Force -ErrorAction SilentlyContinue
Start-Service -Name "WSearch"

# Re-Register Start Menu Experience and Cortana (Windows Shell Experience)
Write-Host "Re-Registering of Start Menu Experience and Cortana..."
Get-AppxPackage -AllUsers Microsoft.Windows.StartMenuExperienceHost | Foreach {
Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"
}
Get-AppxPackage -AllUsers Microsoft.Windows.Cortana | Foreach {
Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"
}

# Erase Windows search Cache
$searchDatabasePath = "$env:ProgramData\Microsoft\Search\Data\Applications\Windows\Windows.edb"
if (Test-Path $searchDatabasePath) {
Write-Host "Stopping windows Search Service in order to allow Index refresh"
Stop-Service -Name "WSearch" -Force
Write-Host "Suppressing the Windows Search Index Database file..."
Remove-Item -Path $searchDatabasePath -Force
Write-Host "Restart of Wondows Search Service..."
Start-Service -Name "WSearch"
} else {
Write-Host "Windows Search Database File not found."
}

# Optional : Restart Explorer (to refresh changes)
Write-Host "Restarting Explorer..."
Stop-Process -Name explorer -Force
Start-Process explorer.exe
