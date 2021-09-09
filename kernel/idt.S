###############################################################################
# File name:    idt.S
# Description:  Kernel interrupt descriptor table
# Author:       Ramses A.
###############################################################################
#
# UPCR Operating System for x86_64 architecture
# Copyright (c) 2021 Ramses A.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software AND associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, AND/or sell
# copies of the Software, AND to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice AND this permission notice shall be included in all
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
#                                 MACROS                                      #
###############################################################################

    # dpl levels
    .equ     DPL0,       0x0000
    .equ     DPL1,       0x2000
    .equ     DPL2,       0x4000
    .equ     DPL3,       0x6000

    # gate types
    .equ     GATE_CALL,  0x0C00    # not even in IDT
    .equ     GATE_INTR,  0x0E00    # disables interrupts
    .equ     GATE_TRAP,  0x0F00    # doesn't disable interrupts

    # present field
    .equ     PRESENT,    0x8000

    # gate size
    .equ     GATE_SIZE,  256

    # IDT sections
    .equ     IDT_EXP_START, 0x00
    .equ     IDT_EXP_COUNT, 0x20
    .equ     IDT_IRQ_START, 0x40
    .equ     IDT_IRQ_COUNT, 0x10
    .equ     IDT_SVC_START, 0x80
    .equ     IDT_SVC_COUNT, 0x01

###############################################################################
#                              TEXT SECTION                                   #
###############################################################################

    # text section
    .text

###############################################################################
#                            EXCEPTION GATES                                  #
###############################################################################

    # template macro for all exception gates
    .macro   ExpGate  ExpNbr, DummyErr
    .align   GATE_SIZE
    .if      \DummyErr
    PUSH     $0x00               # PUSH a dummy error code
    .endif
    PUSH     \ExpNbr                    # PUSH exception number
    PUSH     %r15                       # PUSH a copy of R15
    PUSH     %r14                       # PUSH a copy of R14
    PUSH     %r13                       # PUSH a copy of R13
    PUSH     %r12                       # PUSH a copy of R12
    PUSH     %r11                       # PUSH a copy of R11
    PUSH     %r10                       # PUSH a copy of R10
    PUSH     %r9                        # PUSH a copy of R9
    PUSH     %r8                        # PUSH a copy of R8
    PUSH     %rbp                       # PUSH a copy of RBP
    PUSH     %rdi                       # PUSH a copy of RDI
    PUSH     %rsi                       # PUSH a copy of RSI
    PUSH     %rdx                       # PUSH a copy of RDX
    PUSH     %rcx                       # PUSH a copy of RCX
    PUSH     %rbx                       # PUSH a copy of RBX
    PUSH     %rax                       # PUSH a copy of RAX
    SUB      $0x50, %rsp                # PUSH padding
    MOV      StackFrameCS(%rsp), %rax   # load origin's CS
    AND      $3, %rax                   # test if origin is DPL3
    JNZ      1f                         # skip next lines if DPL3
    CALL     KernelIrqIipi              # DPL0: disable all other CPUs
    MOV      %rsp, %rdi                 # DPL0: load stack frame address
    CALL     KernelPanicHandle          # DPL0: kernel panic
    HLT                                 # DPL0: halt here
    JMP      .                          # DPL0: LOOP forever
