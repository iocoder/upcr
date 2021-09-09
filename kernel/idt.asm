;###############################################################################
;# File name:    idt.S
;# Description:  Kernel interrupt descriptor table
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
            PUBLIC   KIDTINIT

;###############################################################################
;#                                 MACROS                                      #
;###############################################################################

            ;# dpl levels
            EQU      DPL0,       0x0000
            EQU      DPL1,       0x2000
            EQU      DPL2,       0x4000
            EQU      DPL3,       0x6000

            ;# gate types
            EQU      GATE_CALL,  0x0C00    ;# not even in IDT
            EQU      GATE_INTR,  0x0E00    ;# disables interrupts
            EQU      GATE_TRAP,  0x0F00    ;# doesn't disable interrupts

            ;# present field
            EQU      PRESENT,    0x8000

            ;# gate size
            EQU      GATE_SIZE,  256

            ;# IDT sections
            EQU      IDT_EXP_START, 0x00
            EQU      IDT_EXP_COUNT, 0x20
            EQU      IDT_IRQ_START, 0x40
            EQU      IDT_IRQ_COUNT, 0x10
            EQU      IDT_SVC_START, 0x80
            EQU      IDT_SVC_COUNT, 0x01

;###############################################################################
;#                              TEXT SECTION                                   #
;###############################################################################

            ;# text section
            SEGMENT  ".text"

;#-----------------------------------------------------------------------------#
;#                            EXCEPTION GATES                                  #
;#-----------------------------------------------------------------------------#

            ;# macro to push a dummy error code if needed
            MACRO    PUSHE   DummyErr
            IF       \DummyErr
            PUSH     $0x00                      
            ENDIF
            ENDM

            ;# macro to pop a dummy error code if needed
            MACRO    POPE   DummyErr
            IF       \DummyErr
            ADD      $8, %rsp
            ENDIF
            ENDM

            ;# macro to halt the kernel in case of DPL error
            MACRO    CHKDPL   CheckDPL
            IF       \CheckDPL
            MOV      SFRAME_CS(%rsp), %rax      ;# load origin's CS
            AND      $3, %rax                   ;# test if origin is DPL3
            JNZ      1f                         ;# skip next lines if DPL3
            CALL     KIRQIIPI                   ;# DPL0: disable all other CPUs
            MOV      %rsp, %rdi                 ;# DPL0: load stack frame address
            CALL     KERRPANIC                  ;# DPL0: kernel panic
            HLT                                 ;# DPL0: halt here
            JMP      .                          ;# DPL0: LOOP forever
1:          NOP
            ENDIF
            ENDM

            ;# template macro for all IDT gates
            MACRO    GATE  Handler, ExpNbr, DummyErr, CheckDPL
            ALIGN    GATE_SIZE
            PUSHE    \DummyErr                  ;# PUSH dummy error if needed
            PUSH     \ExpNbr                    ;# PUSH exception number
            PUSH     %r15                       ;# PUSH a copy of R15
            PUSH     %r14                       ;# PUSH a copy of R14
            PUSH     %r13                       ;# PUSH a copy of R13
            PUSH     %r12                       ;# PUSH a copy of R12
            PUSH     %r11                       ;# PUSH a copy of R11
            PUSH     %r10                       ;# PUSH a copy of R10
            PUSH     %r9                        ;# PUSH a copy of R9
            PUSH     %r8                        ;# PUSH a copy of R8
            PUSH     %rbp                       ;# PUSH a copy of RBP
            PUSH     %rdi                       ;# PUSH a copy of RDI
            PUSH     %rsi                       ;# PUSH a copy of RSI
            PUSH     %rdx                       ;# PUSH a copy of RDX
            PUSH     %rcx                       ;# PUSH a copy of RCX
            PUSH     %rbx                       ;# PUSH a copy of RBX
            PUSH     %rax                       ;# PUSH a copy of RAX
            SUB      $0x50, %rsp                ;# PUSH padding
            CHKDPL   \CheckDPL                  ;# CHECK DPL if needed
            CALL     \Handler                   ;# HANDLE interrupt
            ADD      $0x50, %rsp                ;# POP padding
            POP      %rax                       ;# POP a copy of RAX
            POP      %rbx                       ;# POP a copy of RBX
            POP      %rcx                       ;# POP a copy of RCX
            POP      %rdx                       ;# POP a copy of RDX
            POP      %rsi                       ;# POP a copy of RSI
            POP      %rdi                       ;# POP a copy of RDI
            POP      %rbp                       ;# POP a copy of RBP
            POP      %r8                        ;# POP a copy of R8
            POP      %r9                        ;# POP a copy of R9
            POP      %r10                       ;# POP a copy of R10
            POP      %r11                       ;# POP a copy of R11
            POP      %r12                       ;# POP a copy of R12
            POP      %r13                       ;# POP a copy of R13
            POP      %r14                       ;# POP a copy of R14
            POP      %r15                       ;# POP a copy of R15
            ADD      $8, %rsp                   ;# POP exception number
            POPE     \DummyErr                  ;# POP dummy error if needed
            IRETQ                               ;# return from exception
            ALIGN    GATE_SIZE
            ENDM

