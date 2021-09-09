;###############################################################################
;# File name:    sys.S
;# Description:  Kernel system initialization procedures
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
;#                                GLOBALS                                      #
;###############################################################################

    ;# global symbols
    .global KSYSINIT

;###############################################################################
;#                              TEXT SECTION                                   #
;###############################################################################

    ;# text section
    .text

;###############################################################################
;#                               KSYSINIT()                                    #
;###############################################################################

KSYSINIT:

    ;# initialize vga module
    PUSH     %rdi
    CALL     KVGAINIT
    POP      %rdi

    ;# initialize log module
    PUSH     %rdi
    CALL     KLOGINIT
    POP      %rdi

    ;# initialize ram module
    PUSH     %rdi
    CALL     KRAMINIT
    POP      %rdi

    ;# initialize page module
    PUSH     %rdi
    CALL     KVMMINIT
    POP      %rdi

    ;# initialize gdt module
    PUSH     %rdi
    CALL     KGDTINIT
    POP      %rdi

    ;# initialize idt module
    PUSH     %rdi
    CALL     KIDTINIT
    POP      %rdi

    ;# initialize tss module
    PUSH     %rdi
    CALL     KTSSINIT
    POP      %rdi

    ;# initialize irq module
    PUSH     %rdi
    CALL     KIRQINIT
    POP      %rdi

    ;# initialize smp module
    PUSH     %rdi
    CALL     KSMPINIT
    POP      %rdi

    ;# done
    XOR      %rax, %rax
    RET
