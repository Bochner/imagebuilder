# Create temporary directory for VirtIO drivers
New-Item -Path "C:\Windows\Temp\virtio" -ItemType Directory -Force

# Download VirtIO drivers
$virtioIsoUrl = "https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso"
$virtioIsoPath = "C:\Windows\Temp\virtio\virtio-win.iso"
Invoke-WebRequest -Uri $virtioIsoUrl -OutFile $virtioIsoPath

# Mount the ISO
$mountResult = Mount-DiskImage -ImagePath $virtioIsoPath -PassThru
$driveLetter = ($mountResult | Get-Volume).DriveLetter

# Install drivers
$driverPath = "${driveLetter}:\w11\amd64"
pnputil /add-driver "$driverPath\*.inf" /install /subdirs

# Cleanup
Dismount-DiskImage -ImagePath $virtioIsoPath
Remove-Item -Path "C:\Windows\Temp\virtio" -Recurse -Force 