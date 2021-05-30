
    # common definitions used by kernel
    .include "kernel/macro.inc"

    # text section
    .text

###############################################################################
#                            KernelSystemInit()                               #
###############################################################################

    .global  KernelSystemInit
    .set     KernelSystemInit, .

    # do nothing
    ret

###############################################################################
#                            KernelSystemStart()                              #
###############################################################################

    .global  KernelSystemStart
    .set     KernelSystemStart, .

    # halt until we implement this system call
    jmp      .

###############################################################################
#                            KernelSystemStop()                               #
###############################################################################

    .global  KernelSystemStop
    .set     KernelSystemStop, .

    # halt until we implement this system call
    jmp      .
