###############################################################################
# File name:    boot.S
# Description:  Kernel boot procedures
# Author:       Ramses A.
###############################################################################
#
# UPCR Operating System for x86_64 architecture
# Copyright (c) 2021 Ramses A.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
###############################################################################
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
###############################################################################

###############################################################################
#                                INCLUDES                                     #
###############################################################################

    # common definitions used by kernel
    .include "kernel/macro.inc"

###############################################################################
#                              TEXT SECTION                                   #
###############################################################################

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