1:  CALL     KernelIdtExp               # DPL3: handle current task exception
    ADD      $0x50, %rsp                # POP padding
    POP      %rax                       # POP a copy of RAX
    POP      %rbx                       # POP a copy of RBX
    POP      %rcx                       # POP a copy of RCX
    POP      %rdx                       # POP a copy of RDX
    POP      %rsi                       # POP a copy of RSI
    POP      %rdi                       # POP a copy of RDI
    POP      %rbp                       # POP a copy of RBP
    POP      %r8                        # POP a copy of R8
    POP      %r9                        # POP a copy of R9
    POP      %r10                       # POP a copy of R10
    POP      %r11                       # POP a copy of R11
    POP      %r12                       # POP a copy of R12
    POP      %r13                       # POP a copy of R13
    POP      %r14                       # POP a copy of R14
    POP      %r15                       # POP a copy of R15
    ADD      $8, %rsp                   # POP exception number
    .if      \DummyErr
    ADD      $8, %rsp                   # POP dummy error code
    .endif
    iRETq                               # RETurn from exception
    .align   GATE_SIZE
    .endm

    # symbol defining the start of exception gates
    .align   GATE_SIZE
    .set     ExpGates, .

    # 32 exception gates for 32 exceptions
    ExpGate  $0x00, 1
    ExpGate  $0x01, 1
    ExpGate  $0x02, 1
    ExpGate  $0x03, 1
    ExpGate  $0x04, 1
    ExpGate  $0x05, 1
    ExpGate  $0x06, 1
    ExpGate  $0x07, 1
    ExpGate  $0x08, 0
    ExpGate  $0x09, 0
    ExpGate  $0x0A, 0
    ExpGate  $0x0B, 0
    ExpGate  $0x0C, 0
    ExpGate  $0x0D, 0
    ExpGate  $0x0E, 0
    ExpGate  $0x0F, 0
    ExpGate  $0x10, 1
    ExpGate  $0x11, 0
    ExpGate  $0x12, 1
    ExpGate  $0x13, 1
    ExpGate  $0x14, 0
    ExpGate  $0x15, 0
    ExpGate  $0x16, 0
    ExpGate  $0x17, 0
    ExpGate  $0x18, 0
    ExpGate  $0x19, 0
    ExpGate  $0x1A, 0
    ExpGate  $0x1B, 0
    ExpGate  $0x1C, 0
    ExpGate  $0x1D, 0
    ExpGate  $0x1E, 0
    ExpGate  $0x1F, 0

###############################################################################
#                               IRQ GATES                                     #
###############################################################################

    # template macro for all IRQ gates
    .macro   IrqGate  IrqNbr
    .align   GATE_SIZE
    PUSH     $0x00                      # PUSH a dummy error code
    PUSH     \IrqNbr                    # PUSH IRQ number
    PUSH     %r15                       # PUSH a copy of R15
    PUSH     %r14                       # PUSH a copy of R14
    PUSH     %r13                       # PUSH a copy of R13
    PUSH     %r12                       # PUSH a copy of R12
    PUSH     %r11                       # PUSH a copy of R11
    PUSH     %r10                       # PUSH a copy of R10
    PUSH     %r9                        # PUSH a copy of R9
    PUSH     %r8                        # PUSH a copy of R8
    PUSH     %rbp                       # PUSH a copy of RBP
    PUSH     %rdi                       # PUSH a copy of RDI
    PUSH     %rsi                       # PUSH a copy of RSI
    PUSH     %rdx                       # PUSH a copy of RDX
    PUSH     %rcx                       # PUSH a copy of RCX
    PUSH     %rbx                       # PUSH a copy of RBX
    PUSH     %rax                       # PUSH a copy of RAX
    SUB      $0x50, %rsp                # PUSH padding
    MOV      %rsp, %rdi                 # address of register info
    CALL     KernelIdtIrq               # handle external IRQ
    ADD      $0x50, %rsp                # POP padding
    POP      %rax                       # POP a copy of RAX
    POP      %rbx                       # POP a copy of RBX
    POP      %rcx                       # POP a copy of RCX
    POP      %rdx                       # POP a copy of RDX
    POP      %rsi                       # POP a copy of RSI
    POP      %rdi                       # POP a copy of RDI
    POP      %rbp                       # POP a copy of RBP
    POP      %r8                        # POP a copy of R8
    POP      %r9                        # POP a copy of R9
    POP      %r10                       # POP a copy of R10
    POP      %r11                       # POP a copy of R11
    POP      %r12                       # POP a copy of R12
    POP      %r13                       # POP a copy of R13
    POP      %r14                       # POP a copy of R14
    POP      %r15                       # POP a copy of R15
    ADD      $8, %rsp                   # POP exception number
    ADD      $8, %rsp                   # POP dummy error code
    IRET                                # RETurn from exception
    .align   GATE_SIZE
    .endm

    # symbol defining the beginning of IRQ gates
    .align   GATE_SIZE
    .set     IrqGates, .

    # 16 IRQ gates for 16 IRQs
    IrqGate  $0x00
    IrqGate  $0x01
    IrqGate  $0x02
    IrqGate  $0x03
    IrqGate  $0x04
    IrqGate  $0x05
    IrqGate  $0x06
    IrqGate  $0x07
    IrqGate  $0x08
    IrqGate  $0x09
    IrqGate  $0x0A
    IrqGate  $0x0B
    IrqGate  $0x0C
    IrqGate  $0x0D
    IrqGate  $0x0E
    IrqGate  $0x0F

