
/* C includes */
#include "boot/macros.h"

/* assembler includes */
.include "boot/efi.inc"

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
