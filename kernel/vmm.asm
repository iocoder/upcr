;###############################################################################
;# File name:    vmm.S
;# Description:  Kernel virtual memory module
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
            INCLUDE  "kernel/macro.inc"

;###############################################################################
;#                                GLOBALS                                      #
;###############################################################################

            ;# global symbols
            PUBLIC   KVMMINIT

;###############################################################################
;#                              TEXT SECTION                                   #
;###############################################################################

            ;# text section
            SEGMENT  ".text"

;###############################################################################
;#                               KVMMINIT()                                    #
;###############################################################################

KVMMINIT:   ;# print heading of line
            MOV      $0x0A, %rdi
            MOV      $-1, %rsi
            CALL     KLOGATT
            LEA      KVMMNAME(%rip), %rdi
            CALL     KLOGSTR
            MOV      $0x0B, %rdi
            MOV      $-1, %rsi
            CALL     KLOGATT

            ;# print module info
            LEA      KVMMMSG(%rip), %rdi
            CALL     KLOGSTR
            MOV      $'\n', %rdi
            CALL     KLOGCHR

            ;# initialize PML4Table
            MOV      %cr3, %rsi
            MOV      $PM4L_ADDR, %rdi
            MOV      $0x1000, %rcx
            ;# copy LOOP
1:          MOV      (%rsi), %al
            MOV      %al, (%rdi)
            INC      %rsi
            INC      %rdi
            LOOP     1b

            ;# load CR3 with PML4 table base
            MOV      $PM4L_ADDR, %rax
            MOV      %rax, %cr3

            ;# done
2:          XOR      %rax, %rax
            RET

;###############################################################################
;#                              DATA SECTION                                   #
;###############################################################################

            ;# data section
            SEGMENT  ".data"

;###############################################################################
;#                            LOGGING STRINGS                                  #
;###############################################################################

            ;# VMM heading and ascii strings
KVMMNAME:   DB       " [KERNEL VMM] \0"
KVMMMSG:    DB       "Initializing virtual memory manager...\0"
