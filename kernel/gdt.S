###############################################################################
# File name:    gdt.S
# Description:  Kernel global descriptor table
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
#                              KernelGdtInit()                                #
###############################################################################

    # declare a linker symbol
    .global  KernelGdtInit
    .set     KernelGdtInit, .

    # print heading of line
    mov      $0x0A, %rdi
    mov      $-1, %rsi
    call     KernelLogColour
    leaq     GdtModuleStr(%rip), %rdi
    call     KernelLogString
    mov      $0x0B, %rdi
    mov      $-1, %rsi
    call     KernelLogColour

    # print module info
    leaq     GdtStartStr(%rip), %rdi
    call     KernelLogString
    mov      $'\n', %rdi
    call     KernelLogChar

    # copy the GDTR descriptor to lower memory
    movq     $GdtrDescBase, %rdi
    movq     GdtrDesc(%rip), %rax
    movq     %rax, (%rdi)

    # copy the GDT table to lower memory
    movq     $GdtTableBase, %rdi
    leaq     GdtStart(%rip), %rsi
    leaq     GdtEnd(%rip), %rcx
    subq     %rsi, %rcx

    # copy loop
1:  movb     (%rsi), %al
    movb     %al, (%rdi)
    inc      %rsi
    inc      %rdi
    loop     1b

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

    # GDT table for protected & long mode
    .set     GdtStart, .
    .quad    0x0000000000000000  # 0x00
    .quad    0x0000000000000000  # 0x00
    .quad    0x00CF9A000000FFFF  # 0x10 (KERN CODE 32-bit)
    .quad    0x00CF92000000FFFF  # 0x18 (KERN DATA 32-bit)
    .quad    0x00AF9A000000FFFF  # 0x20 (KERN CODE 64-bit)
    .quad    0x00AF92000000FFFF  # 0x28 (KERN DATA 64-bit)
    .quad    0x00AFFA000000FFFF  # 0x30 (USER CODE 64-bit)
    .quad    0x00AFF2000000FFFF  # 0x38 (USER DATA 64-bit)
    .set     GdtEnd, .

    # GDTR descriptor
    .set     GdtrDesc, .
    .word    GdtTableSize-1
    .long    GdtTableBase
    .word    0

###############################################################################
#                            LOGGING STRINGS                                  #
###############################################################################

    # GDT heading
    .set     GdtModuleStr, .
    .string  " [KERNEL GDT] "

    # GDT start ascii string
    .set     GdtStartStr, .
    .string  "Initializing GDT module..."