;#-----------------------------------------------------------------------------#
;#                               IDT GATES                                     #
;#-----------------------------------------------------------------------------#

            ;# align to 256-byte border
            ALIGN    GATE_SIZE

ExpGates:   ;# 32 exception gates for 32 exceptions
            GATE     KIDTEXP, $0x00, 1, 1
            GATE     KIDTEXP, $0x01, 1, 1
            GATE     KIDTEXP, $0x02, 1, 1
            GATE     KIDTEXP, $0x03, 1, 1
            GATE     KIDTEXP, $0x04, 1, 1
            GATE     KIDTEXP, $0x05, 1, 1
            GATE     KIDTEXP, $0x06, 1, 1
            GATE     KIDTEXP, $0x07, 1, 1
            GATE     KIDTEXP, $0x08, 0, 1
            GATE     KIDTEXP, $0x09, 0, 1
            GATE     KIDTEXP, $0x0A, 0, 1
            GATE     KIDTEXP, $0x0B, 0, 1
            GATE     KIDTEXP, $0x0C, 0, 1
            GATE     KIDTEXP, $0x0D, 0, 1
            GATE     KIDTEXP, $0x0E, 0, 1
            GATE     KIDTEXP, $0x0F, 0, 1
            GATE     KIDTEXP, $0x10, 1, 1
            GATE     KIDTEXP, $0x11, 0, 1
            GATE     KIDTEXP, $0x12, 1, 1
            GATE     KIDTEXP, $0x13, 1, 1
            GATE     KIDTEXP, $0x14, 0, 1
            GATE     KIDTEXP, $0x15, 0, 1
            GATE     KIDTEXP, $0x16, 0, 1
            GATE     KIDTEXP, $0x17, 0, 1
            GATE     KIDTEXP, $0x18, 0, 1
            GATE     KIDTEXP, $0x19, 0, 1
            GATE     KIDTEXP, $0x1A, 0, 1
            GATE     KIDTEXP, $0x1B, 0, 1
            GATE     KIDTEXP, $0x1C, 0, 1
            GATE     KIDTEXP, $0x1D, 0, 1
            GATE     KIDTEXP, $0x1E, 0, 1
            GATE     KIDTEXP, $0x1F, 0, 1

