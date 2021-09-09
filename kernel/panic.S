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
    MOV      $0x0A, %rdi
    MOV      $-1, %rsi
    CALL     KernelLogColour
    LEA      PanicModuleStr(%rip), %rdi
    CALL     KernelLogString
    MOV      $0x0B, %rdi
    MOV      $-1, %rsi
    CALL     KernelLogColour

    # print module info
    LEA      PanicStartStr(%rip), %rdi
    CALL     KernelLogString
    MOV      $'\n', %rdi
    CALL     KernelLogChar

    # done
1:  XOR      %rax, %rax
    RET


###############################################################################
#                            KernelPanicHandle()                              #
###############################################################################

    # declare a linker symbol
    .global  KernelPanicHandle
    .set     KernelPanicHandle, .

    # set panic colour
    PUSH     %rdi
    MOV      $0x0A, %rdi
    MOV      $0x01, %rsi
    CALL     KernelLogColour
    POP      %rdi 

    # cLEAr screen
    PUSH     %rdi
    CALL     KernelLogCLEAr
    POP      %rdi

    # print panic heading
    PUSH     %rdi
    LEA      PanicHeaderStr(%rip), %rdi
    CALL     KernelLogString
    POP      %rdi

    # print exception name
    PUSH     %rdi
    LEA      PanicExpNameStr(%rip), %rdi
    CALL     KernelLogString
    POP      %rdi
    PUSH     %rdi
    MOV      StackFrameNbr(%rdi), %rax
    SHL      $5, %rax
    LEA      PanicExpNamesStr(%rip), %rdi
    ADD      %rax, %rdi
    CALL     KernelLogString
    POP      %rdi

    # new line
    PUSH     %rdi
    MOV      $'\n', %rdi
    CALL     KernelLogChar
    POP      %rdi

    # print exception code
    PUSH     %rdi
    LEA      PanicExpCodeStr(%rip), %rdi
    CALL     KernelLogString
    POP      %rdi
    PUSH     %rdi
    MOV      StackFrameNbr(%rdi), %rdi
    CALL     KernelLogHex
    POP      %rdi

    # new line
    PUSH     %rdi
    MOV      $'\n', %rdi
    CALL     KernelLogChar
    POP      %rdi

    # print err code
    PUSH     %rdi
    LEA      PanicErrCodeStr(%rip), %rdi
    CALL     KernelLogString
    POP      %rdi
    PUSH     %rdi
    MOV      StackFrameErr(%rdi), %rdi
    CALL     KernelLogHex
    POP      %rdi

    # new line
    PUSH     %rdi
    MOV      $'\n', %rdi
    CALL     KernelLogChar
    POP      %rdi

    # print cpu core number
    PUSH     %rdi
    LEA      PanicCoreNumStr(%rip), %rdi
    CALL     KernelLogString
    POP      %rdi
    PUSH     %rdi
    XOR      %rax, %rax
    MOV      0xFEE00020, %eax
    SHR      $24, %eax
    MOV      %rax, %rdi
    CALL     KernelLogDecimal
    POP      %rdi

    # horizontal line
    PUSH     %rdi
    LEA      PanicLineStr(%rip), %rdi
    CALL     KernelLogString
    POP      %rdi
    
    # print CS
    PUSH     %rdi
    LEA      PanicRegCsStr(%rip), %rdi
    CALL     KernelLogString
    POP      %rdi
    PUSH     %rdi
    MOV      StackFrameCS(%rdi), %rdi
    CALL     KernelLogHex
    POP      %rdi
    
    # print RIP
    PUSH     %rdi
    LEA      PanicRegRipStr(%rip), %rdi
    CALL     KernelLogString
    POP      %rdi
    PUSH     %rdi
    MOV      StackFrameRIP(%rdi), %rdi
    CALL     KernelLogHex
    POP      %rdi
    
    # print RFLAGS
    PUSH     %rdi
    LEA      PanicRegRflagsStr(%rip), %rdi
    CALL     KernelLogString
    POP      %rdi
    PUSH     %rdi
    MOV      StackFrameRFLAGS(%rdi), %rdi
    CALL     KernelLogHex
    POP      %rdi

    # new line
    PUSH     %rdi
    MOV      $'\n', %rdi
    CALL     KernelLogChar
    POP      %rdi
    
    # print SS
    PUSH     %rdi
    LEA      PanicRegSsStr(%rip), %rdi
    CALL     KernelLogString
    POP      %rdi
    PUSH     %rdi
    MOV      StackFrameSS(%rdi), %rdi
    CALL     KernelLogHex
    POP      %rdi
    
    # print RSP
    PUSH     %rdi
    LEA      PanicRegRspStr(%rip), %rdi
    CALL     KernelLogString
    POP      %rdi
    PUSH     %rdi
    MOV      StackFrameRSP(%rdi), %rdi
    CALL     KernelLogHex
    POP      %rdi

    # horizontal line
    PUSH     %rdi
    LEA      PanicLineStr(%rip), %rdi
    CALL     KernelLogString
    POP      %rdi
    
    # print RAX
    PUSH     %rdi
    LEA      PanicRegRaxStr(%rip), %rdi
    CALL     KernelLogString
    POP      %rdi
    PUSH     %rdi
    MOV      StackFrameRAX(%rdi), %rdi
    CALL     KernelLogHex
    POP      %rdi
    
    # print RBX
    PUSH     %rdi
    LEA      PanicRegRbxStr(%rip), %rdi
    CALL     KernelLogString
    POP      %rdi
    PUSH     %rdi
    MOV      StackFrameRBX(%rdi), %rdi
    CALL     KernelLogHex
    POP      %rdi
    
    # print RCX
    PUSH     %rdi
    LEA      PanicRegRcxStr(%rip), %rdi
    CALL     KernelLogString
    POP      %rdi
    PUSH     %rdi
    MOV      StackFrameRCX(%rdi), %rdi
    CALL     KernelLogHex
    POP      %rdi

    # new line
    PUSH     %rdi
    MOV      $'\n', %rdi
    CALL     KernelLogChar
    POP      %rdi

    # print RDX
    PUSH     %rdi
    LEA      PanicRegRdxStr(%rip), %rdi
    CALL     KernelLogString
    POP      %rdi
    PUSH     %rdi
    MOV      StackFrameRDX(%rdi), %rdi
    CALL     KernelLogHex
    POP      %rdi

    # print RSI
    PUSH     %rdi
    LEA      PanicRegRsiStr(%rip), %rdi
    CALL     KernelLogString
    POP      %rdi
    PUSH     %rdi
    MOV      StackFrameRSI(%rdi), %rdi
    CALL     KernelLogHex
    POP      %rdi

    # print RDI
    PUSH     %rdi
    LEA      PanicRegRdiStr(%rip), %rdi
    CALL     KernelLogString
    POP      %rdi
    PUSH     %rdi
    MOV      StackFrameRDI(%rdi), %rdi
    CALL     KernelLogHex
    POP      %rdi

    # new line
    PUSH     %rdi
    MOV      $'\n', %rdi
    CALL     KernelLogChar
    POP      %rdi
    
    # print RBP
    PUSH     %rdi
    LEA      PanicRegRbpStr(%rip), %rdi
    CALL     KernelLogString
    POP      %rdi
    PUSH     %rdi
    MOV      StackFrameRBP(%rdi), %rdi
    CALL     KernelLogHex
    POP      %rdi

    # horizontal line
    PUSH     %rdi
    LEA      PanicLineStr(%rip), %rdi
    CALL     KernelLogString
    POP      %rdi
    
    # print R8
    PUSH     %rdi
    LEA      PanicRegR8Str(%rip), %rdi
    CALL     KernelLogString
    POP      %rdi
    PUSH     %rdi
    MOV      StackFrameR8(%rdi), %rdi
    CALL     KernelLogHex
    POP      %rdi
    
    # print R9
    PUSH     %rdi
    LEA      PanicRegR9Str(%rip), %rdi
    CALL     KernelLogString
    POP      %rdi
    PUSH     %rdi
    MOV      StackFrameR9(%rdi), %rdi
    CALL     KernelLogHex
    POP      %rdi
    
    # print R10
    PUSH     %rdi
    LEA      PanicRegR10Str(%rip), %rdi
    CALL     KernelLogString
    POP      %rdi
    PUSH     %rdi
    MOV      StackFrameR10(%rdi), %rdi
    CALL     KernelLogHex
    POP      %rdi

    # new line
    PUSH     %rdi
    MOV      $'\n', %rdi
    CALL     KernelLogChar
    POP      %rdi
    
    # print R11
    PUSH     %rdi
    LEA      PanicRegR11Str(%rip), %rdi
    CALL     KernelLogString
    POP      %rdi
    PUSH     %rdi
    MOV      StackFrameR11(%rdi), %rdi
    CALL     KernelLogHex
    POP      %rdi
    
    # print R12
    PUSH     %rdi
    LEA      PanicRegR12Str(%rip), %rdi
    CALL     KernelLogString
    POP      %rdi
    PUSH     %rdi
    MOV      StackFrameR12(%rdi), %rdi
    CALL     KernelLogHex
    POP      %rdi
    
    # print R13
    PUSH     %rdi
    LEA      PanicRegR13Str(%rip), %rdi
    CALL     KernelLogString
    POP      %rdi
    PUSH     %rdi
    MOV      StackFrameR13(%rdi), %rdi
    CALL     KernelLogHex
    POP      %rdi

    # new line
    PUSH     %rdi
    MOV      $'\n', %rdi
    CALL     KernelLogChar
    POP      %rdi
    
    # print R14
    PUSH     %rdi
    LEA      PanicRegR14Str(%rip), %rdi
    CALL     KernelLogString
    POP      %rdi
    PUSH     %rdi
    MOV      StackFrameR14(%rdi), %rdi
    CALL     KernelLogHex
    POP      %rdi
    
    # print R15
    PUSH     %rdi
    LEA      PanicRegR15Str(%rip), %rdi
    CALL     KernelLogString
    POP      %rdi
    PUSH     %rdi
    MOV      StackFrameR15(%rdi), %rdi
    CALL     KernelLogHex
    POP      %rdi

    # horizontal line
    PUSH     %rdi
    LEA      PanicLineStr(%rip), %rdi
    CALL     KernelLogString
    POP      %rdi

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
