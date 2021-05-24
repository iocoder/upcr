
/* C includes */
#include "kernel/asm.h"

/* place in init section */
.section  .init, "ax"

/* KernelInit function */
KernelInit:

    /* halt */
    jmp    .
