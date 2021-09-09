;###############################################################################
;# File name:    tss.S
;# Description:  Kernel TSS descriptors
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
    .include "kernel/macro.inc"

;###############################################################################
;#                                GLOBALS                                      #
;###############################################################################

    ;# global symbols
    .global KernelTssInit

;###############################################################################
;#                              TEXT SECTION                                   #
;###############################################################################

    ;# text section
    .text

;###############################################################################
;#                              KernelTssInit()                                #
;###############################################################################

    ;# declare a linker symbol
    .set     KernelTssInit, .

    ;# print heading of line
    MOV      $0x0A, %rdi
    MOV      $-1, %rsi
    CALL     KernelLogColour
    LEA      TssModuleStr(%rip), %rdi
    CALL     KernelLogString
    MOV      $0x0B, %rdi
    MOV      $-1, %rsi
    CALL     KernelLogColour

    ;# print module info
    LEA      TssStartStr(%rip), %rdi
    CALL     KernelLogString
    MOV      $'\n', %rdi
    CALL     KernelLogChar

    ;# done
1:  XOR      %rax, %rax
    RET

;###############################################################################
;#                              DATA SECTION                                   #
;###############################################################################

    ;# data section
    .data

;###############################################################################
;#                            LOGGING STRINGS                                  #
;###############################################################################

    ;# TSS heading
    .set     TssModuleStr, .
    .string  " [KERNEL TSS] "

    ;# TSS start ascii string
    .set     TssStartStr, .
    .string  "Initializing TSS module..."
