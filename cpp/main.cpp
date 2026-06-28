// Smallest possible "hello world" — no libc, no CRT, raw syscalls only
//
// Uses custom _start entry point (bypasses main/crt0) and direct kernel
// syscalls for write() and exit(), so the linker pulls in zero libraries.
//
// Supported architectures: aarch64 and x86_64.

#if defined(__aarch64__)

extern "C" void _start() {
    const char msg[] = "Hello, world!\n";

    // write(1, msg, 14)
    register long x0 __asm__("x0") = 1;
    register const char* x1 __asm__("x1") = msg;
    register long x2 __asm__("x2") = 14;
    register long x8 __asm__("x8") = 64;       // __NR_write
    __asm__ volatile("svc #0" : "+r"(x0) : "r"(x1), "r"(x2), "r"(x8));

    // exit(0)
    register long r0 __asm__("x0") = 0;
    register long r8 __asm__("x8") = 93;       // __NR_exit
    __asm__ volatile("svc #0" : : "r"(r0), "r"(r8));
    __builtin_unreachable();
}

#elif defined(__x86_64__)

extern "C" void _start() {
    const char msg[] = "Hello, world!\n";

    // write(1, msg, 14)
    __asm__ volatile(
        "mov $1, %%rax\n"
        "mov $1, %%rdi\n"
        "mov %0, %%rsi\n"
        "mov $14, %%rdx\n"
        "syscall"
        :
        : "r"(msg)
        : "rax", "rdi", "rsi", "rdx"
    );

    // exit(0)
    __asm__ volatile(
        "mov $60, %%rax\n"
        "xor %%rdi, %%rdi\n"
        "syscall"
    );
    __builtin_unreachable();
}

#else
#error "Unsupported architecture"
#endif
