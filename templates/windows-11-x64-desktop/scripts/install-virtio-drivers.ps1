# Download and install VirtIO drivers
$virtioIsoUrl = "https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso"
$virtioIsoPath = "$env:TEMP\virtio-win.iso"
$mountPath = "V:"

# Download VirtIO ISO
Invoke-WebRequest -Uri $virtioIsoUrl -OutFile $virtioIsoPath

# Mount the ISO
Mount-DiskImage -ImagePath $virtioIsoPath

# Get the drive letter of the mounted ISO
$driveLetter = (Get-DiskImage -ImagePath $virtioIsoPath | Get-Volume).DriveLetter

# Install drivers
$driverPath = "${driveLetter}:\w11\amd64"
pnputil /add-driver "$driverPath\*.inf" /install /subdirs

# Unmount the ISO
Dismount-DiskImage -ImagePath $virtioIsoPath

# Clean up
Remove-Item $virtioIsoPath -Force
