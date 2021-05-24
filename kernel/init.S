
/* C includes */
#include "kernel/asm.h"

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
