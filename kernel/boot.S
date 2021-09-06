
    # common definitions used by kernel
    .include "kernel/macro.inc"

    # text section
    .text

###############################################################################
#                             KernelBootInit()                                #
###############################################################################

    # declare a linker symbol
    .global  KernelBootInit
    .set     KernelBootInit, .

    # initialize vga module
    push     %rdi
    call     KernelVgaInit
    pop      %rdi

    # initialize log module
    push     %rdi
    call     KernelLogInit
    pop      %rdi

    # initialize ram module
    push     %rdi
    call     KernelRamInit
    pop      %rdi

    # initialize page module
    push     %rdi
    call     KernelPageInit
    pop      %rdi

    # initialize gop module
    push     %rdi
    call     KernelTrumpInit
    pop      %rdi

    # initialize gdt module
    push     %rdi
    call     KernelGdtInit
    pop      %rdi

    # initialize idt module
    push     %rdi
    call     KernelIdtInit
    pop      %rdi

    # initialize tss module
    push     %rdi
    call     KernelTssInit
    pop      %rdi

    # initialize stack module
    push     %rdi
    call     KernelStackInit
    pop      %rdi

    # initialize irq module
    push     %rdi
    call     KernelIrqInit
    pop      %rdi

    # initialize cpu module
    push     %rdi
    call     KernelCpuInit
    pop      %rdi

    # initialize system module
    push     %rdi
    call     KernelSystemInit
    pop      %rdi

    # no error
    xor      %rax, %rax

    # done
    ret
