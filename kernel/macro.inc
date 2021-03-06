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

            .intel_syntax  noprefix

# --------------------------------------
# LOWER 1MB OF MEMORY
# --------------------------------------

            .EQU     MEM_TRUMP,       0x00000000     ;# SMP trampoline
            .EQU     MEM_GDTR,        0x00001000     ;# GDTR Descriptor
            .EQU     MEM_IDTR,        0x00001800     ;# IDTR Descriptor
            .EQU     MEM_GDT_TABLE,   0x00002000     ;# GDT Table
            .EQU     MEM_IDT_TABLE,   0x00003000     ;# IDT Table
            .EQU     MEM_TSS_TABLE,   0x00004000     ;# TSS Segments (32 segments for 32 CPUs)
            .EQU     MEM_IDN_PTABLE,  0x00005000     ;# L3 PAGE TABLE
            .EQU     MEM_CPU_PTABLES, 0x00010000     ;# Kernel root page table
            .EQU     MEM_CPU_STACKS,  0x00030000     ;# Kernel Stacks (32 stacks for 32 CPUs)    
            .EQU     MEM_LAST_ADDR,   0x00050000     ;# LAST ADDRESS IN LOWER 640KB

# --------------------------------------
# ACPI TABLE NAMES
# --------------------------------------

            .EQU     ACPI_TBL_MADT,   0x43495041
            .EQU     ACPI_TBL_BERT,   0x54524542
            .EQU     ACPI_TBL_BGRT,   0x54524742
            .EQU     ACPI_TBL_CPEP,   0x50455043
            .EQU     ACPI_TBL_DSDT,   0x54445344
            .EQU     ACPI_TBL_ECDT,   0x54444345
            .EQU     ACPI_TBL_EINJ,   0x4a4e4945
            .EQU     ACPI_TBL_ERST,   0x54535245
            .EQU     ACPI_TBL_FADT,   0x50434146
            .EQU     ACPI_TBL_FACS,   0x53434146
            .EQU     ACPI_TBL_FPDT,   0x54445046
            .EQU     ACPI_TBL_GTDT,   0x54445447
            .EQU     ACPI_TBL_HEST,   0x54534548
            .EQU     ACPI_TBL_HPET,   0x54455048
            .EQU     ACPI_TBL_MSCT,   0x5443534d
            .EQU     ACPI_TBL_MPST,   0x5453504d
            .EQU     ACPI_TBL_NFIT,   0x5449464e
            .EQU     ACPI_TBL_OEMX,   0x004d454f
            .EQU     ACPI_TBL_PCCT,   0x54434350
            .EQU     ACPI_TBL_PHAT,   0x54414850
            .EQU     ACPI_TBL_PMTT,   0x54544d50
            .EQU     ACPI_TBL_PSDT,   0x54445350
            .EQU     ACPI_TBL_RASF,   0x46534152
            .EQU     ACPI_TBL_RSDP,   0x50445352
            .EQU     ACPI_TBL_RSDT,   0x54445352
            .EQU     ACPI_TBL_SBST,   0x54534253
            .EQU     ACPI_TBL_SDEV,   0x56454453
            .EQU     ACPI_TBL_SLIT,   0x54494c53
            .EQU     ACPI_TBL_SRAT,   0x54415253
            .EQU     ACPI_TBL_SSDT,   0x54445353
            .EQU     ACPI_TBL_XSDT,   0x54445358

# --------------------------------------
# MSR REGISTERS
# --------------------------------------

            .EQU     MSR_TSC,         0x00000010
            .EQU     MSR_APIC_BASE,   0x0000001B
            .EQU     MSR_MTRR_CAP,    0x000000FE
            .EQU     MSR_MISC_ENABLE, 0x000001A0
            .EQU     MSR_MTRR_BASE,   0x00000200
            .EQU     MSR_TSC_DEADLN,  0x000006E0
            .EQU     MSR_EFER,        0xC0000080

