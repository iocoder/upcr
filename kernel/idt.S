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
    pushq    $0x00               # push a dummy error code
    .endif
    pushq    \ExpNbr                    # push exception number
    pushq    %r15                       # push a copy of R15
    pushq    %r14                       # push a copy of R14
    pushq    %r13                       # push a copy of R13
    pushq    %r12                       # push a copy of R12
    pushq    %r11                       # push a copy of R11
    pushq    %r10                       # push a copy of R10
    pushq    %r9                        # push a copy of R9
    pushq    %r8                        # push a copy of R8
    pushq    %rbp                       # push a copy of RBP
    pushq    %rdi                       # push a copy of RDI
    pushq    %rsi                       # push a copy of RSI
    pushq    %rdx                       # push a copy of RDX
    pushq    %rcx                       # push a copy of RCX
    pushq    %rbx                       # push a copy of RBX
    pushq    %rax                       # push a copy of RAX
    subq     $0x50, %rsp                # push padding
    movq     StackFrameCS(%rsp), %rax   # load origin's CS
    andq     $3, %rax                   # test if origin is DPL3
    jnz      1f                         # skip next lines if DPL3
    call     KernelIrqIipi              # DPL0: disable all other CPUs
    movq     %rsp, %rdi                 # DPL0: load stack frame address
    call     KernelPanicHandle          # DPL0: kernel panic
    hlt                                 # DPL0: halt here
    jmp      .                          # DPL0: loop forever
1:  call     KernelIdtExp               # DPL3: handle current task exception
    addq     $0x50, %rsp                # pop padding
    popq     %rax                       # pop a copy of RAX
    popq     %rbx                       # pop a copy of RBX
    popq     %rcx                       # pop a copy of RCX
    popq     %rdx                       # pop a copy of RDX
    popq     %rsi                       # pop a copy of RSI
    popq     %rdi                       # pop a copy of RDI
    popq     %rbp                       # pop a copy of RBP
    popq     %r8                        # pop a copy of R8
    popq     %r9                        # pop a copy of R9
    popq     %r10                       # pop a copy of R10
    popq     %r11                       # pop a copy of R11
    popq     %r12                       # pop a copy of R12
    popq     %r13                       # pop a copy of R13
    popq     %r14                       # pop a copy of R14
    popq     %r15                       # pop a copy of R15
    addq     $8, %rsp                   # pop exception number
    .if      \DummyErr
    addq     $8, %rsp                   # pop dummy error code
    .endif
    iretq                               # return from exception
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
    pushq    $0x00                      # push a dummy error code
    pushq    \IrqNbr                    # push IRQ number
    pushq    %r15                       # push a copy of R15
    pushq    %r14                       # push a copy of R14
    pushq    %r13                       # push a copy of R13
    pushq    %r12                       # push a copy of R12
    pushq    %r11                       # push a copy of R11
    pushq    %r10                       # push a copy of R10
    pushq    %r9                        # push a copy of R9
    pushq    %r8                        # push a copy of R8
    pushq    %rbp                       # push a copy of RBP
    pushq    %rdi                       # push a copy of RDI
    pushq    %rsi                       # push a copy of RSI
    pushq    %rdx                       # push a copy of RDX
    pushq    %rcx                       # push a copy of RCX
    pushq    %rbx                       # push a copy of RBX
    pushq    %rax                       # push a copy of RAX
    subq     $0x50, %rsp                # push padding
    movq     %rsp, %rdi                 # address of register info
    call     KernelIdtIrq               # handle external IRQ
    addq     $0x50, %rsp                # pop padding
    popq     %rax                       # pop a copy of RAX
    popq     %rbx                       # pop a copy of RBX
    popq     %rcx                       # pop a copy of RCX
    popq     %rdx                       # pop a copy of RDX
    popq     %rsi                       # pop a copy of RSI
    popq     %rdi                       # pop a copy of RDI
    popq     %rbp                       # pop a copy of RBP
    popq     %r8                        # pop a copy of R8
    popq     %r9                        # pop a copy of R9
    popq     %r10                       # pop a copy of R10
    popq     %r11                       # pop a copy of R11
    popq     %r12                       # pop a copy of R12
    popq     %r13                       # pop a copy of R13
    popq     %r14                       # pop a copy of R14
    popq     %r15                       # pop a copy of R15
    addq     $8, %rsp                   # pop exception number
    addq     $8, %rsp                   # pop dummy error code
    iretq                               # return from exception
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
    pushq    $0x00                      # push a dummy error code
    pushq    \SvcNbr                    # push call number
    pushq    %r15                       # push a copy of R15
    pushq    %r14                       # push a copy of R14
    pushq    %r13                       # push a copy of R13
    pushq    %r12                       # push a copy of R12
    pushq    %r11                       # push a copy of R11
    pushq    %r10                       # push a copy of R10
    pushq    %r9                        # push a copy of R9
    pushq    %r8                        # push a copy of R8
    pushq    %rbp                       # push a copy of RBP
    pushq    %rdi                       # push a copy of RDI
    pushq    %rsi                       # push a copy of RSI
    pushq    %rdx                       # push a copy of RDX
    pushq    %rcx                       # push a copy of RCX
    pushq    %rbx                       # push a copy of RBX
    pushq    %rax                       # push a copy of RAX
    subq     $0x50, %rsp                # push padding
    movq     %rsp, %rdi                 # address of register info
    call     KernelIdtSvc               # handle service call
    addq     $0x50, %rsp                # pop padding
    popq     %rax                       # pop a copy of RAX
    popq     %rbx                       # pop a copy of RBX
    popq     %rcx                       # pop a copy of RCX
    popq     %rdx                       # pop a copy of RDX
    popq     %rsi                       # pop a copy of RSI
    popq     %rdi                       # pop a copy of RDI
    popq     %rbp                       # pop a copy of RBP
    popq     %r8                        # pop a copy of R8
    popq     %r9                        # pop a copy of R9
    popq     %r10                       # pop a copy of R10
    popq     %r11                       # pop a copy of R11
    popq     %r12                       # pop a copy of R12
    popq     %r13                       # pop a copy of R13
    popq     %r14                       # pop a copy of R14
    popq     %r15                       # pop a copy of R15
    addq     $8, %rsp                   # pop exception number
    addq     $8, %rsp                   # pop dummy error code
    iretq                               # return from exception
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
    mov      $0x0A, %rdi
    mov      $-1, %rsi
    call     KernelLogColour
    leaq     IdtModuleStr(%rip), %rdi
    call     KernelLogString
    mov      $0x0B, %rdi
    mov      $-1, %rsi
    call     KernelLogColour

    # print module info
    leaq     IdtStartStr(%rip), %rdi
    call     KernelLogString
    mov      $'\n', %rdi
    call     KernelLogChar

    # initialize IDT exception entries
    # RDI: Address of first IDT descriptor to fill
    # RCX: Address of the IDT descriptor to stop at
    # RSI: Address of ExpGates
    movq     $IdtTableBase, %rdi
    movq     $IdtTableBase, %rcx
    addq     $(IDT_EXP_START*16), %rdi
    addq     $(IDT_EXP_START*16+IDT_EXP_COUNT*16), %rcx
    leaq     ExpGates(%rip), %rsi

    # store an IDT descriptor using gate address in RAX
