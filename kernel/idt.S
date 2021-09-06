
    # common definitions used by kernel
    .include "kernel/macro.inc"

    # text section
    .text

###############################################################################
#                              KernelIdtInit()                                #
###############################################################################

    # declare a linker symbol
    .global  KernelIdtInit
    .set     KernelIdtInit, .

    # print heading of line
    mov      $0x0A, %rdi
    mov      $-1, %rsi
    call     KernelLogColour
    leaq     IdtModuleStr(%rip), %rdi
    call     KernelLogString
    mov      $0x0B, %rdi
    mov      $-1, %rsi
    call     KernelLogColour

    # print module info
    leaq     IdtStartStr(%rip), %rdi
    call     KernelLogString
    mov      $'\n', %rdi
    call     KernelLogChar

    # done
1:  xor      %rax, %rax
    ret

##############################################################################

    # data section
    .data

    # IDT heading
    .set     IdtModuleStr, .
    .string  " [KERNEL IDT] "

    # IDT start ascii string
    .set     IdtStartStr, .
    .string  "Initializing IDT module..."
