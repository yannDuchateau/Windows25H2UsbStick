# Redémarrer le service de recherche Windows

Write-Host "Redémarrage du service de recherche Windows..."

Stop-Service -Name "WSearch" -Force -ErrorAction SilentlyContinue

Start-Service -Name "WSearch"

# Réenregistrer le menu Démarrer et Cortana (Windows Shell Experience)

Write-Host "Réenregistrement des composants du menu Démarrer et de Cortana..."

Get-AppxPackage -AllUsers Microsoft.Windows.StartMenuExperienceHost | Foreach {

Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"

}

Get-AppxPackage -AllUsers Microsoft.Windows.Cortana | Foreach {

Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"

}

# Effacer le cache de recherche Windows

$searchDatabasePath = "$env:ProgramData\Microsoft\Search\Data\Applications\Windows\Windows.edb"

if (Test-Path $searchDatabasePath) {

Write-Host "Arrêt du service de recherche Windows pour supprimer l'index..."

Stop-Service -Name "WSearch" -Force

Write-Host "Suppression de la base de données de l'index de recherche..."

Remove-Item -Path $searchDatabasePath -Force

Write-Host "Redémarrage du service de recherche Windows..."

Start-Service -Name "WSearch"

} else {

Write-Host "Base de données de l'index de recherche introuvable."

}

# Optionnel : Redémarrer l'Explorateur (pour appliquer les changements visuellement)

Write-Host "Redémarrage de l'Explorateur..."

Stop-Process -Name explorer -Force

Start-Process explorer.exe