
/* C includes */
#include "boot/macros.h"

/* assembler includes */
.include "boot/efi.inc"

/* linker symbols to export */
.globl ShowBanner

/* text section */
.text

/* ShowBanner function */
ShowBanner:

    /* retrieve system table */
    mov    PTR(SystemTable), %rbx

    /* initialize arguments for OutputString() */
    mov    $2, %eax
    mov    ConOut(%rbx), %rcx
    lea    PTR(BannerData), %rdx

    /* retrieve SystemTable->ConOut->OutputString */
    mov    OutputString(%rcx), %rbx

    /* perform the call */
    call   EfiCall

    /* done */
    ret
