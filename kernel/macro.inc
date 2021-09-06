###############################################################################
# File name:    macro.S
# Description:  Kernel macros used by different modules
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

    #########################################
    # COMMON DEFINITIONS USED ACROSS KERNEL #
    #########################################

    # --------------------------------------
    # LOWER 1MB OF MEMORY
    # --------------------------------------

    # 16-bit to 64-bit transitional code
    .equ     TrampolineCodeBase,  0x00000000
    .equ     TrampolineCodeSize,  0x00001000

    # 16-bit to 64-bit transitional stack
    .equ     TrampolineStackBase, 0x00001000
    .equ     TrampolineStackSize, 0x00001000

    # GDTR Descriptor
    .equ     GdtrDescBase,        0x00002000
    .equ     GdtrDescSize,        0x00001000

    # GDT Table
    .equ     GdtTableBase,        0x00003000
    .equ     GdtTableSize,        0x00001000

    # IDTR Descriptor
    .equ     IdtrDescBase,        0x00004000
    .equ     IdtrDescSize,        0x00001000

    # IDT Table
    .equ     IdtTableBase,        0x00005000
    .equ     IdtTableSize,        0x00001000

    # TSS Segments (32 segments for 32 CPUs)
    .equ     TssSegmentsBase,     0x00006000
    .equ     TssSegmentsSize,     0x00001000 # 0x80*32

    # Kernel Stacks (32 stacks for 32 CPUs)
    .equ     KernelStacksBase,    0x00010000
    .equ     KernelStacksSize,    0x00020000 # 0x1000*32

    # --------------------------------------
    # MSR REGISTERS
    # --------------------------------------

    .equ     ApicBaseAddrMsr,     0x0000001B
    .equ     EferMsr,             0xC0000080
