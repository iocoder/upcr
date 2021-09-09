;###############################################################################
;# File name:    ram.S
;# Description:  Kernel physical memory module
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
            PUBLIC   KRAMINIT

;###############################################################################
;#                              TEXT SECTION                                   #
;###############################################################################

            ;# text section
            SEGMENT  ".text"

;#-----------------------------------------------------------------------------#
;#                              KRAMINIT()                                     #
;#-----------------------------------------------------------------------------#

KRAMINIT:   ;# read KRAMAVL from init struct
            MOV      0x38(%rdi), %rax
            MOV      %rax, KRAMAVL(%rip)

            ;# read KRAMSTART from init struct
            MOV      0x40(%rdi), %rax
            MOV      %rax, KRAMSTART(%rip)

            ;# read KRAMEND from init struct
            MOV      0x48(%rdi), %rax
            MOV      %rax, KRAMEND(%rip)

            ;# did the user provide RAM information anyways?
            MOV      KRAMAVL(%rip), %rax
            CMP      $0, %rax
            JZ       1f

            ;# print heading of line
            MOV      $0x0A, %rdi
            MOV      $-1, %rsi
            CALL     KLOGATT
            LEA      KRAMNAME(%rip), %rdi
            CALL     KLOGSTR
            MOV      $0x0B, %rdi
            MOV      $-1, %rsi
            CALL     KLOGATT

            ;# print ram start
            LEA      KRAMSTARTS(%rip), %rdi
            CALL     KLOGSTR
            MOV      KRAMSTART(%rip), %rdi
            CALL     KLOGHEX
            MOV      $'\n', %rdi
            CALL     KLOGCHR

            ;# print heading of line
            MOV      $0x0A, %rdi
            MOV      $-1, %rsi
            CALL     KLOGATT
            LEA      KRAMNAME(%rip), %rdi
            CALL     KLOGSTR
            MOV      $0x0B, %rdi
            MOV      $-1, %rsi
            CALL     KLOGATT

            ;# print ram end line
            LEA      KRAMENDS(%rip), %rdi
            CALL     KLOGSTR
            MOV      KRAMEND(%rip), %rdi
            CALL     KLOGHEX
            MOV      $'\n', %rdi
            CALL     KLOGCHR

            ;# print heading of line
            MOV      $0x0A, %rdi
            MOV      $-1, %rsi
            CALL     KLOGATT
            LEA      KRAMNAME(%rip), %rdi
            CALL     KLOGSTR
            MOV      $0x0B, %rdi
            MOV      $-1, %rsi
            CALL     KLOGATT

            ;# print ram size line
            LEA      KRAMESIZES(%rip), %rdi
            CALL     KLOGSTR
            MOV      KRAMEND(%rip), %rdi
            SUB      KRAMSTART(%rip), %rdi
            SHR      $20, %rdi
            CALL     KLOGDEC
            MOV      $'M', %rdi
            CALL     KLOGCHR
            MOV      $'B', %rdi
            CALL     KLOGCHR
            MOV      $'\n', %rdi
            CALL     KLOGCHR

            ;# done
1:          XOR      %rax, %rax
            RET

;###############################################################################
;#                              DATA SECTION                                   #
;###############################################################################

            ;# data section
            SEGMENT  ".data"

;#-----------------------------------------------------------------------------#
;#                              MODULE DATA                                    #
;#-----------------------------------------------------------------------------#

            ;# RamInitInfo structure
KRAMAVL:    DQ       0
KRAMSTART:  DQ       0
KRAMEND:    DQ       0

;#-----------------------------------------------------------------------------#
;#                            LOGGING STRINGS                                  #
;#-----------------------------------------------------------------------------#

            ;# RAM heading and messages
KRAMNAME:   DB       " [KERNEL RAM] \0"
KRAMSTARTS: DB       "Detected RAM Start: \0"
KRAMENDS:   DB       "Detected RAM End:   \0"
KRAMESIZES: DB       "Detected RAM Size:  \0"
