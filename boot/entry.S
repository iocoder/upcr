
/* C includes */
#include "asm.h"

/* assembler includes */
.include "efi.inc"

/* linker symbols to export */
.globl Entry

/* text section */
.text

/* boot loader entry point */
Entry:

    /* initialize boot loader */
    call   InitLoader

    /* get memory map */
    call   GetMemMap

    /* print banner */
    call   ShowBanner

    /* exit from EFI boot services */
    call   ExitBoot

    /* execute kernel code */
    call   ExecKernel
