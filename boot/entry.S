
/* C includes */
#include "boot/macros.h"

/* assembler includes */
.include "boot/efi.inc"

/* linker symbols to export */
.globl Entry

/* text section */
.text

/* boot loader entry point */
Entry:

    /* initialize boot loader */
    call   InitLoader

    /* print banner */
    call   ShowBanner

    /* get BLT information */
    call   GetBlt

    /* get memory map */
    call   GetMemMap

    /* exit from EFI boot services */
    call   ExitBoot

    /* execute kernel code */
    call   ExecKernel
