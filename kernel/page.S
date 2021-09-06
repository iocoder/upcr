
    # common definitions used by kernel
    .include "kernel/macro.inc"

    # text section
    .text

###############################################################################
#                             KernelPageInit()                                #
###############################################################################

    # declare a linker symbol
    .global  KernelPageInit
    .set     KernelPageInit, .

    # print heading of line
    mov      $0x0A, %rdi
    mov      $-1, %rsi
    call     KernelLogColour
    leaq     PageModuleStr(%rip), %rdi
    call     KernelLogString
    mov      $0x0B, %rdi
    mov      $-1, %rsi
    call     KernelLogColour

    # print module info
    leaq     PageStartStr(%rip), %rdi
    call     KernelLogString
    mov      $'\n', %rdi
    call     KernelLogChar

    # done
1:  xor      %rax, %rax
    ret

##############################################################################

    # data section
    .data

    # Paging heading
    .set     PageModuleStr, .
    .string  " [KERNEL PAGING] "

    # Paging start ascii string
    .set     PageStartStr, .
    .string  "Initializing paging module..."
