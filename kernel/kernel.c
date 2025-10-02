 void main() {
    char *vidmem = (char*)0xb8000;
    const char *msg = "Welcome to ShittimChest OS!";
    int i = 0;
    while (msg[i]) {
        vidmem[i*2] = msg[i];
        vidmem[i*2+1] = 0x0F; // white text
        i++;
    }
    for (;;) {}
}
