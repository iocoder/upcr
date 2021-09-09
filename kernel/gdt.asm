;###############################################################################
;# File name:    gdt.S
;# Description:  Kernel global descriptor table
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
            PUBLIC   KGDTINIT

;###############################################################################
;#                              TEXT SECTION                                   #
;###############################################################################

            ;# text section
            SEGMENT  ".text"

;#-----------------------------------------------------------------------------#
;#                                KGDTINIT()                                   #
;#-----------------------------------------------------------------------------#

KGDTINIT:   ;# print init msg
            LEA      KGDTNAME(%rip), %rdi
            CALL     KLOGMOD
            LEA      KGDTMSG(%rip), %rdi
            CALL     KLOGSTR
            MOV      $'\n', %rdi
            CALL     KLOGCHR

            ;# copy the GDTR descriptor to lower memory
            MOV      $GDTR_ADDR, %rdi
            MOV      KGDTDESC(%rip), %rax
            MOV      %rax, (%rdi)

            ;# copy the GDT table to lower memory
            MOV      $GDT_ADDR, %rdi
            LEA      KGDTSTART(%rip), %rsi
            LEA      KGDTDESC(%rip), %rcx
            SUB      %rsi, %rcx

            ;# copy LOOP
1:          MOV      (%rsi), %al
            MOV      %al, (%rdi)
            INC      %rsi
            INC      %rdi
            LOOP     1b

            ;# load GDTR descriptor
            LGDT     GDTR_ADDR

            ;# make a far jump to reload CS using long-mode lRETq
            MOV      $0x20, %rax
            PUSH     %rax
            LEA      2f(%rip), %rax
            PUSH     %rax
            LRETQ

            ;# reload other segment registers
2:          MOV      $0x28, %ax
            MOV      %ax, %ds
            MOV      %ax, %es
            MOV      %ax, %fs
            MOV      %ax, %gs
            MOV      %ax, %ss

            ;# done
            XOR      %rax, %rax
            RET

;###############################################################################
;#                              DATA SECTION                                   #
;###############################################################################

            ;# data section
            SEGMENT  ".data"

;###############################################################################
;#                              MODULE DATA                                    #
;###############################################################################

            ;# GDT table for protected & long mode
KGDTSTART:  DQ       0x0000000000000000  ;# 0x00
            DQ       0x0000000000000000  ;# 0x00
            DQ       0x00CF9A000000FFFF  ;# 0x10 (KERN CODE 32-bit)
            DQ       0x00CF92000000FFFF  ;# 0x18 (KERN DATA 32-bit)
            DQ       0x00AF9A000000FFFF  ;# 0x20 (KERN CODE 64-bit)
            DQ       0x00AF92000000FFFF  ;# 0x28 (KERN DATA 64-bit)
            DQ       0x00AFFA000000FFFF  ;# 0x30 (USER CODE 64-bit)
            DQ       0x00AFF2000000FFFF  ;# 0x38 (USER DATA 64-bit)

            ;# GDTR descriptor
KGDTDESC:   DW       0xFFF
            DD       GDT_ADDR
            DW       0

;###############################################################################
;#                            LOGGING STRINGS                                  #
;###############################################################################

            ;# GDT heading and ascii strings
KGDTNAME:   DB       "KERNEL GDT\0"
KGDTMSG:    DB       "Initializing GDT module...\0"
