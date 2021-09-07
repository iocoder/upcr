###############################################################################
# File name:    lock.S
# Description:  Kernel semaphore to protect kernel code access
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
#                             KernelLockInit()                                #
###############################################################################

    # declare a linker symbol
    .global  KernelLockInit
    .set     KernelLockInit, .

    # print heading of line
    mov      $0x0A, %rdi
    mov      $-1, %rsi
    call     KernelLogColour
    leaq     LockModuleStr(%rip), %rdi
    call     KernelLogString
    mov      $0x0B, %rdi
    mov      $-1, %rsi
    call     KernelLogColour

    # print module info
    leaq     LockStartStr(%rip), %rdi
    call     KernelLogString
    mov      $'\n', %rdi
    call     KernelLogChar

    # initialize the semaphore with 0
    movq     $0, AccessSemaphore(%rip)

    # done
1:  xor      %rax, %rax
    ret

###############################################################################
#                            KernelLockAcquire()                              #
###############################################################################

    # declare a linker symbol
    .global  KernelLockAcquire
    .set     KernelLockAcquire, .

    # cmpxchg loop to acquire the semaphore
1:  xor      %eax, %eax
    mov      $1, %ebx
    lock
    cmpxchg  %ebx, AccessSemaphore(%rip)
    jne      1b

    # done
2:  xor      %rax, %rax
    ret

###############################################################################
#                            KernelLockRelease()                              #
###############################################################################

    # declare a linker symbol
    .global  KernelLockRelease
    .set     KernelLockRelease, .

    # release the kernel access semaphore
    xor      %eax, %eax
    mov      %eax, AccessSemaphore(%rip)

    # done
2:  xor      %rax, %rax
    ret

###############################################################################
#                              DATA SECTION                                   #
###############################################################################

    # data section
    .data

###############################################################################
#                              MODULE DATA                                    #
###############################################################################

    # alignment to 8 bytes
    .align 8

    # Access semaphore
    .set     AccessSemaphore, .
    .quad    0

###############################################################################
#                            LOGGING STRINGS                                  #
###############################################################################

    # Lock heading
    .set     LockModuleStr, .
    .string  " [KERNEL LOCK] "

    # Lock start ascii string
    .set     LockStartStr, .
    .string  "Initializing kernel access semaphore..."
