 [BITS 16]
[ORG 0x7C00]

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    sti

    mov [BOOT_DRIVE], dl     ; save BIOS boot drive

    mov si, msg
    call print_string

    ; load kernel (sector 2) to 0x1000
    mov ax, 0x0000
    mov es, ax
    mov bx, 0x1000           ; ES:BX = 0000:1000
    mov ah, 0x02             ; BIOS read sectors
    mov al, 1                ; sectors to read
    mov ch, 0                ; cylinder
    mov cl, 2                ; sector number (start at 2)
    mov dh, 0                ; head
    mov dl, [BOOT_DRIVE]     ; boot drive

    int 0x13
    jc disk_error

    jmp 0x0000:0x1000        ; jump to kernel

disk_error:
    mov si, err
    call print_string
    jmp $

print_string:
    lodsb
    or al, al
    jz .done
    mov ah, 0x0E
    int 0x10
    jmp print_string
.done:
    ret

msg db "Booting ShittimChest OS...", 0
err db "Disk error!", 0
BOOT_DRIVE db 0

times 510-($-$$) db 0
dw 0xAA55
