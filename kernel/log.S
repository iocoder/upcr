;###############################################################################
;# File name:    log.S
;# Description:  Kernel logging module
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
    .global KernelLogInit
    .global KernelLogChar
    .global KernelLogDecimal
    .global KernelLogHex
    .global KernelLogString
    .global KernelLogColour
    .global KernelLogCLEAr

;###############################################################################
;#                              TEXT SECTION                                   #
;###############################################################################

    ;# text section
    .text

;###############################################################################
;#                            KernelLogInit()                                  #
;###############################################################################

    ;# declare a linker symbol
    .set     KernelLogInit, .

    ;# cLEAr screen
    CALL     KernelLogCLEAr

    ;# header colour
    MOV      $0x0A, %rdi
    MOV      $-1,   %rsi
    CALL     KernelLogColour

    ;# print header
    LEA      LogHeader(%rip), %rdi
    CALL     KernelLogString

    ;# welcome msg colour
    MOV      $0x0E, %rdi
    MOV      $-1,   %rsi
    CALL     KernelLogColour

    ;# print welcome msg
    LEA      LogWelcome(%rip), %rdi
    CALL     KernelLogString

    ;# license colour
    MOV      $0x0F, %rdi
    MOV      $-1,   %rsi
    CALL     KernelLogColour

    ;# print license
    LEA      LogLicense(%rip), %rdi
    CALL     KernelLogString

    ;# set printing colour to yellow
    MOV      $0x0B, %rdi
    MOV      $-1,   %rsi
    CALL     KernelLogColour

    ;# done
    XOR      %rax, %rax
    RET

;###############################################################################
;#                            KernelLogChar()                                  #
;###############################################################################

    ;# declare a linker symbol
    .set     KernelLogChar, .

    ;# print character to VGA
    PUSH     %rdi
    CALL     KernelVgaPut
    POP      %rdi

    ;# done
    XOR      %rax, %rax
    RET

;###############################################################################
;#                          KernelLogDecimal()                                 #
;###############################################################################

    ;# declare a linker symbol
    .set     KernelLogDecimal, .

    ;# we will keep dividing RDX:RAX by 10
    MOV      %rdi, %rax
    XOR      %ecx, %ecx
    MOV      $10,  %r8

    ;# divide by 10
1:  XOR      %rdx, %rdx
    DIV      %r8

    ;# use CPU stack as a PUSH-down automaton
    PUSH     %rdx
    INC      %ecx

    ;# done?
    AND      %rax, %rax
    JNZ      1b

    ;# now print all the digits
2:  POP      %rdx
    add      $'0', %rdx
    AND      $0xFF, %rdx
    MOV      %rdx, %rdi
    PUSH     %rcx
    CALL     KernelLogChar
    POP      %rcx

    ;# all digits printed?
    DEC      %ecx
    JNZ      2b

    ;# done
    XOR      %rax, %rax
    RET

;###############################################################################
;#                            KernelLogHex()                                   #
;###############################################################################

    ;# declare a linker symbol
    .set     KernelLogHex, .

    ;# print 0x
    PUSH     %rdi
    MOV      $'0', %rdi
    CALL     KernelVgaPut
    MOV      $'x', %rdi
    CALL     KernelVgaPut
    POP      %rdi

    ;# print hexadecimal number (8 bytes - 16 hexdigits)
    MOV      $16, %cl

    ;# put next byte in RDI[3:0] (ROL unrolled to prevent stall)
1:  ROL      %rdi
    ROL      %rdi
    ROL      %rdi
    ROL      %rdi

    ;# print DL[0:3]
    PUSH     %rcx
    PUSH     %rdi
    LEA      Digits(%rip), %rsi
    AND      $0x0F, %rdi
    ADD      %rdi, %rsi
    XOR      %rax, %rax
    MOV      (%rsi), %al
    MOV      %rax, %rdi
    CALL     KernelLogChar
    POP      %rdi
    POP      %rcx

    ;# next digit
    DEC      %cl
    JNZ      1b

    ;# done
    XOR      %rax, %rax
    RET

;###############################################################################
;#                             KernelLogString()                               #
;###############################################################################

    ;# declare a linker symbol
    .set     KernelLogString, .

    ;# fetch next character
1:  XOR      %rax, %rax
    MOV      (%rdi), %al

    ;# terminate if zero
    AND      %al, %al
    JZ       2f

    ;# print character
    PUSH     %rdi
    MOV      %rax, %rdi
    CALL     KernelVgaPut
    POP      %rdi

    ;# LOOP again
    INC      %rdi
    JMP      1b

    ;# done
2:  XOR      %rax, %rax
    RET

;##############################################################################
;#                             KernelLogColour()                              #
;##############################################################################

    ;# declare a linker symbol
    .set     KernelLogColour, .

    ;# set vga colours
    PUSH     %rdi
    PUSH     %rsi
    CALL     KernelVgaColour
    POP      %rsi
    POP      %rdi

    ;# done
    XOR      %rax, %rax
    RET


;##############################################################################
;#                             KernelLogCLEAr()                               #
;##############################################################################

    ;# declare a linker symbol
    .set     KernelLogCLEAr, .

    ;# cLEAr vga screen
    PUSH     %rdi
    PUSH     %rsi
    PUSH     %rcx
    CALL     KernelVgaCLEAr
    POP      %rsi
    POP      %rdi
    POP      %rcx

    ;# done
    XOR      %rax, %rax
    RET

;###############################################################################
;#                              DATA SECTION                                   #
;###############################################################################

    ;# data section
    .data

;###############################################################################
;#                              MODULE DATA                                    #
;###############################################################################

    ;# digits to print
    .set     Digits, .
    .ascii   "0123456789ABCDEF"

;###############################################################################
;#                            LOGGING STRINGS                                  #
;###############################################################################

    ;# header text
    .set     LogHeader, .
    .incbin  "kernel/header.txt"
    .byte    0

    ;# welcome text
    .set     LogWelcome, .
    .incbin  "kernel/welcome.txt"
    .byte    0

    ;# license text
    .set     LogLicense, .
    .incbin  "kernel/license.txt"
    .byte    0
