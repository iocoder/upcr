###############################################################################
# File name:    page.S
# Description:  Kernel virtual memory module
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
#                             KernelPageInit()                                #
###############################################################################

    # declare a linker symbol
    .global  KernelPageInit
    .set     KernelPageInit, .

    # print heading of line
    mov      $0x0A, %rdi
    mov      $-1, %rsi
    call     KernelLogColour
    leaq     PageModuleStr(%rip), %rdi
    call     KernelLogString
    mov      $0x0B, %rdi
    mov      $-1, %rsi
    call     KernelLogColour

    # print module info
    leaq     PageStartStr(%rip), %rdi
    call     KernelLogString
    mov      $'\n', %rdi
    call     KernelLogChar

    # initialize PML4Table
    movq     %cr3, %rsi
    movq     $RootPageTableBase, %rdi
    movq     $RootPageTableSize, %rcx
    # copy loop
1:  movb     (%rsi), %al
    movb     %al, (%rdi)
    inc      %rsi
    inc      %rdi
    loop     1b

    # load CR3 with PML4 table base
    movq     $RootPageTableBase, %rax
    movq     %rax, %cr3

    # done
2:  xor      %rax, %rax
    ret

###############################################################################
#                              DATA SECTION                                   #
###############################################################################

    # data section
    .data

###############################################################################
#                            LOGGING STRINGS                                  #
###############################################################################

    # Paging heading
    .set     PageModuleStr, .
    .string  " [KERNEL PAGING] "

    # Paging start ascii string
    .set     PageStartStr, .
    .string  "Initializing paging module..."
