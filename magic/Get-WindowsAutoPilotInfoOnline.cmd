rem powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$SERIAL = (Get-WmiObject -Class Win32_BIOS).SerialNumber; & .\Get-WindowsAutoPilotInfo.ps1 -OutputFile .\Autopilot\Autopilot-$SERIAL.csv"

call powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "install-script get-windowsautopilotinfo"

call powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "get-windowsautopilotinfo -online"