# --------------------------------------
# LAPIC REGISTERS
# --------------------------------------

            ;# (I) LAPIC ID AND VERSION
            .EQU     LAPIC_ID,        0xFEE00020
            .EQU     LAPIC_VERSION,   0xFEE00030

            ;# (II) LAPIC BUS PRIORITY REGISTERS
            .EQU     LAPIC_TASKPRI,   0xFEE00080
            .EQU     LAPIC_ARBIPRI,   0xFEE00090
            .EQU     LAPIC_PROCPRI,   0xFEE000A0

            ;# (III) LAPIC OPERATION REGISTERS
            .EQU     LAPIC_EOI,       0xFEE000B0
            .EQU     LAPIC_REMOTERD,  0xFEE000C0
            .EQU     LAPIC_LOGDEST,   0xFEE000D0
            .EQU     LAPIC_DESTFMT,   0xFEE000E0
            .EQU     LAPIC_SPUIVT,    0xFEE000F0
            .EQU     LAPIC_INSERV,    0xFEE00100
            .EQU     LAPIC_TRIGMODE,  0xFEE00180
            .EQU     LAPIC_INTREQ,    0xFEE00200
            .EQU     LAPIC_ERRSTAT,   0xFEE00280
            .EQU     LAPIC_INTCMDL,   0xFEE00300
            .EQU     LAPIC_INTCMDH,   0xFEE00310

            ;# (IV) IVT REGISTERS
            .EQU     LAPIC_TIMERIVT,  0xFEE00320
            .EQU     LAPIC_THERMIVT,  0xFEE00330
            .EQU     LAPIC_PERFCIVT,  0xFEE00340
            .EQU     LAPIC_LINT0IVT,  0xFEE00350
            .EQU     LAPIC_LINT1IVT,  0xFEE00360
            .EQU     LAPIC_ERRORIVT,  0xFEE00370

            ;# (V) TIMER REGISTERS
            .EQU     LAPIC_TMRINIT,   0xFEE00380
            .EQU     LAPIC_TMRCURR,   0xFEE00390
            .EQU     LAPIC_TMRDIVD,   0xFEE003E0

# --------------------------------------
# INTERRUPT VECTORS
# --------------------------------------

            ;# EXCEPTION VECTORS
            .EQU     IVT_EXP_DIV,       0x00
            .EQU     IVT_EXP_DEBUG,     0x01
            .EQU     IVT_EXP_NMI,       0x02
            .EQU     IVT_EXP_INT3,      0x03
            .EQU     IVT_EXP_INTO,      0x04
            .EQU     IVT_EXP_BOUND,     0x05
            .EQU     IVT_EXP_OPCODE,    0x06
            .EQU     IVT_EXP_DEV,       0x07
            .EQU     IVT_EXP_DOUBLE,    0x08
            .EQU     IVT_EXP_UNSUP,     0x09
            .EQU     IVT_EXP_TSS,       0x0A
            .EQU     IVT_EXP_SEG,       0x0B
            .EQU     IVT_EXP_STACK,     0x0C
            .EQU     IVT_EXP_GPE,       0x0D
            .EQU     IVT_EXP_PAGE,      0x0E
            .EQU     IVT_EXP_RES15,     0x0F
            .EQU     IVT_EXP_X87,       0x10
            .EQU     IVT_EXP_ALIGN,     0x11
            .EQU     IVT_EXP_MACHINE,   0x12
            .EQU     IVT_EXP_SIMD,      0x13
            .EQU     IVT_EXP_RES20,     0x14
            .EQU     IVT_EXP_CTRL,      0x15
            .EQU     IVT_EXP_RES22,     0x16
            .EQU     IVT_EXP_RES23,     0x17
            .EQU     IVT_EXP_RES24,     0x18
            .EQU     IVT_EXP_RES25,     0x19
            .EQU     IVT_EXP_RES26,     0x1A
            .EQU     IVT_EXP_RES27,     0x1B
            .EQU     IVT_EXP_HVC,       0x1C
            .EQU     IVT_EXP_VMM,       0x1D
            .EQU     IVT_EXP_SECUR,     0x1E
            .EQU     IVT_EXP_RES31,     0x1F

            ;# SVC VECTORS
            .EQU     IVT_SVC_SYSCALL,   0x20

            ;# SMP VECTORS
            .EQU     IVT_SMP_EN,        0x21

            ;# IRQ VECTORS
            .EQU     IVT_IRQ_TIMER,     0x22
            .EQU     IVT_IRQ_THERM,     0x23
            .EQU     IVT_IRQ_PERFC,     0x24
            .EQU     IVT_IRQ_LINT0,     0x25
            .EQU     IVT_IRQ_LINT1,     0x26
            .EQU     IVT_IRQ_ERROR,     0x27
            .EQU     IVT_IRQ_SPURI,     0x28
            .EQU     IVT_IRQ_SCHED,     0x29
            .EQU     IVT_IRQ_RES42,     0x2A
            .EQU     IVT_IRQ_RES43,     0x2B
            .EQU     IVT_IRQ_RES44,     0x2C
            .EQU     IVT_IRQ_RES45,     0x2D
            .EQU     IVT_IRQ_RES46,     0x2E
            .EQU     IVT_IRQ_RES47,     0x2F
            .EQU     IVT_IRQ_IOAPIC0,   0x30
            .EQU     IVT_IRQ_IOAPIC1,   0x31
            .EQU     IVT_IRQ_IOAPIC2,   0x32
            .EQU     IVT_IRQ_IOAPIC3,   0x33
            .EQU     IVT_IRQ_IOAPIC4,   0x34
            .EQU     IVT_IRQ_IOAPIC5,   0x35
            .EQU     IVT_IRQ_IOAPIC6,   0x36
            .EQU     IVT_IRQ_IOAPIC7,   0x37
            .EQU     IVT_IRQ_IOAPIC8,   0x38
            .EQU     IVT_IRQ_IOAPIC9,   0x39
            .EQU     IVT_IRQ_IOAPIC10,  0x3A
            .EQU     IVT_IRQ_IOAPIC11,  0x3B
            .EQU     IVT_IRQ_IOAPIC12,  0x3C
            .EQU     IVT_IRQ_IOAPIC13,  0x3D
            .EQU     IVT_IRQ_IOAPIC14,  0x3E
            .EQU     IVT_IRQ_IOAPIC15,  0x3F

            ;# IDT SECTIONS
            .EQU     IVT_EXP_START,     0x00
            .EQU     IVT_EXP_COUNT,     0x20
            .EQU     IVT_SVC_START,     0x20
            .EQU     IVT_SVC_COUNT,     0x01
            .EQU     IVT_SMP_START,     0x21
            .EQU     IVT_SMP_COUNT,     0x01
            .EQU     IVT_IRQ_START,     0x22
            .EQU     IVT_IRQ_COUNT,     0x1E