###############################################################################
#                             SERVICE GATES                                   #
###############################################################################

    # template macro for all SVC gates
    .macro   SvcGate  SvcNbr
    .align   GATE_SIZE
    PUSH     $0x00                      # PUSH a dummy error code
    PUSH     \SvcNbr                    # PUSH CALL number
    PUSH     %r15                       # PUSH a copy of R15
    PUSH     %r14                       # PUSH a copy of R14
    PUSH     %r13                       # PUSH a copy of R13
    PUSH     %r12                       # PUSH a copy of R12
    PUSH     %r11                       # PUSH a copy of R11
    PUSH     %r10                       # PUSH a copy of R10
    PUSH     %r9                        # PUSH a copy of R9
    PUSH     %r8                        # PUSH a copy of R8
    PUSH     %rbp                       # PUSH a copy of RBP
    PUSH     %rdi                       # PUSH a copy of RDI
    PUSH     %rsi                       # PUSH a copy of RSI
    PUSH     %rdx                       # PUSH a copy of RDX
    PUSH     %rcx                       # PUSH a copy of RCX
    PUSH     %rbx                       # PUSH a copy of RBX
    PUSH     %rax                       # PUSH a copy of RAX
    SUB      $0x50, %rsp                # PUSH padding
    MOV      %rsp, %rdi                 # address of register info
    CALL     KernelIdtSvc               # handle service CALL
    ADD      $0x50, %rsp                # POP padding
    POP      %rax                       # POP a copy of RAX
    POP      %rbx                       # POP a copy of RBX
    POP      %rcx                       # POP a copy of RCX
    POP      %rdx                       # POP a copy of RDX
    POP      %rsi                       # POP a copy of RSI
    POP      %rdi                       # POP a copy of RDI
    POP      %rbp                       # POP a copy of RBP
    POP      %r8                        # POP a copy of R8
    POP      %r9                        # POP a copy of R9
    POP      %r10                       # POP a copy of R10
    POP      %r11                       # POP a copy of R11
    POP      %r12                       # POP a copy of R12
    POP      %r13                       # POP a copy of R13
    POP      %r14                       # POP a copy of R14
    POP      %r15                       # POP a copy of R15
    ADD      $8, %rsp                   # POP exception number
    ADD      $8, %rsp                   # POP dummy error code
    IRET                                # RETurn from exception
    .align   GATE_SIZE
    .endm

    # symbol defining the beginning of SVC gates
    .align   GATE_SIZE
    .set     SvcGates, .

    # 1 SVC gate for 1 SVC
    SvcGate  $0x00

###############################################################################
#                              KernelIdtInit()                                #
###############################################################################

    # declare a linker symbol
    .global  KernelIdtInit
    .set     KernelIdtInit, .

    # print heading of line
    MOV      $0x0A, %rdi
    MOV      $-1, %rsi
    CALL     KernelLogColour
    LEA      IdtModuleStr(%rip), %rdi
    CALL     KernelLogString
    MOV      $0x0B, %rdi
    MOV      $-1, %rsi
    CALL     KernelLogColour

    # print module info
    LEA      IdtStartStr(%rip), %rdi
    CALL     KernelLogString
    MOV      $'\n', %rdi
    CALL     KernelLogChar

    # initialize IDT exception entries
    # RDI: Address of first IDT descriptor to fill
    # RCX: Address of the IDT descriptor to stop at
    # RSI: Address of ExpGates
    MOV      $IdtTableBase, %rdi
    MOV      $IdtTableBase, %rcx
    ADD      $(IDT_EXP_START*16), %rdi
    ADD      $(IDT_EXP_START*16+IDT_EXP_COUNT*16), %rcx
    LEA      ExpGates(%rip), %rsi

    # store an IDT descriptor using gate address in RAX
