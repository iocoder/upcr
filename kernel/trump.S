
    # common definitions used by kernel
    .include "kernel/macro.inc"

    # text section
    .text

###############################################################################
#                             KernelTrumpInit()                               #
###############################################################################

    # declare a linker symbol
    .global  KernelTrumpInit
    .set     KernelTrumpInit, .

    # print heading of line
    mov      $0x0A, %rdi
    mov      $-1, %rsi
    call     KernelLogColour
    leaq     TrumpModuleStr(%rip), %rdi
    call     KernelLogString
    mov      $0x0B, %rdi
    mov      $-1, %rsi
    call     KernelLogColour

    # print module info
    leaq     TrumpStartStr(%rip), %rdi
    call     KernelLogString
    mov      $'\n', %rdi
    call     KernelLogChar

    # done
1:  xor      %rax, %rax
    ret

##############################################################################

    # data section
    .data

    # Trump heading
    .set     TrumpModuleStr, .
    .string  " [KERNEL TRAMPOLINE] "

    # Trump start ascii string
    .set     TrumpStartStr, .
    .string  "Initializing trampoline module..."