1:  movq     %rsi, %rax
    movw     %ax, 0(%rdi)
    shrq     $16, %rax
    movw     $0x20, 2(%rdi)
    movw     $(GATE_INTR|PRESENT|DPL0), 4(%rdi)
    movw     %ax, 6(%rdi)
    shrq     $16, %rax
    movl     %eax, 8(%rdi)
    movl     $0, 12(%rdi)

    # update RAX to next gate address, RDI to next descriptor
    addq     $GATE_SIZE, %rsi
    addq     $16, %rdi

    # done yet?
    cmp      %rdi, %rcx
    jnz      1b

    # initialize IDT IRQ entries
    # RDI: Address of first IDT descriptor to fill
    # RCX: Address of the IDT descriptor to stop at
    # RSI: Address of IrqGates
    movq     $IdtTableBase, %rdi
    movq     $IdtTableBase, %rcx
    addq     $(IDT_IRQ_START*16), %rdi
    addq     $(IDT_IRQ_START*16+IDT_IRQ_COUNT*16), %rcx
    leaq     IrqGates(%rip), %rsi

    # store an IDT descriptor using gate address in RAX
1:  movq     %rsi, %rax
    movw     %ax, 0(%rdi)
    shrq     $16, %rax
    movw     $0x20, 2(%rdi)
    movw     $(GATE_INTR|PRESENT|DPL0), 4(%rdi)
    movw     %ax, 6(%rdi)
    shrq     $16, %rax
    movl     %eax, 8(%rdi)
    movl     $0, 12(%rdi)

    # update RAX to next gate address, RDI to next descriptor
    addq     $GATE_SIZE, %rsi
    addq     $16, %rdi

    # done yet?
    cmp      %rdi, %rcx
    jnz      1b

    # initialize IDT SVC entries
    # RDI: Address of first IDT descriptor to fill
    # RCX: Address of the IDT descriptor to stop at
    # RSI: Address of SvcGates
    movq     $IdtTableBase, %rdi
    movq     $IdtTableBase, %rcx
    addq     $(IDT_SVC_START*16), %rdi
    addq     $(IDT_SVC_START*16+IDT_SVC_COUNT*16), %rcx
    leaq     SvcGates(%rip), %rsi

    # store an IDT descriptor using gate address in RAX
1:  movq     %rsi, %rax
    movw     %ax, 0(%rdi)
    shrq     $16, %rax
    movw     $0x20, 2(%rdi)
    movw     $(GATE_INTR|PRESENT|DPL3), 4(%rdi)
    movw     %ax, 6(%rdi)
    shrq     $16, %rax
    movl     %eax, 8(%rdi)
    movl     $0, 12(%rdi)

    # update RAX to next gate address, RDI to next descriptor
    addq     $GATE_SIZE, %rsi
    addq     $16, %rdi

    # done yet?
    cmp      %rdi, %rcx
    jnz      1b

    # initialize IDTR descriptor
    movw     $(IdtTableSize-1), IdtrDescBase+0
    movl     $(IdtTableBase  ), IdtrDescBase+2

    # load IDT table
    lidt     IdtrDescBase

    # done
3:  xor      %rax, %rax
    ret

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
    # 3. release kernel lock

    # infinte loop
    jmp      .

    # done
1:  xor      %rax, %rax
    ret

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
    # 3. release kernel lock

    # infinte loop
    jmp      .

    # done
1:  xor      %rax, %rax
    ret

###############################################################################
#                              KernelIdtSvc                                   #
###############################################################################

    # declare a linker symbol
    .global  KernelIdtSvc
    .set     KernelIdtSvc, .

    # TODO:
    # -----
    # 1. acquire kernel lock
    # 2. handle system call
    # 3. release kernel lock

    # infinte loop
    jmp      .

    # done
1:  xor      %rax, %rax
    ret

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
