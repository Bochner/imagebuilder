# Disable unnecessary Windows features
$features = @(
    "WindowsMediaPlayer",
    "Internet-Explorer-Optional-*",
    "Microsoft-Windows-Subsystem-Linux"
)

foreach ($feature in $features) {
    Disable-WindowsOptionalFeature -Online -FeatureName $feature -NoRestart
}

# Disable unnecessary services
$services = @(
    "DiagTrack",                       # Connected User Experiences and Telemetry
    "dmwappushservice",               # WAP Push Message Routing Service
    "MapsBroker",                     # Downloaded Maps Manager
    "RemoteRegistry",                 # Remote Registry
    "SharedAccess",                   # Internet Connection Sharing
    "TrkWks",                        # Distributed Link Tracking Client
    "WSearch"                        # Windows Search
)

foreach ($service in $services) {
    Stop-Service -Name $service -Force -ErrorAction SilentlyContinue
    Set-Service -Name $service -StartupType Disabled -ErrorAction SilentlyContinue
}

# Disable scheduled tasks
$tasks = @(
    "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser",
    "\Microsoft\Windows\Application Experience\ProgramDataUpdater",
    "\Microsoft\Windows\Autochk\Proxy",
    "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator",
    "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip",
    "\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector",
    "\Microsoft\Windows\Maintenance\WinSAT",
    "\Microsoft\Windows\Windows Error Reporting\QueueReporting"
)

foreach ($task in $tasks) {
    Disable-ScheduledTask -TaskName $task -ErrorAction SilentlyContinue
}

# Optimize performance settings
$regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"
Set-ItemProperty -Path $regPath -Name "VisualFXSetting" -Value 2

# Disable hibernation
powercfg /h off

# Set power plan to high performance
powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c

# Clean up disk space
cleanmgr /sagerun:1
