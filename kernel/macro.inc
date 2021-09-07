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

    # GDTR Descriptor
    .equ     GdtrDescBase,        0x00001000
    .equ     GdtrDescSize,        0x00000800

    # IDTR Descriptor
    .equ     IdtrDescBase,        0x00001800
    .equ     IdtrDescSize,        0x00000800

    # GDT Table
    .equ     GdtTableBase,        0x00002000
    .equ     GdtTableSize,        0x00001000

    # IDT Table
    .equ     IdtTableBase,        0x00003000
    .equ     IdtTableSize,        0x00001000

    # TSS Segments (32 segments for 32 CPUs)
    .equ     TssSegmentsBase,     0x00004000
    .equ     TssSegmentsSize,     0x00001000 # 0x80*32

    # Kernel Stacks (32 stacks for 32 CPUs)
    .equ     KernelStacksBase,    0x00010000
    .equ     KernelStacksSize,    0x00020000 # 0x1000*32

    # Kernel root page table
    .equ     RootPageTableBase,   0x00040000
    .equ     RootPageTableSize,   0x00001000

    # --------------------------------------
    # MSR REGISTERS
    # --------------------------------------

    .equ     ApicBaseAddrMsr,     0x0000001B
    .equ     EferMsr,             0xC0000080

    # --------------------------------------
    # STACK FRAME LAYOT
    # --------------------------------------

    .equ     StackFramePad0,      0x00
    .equ     StackFramePad1,      0x08
    .equ     StackFramePad2,      0x10
    .equ     StackFramePad3,      0x18
    .equ     StackFramePad4,      0x20
    .equ     StackFramePad5,      0x28
    .equ     StackFramePad6,      0x30
    .equ     StackFramePad7,      0x38
    .equ     StackFramePad8,      0x40
    .equ     StackFramePad9,      0x48
    .equ     StackFrameRAX,       0x50
    .equ     StackFrameRBX,       0x58
    .equ     StackFrameRCX,       0x60
    .equ     StackFrameRDX,       0x68
    .equ     StackFrameRSI,       0x70
    .equ     StackFrameRDI,       0x78
    .equ     StackFrameRBP,       0x80
    .equ     StackFrameR8,        0x88
    .equ     StackFrameR9,        0x90
    .equ     StackFrameR10,       0x98
    .equ     StackFrameR11,       0xA0
    .equ     StackFrameR12,       0xA8
    .equ     StackFrameR13,       0xB0
    .equ     StackFrameR14,       0xB8
    .equ     StackFrameR15,       0xC0
    .equ     StackFrameNbr,       0xC8
    .equ     StackFrameErr,       0xD0
    .equ     StackFrameRIP,       0xD8
    .equ     StackFrameCS,        0xE0
    .equ     StackFrameRFLAGS,    0xE8
    .equ     StackFrameRSP,       0xF0
    .equ     StackFrameSS,        0xF8
