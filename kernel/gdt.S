
    # common definitions used by kernel
    .include "kernel/macro.inc"

    # text section
    .text

###############################################################################
#                              KernelGdtInit()                                #
###############################################################################

    # declare a linker symbol
    .global  KernelGdtInit
    .set     KernelGdtInit, .

    # print heading of line
    mov      $0x0A, %rdi
    mov      $-1, %rsi
    call     KernelLogColour
    leaq     GdtModuleStr(%rip), %rdi
    call     KernelLogString
    mov      $0x0B, %rdi
    mov      $-1, %rsi
    call     KernelLogColour

    # print module info
    leaq     GdtStartStr(%rip), %rdi
    call     KernelLogString
    mov      $'\n', %rdi
    call     KernelLogChar

    # done
1:  xor      %rax, %rax
    ret

##############################################################################

    # data section
    .data

    # GDT heading
    .set     GdtModuleStr, .
    .string  " [KERNEL GDT] "

    # GDT start ascii string
    .set     GdtStartStr, .
    .string  "Initializing GDT module..."
