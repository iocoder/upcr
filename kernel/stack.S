
    # common definitions used by kernel
    .include "kernel/macro.inc"

    # text section
    .text

###############################################################################
#                             KernelStackInit()                               #
###############################################################################

    # declare a linker symbol
    .global  KernelStackInit
    .set     KernelStackInit, .

    # print heading of line
    mov      $0x0A, %rdi
    mov      $-1, %rsi
    call     KernelLogColour
    leaq     StackModuleStr(%rip), %rdi
    call     KernelLogString
    mov      $0x0B, %rdi
    mov      $-1, %rsi
    call     KernelLogColour

    # print module info
    leaq     StackStartStr(%rip), %rdi
    call     KernelLogString
    mov      $'\n', %rdi
    call     KernelLogChar

    # done
1:  xor      %rax, %rax
    ret

##############################################################################

    # data section
    .data

    # Stack heading
    .set     StackModuleStr, .
    .string  " [KERNEL STACK] "

    # Stack start ascii string
    .set     StackStartStr, .
    .string  "Initializing kernel stacks..."
