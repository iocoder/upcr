;###############################################################################
;# File name:    cpu.S
;# Description:  Kernel cpu initialization code
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
            .global  KSMPINIT
            .global  KSMPEN

;###############################################################################
;#                              TEXT SECTION                                   #
;###############################################################################

            ;# text section
            .text

;###############################################################################
;#                          REAL MODE TRAMPOLINE                               #
;###############################################################################

KSMP16:     ;# 16-bit code
            .code16

            ;# first instruction executed by CPU core!!!
            MOV      $0x55AA, %ax

            ;# make sure interrupts are disabled
            cli

            ;# initialize segment registers
            XOR      %bx, %bx
            MOV      %bx, %ds
            MOV      %bx, %es
            MOV      %bx, %ss

            ;# load GDTR register
            LGDT     GDTR_ADDR

            ;# enter protected mode
            MOV      %cr0, %eax
            OR       $1, %eax
            MOV      %eax, %cr0

            ;# jump into 32-bit mode
            LJMP     $0x10, $(KSMP32-KSMP16)

KSMP32:     ;# 32-bit code
            .code32

            ;# initialize segment registers
            MOV      $0x18, %ax
            MOV      %ax, %ds
            MOV      %ax, %es
            MOV      %ax, %fs
            MOV      %ax, %gs
            MOV      %ax, %ss

            ;# enable physical address extension
            MOV      %cr4, %eax
            OR       $0x00000020, %eax
            MOV      %eax, %cr4

            ;# enable long-mode in EFER
            MOV      $MSR_EFER, %ecx
            RDMSR
            OR       $0x00000100, %eax
            WRMSR

            ;# load CR3 with PML4 table base
            MOV      $PM4L_ADDR, %eax
            MOV      %eax, %cr3

            ;# enable paging; this activates long mode
            MOV      %cr0, %eax
            OR       $0x80000000, %eax
            MOV      %eax, %cr0

            ;# we are in compatibility mode now! jump to code64
            LJMP     $0x0020, $(KSMP64-KSMP16)

KSMP64:     ;# 64-bit code
            .code64

            ;# initialize segment registers
            MOV      $0x0028, %ax
            MOV      %ax, %ds
            MOV      %ax, %es
            MOV      %ax, %fs
            MOV      %ax, %gs
            MOV      %ax, %ss

            ;# initialize all 64-bit GPRs
            MOV      $0x1111111111111111, %rax
            MOV      $0x2222222222222222, %rbx
            MOV      $0x3333333333333333, %rcx
            MOV      $0x4444444444444444, %rdx
            MOV      $0xAAAAAAAAAAAAAAAA, %rsi
            MOV      $0xBBBBBBBBBBBBBBBB, %rdi
            MOV      $0xCCCCCCCCCCCCCCCC, %rbp
            MOV      $0xDDDDDDDDDDDDDDDD, %rsp
            MOV      $0x1111111111111111, %r8
            MOV      $0x2222222222222222, %r9
            MOV      $0x3333333333333333, %r10
            MOV      $0x4444444444444444, %r11
            MOV      $0xAAAAAAAAAAAAAAAA, %r12
            MOV      $0xBBBBBBBBBBBBBBBB, %r13
            MOV      $0xCCCCCCCCCCCCCCCC, %r14
            MOV      $0xDDDDDDDDDDDDDDDD, %r15

            ;# read local APIC ID
            XOR      %rax, %rax
            MOV      0xFEE00020, %eax
            SHR      $24, %eax

            ;# use this particular CPU stack
            MOV      %rax, %rsp
            SHL      $12, %rsp
            ADD      $(STACK_ADDR), %rsp
            ADD      $0x1000, %rsp
            MOV      %rsp, %rbp
            NOP

            ;# initialize IDT
            LIDT     IDTR_ADDR

            ;# jump to KSMPEN
            MOV      SmpFunAddress-KSMP16, %rax
            CALL     *%rax

            ;# LOOP forever
            JMP      .

            ;# alignment for data
            .align   8

            ;# SmpFunAddress
            .set     SmpFunAddress, .
            .quad    0

;###############################################################################
;#                              KSMPINIT()                                     #
;###############################################################################

KSMPINIT:   ;# print heading of line
            MOV      $0x0A, %rdi
            MOV      $-1, %rsi
            CALL     KLOGATT
            LEA      KSMPNAME(%rip), %rdi
            CALL     KLOGSTR
            MOV      $0x0B, %rdi
            MOV      $-1, %rsi
            CALL     KLOGATT

            ;# print module info
            LEA      KSMPMSG(%rip), %rdi
            CALL     KLOGSTR
            MOV      $'\n', %rdi
            CALL     KLOGCHR

            ;# store the address of KSMPEN() to be fetched by trampoline
            LEA      KSMPEN(%rip), %rax
            MOV      %rax, SmpFunAddress(%rip)

            ;# copy the real-mode trampoline to lower memory
            MOV      $TRUMP_ADDR, %rdi
            LEA      KSMP16(%rip), %rsi
            LEA      KSMPINIT(%rip), %rcx
            SUB      %rsi, %rcx

            ;# copy LOOP
1:          MOV      (%rsi), %al
            MOV      %al, (%rdi)
            INC      %rsi
            INC      %rdi
            LOOP     1b

            ;# first we need to initialize core 0
            CALL     KSMPEN

            ;# send INIT-SIPI-SIPI sequence to other CPUs
            CALL     KIRQIIPI
            CALL     KIRQSIPI
            CALL     KIRQSIPI

            ;# done
            XOR      %rax, %rax
            RET

;###############################################################################
;#                               KSMPEN()                                      #
;###############################################################################

;# TODO: move lock instructions to IDT

KSMPEN:     ;# acquire kernel lock to avoid race conditions with other CPUS
            CALL     KLOCPEND

            ;# initialize LAPIC AND enable IRQs
            CALL     KIRQEN

            ;# set heading colour
            MOV      $0x0A, %rdi
            MOV      $-1, %rsi
            CALL     KLOGATT

            ;# print module name
            LEA      KSMPNAME(%rip), %rdi
            CALL     KLOGSTR

            ;# reset colour
            MOV      $0x0B, %rdi
            MOV      $-1, %rsi
            CALL     KLOGATT

            ;# print lapic detection string
            LEA      KSMPID(%rip), %rdi
            CALL     KLOGSTR

            ;# print LAPIC ID
            XOR      %rax, %rax
            MOV      0xFEE00020, %eax
            SHR      $24, %eax
            MOV      %rax, %rdi
            CALL     KLOGDEC

            ;# print new line
            MOV      $'\n', %rdi
            CALL     KLOGCHR

            ;# release the lock
            PUSH     %rdi
            CALL     KLOCPOST
            POP      %rdi

            ;# done
            XOR      %rax, %rax
            RET

;###############################################################################
;#                              DATA SECTION                                   #
;###############################################################################

            ;# data section
            .data

;###############################################################################
;#                            LOGGING STRINGS                                  #
;###############################################################################

            ;# SMP module name and messages
KSMPNAME:   .ascii   " [KERNEL SMP] \0"
KSMPMSG:    .ascii   "Detecting CPU cores available in the system...\0"
KSMPID:     .ascii   "Successfully initialized CPU core with LAPIC ID: \0"
