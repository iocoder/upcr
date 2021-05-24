
# C includes
#include "kernel/asm.h"

# symbols to export to linker
.globl KernelDataInit

# text section
.text

##############################################################################
#                           KernelDataInit()                                 #
##############################################################################

KernelDataInit:

    # load frame buffer info from RDX
    mov    0x00(%rdx), %rax
    mov    %rax, PTR(FrameBufVirt)
    mov    0x08(%rdx), %rax
    mov    %rax, PTR(FrameBufPhys)
    mov    0x10(%rdx), %rax
    mov    %rax, PTR(FrameBufSize)
    mov    0x18(%rdx), %rax
    mov    %rax, PTR(FrameBufWidth)
    mov    0x20(%rdx), %rax
    mov    %rax, PTR(FrameBufHeight)
    mov    0x28(%rdx), %rax
    mov    %rax, PTR(FrameBufScanLn)

    # done
    ret
