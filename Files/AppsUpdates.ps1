# command line pre-setup prerequisites:
winget install -e -h --id Microsoft.DesktopAppInstaller_8wekyb3d8bbwe -s msstore  --accept-package-agreements
winget upgrade Microsoft.AppInstaller --accept-source-agreements --accept-package-agreements --include-unknown
Install-Module -Name Microsoft.WinGet.Client

Import-Module Appx
Import-Module Dism

winget search "Microsoft.Desktop"
winget search "teams" -s msstore
winget search "Teams"-s winget
winget search "edge"
#Powershell
winget install --id Microsoft.Powershell --source winget
winget update --id Microsoft.Powershell --source winget
# dotnet 
dotnet --list-runtimes
winget install -e -h Microsoft.DotNet.Runtime.10 --source msstore --accept-source-agreements --accept-package-agreements
winget install  -e -h Microsoft.DotNet.AspNetCore.10 --source msstore --accept-source-agreements --accept-package-agreements
winget install -e -h Microsoft.VisualStudioCode --accept-package-agreements --accept-source-agreements
# edge basic
winget search "XPFFTQ037JWMHS" -s msstore
# edge latest
winget install Microsoft.Edge --accept-package-agreements --accept-source-agreements
winget install XP8BT8DW290MPQ --accept-package-agreements --accept-source-agreements
winget install Mozilla.Firefox.fr --accept-package-agreements --accept-source-agreements
winget install -e -h --id Microsoft.WindowsTerminal -s msstore  --accept-package-agreements
#Microsoft.Sysinternals.Suite
winget install -e -h Microsoft.Sysinternals.Suite --accept-package-agreements --accept-source-agreements
#mRemoteNG
winget install -e -h mRemoteNG.mRemoteNG --accept-package-agreements --accept-source-agreements
#Microsoft.Sysinternals.Suite
winget install -e -h Microsoft.Sysinternals.Suite --accept-package-agreements --accept-source-agreements
#Google.Chrome
winget install -e -h Google.Chrome --accept-package-agreements --accept-source-agreements
#Slack
winget install -e -h 9WZDNCRDK3WP --accept-package-agreements --accept-source-agreements
#Microsoft Remote Desktop               
winget install -e -h Remote Desktop --accept-package-agreements --accept-source-agreements
#Free Download Manager
winget install -e -h XPDLMKFTXTDHSD --accept-package-agreements --accept-source-agreements

winget update --id Notepad++.Notepad++ --accept-source-agreements
winget update --id Adobe.Acrobat.Reader.64-bit --accept-source-agreements
winget update --id CodecGuide.K-LiteCodecPack.Full --accept-source-agreements
winget update --id Microsoft.Teams --accept-source-agreements
winget update --id Microsoft.WindowsTerminal --accept-source-agreements
winget update --id Microsoft.Teams.Free --accept-source-agreements
winget upgrade --all --include-unknown --source winget
winget upgrade --all --accept-package-agreements --accept-source-agreements
#Upgrade Teams
#winget upgrade Microsoft.Teams --accept-package-agreements --accept-source-agreements
winget upgrade --all --silent --accept-source-agreements --accept-package-agreements >> c:\Windows\Logs\WgetUpdatesSofts.log
