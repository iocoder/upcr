
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

    /* parameters to pass to kernel */
    lea    PTR(RamStart), %rcx
    lea    PTR(FrameBufVirt), %rdx

    /* execute kernel code */
    call   *%rbx

    /* halt */
    jmp    .
