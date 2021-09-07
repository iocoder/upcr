###############################################################################
# File name:    panic.S
# Description:  Kernel panic handler
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
#                             KernelPanicInit()                               #
###############################################################################

    # declare a linker symbol
    .global  KernelPanicInit
    .set     KernelPanicInit, .

    # print heading of line
    mov      $0x0A, %rdi
    mov      $-1, %rsi
    call     KernelLogColour
    leaq     PanicModuleStr(%rip), %rdi
    call     KernelLogString
    mov      $0x0B, %rdi
    mov      $-1, %rsi
    call     KernelLogColour

    # print module info
    leaq     PanicStartStr(%rip), %rdi
    call     KernelLogString
    mov      $'\n', %rdi
    call     KernelLogChar

    # done
1:  xor      %rax, %rax
    ret


###############################################################################
#                            KernelPanicHandle()                              #
###############################################################################

    # declare a linker symbol
    .global  KernelPanicHandle
    .set     KernelPanicHandle, .

    # set panic colour
    push     %rdi
    mov      $0x0A, %rdi
    mov      $0x01, %rsi
    call     KernelLogColour
    pop      %rdi 

    # clear screen
    push     %rdi
    call     KernelLogClear
    pop      %rdi

    # print panic heading
    push     %rdi
    leaq     PanicHeaderStr(%rip), %rdi
    call     KernelLogString
    pop      %rdi

    # print exception name
    push     %rdi
    lea      PanicExpNameStr(%rip), %rdi
    call     KernelLogString
    pop      %rdi
    push     %rdi
    movq     StackFrameNbr(%rdi), %rax
    shlq     $5, %rax
    leaq     PanicExpNamesStr(%rip), %rdi
    addq     %rax, %rdi
    call     KernelLogString
    pop      %rdi

    # new line
    push     %rdi
    movq     $'\n', %rdi
    call     KernelLogChar
    pop      %rdi

    # print exception code
    push     %rdi
    lea      PanicExpCodeStr(%rip), %rdi
    call     KernelLogString
    pop      %rdi
    push     %rdi
    movq     StackFrameNbr(%rdi), %rdi
    call     KernelLogHex
    pop      %rdi

    # new line
    push     %rdi
    movq     $'\n', %rdi
    call     KernelLogChar
    pop      %rdi

    # print err code
    push     %rdi
    lea      PanicErrCodeStr(%rip), %rdi
    call     KernelLogString
    pop      %rdi
    push     %rdi
    movq     StackFrameErr(%rdi), %rdi
    call     KernelLogHex
    pop      %rdi

    # new line
    push     %rdi
    movq     $'\n', %rdi
    call     KernelLogChar
    pop      %rdi

    # print cpu core number
    push     %rdi
    lea      PanicCoreNumStr(%rip), %rdi
    call     KernelLogString
    pop      %rdi
    push     %rdi
    xorq     %rax, %rax
    movl     0xFEE00020, %eax
    shrl     $24, %eax
    movq     %rax, %rdi
    call     KernelLogDecimal
    pop      %rdi

    # horizontal line
    push     %rdi
    lea      PanicLineStr(%rip), %rdi
    call     KernelLogString
    pop      %rdi
    
    # print CS
    push     %rdi
    lea      PanicRegCsStr(%rip), %rdi
    call     KernelLogString
    pop      %rdi
    push     %rdi
    movq     StackFrameCS(%rdi), %rdi
    call     KernelLogHex
    pop      %rdi
    
    # print RIP
    push     %rdi
    lea      PanicRegRipStr(%rip), %rdi
    call     KernelLogString
    pop      %rdi
    push     %rdi
    movq     StackFrameRIP(%rdi), %rdi
    call     KernelLogHex
    pop      %rdi
    
    # print RFLAGS
    push     %rdi
    lea      PanicRegRflagsStr(%rip), %rdi
    call     KernelLogString
    pop      %rdi
    push     %rdi
    movq     StackFrameRFLAGS(%rdi), %rdi
    call     KernelLogHex
    pop      %rdi

    # new line
    push     %rdi
    movq     $'\n', %rdi
    call     KernelLogChar
    pop      %rdi
    
    # print SS
    push     %rdi
    lea      PanicRegSsStr(%rip), %rdi
    call     KernelLogString
    pop      %rdi
    push     %rdi
    movq     StackFrameSS(%rdi), %rdi
    call     KernelLogHex
    pop      %rdi
    
    # print RSP
    push     %rdi
    lea      PanicRegRspStr(%rip), %rdi
    call     KernelLogString
    pop      %rdi
    push     %rdi
    movq     StackFrameRSP(%rdi), %rdi
    call     KernelLogHex
    pop      %rdi

    # horizontal line
    push     %rdi
    lea      PanicLineStr(%rip), %rdi
    call     KernelLogString
    pop      %rdi
    
    # print RAX
    push     %rdi
    lea      PanicRegRaxStr(%rip), %rdi
    call     KernelLogString
    pop      %rdi
    push     %rdi
    movq     StackFrameRAX(%rdi), %rdi
    call     KernelLogHex
    pop      %rdi
    
    # print RBX
    push     %rdi
    lea      PanicRegRbxStr(%rip), %rdi
    call     KernelLogString
    pop      %rdi
    push     %rdi
    movq     StackFrameRBX(%rdi), %rdi
    call     KernelLogHex
    pop      %rdi
    
    # print RCX
    push     %rdi
    lea      PanicRegRcxStr(%rip), %rdi
    call     KernelLogString
    pop      %rdi
    push     %rdi
    movq     StackFrameRCX(%rdi), %rdi
    call     KernelLogHex
    pop      %rdi

    # new line
    push     %rdi
    movq     $'\n', %rdi
    call     KernelLogChar
    pop      %rdi

    # print RDX
    push     %rdi
    lea      PanicRegRdxStr(%rip), %rdi
    call     KernelLogString
    pop      %rdi
    push     %rdi
    movq     StackFrameRDX(%rdi), %rdi
    call     KernelLogHex
    pop      %rdi

    # print RSI
    push     %rdi
    lea      PanicRegRsiStr(%rip), %rdi
    call     KernelLogString
    pop      %rdi
    push     %rdi
    movq     StackFrameRSI(%rdi), %rdi
    call     KernelLogHex
    pop      %rdi

    # print RDI
    push     %rdi
    lea      PanicRegRdiStr(%rip), %rdi
    call     KernelLogString
    pop      %rdi
    push     %rdi
    movq     StackFrameRDI(%rdi), %rdi
    call     KernelLogHex
    pop      %rdi

    # new line
    push     %rdi
    movq     $'\n', %rdi
    call     KernelLogChar
    pop      %rdi
    
    # print RBP
    push     %rdi
    lea      PanicRegRbpStr(%rip), %rdi
    call     KernelLogString
    pop      %rdi
    push     %rdi
    movq     StackFrameRBP(%rdi), %rdi
    call     KernelLogHex
    pop      %rdi

    # horizontal line
    push     %rdi
    lea      PanicLineStr(%rip), %rdi
    call     KernelLogString
    pop      %rdi
    
    # print R8
    push     %rdi
    lea      PanicRegR8Str(%rip), %rdi
    call     KernelLogString
    pop      %rdi
    push     %rdi
    movq     StackFrameR8(%rdi), %rdi
    call     KernelLogHex
    pop      %rdi
    
    # print R9
    push     %rdi
    lea      PanicRegR9Str(%rip), %rdi
    call     KernelLogString
    pop      %rdi
    push     %rdi
    movq     StackFrameR9(%rdi), %rdi
    call     KernelLogHex
    pop      %rdi
    
    # print R10
    push     %rdi
    lea      PanicRegR10Str(%rip), %rdi
    call     KernelLogString
    pop      %rdi
    push     %rdi
    movq     StackFrameR10(%rdi), %rdi
    call     KernelLogHex
    pop      %rdi

    # new line
    push     %rdi
    movq     $'\n', %rdi
    call     KernelLogChar
    pop      %rdi
    
    # print R11
    push     %rdi
    lea      PanicRegR11Str(%rip), %rdi
    call     KernelLogString
    pop      %rdi
    push     %rdi
    movq     StackFrameR11(%rdi), %rdi
    call     KernelLogHex
    pop      %rdi
    
    # print R12
    push     %rdi
    lea      PanicRegR12Str(%rip), %rdi
    call     KernelLogString
    pop      %rdi
    push     %rdi
    movq     StackFrameR12(%rdi), %rdi
    call     KernelLogHex
    pop      %rdi
    
    # print R13
    push     %rdi
    lea      PanicRegR13Str(%rip), %rdi
    call     KernelLogString
    pop      %rdi
    push     %rdi
    movq     StackFrameR13(%rdi), %rdi
    call     KernelLogHex
    pop      %rdi

    # new line
    push     %rdi
    movq     $'\n', %rdi
    call     KernelLogChar
    pop      %rdi
    
    # print R14
    push     %rdi
    lea      PanicRegR14Str(%rip), %rdi
    call     KernelLogString
    pop      %rdi
    push     %rdi
    movq     StackFrameR14(%rdi), %rdi
    call     KernelLogHex
    pop      %rdi
    
    # print R15
    push     %rdi
    lea      PanicRegR15Str(%rip), %rdi
    call     KernelLogString
    pop      %rdi
    push     %rdi
    movq     StackFrameR15(%rdi), %rdi
    call     KernelLogHex
    pop      %rdi

    # horizontal line
    push     %rdi
    lea      PanicLineStr(%rip), %rdi
    call     KernelLogString
    pop      %rdi

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

    # Panic heading
    .set     PanicModuleStr, .
    .string  " [KERNEL PANIC HANDLER] "

    # Panic start ascii string
    .set     PanicStartStr, .
    .string  "Initializing kernel panic handler..."

    # Panic header
    .set     PanicHeaderStr, .
    .ascii   "\n"
    .ascii   "\n"
    .ascii   "  =========================================="
    .ascii   "=========================================\n"
    .ascii   "                                   KERNEL PANIC !!!\n"
    .ascii   "  =========================================="
    .ascii   "=========================================\n"
    .ascii   "\n"
    .string  ""

    # panic horizontal line
    .set     PanicLineStr, .
    .ascii   "\n"
    .ascii   "\n"
    .ascii   "  ------------------------------------------"
    .ascii   "-----------------------------------------\n"
    .ascii   "\n"
    .string  ""

    # registers
    .set     PanicExpNameStr, .
    .string  "  EXCEPTION NAME: "
    .set     PanicExpCodeStr, .
    .string  "  EXCEPTION CODE: "
    .set     PanicErrCodeStr, .
    .string  "  ERROR CODE:     "
    .set     PanicCoreNumStr, .
    .string  "  CPU CORE:       "
    .set     PanicRegCsStr, .
    .string  "  CS:  "
    .set     PanicRegRipStr, .
    .string  "  RIP: "
    .set     PanicRegRflagsStr, .
    .string  "  RFLAGS: "
    .set     PanicRegSsStr, .
    .string  "  SS:  "
    .set     PanicRegRspStr, .
    .string  "  RSP: "
    .set     PanicRegRaxStr, .
    .string  "  RAX: "
    .set     PanicRegRbxStr, .
    .string  "  RBX: "
    .set     PanicRegRcxStr, .
    .string  "  RCX: "
    .set     PanicRegRdxStr, .
    .string  "  RDX: "
    .set     PanicRegRsiStr, .
    .string  "  RSI: "
    .set     PanicRegRdiStr, .
    .string  "  RDI: "
    .set     PanicRegRbpStr, .
    .string  "  RBP: "
    .set     PanicRegR8Str, .
    .string  "  R8:  "
    .set     PanicRegR9Str, .
    .string  "  R9:  "
    .set     PanicRegR10Str, .
    .string  "  R10: "
    .set     PanicRegR11Str, .
    .string  "  R11: "
    .set     PanicRegR12Str, .
    .string  "  R12: "
    .set     PanicRegR13Str, .
    .string  "  R13: "
    .set     PanicRegR14Str, .
    .string  "  R14: "
    .set     PanicRegR15Str, .
    .string  "  R15: "

    # exception names
    .set     PanicExpNamesStr, .
    .string  "DIVISION BY ZERO EXCEPTION     "  # 0x00
    .string  "DEBUG EXCEPTION                "  # 0x01
    .string  "NON MASKABLE INTERRUPT         "  # 0x02
    .string  "BREAKPOINT EXCEPTION           "  # 0x03
    .string  "OVERFLOW EXCEPTION             "  # 0x04
    .string  "BOUND RANGE                    "  # 0x05
    .string  "INVALID OPCODE                 "  # 0x06
    .string  "DEVICE NOT AVAILABLE           "  # 0x07
    .string  "DOUBLE FAULT                   "  # 0x08
    .string  "UNSUPPORTED                    "  # 0x09
    .string  "INVALID TSS                    "  # 0x0A
    .string  "SEGMENT NOT PRESENT            "  # 0x0B
    .string  "STACK EXCEPTION                "  # 0x0C
    .string  "GENERAL PROTECTION ERROR       "  # 0x0D
    .string  "PAGE FAULT                     "  # 0x0E
    .string  "RESERVED                       "  # 0x0F
    .string  "X87 FLOATING POINT EXCEPTION   "  # 0x10
    .string  "ALIGNMENT CHECK                "  # 0x11
    .string  "MACHINE CHECK                  "  # 0x12
    .string  "SIMD FLOATING POINT EXCEPTION  "  # 0x13
    .string  "RESERVED                       "  # 0x14
    .string  "CONTROL PROTECTION EXCEPTION   "  # 0x15
    .string  "RESERVED                       "  # 0x16
    .string  "RESERVED                       "  # 0x17
    .string  "RESERVED                       "  # 0x18
    .string  "RESERVED                       "  # 0x19
    .string  "RESERVED                       "  # 0x1A
    .string  "RESERVED                       "  # 0x1B
    .string  "HYPERVISOR INJECTION EXCEPTION "  # 0x1C
    .string  "VMM COMMUNICATION EXCEPTION    "  # 0x1D
    .string  "SECURITY EXCEPTION             "  # 0x1E
    .string  "RESERVED                       "  # 0x1F
    #        "0123456789ABCDEF0123456789ABCDEF"
