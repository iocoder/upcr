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

    # initialize system module
    push     %rdi
    call     KernelSystemInit
    pop      %rdi

    # no error
    xor      %rax, %rax

    # done
    ret
