
/* C includes */
#include "asm.h"

/* assembler includes */
.include "efi.inc"

/* linker symbols to export */
.globl InitLoader

/* text section */
.text

/* InitLoader function */
InitLoader:

    /* just store EFI information to be used later */
    mov    %rcx, PTR(ImageHandle)
    mov    %rdx, PTR(SystemTable)

    /* done */
    ret
