;###############################################################################
;# File name:    loc.S
;# Description:  Kernel semaphore to protect kernel code access
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
            PUBLIC   KLOCPEND
            PUBLIC   KLOCPOST

;###############################################################################
;#                              TEXT SECTION                                   #
;###############################################################################

            ;# text section
            SEGMENT  ".text"

;#-----------------------------------------------------------------------------#
;#                               KLOCPEND()                                    #
;#-----------------------------------------------------------------------------#

KLOCPEND:   ;# cmpxchg LOOP to acquire the semaphore
            XOR      %eax, %eax
            MOV      $1, %ebx
            LOCK
            CMPXCHG  %ebx, KLOC(%rip)
            JNE      KLOCPEND

            ;# done
            XOR      %rax, %rax
            RET

;#-----------------------------------------------------------------------------#
;#                               KLOCPOST()                                    #
;#-----------------------------------------------------------------------------#

KLOCPOST:   ;# release the kernel access semaphore
            XOR      %eax, %eax
            MOV      %eax, KLOC(%rip)

            ;# done
            XOR      %rax, %rax
            RET

;###############################################################################
;#                              DATA SECTION                                   #
;###############################################################################

            ;# data section
            SEGMENT  ".data"

;#-----------------------------------------------------------------------------#
;#                              MODULE DATA                                    #
;#-----------------------------------------------------------------------------#

            ;# alignment to 8 bytes
            ALIGN    8

            ;# the lock itself
KLOC:       DQ       0