# --------------------------------------
# PIT FREQUENCY
# --------------------------------------

            .EQU     PIT_FREQ,          1193182
            .EQU     PIT_CTR_1MS,       1193
            .EQU     PIT_CTR_10MS,      11932

# --------------------------------------
# STACK FRAME LAYOT
# --------------------------------------

            .EQU     SFRAME_PAD0,       0x00
            .EQU     SFRAME_PAD1,       0x08
            .EQU     SFRAME_PAD2,       0x10
            .EQU     SFRAME_PAD3,       0x18
            .EQU     SFRAME_PAD4,       0x20
            .EQU     SFRAME_PAD5,       0x28
            .EQU     SFRAME_PAD6,       0x30
            .EQU     SFRAME_PAD7,       0x38
            .EQU     SFRAME_PAD8,       0x40
            .EQU     SFRAME_PAD9,       0x48
            .EQU     SFRAME_RAX,        0x50
            .EQU     SFRAME_RBX,        0x58
            .EQU     SFRAME_RCX,        0x60
            .EQU     SFRAME_RDX,        0x68
            .EQU     SFRAME_RSI,        0x70
            .EQU     SFRAME_RDI,        0x78
            .EQU     SFRAME_RBP,        0x80
            .EQU     SFRAME_R8,         0x88
            .EQU     SFRAME_R9,         0x90
            .EQU     SFRAME_R10,        0x98
            .EQU     SFRAME_R11,        0xA0
            .EQU     SFRAME_R12,        0xA8
            .EQU     SFRAME_R13,        0xB0
            .EQU     SFRAME_R14,        0xB8
            .EQU     SFRAME_R15,        0xC0
            .EQU     SFRAME_NBR,        0xC8
            .EQU     SFRAME_ERR,        0xD0
            .EQU     SFRAME_RIP,        0xD8
            .EQU     SFRAME_CS,         0xE0
            .EQU     SFRAME_RFLAGS,     0xE8
            .EQU     SFRAME_RSP,        0xF0
            .EQU     SFRAME_SS,         0xF8

# --------------------------------------
# CONSOLE
# --------------------------------------

            .EQU     CONSOLE_WIDTH,      100
            .EQU     CONSOLE_MAXLINES,   4096
            .EQU     CONSOLE_PAGESIZE,   (CONSOLE_WIDTH*CONSOLE_MAXLINES)

            .EQU     CONSOLE_HEADROWS,   5
            .EQU     CONSOLE_WINDROWS,   31
            .EQU     CONSOLE_STATROWS,   1
            .EQU     CONSOLE_TOTROWS,    (CONSOLE_HEADROWS+CONSOLE_WINDROWS+CONSOLE_STATROWS)

            .EQU     CONSOLE_HEADATTR,   0x0B000000
            .EQU     CONSOLE_STATATTR,   0x010B0000
