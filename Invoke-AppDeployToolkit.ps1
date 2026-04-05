
[CmdletBinding()]
param(
[Parameter(Mandatory = $false)][ValidateSet('Install', 'Uninstall', 'Repair')][PSDefaultValue(Help = 'Install', Value = 'Install')][System.String]$DeploymentType,
[Parameter(Mandatory = $false)][ValidateSet('Interactive', 'Silent', 'NonInteractive')][PSDefaultValue(Help = 'Interactive', Value = 'Interactive')][System.String]$DeployMode,
[Parameter(Mandatory = $false)][System.Management.Automation.SwitchParameter]$AllowRebootPassThru,
[Parameter(Mandatory = $false)][System.Management.Automation.SwitchParameter]$TerminalServerMode,
[Parameter(Mandatory = $false)][System.Management.Automation.SwitchParameter]$DisableLogging
)

$adtSession = @{
    AppVendor                   =  'software-options'
    AppName                     =  'Software-options'
    AppVersion                  =  '1.3.1'
    AppArch                     =  'x64'
    AppLang                     =  'en-us'
    AppRevision                 =  '01'
    AppSuccessExitCodes         =  @(0)
    AppRebootExitCodes          =  @(1641, 3010)
    AppScriptVersion            =  '1.0.0'
    AppScriptDate               =  '2026-03-24'
    AppScriptAuthor             =  'Yann Duchateau'
    InstallName                 =  '' # doesn't need to be changed
    InstallTitle                =  '' # doesn't need to be changed
    DeployAppScriptFriendlyName =  $MyInvocation.MyCommand.Name
    DeployAppScriptVersion      =  '4.0.6'
    DeployAppScriptParameters   =  $PSBoundParameters
};

# detection
# File Version  %programfiles%\Java\jre1.8.0_461\bin\Java.exe >= 8.u.471
# how to : https://silentinstallhq.com/ #

