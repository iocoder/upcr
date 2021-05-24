
/* C includes */
#include "boot/macros.h"

/* assembler includes */
.include "boot/efi.inc"

/* linker symbols to export */
.globl ExecKernel

/* text section */
.text

/* ExecKernel function */
ExecKernel:

    /* get kernel entry point */
    lea    PTR(_binary_kernel_bin_start), %rbx

    /* execute kernel code */
    call   *%rbx

    /* halt */
    jmp    .
