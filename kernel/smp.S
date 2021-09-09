###############################################################################
# File name:    cpu.S
# Description:  Kernel cpu initialization code
# Author:       Ramses A.
###############################################################################
#
# UPCR Operating System for x86_64 architecture
# Copyright (c) 2021 Ramses A.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software AND associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, AND/or sell
# copies of the Software, AND to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice AND this permission notice shall be included in all
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
#                            KernelSmpInit()                                  #
###############################################################################

    # declare a linker symbol
    .global  KernelSmpInit
    .set     KernelSmpInit, .

    # print heading of line
    MOV      $0x0A, %rdi
    MOV      $-1, %rsi
    CALL     KernelLogColour
    LEA      SmpModuleStr(%rip), %rdi
    CALL     KernelLogString
    MOV      $0x0B, %rdi
    MOV      $-1, %rsi
    CALL     KernelLogColour

    # print module info
    LEA      SmpStartStr(%rip), %rdi
    CALL     KernelLogString
    MOV      $'\n', %rdi
    CALL     KernelLogChar

    # first we need to initialize core 0
    CALL     KernelSmpEnable

    # send INIT-SIPI-SIPI sequence to other CPUs
    CALL     KernelIrqIipi
    CALL     KernelIrqSipi
    CALL     KernelIrqSipi

    # done
1:  XOR      %rax, %rax
    RET

###############################################################################
#                            KernelSmpEnable()                                #
###############################################################################

    # declare a linker symbol
    .global  KernelSmpEnable
    .set     KernelSmpEnable, .

    # acquire kernel lock to avoid race conditions with other CPUS
    CALL     KernelLockAcquire

    # initialize LAPIC AND enable IRQs
    CALL     KernelIrqEnable

    # set heading colour
    MOV      $0x0A, %rdi
    MOV      $-1, %rsi
    CALL     KernelLogColour

    # print module name
    LEA      SmpModuleStr(%rip), %rdi
    CALL     KernelLogString

    # reset colour
    MOV      $0x0B, %rdi
    MOV      $-1, %rsi
    CALL     KernelLogColour

    # print lapic detection string
    LEA      SmpLapicStr(%rip), %rdi
    CALL     KernelLogString

    # print LAPIC ID
    XOR      %rax, %rax
    MOV      0xFEE00020, %eax
    SHR      $24, %eax
    MOV      %rax, %rdi
    CALL     KernelLogDecimal

    # print new line
    MOV      $'\n', %rdi
    CALL     KernelLogChar

    # reLEAse the lock
    PUSH     %rdi
    CALL     KernelLockReLEAse
    POP      %rdi

    # done
    XOR      %rax, %rax
    RET

###############################################################################
#                              DATA SECTION                                   #
###############################################################################

    # data section
    .data

###############################################################################
#                            LOGGING STRINGS                                  #
###############################################################################

    # SMP heading
    .set     SmpModuleStr, .
    .string  " [KERNEL SMP SUPPORT] "

    # SMP start ascii string
    .set     SmpStartStr, .
    .string  "Detecting CPU cores available in the system..."

    # SMP lapic ascii string
    .set     SmpLapicStr, .
    .string  "Successfully initialized CPU core with LAPIC ID: "
