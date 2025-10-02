 # === Paths ===
$NASM   = "C:\Program Files\NASM\nasm.exe"
$GCC    = "C:\Users\LENOVO\Documents\i686-elf-tools-windows\bin\i686-elf-gcc.exe"
$LD     = "C:\Users\LENOVO\Documents\i686-elf-tools-windows\bin\i686-elf-ld.exe"
$QEMU   = "C:\Program Files\qemu\qemu-system-i386.exe"

$BootSrc = "boot\boot.asm"
$BootBin = "boot\boot.bin"
$KernelSrc = "kernel\kernel.c"
$KernelObj = "kernel\kernel.o"
$KernelBin = "kernel\kernel.bin"
$Floppy    = "os-image.img"

Write-Host "=== Assembling bootloader ==="
& $NASM -f bin $BootSrc -o $BootBin

Write-Host "=== Compiling kernel ==="
& $GCC -ffreestanding -c $KernelSrc -o $KernelObj
& $LD -o $KernelBin -Ttext 0x1000 --oformat binary $KernelObj

Write-Host "=== Creating floppy image ==="
$BootBinBytes   = [System.IO.File]::ReadAllBytes($BootBin)
$KernelBinBytes = [System.IO.File]::ReadAllBytes($KernelBin)

# Create blank 1.44MB floppy
$FloppySize = 1474560
$FloppyBytes = New-Object Byte[] $FloppySize

# Copy boot sector at 0x0
[Array]::Copy($BootBinBytes, 0, $FloppyBytes, 0, $BootBinBytes.Length)

# Copy kernel at sector 2 (offset 512*2 = 1024)
[Array]::Copy($KernelBinBytes, 0, $FloppyBytes, 1024, $KernelBinBytes.Length)

[System.IO.File]::WriteAllBytes($Floppy, $FloppyBytes)

Write-Host "=== Running in QEMU ==="
& $QEMU -fda $Floppy
