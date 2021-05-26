
/* assist with position-independent code */
#define PTR(SomeVariable)   SomeVariable@GOTPCREL(%rip)


/* place in init section */
.section  .init, "ax"

/* KernelInit function */
KernelInit:

    /* initialize kernel data */
    call   KernelDataInit

    /* initialize console */
    call   KernelConsoleInit

    /* initialize splash */
    call   KernelSplashInit

    /* halt */
    jmp    .
