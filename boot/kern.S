
/* C includes */
#include "asm.h"

/* assembler includes */
.include "efi.inc"

/* linker symbols to export */
.globl ExecKernel

/* text section */
.text

/* ExecKernel function */
ExecKernel:

    /* halt */
    jmp    .