IrqGates:   ;# 16 IRQ gates for 16 IRQs
            GATE     KIDTIRQ, $0x00, 1, 0
            GATE     KIDTIRQ, $0x01, 1, 0
            GATE     KIDTIRQ, $0x02, 1, 0
            GATE     KIDTIRQ, $0x03, 1, 0
            GATE     KIDTIRQ, $0x04, 1, 0
            GATE     KIDTIRQ, $0x05, 1, 0
            GATE     KIDTIRQ, $0x06, 1, 0
            GATE     KIDTIRQ, $0x07, 1, 0
            GATE     KIDTIRQ, $0x08, 1, 0
            GATE     KIDTIRQ, $0x09, 1, 0
            GATE     KIDTIRQ, $0x0A, 1, 0
            GATE     KIDTIRQ, $0x0B, 1, 0
            GATE     KIDTIRQ, $0x0C, 1, 0
            GATE     KIDTIRQ, $0x0D, 1, 0
            GATE     KIDTIRQ, $0x0E, 1, 0
            GATE     KIDTIRQ, $0x0F, 1, 0

SvcGates:   ;# 1 SVC gate for 1 SVC
            GATE     KIDTSVC, $0x00, 1, 0

;#-----------------------------------------------------------------------------#
;#                                KIDTINIT()                                   #
;#-----------------------------------------------------------------------------#

KIDTINIT:   ;# print heading of line
            MOV      $0x0A, %rdi
            MOV      $-1, %rsi
            CALL     KLOGATT
            LEA      KIDTNAME(%rip), %rdi
            CALL     KLOGSTR
            MOV      $0x0B, %rdi
            MOV      $-1, %rsi
            CALL     KLOGATT

            ;# print module info
            LEA      KIDTMSG(%rip), %rdi
            CALL     KLOGSTR
            MOV      $'\n', %rdi
            CALL     KLOGCHR

            ;# initialize IDT exception entries
            ;# RDI: Address of first IDT descriptor to fill
            ;# RCX: Address of the IDT descriptor to stop at
            ;# RSI: Address of ExpGates
            MOV      $IDT_ADDR, %rdi
            MOV      $IDT_ADDR, %rcx
            ADD      $(IDT_EXP_START*16), %rdi
            ADD      $(IDT_EXP_START*16+IDT_EXP_COUNT*16), %rcx
            LEA      ExpGates(%rip), %rsi

            ;# store an IDT descriptor using gate address in RAX
1:          MOV      %rsi, %rax
            MOV      %ax, 0(%rdi)
            MOV      $0x20, %ax
            MOV      %ax, 2(%rdi)
            MOV      $(GATE_INTR|PRESENT|DPL0), %ax
            MOV      %ax, 4(%rdi)
            SHR      $16, %rax
            MOV      %ax, 6(%rdi)
            SHR      $16, %rax
            MOV      %eax, 8(%rdi)
            MOV      $0, %eax
            MOV      %eax, 12(%rdi)

            ;# update RAX to next gate address, RDI to next descriptor
            ADD      $GATE_SIZE, %rsi
            ADD      $16, %rdi

            ;# done yet?
            CMP      %rdi, %rcx
            JNZ      1b

            ;# initialize IDT IRQ entries
            ;# RDI: Address of first IDT descriptor to fill
            ;# RCX: Address of the IDT descriptor to stop at
            ;# RSI: Address of IrqGates
            MOV      $IDT_ADDR, %rdi
            MOV      $IDT_ADDR, %rcx
            ADD      $(IDT_IRQ_START*16), %rdi
            ADD      $(IDT_IRQ_START*16+IDT_IRQ_COUNT*16), %rcx
            LEA      IrqGates(%rip), %rsi

            ;# store an IDT descriptor using gate address in RAX
