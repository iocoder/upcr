###############################################################################
# File name:    ram.S
# Description:  Kernel physical memory module
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
#                            KernelRamInit()                                  #
###############################################################################

    # declare a linker symbol
    .global  KernelRamInit
    .set     KernelRamInit, .

    # read RamAvailable from init struct
    MOV      0x38(%rdi), %rax
    MOV      %rax, RamAvailable(%rip)

    # read RamStart from init struct
    MOV      0x40(%rdi), %rax
    MOV      %rax, RamStart(%rip)

    # read RamEnd from init struct
    MOV      0x48(%rdi), %rax
    MOV      %rax, RamEnd(%rip)

    # did the user provide RAM information anyways?
    MOV      RamAvailable(%rip), %rax
    CMP      $0, %rax
    JZ       1f

    # print heading of line
    MOV      $0x0A, %rdi
    MOV      $-1, %rsi
    CALL     KernelLogColour
    LEA      RamModuleStr(%rip), %rdi
    CALL     KernelLogString
    MOV      $0x0B, %rdi
    MOV      $-1, %rsi
    CALL     KernelLogColour

    # print ram start
    LEA      RamStartStr(%rip), %rdi
    CALL     KernelLogString
    MOV      RamStart(%rip), %rdi
    CALL     KernelLogHex
    MOV      $'\n', %rdi
    CALL     KernelLogChar

    # print heading of line
    MOV      $0x0A, %rdi
    MOV      $-1, %rsi
    CALL     KernelLogColour
    LEA      RamModuleStr(%rip), %rdi
    CALL     KernelLogString
    MOV      $0x0B, %rdi
    MOV      $-1, %rsi
    CALL     KernelLogColour

    # print ram end line
    LEA      RamEndStr(%rip), %rdi
    CALL     KernelLogString
    MOV      RamEnd(%rip), %rdi
    CALL     KernelLogHex
    MOV      $'\n', %rdi
    CALL     KernelLogChar

    # print heading of line
    MOV      $0x0A, %rdi
    MOV      $-1, %rsi
    CALL     KernelLogColour
    LEA      RamModuleStr(%rip), %rdi
    CALL     KernelLogString
    MOV      $0x0B, %rdi
    MOV      $-1, %rsi
    CALL     KernelLogColour

    # print ram size line
    LEA      RamSizeStr(%rip), %rdi
    CALL     KernelLogString
    MOV      RamEnd(%rip), %rdi
    SUB      RamStart(%rip), %rdi
    SHR      $20, %rdi
    CALL     KernelLogDecimal
    MOV      $'M', %rdi
    CALL     KernelLogChar
    MOV      $'B', %rdi
    CALL     KernelLogChar
    MOV      $'\n', %rdi
    CALL     KernelLogChar

    # done
1:  XOR      %rax, %rax
    RET

###############################################################################
#                              DATA SECTION                                   #
###############################################################################

    # data section
    .data

###############################################################################
#                              MODULE DATA                                    #
###############################################################################

    # RamInitInfo structure
    .set     RamAvailable, .
    .quad    0
    .set     RamStart, .
    .quad    0
    .set     RamEnd, .
    .quad    0

###############################################################################
#                            LOGGING STRINGS                                  #
###############################################################################

    # RAM heading
    .set     RamModuleStr, .
    .string  " [KERNEL MEMORY MGMT] "

    # RAM start ascii string
    .set     RamStartStr, .
    .string  "Detected RAM Start: "

    # RAM end ascii string
    .set     RamEndStr, .
    .string  "Detected RAM End:   "

    # RAM size ascii string
    .set     RamSizeStr, .
    .string  "Detected RAM Size:  "
