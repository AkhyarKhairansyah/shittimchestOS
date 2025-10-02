 ; --- Bootloader Setup ---
[org 0x7c00]        ; BIOS loads us here

KERNEL_SECTORS   equ 10        ; number of sectors to load
KERNEL_LOAD_SEG  equ 0x1000    ; load segment
KERNEL_LOAD_OFF  equ 0x0000    ; offset (so linear = 0x10000)

jmp short start
nop

; --- Data Section ---
boot_msg   db "Booting ShittimChest OS...", 0
disk_error db "Disk Read Error", 0

; --- Code Start ---
start:
    ; Setup segments
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00

    ; Print boot message
    mov si, boot_msg
    call print_string

    ; Load kernel (from sector 2 onwards)
    mov ax, KERNEL_LOAD_SEG
    mov es, ax
    mov bx, KERNEL_LOAD_OFF

    mov ah, 0x02              ; BIOS read sectors
    mov al, KERNEL_SECTORS    ; number of sectors
    mov ch, 0x00              ; cylinder 0
    mov cl, 0x02              ; sector 2
    mov dh, 0x00              ; head 0
    mov dl, 0x00              ; drive 0 (floppy A:)
    int 0x13
    jc disk_fail              ; if error -> fail

    ; Switch to protected mode
    cli
    lgdt [gdt_descriptor]
    mov eax, cr0
    or eax, 1
    mov cr0, eax
    jmp 0x08:protected_mode

; --- Protected Mode ---
[bits 32]
protected_mode:
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, 0x90000

    jmp 0x10000               ; jump to kernel entry

; --- Utility: Print string ---
[bits 16]
print_string:
    lodsb
    or al, al
    jz .done
    mov ah, 0x0e
    int 0x10
    jmp print_string
.done:
    ret

disk_fail:
    mov si, disk_error
    call print_string
    hlt

; --- GDT ---
gdt_start:
gdt_null: dq 0x0000000000000000
gdt_code: dq 0x00cf9a000000ffff
gdt_data: dq 0x00cf92000000ffff
gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

; --- Boot Signature ---
times 510 - ($ - $$) db 0
dw 0xaa55
