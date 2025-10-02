 // Simple OS kernel entry point
void main() {
    // Video memory address for text mode (80x25 characters)
    char *vidmem = (char*)0xb8000;
    const char *msg = "Welcome to ShittimChest OS Kernel!";
    int i = 0;

    // Loop through the message and write to video memory
    while (msg[i]) {
        // Character byte (even index)
        vidmem[i*2] = msg[i];
        // Attribute byte (odd index): 0x0A is light green text on black background
        vidmem[i*2+1] = 0x0A;
        i++;
    }

    // Simple delay loop (optional, but keeps the screen busy)
    for (volatile long j = 0; j < 5000000; j++);

    // CRITICAL FIX: After the kernel finishes its job, it MUST enter an infinite loop.
    // In a bare-metal environment, there is no place to "return" to.
    for (;;);
}
