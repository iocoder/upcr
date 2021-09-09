;###############################################################################
;# File name:    irq.S
;# Description:  Kernel I/O APIC AND LAPIC driver
;# Author:       Ramses A.
;###############################################################################
;#
;# UPCR Operating System for x86_64 architecture
;# Copyright (c) 2021 Ramses A.
;#
;# Permission is hereby granted, free of charge, to any person obtaining a copy
;# of this software AND associated documentation files (the "Software"), to deal
;# in the Software without restriction, including without limitation the rights
;# to use, copy, modify, merge, publish, distribute, sublicense, AND/or sell
;# copies of the Software, AND to permit persons to whom the Software is
;# furnished to do so, subject to the following conditions:
;#
;# The above copyright notice AND this permission notice shall be included in all
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
;#                                INCLUDES                                     #
;###############################################################################

    ;# common definitions used by kernel
    .INCLUDE "kernel/macro.inc"

;###############################################################################
;#                                 MACROS                                     #
;###############################################################################

    ;# LAPIC REGISTERS
    ;# ---------------
    ;# (I) LAPIC ID AND VERSION
    .EQU     LapicIdReg,          0xFEE00020
    .EQU     LapicVersionReg,     0xFEE00030
    ;# (II) LAPIC BUS PRIORITY REGISTERS
    .EQU     LapicTaskPriReg,     0xFEE00080
    .EQU     LapicArbiPriReg,     0xFEE00090
    .EQU     LapicProcPriReg,     0xFEE000A0
    ;# (III) LAPIC OPERATION REGISTERS
    .EQU     LapicEndOfIntReg,    0xFEE000B0
    .EQU     LapicRemoteRdReg,    0xFEE000C0
    .EQU     LapicLogicalDestReg, 0xFEE000D0
    .EQU     LapicDestFormatReg,  0xFEE000E0
    .EQU     LapicSpuriousIvtReg, 0xFEE000F0
    .EQU     LapicInServiceReg,   0xFEE00100
    .EQU     LapicTriggModeReg,   0xFEE00180
    .EQU     LapicIntReqReg,      0xFEE00200
    .EQU     LapicErrStatusReg,   0xFEE00280
    .EQU     LapicIntCmdLoReg,    0xFEE00300
    .EQU     LapicIntCmdHiReg,    0xFEE00310
    ;# (IV) IVT REGISTERS
    .EQU     LapicTimerIvtReg,    0xFEE00320
    .EQU     LapicThermIvtReg,    0xFEE00330
    .EQU     LapicPerfcIvtReg,    0xFEE00340
    .EQU     LapicLint0IvtReg,    0xFEE00350
    .EQU     LapicLint1IvtReg,    0xFEE00360
    .EQU     LapicErrorIvtReg,    0xFEE00370
    ;# (V) TIMER REGISTERS
    .EQU     LapicTimerInitReg,   0xFEE00380
    .EQU     LapicTimerCurrReg,   0xFEE00390
    .EQU     LapicTimerConfReg,   0xFEE003E0

;###############################################################################
;#                                GLOBALS                                      #
;###############################################################################

    ;# global symbols
    .global KIRQINIT
    .global KIRQEN
    .global KIRQIIPI
    .global KIRQSIPI

;###############################################################################
;#                              TEXT SECTION                                   #
;###############################################################################

    ;# text section
    .text

;###############################################################################
;#                               KIRQINIT()                                    #
;###############################################################################

KIRQINIT:

    ;# print heading of line
    MOV      $0x0A, %rdi
    MOV      $-1, %rsi
    CALL     KLOGATT
    LEA      KIRQNAME(%rip), %rdi
    CALL     KLOGSTR
    MOV      $0x0B, %rdi
    MOV      $-1, %rsi
    CALL     KLOGATT

    ;# print irq module info
    LEA      KIRQMSG(%rip), %rdi
    CALL     KLOGSTR
    MOV      $'\n', %rdi
    CALL     KLOGCHR

    ;# done
1:  XOR      %rax, %rax
    RET

;###############################################################################
;#                               KIRQEN()                                      #
;###############################################################################

KIRQEN:

    ;# Initialize APIC address MSR
    XOR      %rax, %rax
    XOR      %rcx, %rcx
    XOR      %rdx, %rdx
    MOV      $0xFEE00800, %eax
    MOV      $ApicBaseAddrMsr, %ecx
    WRMSR
    NOP
    NOP

    ;# done
1:  XOR      %rax, %rax
    RET

;###############################################################################
;#                               KIRQIIPI()                                    #
;###############################################################################

KIRQIIPI:

    ;# broadcast the INIT IPI to all processors except self
    MOV      $LapicIntCmdLoReg, %rsi
    MOV      $0x000C4500, %eax
    MOV      %eax, (%rsi)

    ;# 10-millisecond delay LOOP.
    ;# TBD
    MOV      $0x1000000, %rcx
    LOOP     .

    ;# done
    XOR      %rax, %rax
    RET

;###############################################################################
;#                                KIRQSIPI()                                   #
;###############################################################################

KIRQSIPI:

    ;# broadcast the SIPI IPI to all processors except self
    MOV      $LapicIntCmdLoReg, %rsi
    MOV      $0x000C4600, %eax  ;# vector 0x0000:0x0000
    MOV      %eax, (%rsi)

    ;# 200-microsecond delay LOOP
    ;# TBD
    MOV      $0x1000000, %rcx
    LOOP     .

    ;# done
    XOR      %rax, %rax
    RET

;###############################################################################
;#                              DATA SECTION                                   #
;###############################################################################

    ;# data section
    .data

;###############################################################################
;#                            LOGGING STRINGS                                  #
;###############################################################################

            ;# IRQ heading and ascii strings
KIRQNAME:   .string  " [KERNEL IRQ] "
KIRQMSG:    .string  "Supported x86 interrupt controllers: LAPIC, I/O APIC."