1:          MOV      %rsi, %rax
            MOV      %ax, 0(%rdi)
            MOV      $0x20, %ax
            MOV      %ax, 2(%rdi)
            MOV      $(GATE_INTR|PRESENT|DPL0), %ax
            MOV      %ax, 4(%rdi)
            SHR      $16, %rax
            MOV      %ax, 6(%rdi)
            SHR      $16, %rax
            MOV      %eax, 8(%rdi)
            MOV      $0, %eax
            MOV      %eax, 12(%rdi)

            ;# update RAX to next gate address, RDI to next descriptor
            ADD      $GATE_SIZE, %rsi
            ADD      $16, %rdi

            ;# done yet?
            CMP      %rdi, %rcx
            JNZ      1b

            ;# initialize IDT SVC entries
            ;# RDI: Address of first IDT descriptor to fill
            ;# RCX: Address of the IDT descriptor to stop at
            ;# RSI: Address of SvcGates
            MOV      $IDT_ADDR, %rdi
            MOV      $IDT_ADDR, %rcx
            ADD      $(IDT_SVC_START*16), %rdi
            ADD      $(IDT_SVC_START*16+IDT_SVC_COUNT*16), %rcx
            LEA      SvcGates(%rip), %rsi

            ;# store an IDT descriptor using gate address in RAX
1:          MOV      %rsi, %rax
            MOV      %ax, 0(%rdi)
            MOV      $0x20, %ax
            MOV      %ax, 2(%rdi)
            MOV      $(GATE_INTR|PRESENT|DPL3), %ax
            MOV      %ax, 4(%rdi)
            SHR      $16, %rax
            MOV      %ax, 6(%rdi)
            SHR      $16, %rax
            MOV      %eax, 8(%rdi)
            MOV      $0, %eax
            MOV      %eax, 12(%rdi)

            ;# update RAX to next gate address, RDI to next descriptor
            ADD      $GATE_SIZE, %rsi
            ADD      $16, %rdi

            ;# done yet?
            CMP      %rdi, %rcx
            JNZ      1b

            ;# initialize IDTR descriptor
            MOV      $0xFFF, %ax
            MOV      %ax, IDTR_ADDR+0
            MOV      $IDT_ADDR, %eax 
            MOV      %eax, IDTR_ADDR+2

            ;# load IDT table
            LIDT     IDTR_ADDR

            ;# done
3:          XOR      %rax, %rax
            RET

;#-----------------------------------------------------------------------------#
;#                              KIDTEXP()                                      #
;#-----------------------------------------------------------------------------#

KIDTEXP:    ;# TODO:
            ;# -----
            ;# 1. acquire kernel lock
            ;# 2. handle exception by terminating the bad task
            ;# 3. reLEAse kernel lock

            ;# infinte LOOP
            JMP      .

            ;# done
            XOR      %rax, %rax
            RET

;#-----------------------------------------------------------------------------#
;#                               KIDTIRQ()                                     #
;#-----------------------------------------------------------------------------#

KIDTIRQ:    ;# TODO:
            ;# -----
            ;# 1. acquire kernel lock
            ;# 2. handle irq
            ;# 3. reLEAse kernel lock

            ;# infinte LOOP
            JMP      .

            ;# done
            XOR      %rax, %rax
            RET

;#-----------------------------------------------------------------------------#
;#                               KIDTSVC()                                     #
;#-----------------------------------------------------------------------------#

KIDTSVC:    ;# TODO:
            ;# -----
            ;# 1. acquire kernel lock
            ;# 2. handle system CALL
            ;# 3. reLEAse kernel lock

            ;# infinte LOOP
            JMP      .

            ;# done
            XOR      %rax, %rax
            RET

;#-----------------------------------------------------------------------------#
;#                               KIDTIPI()                                     #
;#-----------------------------------------------------------------------------#

KIDTIPI:    ;# TODO:
            ;# -----
            ;# 1. acquire kernel lock
            ;# 2. handle inter-process interrupt
            ;# 3. reLEAse kernel lock

            ;# infinte LOOP
            JMP      .

            ;# done
            XOR      %rax, %rax
            RET

;###############################################################################
;#                              DATA SECTION                                   #
;###############################################################################

            ;# data section
            SEGMENT  ".data"

;#-----------------------------------------------------------------------------#
;#                            LOGGING STRINGS                                  #
;#-----------------------------------------------------------------------------#

            ;# IDT heading and ascii strings
KIDTNAME:   DB       " [KERNEL IDT] \0"
KIDTMSG:    DB       "Initializing IDT module...\0"