function Install-ADTDeployment {

    $adtSession.InstallPhase = "Pre-$($adtSession.DeploymentType)";

    $adtSession.InstallPhase = $adtSession.DeploymentType;

    Start-ADTProcess `
     -FilePath "$($adtSession.dirFiles)\npp.8.8.8.Installer.x64.exe" `
     -ArgumentList " /S /V/qn /L=1033 /S /NCRC";

     Start-ADTProcess `
     -FilePath "msiexec.exe" `
     -ArgumentList " /i $($adtSession.dirFiles)\iCloud64.msi INSTALL_SUPPORT_PACKAGES=1 /quiet /norestart /log $env:Username\AppData\Local\Packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\LocalState\DiagOutputDir\Apple.iCloud.7.21.0.23.log";

    # Finding FireFoxRoot
    $FireFoxRoot = $False;
    if ( ( Test-Path "$env:ProgramFiles\Mozilla Firefox\firefox.exe" ) ) { $FireFoxRoot = "$env:ProgramFiles\\Mozilla Firefox\"; 

    $adtSession.InstallPhase = $adtSession.DeploymentType;
        if ( !$FireFoxRoot ) { Write-Host "Office not found!" -ForegroundColor Red; return;
     Start-ADTProcess `
     -FilePath "msiexec.exe" `
     -ArgumentList " /i $($adtSession.dirFiles)\FirefoxSetup132.0.2.msi /qn";
     -PassThru;
         } 
    else { Write-Host "Firefox found at $FireFoxRoot. Firefox is already Installed and its Install Will now end." -ForegroundColor Green; };

    Start-ADTProcess `
     -FilePath "$($adtSession.dirFiles)\CABCompresser.exe" `
     -ArgumentList " /S";

    Start-ADTProcess `
     -FilePath "$($adtSession.dirFiles)\jre-8u471-windows-x64.exe" `
     -ArgumentList "INSTALL_SILENT=1";

    Start-ADTProcess `
     -FilePath "$($adtSession.dirFiles)\PDFCreator-6_2_1-Setup.exe" `
     -ArgumentList " /ForceInstall /VERYSILENT /LANG=French /COMPONENTS=program,ghostscript,languages\English";
     
     Start-ADTProcess `
     -FilePath "$($adtSession.dirFiles)\K-Lite_Codec_Pack_1920_Full.exe" `
     -ArgumentList " /VERYSILENT /SP-";
     
     Start-ADTProcess `
     -FilePath "$($adtSession.dirFiles)\audacity-win-3.7.7-64bit.exe" `
     -ArgumentList " /VERYSILENT /SP-";

     Start-ADTProcess `
     -FilePath "$($adtSession.dirFiles)\FFmpeg_5.0.0_for_Audacity_on_Windows_x86_64.exe" `
     -ArgumentList " /VERYSILENT /SP-";
     Start-ADTProcess `
     -FilePath "$($adtSession.dirFiles)\spybotsd162.exe" `
     -ArgumentList " /sp- /silent /norestart /lang=FRA /group=Spybot /components=!updatedl,!updatew95 /tasks=launchsdhelper";

     Start-ADTProcess `
     -FilePath "$($adtSession.dirFiles)\spybotsd_includes_is.exe" `
     -ArgumentList " /SP- /verysilent /SUPPRESSMSGBOXES";
    
    Start-ADTProcess `
     -FilePath "$($adtSession.dirFiles)\3d_pinball_for_windows_-_space_cadet.exe" `
     -ArgumentList "/S";

     Start-ADTProcess `
     -FilePath "RegEdit.exe" `
     -ArgumentList "/S $($adtSession.dirFiles)\WinRar.reg";

     Start-ADTProcess `
     -FilePath "$($adtSession.dirFiles)\WinRar-x64-401fr.exe" `
     -ArgumentList "/S";
     
     Start-ADTProcess `
     -FilePath "$($adtSession.dirFiles)\winrar-x64-501.exe" `
     -ArgumentList "/S";

     Start-ADTProcess `
     -FilePath "$($adtSession.dirFiles)\ChromeStandaloneSetup64.exe" `
     -ArgumentList "--silent --install=appguid={8A69D345-D564-463C-AFF1-A69D9E530F96}&iid={4D268255-1485-1504-1614-17F8EBFC169B}&lang=en&browser=5&usagestats=0&appname=Google%20Chrome&needsadmin=prefers&ap=-arch_x64-statsdef_1&installdataindex=empty --channel=stable --enable-logging --create-shortcuts=0 --do-not-launch-chrome --vmodule=*/components/winhttp/*=1,*/components/update_client/*=1,*/chrome/enterprise_companion/*=0,*/chrome/updater/*=1";

     Start-ADTProcess `
     -FilePath "$($adtSession.dirFiles)\Opera_GX_128.0.5807.97_Setup_x64.exe" `
     -ArgumentList " /silent /allusers=1 /launchopera=0 /setdefaultbrowser=0";

    $adtSession.InstallPhase = "Post-$($adtSession.DeploymentType)";

}

#region DONOTMODIFY
$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop;
$ProgressPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue;
Set-StrictMode -Version 1;
# Initialization
try {
    $moduleName = if ([System.IO.File]::Exists("$PSScriptRoot\PSAppDeployToolkit\PSAppDeployToolkit.psd1")) {
        Get-ChildItem -LiteralPath $PSScriptRoot\PSAppDeployToolkit -Recurse -File | Unblock-File -ErrorAction Ignore;
        "$PSScriptRoot\PSAppDeployToolkit\PSAppDeployToolkit.psd1";
    } else { 'PSAppDeployToolkit'; }
    Import-Module -FullyQualifiedName @{ ModuleName = $moduleName; Guid = '8c3c366b-8606-4576-9f2d-4051144f7ca2'; ModuleVersion = '4.0.5' } -Force;
    try {
        $iadtParams = Get-ADTBoundParametersAndDefaultValues -Invocation $MyInvocation;
        $adtSession = Open-ADTSession -SessionState $ExecutionContext.SessionState @adtSession @iadtParams -PassThru;
    }
    catch { Remove-Module -Name PSAppDeployToolkit* -Force; throw; }
} catch { $Host.UI.WriteErrorLine((Out-String -InputObject $_ -Width ([System.Int32]::MaxValue))); exit 60008; }
# Invocation
try { 
    Get-Item -Path $PSScriptRoot\PSAppDeployToolkit.* | & { process {
        Get-ChildItem -LiteralPath $_.FullName -Recurse -File | Unblock-File -ErrorAction Ignore;
        Import-Module -Name $_.FullName -Force;
    } }
    & "$($adtSession.DeploymentType)-ADTDeployment";
    Close-ADTSession;
} catch {
    Write-ADTLogEntry -Message ($mainErrorMessage = Resolve-ADTErrorRecord -ErrorRecord $_) -Severity 3;
    Show-ADTDialogBox -Text $mainErrorMessage -Icon Stop | Out-Null;
    Close-ADTSession -ExitCode 60001;
} finally { Remove-Module -Name PSAppDeployToolkit* -Force; }
#endregion DONOTMODIFY