# Stop and disable Windows Update service
Stop-Service -Name wuauserv -Force
Set-Service -Name wuauserv -StartupType Disabled

# Disable automatic updates through registry
$WindowsUpdatePath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\"
$AutoUpdatePath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"

If(!(Test-Path $WindowsUpdatePath)) {
    New-Item -Path $WindowsUpdatePath -Force
}
If(!(Test-Path $AutoUpdatePath)) {
    New-Item -Path $AutoUpdatePath -Force
}

Set-ItemProperty -Path $AutoUpdatePath -Name NoAutoUpdate -Value 1
Set-ItemProperty -Path $AutoUpdatePath -Name AUOptions -Value 1
Set-ItemProperty -Path $AutoUpdatePath -Name ScheduledInstallDay -Value 0
Set-ItemProperty -Path $AutoUpdatePath -Name ScheduledInstallTime -Value 3

# Disable Windows Store automatic updates
$StorePath = "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore"
If(!(Test-Path $StorePath)) {
    New-Item -Path $StorePath -Force
}
Set-ItemProperty -Path $StorePath -Name AutoDownload -Value 2

# Disable Microsoft Store
$registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore"
If(!(Test-Path $registryPath)) {
    New-Item -Path $registryPath -Force
}
Set-ItemProperty -Path $registryPath -Name RemoveWindowsStore -Value 1

Write-Host "Windows Updates have been disabled." 