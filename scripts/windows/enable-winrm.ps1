# Enable WinRM service
Enable-PSRemoting -Force
winrm quickconfig -q
winrm quickconfig -transport:http
winrm set winrm/config '@{MaxTimeoutms="1800000"}'
winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="800"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/client/auth '@{Basic="true"}'

# Configure Windows Firewall
Get-NetFirewallRule -Name "WINRM-HTTP-In-TCP*" | Remove-NetFirewallRule
New-NetFirewallRule -Name "WINRM-HTTP-In-TCP" -DisplayName "Windows Remote Management (HTTP-In)" -Enabled True -Profile Any -Action Allow -Direction Inbound -Protocol TCP -LocalPort 5985

# Set network profile to private
Set-NetConnectionProfile -NetworkCategory Private

# Restart WinRM service
Restart-Service winrm