
    # common definitions used by kernel
    .include "kernel/macro.inc"

    # text section
    .text

###############################################################################
#                            KernelPagingInit()                               #
###############################################################################

    # declare a linker symbol
    .global  KernelPagingInit
    .set     KernelPagingInit, .

    # print heading of line
    mov      $0x0A, %rdi
    mov      $-1, %rsi
    call     KernelLogColour
    leaq     PagingModuleStr(%rip), %rdi
    call     KernelLogString
    mov      $0x0B, %rdi
    mov      $-1, %rsi
    call     KernelLogColour

    # print paging module info
    leaq     PagingStartStr(%rip), %rdi
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
    .set     PagingModuleStr, .
    .string  " [KERNEL PAGING] "

    # Paging start ascii string
    .set     PagingStartStr, .
    .string  "Initializing paging module..."
