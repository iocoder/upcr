;###############################################################################
;# File name:    lock.S
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
    .include "kernel/macro.inc"

;###############################################################################
;#                                GLOBALS                                      #
;###############################################################################

    ;# global symbols
    .global KernelLockInit
    .global KernelLockAcquire
    .global KernelLockReLEAse

;###############################################################################
;#                              TEXT SECTION                                   #
;###############################################################################

    ;# text section
    .text

;###############################################################################
;#                             KernelLockInit()                                #
;###############################################################################

    ;# declare a linker symbol
    .set     KernelLockInit, .

    ;# print heading of line
    MOV      $0x0A, %rdi
    MOV      $-1, %rsi
    CALL     KernelLogColour
    LEA      LockModuleStr(%rip), %rdi
    CALL     KernelLogString
    MOV      $0x0B, %rdi
    MOV      $-1, %rsi
    CALL     KernelLogColour

    ;# print module info
    LEA      LockStartStr(%rip), %rdi
    CALL     KernelLogString
    MOV      $'\n', %rdi
    CALL     KernelLogChar

    ;# initialize the semaphore with 0
    XOR      %rax, %rax
    MOV      %rax, AccessSemaphore(%rip)

    ;# done
1:  XOR      %rax, %rax
    RET

;###############################################################################
;#                            KernelLockAcquire()                              #
;###############################################################################

    ;# declare a linker symbol
    .set     KernelLockAcquire, .

    ;# cmpxchg LOOP to acquire the semaphore
1:  XOR      %eax, %eax
    MOV      $1, %ebx
    LOCK
    CMPXCHG  %ebx, AccessSemaphore(%rip)
    JNE      1b

    ;# done
2:  XOR      %rax, %rax
    RET

;###############################################################################
;#                            KernelLockReLEAse()                              #
;###############################################################################

    ;# declare a linker symbol
    .set     KernelLockReLEAse, .

    ;# reLEAse the kernel access semaphore
    XOR      %eax, %eax
    MOV      %eax, AccessSemaphore(%rip)

    ;# done
2:  XOR      %rax, %rax
    RET

;###############################################################################
;#                              DATA SECTION                                   #
;###############################################################################

    ;# data section
    .data

;###############################################################################
;#                              MODULE DATA                                    #
;###############################################################################

    ;# alignment to 8 bytes
    .align 8

    ;# Access semaphore
    .set     AccessSemaphore, .
    .quad    0

;###############################################################################
;#                            LOGGING STRINGS                                  #
;###############################################################################

    ;# Lock heading
    .set     LockModuleStr, .
    .string  " [KERNEL LOCK] "

    ;# Lock start ascii string
    .set     LockStartStr, .
    .string  "Initializing kernel access semaphore..."