1:  MOV      %rsi, %rax
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

    # update RAX to next gate address, RDI to next descriptor
    ADD      $GATE_SIZE, %rsi
    ADD      $16, %rdi

    # done yet?
    CMP      %rdi, %rcx
    JNZ      1b

    # initialize IDT IRQ entries
    # RDI: Address of first IDT descriptor to fill
    # RCX: Address of the IDT descriptor to stop at
    # RSI: Address of IrqGates
    MOV      $IdtTableBase, %rdi
    MOV      $IdtTableBase, %rcx
    ADD      $(IDT_IRQ_START*16), %rdi
    ADD      $(IDT_IRQ_START*16+IDT_IRQ_COUNT*16), %rcx
    LEA      IrqGates(%rip), %rsi

    # store an IDT descriptor using gate address in RAX
1:  MOV      %rsi, %rax
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

    # update RAX to next gate address, RDI to next descriptor
    ADD      $GATE_SIZE, %rsi
    ADD      $16, %rdi

    # done yet?
    CMP      %rdi, %rcx
    JNZ      1b

    # initialize IDT SVC entries
    # RDI: Address of first IDT descriptor to fill
    # RCX: Address of the IDT descriptor to stop at
    # RSI: Address of SvcGates
    MOV      $IdtTableBase, %rdi
    MOV      $IdtTableBase, %rcx
    ADD      $(IDT_SVC_START*16), %rdi
    ADD      $(IDT_SVC_START*16+IDT_SVC_COUNT*16), %rcx
    LEA      SvcGates(%rip), %rsi

    # store an IDT descriptor using gate address in RAX
1:  MOV      %rsi, %rax
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

    # update RAX to next gate address, RDI to next descriptor
    ADD      $GATE_SIZE, %rsi
    ADD      $16, %rdi

    # done yet?
    CMP      %rdi, %rcx
    JNZ      1b

    # initialize IDTR descriptor
    MOV      $(IdtTableSize-1), IdtrDescBase+0
    MOV      $(IdtTableBase  ), IdtrDescBase+2

    # load IDT table
    LIDT     IdtrDescBase

    # done
3:  XOR      %rax, %rax
    RET

###############################################################################
#                              KernelIdtExp                                   #
###############################################################################

    # declare a linker symbol
    .global  KernelIdtExp
    .set     KernelIdtExp, .

    # TODO:
    # -----
    # 1. acquire kernel lock
    # 2. handle exception by terminating the bad task
    # 3. reLEAse kernel lock

    # infinte LOOP
    JMP      .

    # done
1:  XOR      %rax, %rax
    RET

###############################################################################
#                              KernelIdtIrq                                   #
###############################################################################

    # declare a linker symbol
    .global  KernelIdtIrq
    .set     KernelIdtIrq, .

    # TODO:
    # -----
    # 1. acquire kernel lock
    # 2. handle irq
    # 3. reLEAse kernel lock

    # infinte LOOP
    JMP      .

    # done
1:  XOR      %rax, %rax
    RET

###############################################################################
#                              KernelIdtSvc                                   #
###############################################################################

    # declare a linker symbol
    .global  KernelIdtSvc
    .set     KernelIdtSvc, .

    # TODO:
    # -----
    # 1. acquire kernel lock
    # 2. handle system CALL
    # 3. reLEAse kernel lock

    # infinte LOOP
    JMP      .

    # done
1:  XOR      %rax, %rax
    RET

###############################################################################
#                              DATA SECTION                                   #
###############################################################################

    # data section
    .data

###############################################################################
#                            LOGGING STRINGS                                  #
###############################################################################

    # IDT heading
    .set     IdtModuleStr, .
    .string  " [KERNEL IDT] "

    # IDT start ascii string
    .set     IdtStartStr, .
    .string  "Initializing IDT module..."
