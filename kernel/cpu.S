###############################################################################
# File name:    cpu.S
# Description:  Kernel cpu initialization code
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
#                          REAL MODE TRAMPOLINE                               #
###############################################################################

    # start of trampoline
    .set     TrampolineStart, .

    # 16-bit code
    .code16

    # first instruction executed by CPU core!!!
    mov      $0x55AA, %ax

    # make sure interrupts are disabled
    cli

    # initialize segment registers
    ljmp     $0x0000, $(1f-TrampolineStart)
1:  xor      %bx, %bx
    mov      %bx, %ds
    mov      %bx, %es
    mov      %bx, %ss

    # initialize GPRs
    mov      $0x11111111, %eax
    mov      $0x22222222, %ebx
    mov      $0x33333333, %ecx
    mov      $0x44444444, %edx
    mov      $0xAAAAAAAA, %esi
    mov      $0xBBBBBBBB, %edi
    mov      $0xCCCCCCCC, %ebp
    mov      $0xDDDDDDDD, %esp

    # load GDTR register
    lgdt     GdtrDesc-TrampolineStart

    # enter protected mode
    mov      %cr0, %eax
    orl      $1, %eax
    mov      %eax, %cr0

    # jump into 32-bit mode
    ljmp     $0x10, $(2f-TrampolineStart)

    # 32-bit code
    .code32

    # initialize segment registers
2:  mov      $0x18, %ax
    mov      %ax, %ds
    mov      %ax, %es
    mov      %ax, %fs
    mov      %ax, %gs
    mov      %ax, %ss

    # enable physical address extension
    mov      %cr4, %eax
    orl      $0x00000020, %eax
    mov      %eax, %cr4

    # enable long-mode in EFER
    mov      $EferMsr, %ecx
    rdmsr
    orl      $0x00000100, %eax
    wrmsr

    # load CR3 with PML4 table base
    mov      PML4TableAddress-TrampolineStart, %eax
    mov      %eax, %cr3

    # enable paging; this activates long mode
    mov      %cr0, %eax
    orl      $0x80000000, %eax
    mov      %eax, %cr0

    # we are in compatibility mode now! jump to code64
    ljmp     $0x0020, $(3f-TrampolineStart)

    # 64-bit code
    .code64

    # initialize segment registers
3:  mov      $0x0028, %ax
    mov      %ax, %ds
    mov      %ax, %es
    mov      %ax, %fs
    mov      %ax, %gs
    mov      %ax, %ss

    # initialize all 64-bit GPRs
    mov      $0x1111111111111111, %rax
    mov      $0x2222222222222222, %rbx
    mov      $0x3333333333333333, %rcx
    mov      $0x4444444444444444, %rdx
    mov      $0xAAAAAAAAAAAAAAAA, %rsi
    mov      $0xBBBBBBBBBBBBBBBB, %rdi
    mov      $0xCCCCCCCCCCCCCCCC, %rbp
    mov      $0xDDDDDDDDDDDDDDDD, %rsp
    mov      $0x1111111111111111, %r8
    mov      $0x2222222222222222, %r9
    mov      $0x3333333333333333, %r10
    mov      $0x4444444444444444, %r11
    mov      $0xAAAAAAAAAAAAAAAA, %r12
    mov      $0xBBBBBBBBBBBBBBBB, %r13
    mov      $0xCCCCCCCCCCCCCCCC, %r14
    mov      $0xDDDDDDDDDDDDDDDD, %r15

    # initialize stack
    movq     $(TrampolineStackBase), %rax
    addq     $(TrampolineStackSize), %rax
    mov      %rax, %rsp
    mov      %rax, %rbp
    nop

    # try to obtain the semaphore
4:  xor      %eax, %eax
    mov      $1, %ebx
    lock
    cmpxchg  %ebx, AccessSemaphore-TrampolineStart
    jne      4b

    # now initialize LAPIC and IDT
    mov      IrqEnableAddress-TrampolineStart, %rbx
    call     *%rbx

    # done
    xor      %eax, %eax
    mov      %eax, AccessSemaphore-TrampolineStart

    # halt here
    jmp      .

    # alignment for data
    .align   8

    # Access semaphore
    .set     AccessSemaphore, .
    .quad    0

    # PML4TableAddress
    .set     PML4TableAddress, .
    .quad    0

    # IrqEnableAddress
    .set     IrqEnableAddress, .
    .quad    0

    # GDTR descriptor
    .set     GdtrDesc, .
    .word    GdtEnd-GdtStart-1
    .long    GdtStart-TrampolineStart

    # alignment for GDT table
    .align   16

    # GDT table for protected & long mode
    .set     GdtStart, .
    .quad    0x0000000000000000  # 0x00
    .quad    0x0000000000000000  # 0x00
    .quad    0x00CF9A000000FFFF  # 0x10 (KERN CODE 32-bit)
    .quad    0x00CF92000000FFFF  # 0x18 (KERN DATA 32-bit)
    .quad    0x00AF9A000000FFFF  # 0x20 (KERN CODE 64-bit)
    .quad    0x00AF92000000FFFF  # 0x28 (KERN DATA 64-bit)
    .quad    0x00AFFA000000FFFF  # 0x30 (USER CODE 64-bit)
    .quad    0x00AFF2000000FFFF  # 0x38 (USER DATA 64-bit)
    .set     GdtEnd, .

    # end of trampoline
    .set     TrampolineEnd, .

###############################################################################
#                            KernelCpuInit()                                  #
###############################################################################

    # declare a linker symbol
    .global  KernelCpuInit
    .set     KernelCpuInit, .

    # print heading of line
    mov      $0x0A, %rdi
    mov      $-1, %rsi
    call     KernelLogColour
    leaq     CpuModuleStr(%rip), %rdi
    call     KernelLogString
    mov      $0x0B, %rdi
    mov      $-1, %rsi
    call     KernelLogColour

    # print cpu module info
    leaq     CpuStartStr(%rip), %rdi
    call     KernelLogString
    mov      $'\n', %rdi
    call     KernelLogChar

    # store CR3 into PML4TableAddress to be fetched by trampoline
    mov      %cr3, %rax
    mov      %eax, PML4TableAddress(%rip)

    # store KernelIrqEnable to be fetched by trampoline
    leaq     KernelIrqEnable(%rip), %rax
    movq     %rax, IrqEnableAddress(%rip)

    # copy the real-mode trampoline to lower memory
    movq     $TrampolineCodeBase, %rdi
    leaq     TrampolineStart(%rip), %rsi
    leaq     TrampolineEnd(%rip), %rcx
    subq     %rsi, %rcx

    # copy loop
1:  movb     (%rsi), %al
    movb     %al, (%rdi)
    inc      %rsi
    inc      %rdi
    loop     1b

    # first we need to initialize local APIC
    call     KernelIrqEnable

    # send INIT-SIPI-SIPI sequence to other CPUs
    call     KernelIrqIpi

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

    # CPU heading
    .set     CpuModuleStr, .
    .string  " [KERNEL CPU DRIVER] "

    # CPU start ascii string
    .set     CpuStartStr, .
    .string  "Detecting other cores in the system..."
