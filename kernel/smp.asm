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
            INCLUDE  "kernel/macro.inc"

;###############################################################################
;#                                GLOBALS                                      #
;###############################################################################

            ;# global symbols
            PUBLIC   KSMPINIT
            PUBLIC   KSMPEN

;###############################################################################
;#                              TEXT SECTION                                   #
;###############################################################################

            ;# text section
            SEGMENT  ".text"

;#-----------------------------------------------------------------------------#
;#                          REAL MODE TRAMPOLINE                               #
;#-----------------------------------------------------------------------------#

KSMP16:     ;# 16-bit code
            CODE16

            ;# first instruction executed by CPU core!!!
            MOV      AX, 0x55AA

            ;# make sure interrupts are disabled
            cli

            ;# initialize segment registers
            XOR      BX, BX
            MOV      DS, BX
            MOV      ES, BX
            MOV      SS, BX

            ;# load GDTR register
            LGDT     [GDTR_ADDR]

            ;# enter protected mode
            MOV      EAX, CR0
            OR       EAX, 1
            MOV      CR0, EAX

            ;# far jump into 32-bit mode
            LJMP     0x10, KSMP32-KSMP16

;#-----------------------------------------------------------------------------#
;#                        PROTECTED MODE TRAMPOLINE                            #
;#-----------------------------------------------------------------------------#

KSMP32:     ;# 32-bit code
            CODE32

            ;# initialize segment registers
            MOV      AX, 0x18
            MOV      DS, AX
            MOV      ES, AX
            MOV      FS, AX
            MOV      GS, AX
            MOV      SS, AX

            ;# enable physical address extension
            MOV      EAX, CR4
            OR       EAX, 0x00000020
            MOV      CR4, EAX

            ;# enable long-mode in EFER
            MOV      ECX, MSR_EFER
            RDMSR
            OR       EAX, 0x00000100
            WRMSR

            ;# load CR3 with PML4 table base
            MOV      EAX, PM4L_ADDR
            MOV      CR3, EAX

            ;# enable paging; this activates long mode
            MOV      EAX, CR0
            OR       EAX, 0x80000000
            MOV      CR0, EAX

            ;# we are in compatibility mode now! jump to code64
            LJMP     0x20, KSMP64-KSMP16

;#-----------------------------------------------------------------------------#
;#                          LONG MODE TRAMPOLINE                               #
;#-----------------------------------------------------------------------------#

KSMP64:     ;# 64-bit code
            CODE64

            ;# initialize segment registers
            MOV      AX, 0x0028
            MOV      DS, AX
            MOV      ES, AX
            MOV      FS, AX
            MOV      GS, AX
            MOV      SS, AX

            ;# initialize all 64-bit GPRs
            MOV      RAX, 0x1111111111111111
            MOV      RBX, 0x2222222222222222
            MOV      RCX, 0x3333333333333333
            MOV      RDX, 0x4444444444444444
            MOV      RSI, 0xAAAAAAAAAAAAAAAA
            MOV      RDI, 0xBBBBBBBBBBBBBBBB
            MOV      RBP, 0xCCCCCCCCCCCCCCCC
            MOV      RSP, 0xDDDDDDDDDDDDDDDD
            MOV      R8,  0x1111111111111111
            MOV      R9,  0x2222222222222222
            MOV      R10, 0x3333333333333333
            MOV      R11, 0x4444444444444444
            MOV      R12, 0xAAAAAAAAAAAAAAAA
            MOV      R13, 0xBBBBBBBBBBBBBBBB
            MOV      R14, 0xCCCCCCCCCCCCCCCC
            MOV      R15, 0xDDDDDDDDDDDDDDDD

            ;# read local APIC ID
            XOR      RAX, RAX
            MOV      EAX, [0xFEE00020]
            SHR      EAX, 24

            ;# use this particular CPU stack
            MOV      RSP, RAX
            SHL      RSP, 12
            ADD      RSP, STACK_ADDR
            ADD      RSP, 0x1000
            MOV      RBP, RSP
            NOP

            ;# initialize IDT
            LIDT     [IDTR_ADDR]

            ;# jump to KSMPEN
            MOV      RAX, [SmpFunAddress-KSMP16]
            CALL     RAX

            ;# LOOP forever
            JMP      .

            ;# alignment for data
            ALIGN    8

            ;# SmpFunAddress
            EQU      SmpFunAddress, .
            DQ       0

;#-----------------------------------------------------------------------------#
;#                              KSMPINIT()                                     #
;#-----------------------------------------------------------------------------#

KSMPINIT:   ;# print init msg
            LEA      RDI, [RIP+KSMPNAME]
            CALL     KLOGMOD
            LEA      RDI, [RIP+KSMPMSG]
            CALL     KLOGSTR
            MOV      RDI, '\n'
            CALL     KLOGCHR

            ;# store the address of KSMPEN() to be fetched by trampoline
            LEA      RAX, [RIP+KSMPEN]
            MOV      [RIP+SmpFunAddress], RAX

            ;# copy the trampoline to lower memory
            MOV      RDI, TRUMP_ADDR
            LEA      RSI, [RIP+KSMP16]
            LEA      RCX, [RIP+KSMPINIT]
            SUB      RCX, RSI

            ;# copy LOOP
1:          MOV      AL, [RSI]
            MOV      [RDI], AL
            INC      RSI
            INC      RDI
            LOOP     1b

            ;# first we need to initialize core 0
            CALL     KSMPEN

            ;# send INIT-SIPI-SIPI sequence to other CPUs
            CALL     KIRQIIPI
            CALL     KIRQSIPI
            CALL     KIRQSIPI

            ;# done
            XOR      RAX, RAX
            RET

;#-----------------------------------------------------------------------------#
;#                               KSMPEN()                                      #
;#-----------------------------------------------------------------------------#

;# TODO: move lock instructions to IDT

KSMPEN:     ;# acquire kernel lock to avoid race conditions with other CPUS
            CALL     KLOCPEND

            ;# initialize LAPIC AND enable IRQs
            CALL     KIRQEN

            ;# print module name
            LEA      RDI, [RIP+KSMPNAME]
            CALL     KLOGMOD

            ;# print lapic detection string
            LEA      RDI, [RIP+KSMPID]
            CALL     KLOGSTR

            ;# print LAPIC ID
            XOR      RAX, RAX
            MOV      EAX, [0xFEE00020]
            SHR      EAX, 24
            MOV      RDI, RAX
            CALL     KLOGDEC

            ;# print new line
            MOV      RDI, '\n'
            CALL     KLOGCHR

            ;# release the lock
            PUSH     RDI
            CALL     KLOCPOST
            POP      RDI

            ;# done
            XOR      RAX, RAX
            RET

;###############################################################################
;#                              DATA SECTION                                   #
;###############################################################################

            ;# data section
            SEGMENT  ".data"

;#-----------------------------------------------------------------------------#
;#                            LOGGING STRINGS                                  #
;#-----------------------------------------------------------------------------#

            ;# SMP module name and messages
KSMPNAME:   DB       "KERNEL SMP\0"
KSMPMSG:    DB       "Detecting CPU cores available in the system...\0"
KSMPID:     DB       "Successfully initialized CPU core with LAPIC ID: \0"
