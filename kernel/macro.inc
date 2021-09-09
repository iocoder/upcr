;###############################################################################
;# File name:    macro.S
;# Description:  Kernel macros used by different modules
;# Author:       Ramses A.
;###############################################################################
;#
;# UPCR Operating System for x86_64 architecture
;# Copyright (c) 2021 Ramses A.
;#
;# Permission is hereby granted, free of charge, to any person obtaining a copy
;# of this software and associated documentation files (the "Software"), to deal
;# in the Software without restriction, including without limitation the rights
;# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
;# copies of the Software, and to permit persons to whom the Software is
;# furnished to do so, subject to the following conditions:
;#
;# The above copyright notice and this permission notice shall be included in all
;# copies or substantial portions of the Software.
;#
;###############################################################################
;#
;# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
;# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
;# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
;# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
;# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
;# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
;# SOFTWARE.
;#
;###############################################################################

;###############################################################################
;#                  COMMON DEFINITIONS USED ACROSS KERNEL                      #
;###############################################################################

# --------------------------------------
# LOWER 1MB OF MEMORY
# --------------------------------------

            .EQU    TRUMP_ADDR,      0x00000000     ;# real-mode trampoline
            .EQU    GDTR_ADDR,       0x00001000     ;# GDTR Descriptor
            .EQU    IDTR_ADDR,       0x00001800     ;# IDTR Descriptor
            .EQU    GDT_ADDR,        0x00002000     ;# GDT Table
            .EQU    IDT_ADDR,        0x00003000     ;# IDT Table
            .EQU    TSS_ADDR,        0x00004000     ;# TSS Segments (32 segments for 32 CPUs)
            .EQU    STACK_ADDR,      0x00010000     ;# Kernel Stacks (32 stacks for 32 CPUs)    
            .EQU    PM4L_ADDR,       0x00040000     ;# Kernel root page table

# --------------------------------------
# MSR REGISTERS
# --------------------------------------

            .EQU    MSR_APIC_BASE,   0x0000001B
            .EQU    MSR_EFER,        0xC0000080

# --------------------------------------
# LAPIC REGISTERS
# --------------------------------------

            ;# (I) LAPIC ID AND VERSION
            .EQU    LAPIC_ID,        0xFEE00020
            .EQU    LAPIC_VERSION,   0xFEE00030

            ;# (II) LAPIC BUS PRIORITY REGISTERS
            .EQU    LAPIC_TASKPRI,   0xFEE00080
            .EQU    LAPIC_ARBIPRI,   0xFEE00090
            .EQU    LAPIC_PROCPRI,   0xFEE000A0

            ;# (III) LAPIC OPERATION REGISTERS
            .EQU    LAPIC_EOI,       0xFEE000B0
            .EQU    LAPIC_REMOTERD,  0xFEE000C0
            .EQU    LAPIC_LOGDEST,   0xFEE000D0
            .EQU    LAPIC_DESTFMT,   0xFEE000E0
            .EQU    LAPIC_SPUIVT,    0xFEE000F0
            .EQU    LAPIC_INSERV,    0xFEE00100
            .EQU    LAPIC_TRIGMODE,  0xFEE00180
            .EQU    LAPIC_INTREQ,    0xFEE00200
            .EQU    LAPIC_ERRSTAT,   0xFEE00280
            .EQU    LAPIC_INTCMDL,   0xFEE00300
            .EQU    LAPIC_INTCMDH,   0xFEE00310

            ;# (IV) IVT REGISTERS
            .EQU    LAPIC_TIMERIVT,  0xFEE00320
            .EQU    LAPIC_THERMIVT,  0xFEE00330
            .EQU    LAPIC_PERFCIVT,  0xFEE00340
            .EQU    LAPIC_LINT0IVT,  0xFEE00350
            .EQU    LAPIC_LINT1IVT,  0xFEE00360
            .EQU    LAPIC_ERRORIVT,  0xFEE00370

            ;# (V) TIMER REGISTERS
            .EQU    LAPIC_TMRINIT,   0xFEE00380
            .EQU    LAPIC_TMRCURR,   0xFEE00390
            .EQU    LAPIC_TMRCONF,   0xFEE003E0

# --------------------------------------
# STACK FRAME LAYOT
# --------------------------------------

            .EQU    SFRAME_PAD0,     0x00
            .EQU    SFRAME_PAD1,     0x08
            .EQU    SFRAME_PAD2,     0x10
            .EQU    SFRAME_PAD3,     0x18
            .EQU    SFRAME_PAD4,     0x20
            .EQU    SFRAME_PAD5,     0x28
            .EQU    SFRAME_PAD6,     0x30
            .EQU    SFRAME_PAD7,     0x38
            .EQU    SFRAME_PAD8,     0x40
            .EQU    SFRAME_PAD9,     0x48
            .EQU    SFRAME_RAX,      0x50
            .EQU    SFRAME_RBX,      0x58
            .EQU    SFRAME_RCX,      0x60
            .EQU    SFRAME_RDX,      0x68
            .EQU    SFRAME_RSI,      0x70
            .EQU    SFRAME_RDI,      0x78
            .EQU    SFRAME_RBP,      0x80
            .EQU    SFRAME_R8,       0x88
            .EQU    SFRAME_R9,       0x90
            .EQU    SFRAME_R10,      0x98
            .EQU    SFRAME_R11,      0xA0
            .EQU    SFRAME_R12,      0xA8
            .EQU    SFRAME_R13,      0xB0
            .EQU    SFRAME_R14,      0xB8
            .EQU    SFRAME_R15,      0xC0
            .EQU    SFRAME_NBR,      0xC8
            .EQU    SFRAME_ERR,      0xD0
            .EQU    SFRAME_RIP,      0xD8
            .EQU    SFRAME_CS,       0xE0
            .EQU    SFRAME_RFLAGS,   0xE8
            .EQU    SFRAME_RSP,      0xF0
            .EQU    SFRAME_SS,       0xF8

