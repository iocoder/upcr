
/* C includes */
#include "boot/macros.h"

/* assembler includes */
.include "boot/efi.inc"

/* linker symbols to export */
.globl GetMemMap

/* text section */
.text

/* GetMemMap function */
GetMemMap:

    /* ----------------------------------------------- */
    /* (I) call GetMemoryMap() to get MapSize/DescSize */
    /* ----------------------------------------------- */

    /* initialize arguments */
    mov    $5, %rax             /* 5 arguments */
    lea    PTR(MapSize), %rcx   /* &MapSize */
    xor    %rdx, %rdx           /* &MemoryMap (NULL PTR) */
    xor    %r8, %r8             /* &MapKey (NULL PTR) */
    lea    PTR(DescSize), %r9   /* &DescSize */
    xor    %r10, %r10           /* &DescVersion (NULL PTR) */

    /* obtain SystemTable->BootServices->GetMemoryMap */
    mov    PTR(SystemTable), %rbx
    mov    BootServices(%rbx), %rbx
    mov    GetMemoryMap(%rbx), %rbx

    /* perform the call, returns values in MapSize and DescSize */
    call   EfiCall

    /* increase mapSize by 2*DescSize to compensate for AllocatePool() */
    mov    PTR(DescSize), %rax  /* retieve value in DescSize */
    shl    $1, %rax             /* multiply by 2 */
    add    %rax, PTR(MapSize)   /* increase MapSize */

    /* ----------------------------------- */
    /* (II) allocate buffer for memory map */
    /* ----------------------------------- */

    /* initialize arguments */
    mov    $3, %rax               /* 3 arguments */
    mov    $EfiLoaderData, %rcx   /* pool type */
    mov    PTR(MapSize), %rdx     /* pool size */
    lea    PTR(MemoryMap), %r8    /* return address in MemoryMap */

    /* obrain SystemTable->BootServices->AllocatePool */
    mov    PTR(SystemTable), %rbx
    mov    BootServices(%rbx), %rbx
    mov    AllocatePool(%rbx), %rbx

    /* perform the call, returns pointer in MemoryMap */
    call   EfiCall

    /* ------------------------------ */
    /* (III) retrieve UEFI memory map */
    /* ------------------------------ */

    /* initialize arguments */
    mov    $5, %rax                /* 5 arguments */
    lea    PTR(MapSize), %rcx      /* &MapSize */
    mov    PTR(MemoryMap), %rdx    /* MemoryMap */
    lea    PTR(MapKey), %r8        /* &MapKey */
    lea    PTR(DescSize), %r9      /* &DescSize */
    lea    PTR(DescVersion), %r10  /* &DescVersion */

    /* obtain SystemTable->BootServices->GetMemoryMap */
    mov    PTR(SystemTable), %rbx
    mov    BootServices(%rbx), %rbx
    mov    GetMemoryMap(%rbx), %rbx

    /* perform the call again (see step I) */
    call   EfiCall

    /* ------------------------------ */
    /* (IV) parse the UEFI memory map */
    /* ------------------------------ */

    /* load loop counters into CPU registers */
    mov    PTR(MemoryMap), %rsi    /* pointer to first descriptor */
    mov    PTR(MapSize), %rcx      /* MapSize */
    mov    PTR(DescSize), %rdx     /* DescSize */

    /* check if current entry is conventional memory */
1:  mov    Type(%rsi), %r10
    cmp    $EfiConventionalMemory, %r10
    jne    2f                      /* skip next block if not a memory */

    /* obtain size of RAM region from current descriptor */
    mov    NumberOfPages(%rsi), %r12
    shl    $12, %r12               /* multiply by PAGE_SIZE */
    cmp    %r12, PTR(RamSize)      /* biggest region found? */
    jg     2f                      /* skip next block if not */

    /* found a potential RAM region, retrieve all info */
    mov    PhysicalStart(%rsi), %r10 /* start address */
    mov    %r10, %r11                /* r11 will hold start address + size */
    add    %r12, %r11

    /* store the information in boot loader memory */
    mov    %r10, PTR(RamStart)
    mov    %r11, PTR(RamEnd)
    mov    %r12, PTR(RamSize)

    /* loop into next descriptor */
2:  add    %rdx, %rsi
    sub    %rdx, %rcx
    jnz    1b

    /* -------------------- */
    /* (V) return to caller */
    /* -------------------- */

    /* return */
    ret
