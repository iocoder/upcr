;###############################################################################
;# File name:    boot.S
;# Description:  Kernel boot procedures
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
    .global KernelBootInit

;###############################################################################
;#                              TEXT SECTION                                   #
;###############################################################################

    ;# text section
    .text

;###############################################################################
;#                             KernelBootInit()                                #
;###############################################################################

    ;# declare a linker symbol
    .set     KernelBootInit, .

    ;# initialize vga module
    PUSH     %rdi
    CALL     KernelVgaInit
    POP      %rdi

    ;# initialize log module
    PUSH     %rdi
    CALL     KernelLogInit
    POP      %rdi

    ;# initialize panic module
    PUSH     %rdi
    CALL     KernelPanicInit
    POP      %rdi

    ;# initialize ram module
    PUSH     %rdi
    CALL     KernelRamInit
    POP      %rdi

    ;# initialize page module
    PUSH     %rdi
    CALL     KernelPageInit
    POP      %rdi

    ;# initialize gdt module
    PUSH     %rdi
    CALL     KernelGdtInit
    POP      %rdi

    ;# initialize idt module
    PUSH     %rdi
    CALL     KernelIdtInit
    POP      %rdi

    ;# initialize tss module
    PUSH     %rdi
    CALL     KernelTssInit
    POP      %rdi

    ;# initialize stack module
    PUSH     %rdi
    CALL     KernelStackInit
    POP      %rdi

    ;# initialize irq module
    PUSH     %rdi
    CALL     KernelIrqInit
    POP      %rdi

    ;# initialize smp module
    PUSH     %rdi
    CALL     KernelSmpInit
    POP      %rdi

    ;# done
    XOR      %rax, %rax
    RET
