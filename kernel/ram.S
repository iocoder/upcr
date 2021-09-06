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
#                            KernelRamInit()                                  #
###############################################################################

    # declare a linker symbol
    .global  KernelRamInit
    .set     KernelRamInit, .

    # read RamAvailable from init struct
    mov      0x38(%rdi), %rax
    mov      %rax, RamAvailable(%rip)

    # read RamStart from init struct
    mov      0x40(%rdi), %rax
    mov      %rax, RamStart(%rip)

    # read RamEnd from init struct
    mov      0x48(%rdi), %rax
    mov      %rax, RamEnd(%rip)

    # did the user provide RAM information anyways?
    cmpb     $0, RamAvailable(%rip)
    jz       1f

    # print heading of line
    mov      $0x0A, %rdi
    mov      $-1, %rsi
    call     KernelLogColour
    leaq     RamModuleStr(%rip), %rdi
    call     KernelLogString
    mov      $0x0B, %rdi
    mov      $-1, %rsi
    call     KernelLogColour

    # print ram start
    leaq     RamStartStr(%rip), %rdi
    call     KernelLogString
    movq     RamStart(%rip), %rdi
    call     KernelLogHex
    mov      $'\n', %rdi
    call     KernelLogChar

    # print heading of line
    mov      $0x0A, %rdi
    mov      $-1, %rsi
    call     KernelLogColour
    leaq     RamModuleStr(%rip), %rdi
    call     KernelLogString
    mov      $0x0B, %rdi
    mov      $-1, %rsi
    call     KernelLogColour

    # print ram end line
    leaq     RamEndStr(%rip), %rdi
    call     KernelLogString
    movq     RamEnd(%rip), %rdi
    call     KernelLogHex
    mov      $'\n', %rdi
    call     KernelLogChar

    # print heading of line
    mov      $0x0A, %rdi
    mov      $-1, %rsi
    call     KernelLogColour
    leaq     RamModuleStr(%rip), %rdi
    call     KernelLogString
    mov      $0x0B, %rdi
    mov      $-1, %rsi
    call     KernelLogColour

    # print ram size line
    leaq     RamSizeStr(%rip), %rdi
    call     KernelLogString
    movq     RamEnd(%rip), %rdi
    subq     RamStart(%rip), %rdi
    shr      $20, %rdi
    call     KernelLogDecimal
    mov      $'M', %rdi
    call     KernelLogChar
    mov      $'B', %rdi
    call     KernelLogChar
    mov      $'\n', %rdi
    call     KernelLogChar

    # done
1:  xor      %rax, %rax
    ret

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
