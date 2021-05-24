
/* C includes */
#include "boot/macros.h"

/* assembler includes */
.include "boot/efi.inc"

/* linker symbols to export */
.globl GetBlt

/* text section */
.text

/* GetBlt function */
GetBlt:

    /* --------------------------------------------- */
    /* (I) search for Graphics Output Protocol (GOP) */
    /* --------------------------------------------- */

    /* initialize arguments for LocateProtocol() */
    mov    $3, %eax
    lea    PTR(GopGuid), %rcx
    xor    %rdx, %rdx
    lea    PTR(Gop), %r8

    /* obtain SystemTable->BootServices->LocateProtocol */
    mov    PTR(SystemTable), %rbx
    mov    BootServices(%rbx), %rbx
    mov    LocateProtocol(%rbx), %rbx

    /* perform the call */
    call   EfiCall

    /* -------------------------------------- */
    /* (II) get BLT information from GOP mode */
    /* -------------------------------------- */

    /* get EFI_GRAPHICS_OUTPUT_PROTOCOL_MODE structure */
    mov    PTR(Gop), %rsi
    mov    Mode(%rsi), %rsi

    /* get physical framebuffer info */
    mov    FrameBufferBase(%rsi), %rax
    mov    %rax, PTR(FrameBufPhys)
    mov    FrameBufferSize(%rsi), %rax
    mov    %rax, PTR(FrameBufSize)

    /* get screen resolution */
    mov    Info(%rsi), %rsi
    xor    %rax, %rax
    mov    HorizontalResolution(%rsi), %eax
    mov    %rax, PTR(FrameBufWidth)
    mov    VerticalResolution(%rsi), %eax
    mov    %rax, PTR(FrameBufHeight)
    mov    PixelsPerScanLine(%rsi), %eax
    mov    %rax, PTR(FrameBufScanLn)

    /* ---------------------------------------------------- */
    /* (III) allocate a virtual buffer for double buffering */
    /* ---------------------------------------------------- */

    /* initialize arguments */
    mov    $3, %rax                  /* 3 arguments */
    mov    $EfiLoaderData, %rcx      /* pool type */
    mov    PTR(FrameBufSize), %rdx   /* pool size */
    lea    PTR(FrameBufVirt), %r8    /* return address in FrameBufVirt */

    /* obrain SystemTable->BootServices->AllocatePool */
    mov    PTR(SystemTable), %rbx
    mov    BootServices(%rbx), %rbx
    mov    AllocatePool(%rbx), %rbx

    /* perform the call, returns pointer in MemoryMap */
    call   EfiCall

    /* -------------------- */
    /* (V) return to caller */
    /* -------------------- */

    /* done */
    ret
