###############################################################################
# File name:    irq.S
# Description:  Kernel I/O APIC and LAPIC driver
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
#                                 MACROS                                     #
###############################################################################

    # LAPIC REGISTERS
    # ---------------
    # (I) LAPIC ID and VERSION
    .equ     LapicIdReg,          0xFEE00020
    .equ     LapicVersionReg,     0xFEE00030
    # (II) LAPIC BUS PRIORITY REGISTERS
    .equ     LapicTaskPriReg,     0xFEE00080
    .equ     LapicArbiPriReg,     0xFEE00090
    .equ     LapicProcPriReg,     0xFEE000A0
    # (III) LAPIC OPERATION REGISTERS
    .equ     LapicEndOfIntReg,    0xFEE000B0
    .equ     LapicRemoteRdReg,    0xFEE000C0
    .equ     LapicLogicalDestReg, 0xFEE000D0
    .equ     LapicDestFormatReg,  0xFEE000E0
    .equ     LapicSpuriousIvtReg, 0xFEE000F0
    .equ     LapicInServiceReg,   0xFEE00100
    .equ     LapicTriggModeReg,   0xFEE00180
    .equ     LapicIntReqReg,      0xFEE00200
    .equ     LapicErrStatusReg,   0xFEE00280
    .equ     LapicIntCmdLoReg,    0xFEE00300
    .equ     LapicIntCmdHiReg,    0xFEE00310
    # (IV) IVT REGISTERS
    .equ     LapicTimerIvtReg,    0xFEE00320
    .equ     LapicThermIvtReg,    0xFEE00330
    .equ     LapicPerfcIvtReg,    0xFEE00340
    .equ     LapicLint0IvtReg,    0xFEE00350
    .equ     LapicLint1IvtReg,    0xFEE00360
    .equ     LapicErrorIvtReg,    0xFEE00370
    # (V) TIMER REGISTERS
    .equ     LapicTimerInitReg,   0xFEE00380
    .equ     LapicTimerCurrReg,   0xFEE00390
    .equ     LapicTimerConfReg,   0xFEE003E0

###############################################################################
#                              TEXT SECTION                                   #
###############################################################################

    # text section
    .text

###############################################################################
#                            KernelIrqInit()                                  #
###############################################################################

    # declare a linker symbol
    .global  KernelIrqInit
    .set     KernelIrqInit, .

    # print heading of line
    mov      $0x0A, %rdi
    mov      $-1, %rsi
    call     KernelLogColour
    leaq     IrqModuleStr(%rip), %rdi
    call     KernelLogString
    mov      $0x0B, %rdi
    mov      $-1, %rsi
    call     KernelLogColour

    # print irq module info
    leaq     IrqStartStr(%rip), %rdi
    call     KernelLogString
    mov      $'\n', %rdi
    call     KernelLogChar

    # done
1:  xor      %rax, %rax
    ret

###############################################################################
#                           KernelIrqEnable()                                 #
###############################################################################

    # declare a linker symbol
    .global  KernelIrqEnable
    .set     KernelIrqEnable, .

    # Initialize APIC address MSR
    xor      %rax, %rax
    xor      %rcx, %rcx
    xor      %rdx, %rdx
    mov      $0xFEE00800, %eax
    mov      $ApicBaseAddrMsr, %ecx
    wrmsr
    nop
    nop

    # done
1:  xor      %rax, %rax
    ret

###############################################################################
#                             KernelIrqIipi()                                 #
###############################################################################

    # declare a linker symbol
    .global  KernelIrqIipi
    .set     KernelIrqIipi, .

    # broadcast the INIT IPI to all processors except self
    mov      $LapicIntCmdLoReg, %rsi
    mov      $0x000C4500, %eax
    mov      %eax, (%rsi)

    # 10-millisecond delay loop.
    # TBD
    mov      $0x1000000, %rcx
    loop     .

    # done
    xor      %rax, %rax
    ret

###############################################################################
#                             KernelIrqSipi()                                 #
###############################################################################

    # declare a linker symbol
    .global  KernelIrqSipi
    .set     KernelIrqSipi, .

    # broadcast the SIPI IPI to all processors except self
    mov      $LapicIntCmdLoReg, %rsi
    mov      $0x000C4600, %eax  # vector 0x0000:0x0000
    mov      %eax, (%rsi)

    # 200-microsecond delay loop
    # TBD
    mov      $0x1000000, %rcx
    loop     .

    # done
    xor      %rax, %rax
    ret

###############################################################################
#                              DATA SECTION                                   #
###############################################################################

    # data section
    .data

###############################################################################
#                            LOGGING STRINGS                                  #
###############################################################################

    # IRQ heading
    .set     IrqModuleStr, .
    .string  " [KERNEL IRQ SUBSYSTEM] "

    # IRQ start ascii string
    .set     IrqStartStr, .
    .string  "Supported x86 interrupt controllers: LAPIC, I/O APIC"
