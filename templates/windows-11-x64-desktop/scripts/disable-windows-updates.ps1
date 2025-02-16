# Stop and disable Windows Update service
Stop-Service -Name wuauserv -Force
Set-Service -Name wuauserv -StartupType Disabled

# Disable Windows Update through Group Policy
$regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
if (!(Test-Path $regPath)) {
    New-Item -Path $regPath -Force
}
Set-ItemProperty -Path $regPath -Name "NoAutoUpdate" -Value 1
Set-ItemProperty -Path $regPath -Name "AUOptions" -Value 1
Set-ItemProperty -Path $regPath -Name "NoAutoRebootWithLoggedOnUsers" -Value 1

# Disable Windows Update through Registry
$regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update"
if (!(Test-Path $regPath)) {
    New-Item -Path $regPath -Force
}
Set-ItemProperty -Path $regPath -Name "AUOptions" -Value 1

# Disable Windows Update Medic Service
$regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\WaaSMedicSvc"
if (!(Test-Path $regPath)) {
    New-Item -Path $regPath -Force
}
Set-ItemProperty -Path $regPath -Name "Start" -Value 4
