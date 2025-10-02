 # build.ps1
# Adjust tool paths to your installs:
$NASM = "C:\Program Files\NASM\nasm.exe"
$GCC = "C:\Users\LENOVO\Documents\i686-elf-tools-windows\bin\i686-elf-gcc.exe"
$LD = "C:\Users\LENOVO\Documents\i686-elf-tools-windows\bin\i686-elf-ld.exe"
$QEMU = "C:\Program Files\qemu\qemu-system-i386.exe"

$BootSrc = "boot\boot.asm"
$BootBin = "boot\boot.bin"
$KernelSrc = "kernel\kernel.c"
$KernelObj = "kernel\kernel.o"
$KernelBin = "kernel\kernel.bin"
$Floppy = "os-image.img"

Write-Host "=== Assembling bootloader ==="
& $NASM -f bin $BootSrc -o $BootBin
if (-not (Test-Path $BootBin)) { Write-Error "boot.bin missing - assembly failed"; exit 1 }

Write-Host "=== Compiling kernel ==="
& $GCC -m32 -ffreestanding -c $KernelSrc -o $KernelObj
if ($LASTEXITCODE -ne 0) { Write-Error "GCC failed"; exit 1 }

Write-Host "=== Linking kernel (flat binary at 0x10000) ==="
& $LD -Ttext 0x10000 --oformat binary -o $KernelBin $KernelObj
if (-not (Test-Path $KernelBin)) { Write-Error "kernel binary missing"; exit 1 }

Write-Host "=== Preparing kernel bytes and padding to sectors ==="
$KernelBytes = [System.IO.File]::ReadAllBytes($KernelBin)

# pad to 512-byte sector multiple
$pad = 512 - ($KernelBytes.Length % 512)
if ($pad -ne 512) {
    $KernelBytes += (New-Object byte[] $pad)
}

# calculate sectors
$kernelSectors = [math]::Ceiling($KernelBytes.Length / 512)
Write-Host "Kernel size: $($KernelBytes.Length) bytes -> $kernelSectors sectors"

Write-Host "=== Creating blank floppy image (1.44MB) ==="
$floppySize = 1474560
$floppyBytes = New-Object byte[] $floppySize

Write-Host "=== Copying boot sector ==="
$bootBytes = [System.IO.File]::ReadAllBytes($BootBin)
if ($bootBytes.Length -gt 512) { Write-Error "boot.bin is larger than 512 bytes"; exit 1 }
[Array]::Copy($bootBytes, 0, $floppyBytes, 0, $bootBytes.Length)

Write-Host "=== Writing kernel at sector 2 (offset 512) ==="
[Array]::Copy($KernelBytes, 0, $floppyBytes, 512, $KernelBytes.Length)

Write-Host "=== Writing floppy file ==="
[System.IO.File]::WriteAllBytes($Floppy, $floppyBytes)

Write-Host "=== Launching QEMU ==="
& $QEMU -fda $Floppy -boot a
