
/* C includes */
#include "asm.h"

/* assembler includes */
.include "efi.inc"

/* linker symbols to export */
.globl ExitBoot

/* text section */
.text

/* ExitBoot function */
ExitBoot:

    /* initialize arguments for ExitBootServices() */
    mov    $2, %eax
    mov    PTR(ImageHandle), %rcx
    mov    PTR(MapKey), %rdx

    /* obtain SystemTable->BootServices->ExitBootServices */
    mov    PTR(SystemTable), %rbx
    mov    BootServices(%rbx), %rbx
    mov    ExitBootServices(%rbx), %rbx

    /* perform the call */
    call   EfiCall

    /* done */
    ret
