# Enable WinRM
Enable-PSRemoting -Force
winrm quickconfig -q
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'

# Configure Windows Firewall
netsh advfirewall firewall add rule name="WinRM-HTTP" dir=in localport=5985 protocol=TCP action=allow

# Set network to private
$networkProfile = Get-NetConnectionProfile
Set-NetConnectionProfile -NetworkCategory Private -InterfaceIndex $networkProfile.InterfaceIndex

# Restart WinRM service
Restart-Service WinRM
