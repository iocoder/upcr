
    # common definitions used by kernel
    .include "kernel/macro.inc"

    # text section
    .text

###############################################################################
#                              KernelTssInit()                                #
###############################################################################

    # declare a linker symbol
    .global  KernelTssInit
    .set     KernelTssInit, .

    # print heading of line
    mov      $0x0A, %rdi
    mov      $-1, %rsi
    call     KernelLogColour
    leaq     TssModuleStr(%rip), %rdi
    call     KernelLogString
    mov      $0x0B, %rdi
    mov      $-1, %rsi
    call     KernelLogColour

    # print module info
    leaq     TssStartStr(%rip), %rdi
    call     KernelLogString
    mov      $'\n', %rdi
    call     KernelLogChar

    # done
1:  xor      %rax, %rax
    ret

##############################################################################

    # data section
    .data

    # TSS heading
    .set     TssModuleStr, .
    .string  " [KERNEL TSS] "

    # TSS start ascii string
    .set     TssStartStr, .
    .string  "Initializing TSS module..."
