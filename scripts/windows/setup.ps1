# Install Windows Updates
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Install-Module PSWindowsUpdate -Force
Get-WindowsUpdate -Install -AcceptAll -IgnoreReboot

# Enable Remote Desktop
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value 0
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

# Install QEMU Guest Agent
$ErrorActionPreference = "Stop"
$url = "https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/latest-virtio/qemu-ga-x86_64.msi"
$output = "$env:TEMP\qemu-ga-x86_64.msi"
Invoke-WebRequest -Uri $url -OutFile $output
Start-Process -FilePath msiexec -ArgumentList "/i $output /qn" -Wait

# Cleanup
Remove-Item -Path $output -Force
Clear-RecycleBin -Force -ErrorAction SilentlyContinue
Clear-BCCache -Force -ErrorAction SilentlyContinue

# Optimize disk space
Optimize-Volume -DriveLetter C -Defrag -ReTrim