###############################################################################
# File name:    log.S
# Description:  Kernel logging module
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
#                            KernelLogInit()                                  #
###############################################################################

    # declare a linker symbol
    .global  KernelLogInit
    .set     KernelLogInit, .

    # header colour
    mov      $0x0A, %rdi
    mov      $-1,   %rsi
    call     KernelLogColour

    # print header
    lea      LogHeader(%rip), %rdi
    call     KernelLogString

    # welcome msg colour
    mov      $0x0E, %rdi
    mov      $-1,   %rsi
    call     KernelLogColour

    # print welcome msg
    lea      LogWelcome(%rip), %rdi
    call     KernelLogString

    # license colour
    mov      $0x0F, %rdi
    mov      $-1,   %rsi
    call     KernelLogColour

    # print license
    lea      LogLicense(%rip), %rdi
    call     KernelLogString

    # set printing colour to yellow
    mov      $0x0B, %rdi
    mov      $-1,   %rsi
    call     KernelLogColour

    # done
    xor      %rax, %rax
    ret

###############################################################################
#                            KernelLogChar()                                  #
###############################################################################

    # declare a linker symbol
    .global  KernelLogChar
    .set     KernelLogChar, .

    # print character to VGA
    push     %rdi
    call     KernelVgaPut
    pop      %rdi

    # done
    xor      %rax, %rax
    ret

###############################################################################
#                          KernelLogDecimal()                                 #
###############################################################################

    # declare a linker symbol
    .global  KernelLogDecimal
    .set     KernelLogDecimal, .

    # we will keep dividing RDX:RAX by 10
    mov      %rdi, %rax
    xor      %ecx, %ecx
    mov      $10,  %r8

    # divide by 10
1:  xor      %rdx, %rdx
    div      %r8

    # use CPU stack as a push-down automaton
    push     %dx
    inc      %ecx

    # done?
    and      %rax, %rax
    jnz      1b

    # now print all the digits
2:  pop      %dx
    add      $'0', %dx
    movzwq   %dx, %rdi
    push     %rcx
    call     KernelLogChar
    pop      %rcx

    # all digits printed?
    dec      %ecx
    jnz      2b

    # done
    xor      %rax, %rax
    ret

###############################################################################
#                            KernelLogHex()                                   #
###############################################################################

    # declare a linker symbol
    .global  KernelLogHex
    .set     KernelLogHex, .

    # print 0x
    push     %rdi
    mov      $'0', %rdi
    call     KernelVgaPut
    mov      $'x', %rdi
    call     KernelVgaPut
    pop      %rdi

    # print hexadecimal number (8 bytes - 16 hexdigits)
    mov      $16, %cl

    # put next byte in RDI[3:0] (ROL unrolled to prevent stall)
1:  rol      %rdi
    rol      %rdi
    rol      %rdi
    rol      %rdi

    # print DL[0:3]
    push     %rcx
    push     %rdi
    leaq     Digits(%rip), %rsi
    and      $0x0F, %rdi
    movzbq   (%rsi, %rdi), %rdi
    call     KernelLogChar
    pop      %rdi
    pop      %rcx

    # next digit
    dec      %cl
    jnz      1b

    # done
    xor      %rax, %rax
    ret

###############################################################################
#                             KernelLogString()                               #
###############################################################################

    # declare a linker symbol
    .global  KernelLogString
    .set     KernelLogString, .

    # fetch next character
1:  xor      %rax, %rax
    mov      (%rdi), %al

    # terminate if zero
    and      %al, %al
    jz       2f

    # print character
    push     %rdi
    mov      %rax, %rdi
    call     KernelVgaPut
    pop      %rdi

    # loop again
    inc      %rdi
    jmp      1b

    # next character
    cmpb     $0, (%rdi)

    # done
2:  xor      %rax, %rax
    ret

##############################################################################
#                             KernelLogColour()                              #
##############################################################################

    # declare a linker symbol
    .global  KernelLogColour
    .set     KernelLogColour, .

    # set vga colours
    push     %rdi
    push     %rsi
    call     KernelVgaColour
    pop      %rsi
    pop      %rdi

    # done
    xor      %rax, %rax
    ret

###############################################################################
#                              DATA SECTION                                   #
###############################################################################

    # data section
    .data

###############################################################################
#                              MODULE DATA                                    #
###############################################################################

    # digits to print
    .set     Digits, .
    .ascii   "0123456789ABCDEF"

###############################################################################
#                            LOGGING STRINGS                                  #
###############################################################################

    # header text
    .set     LogHeader, .
    .incbin  "kernel/header.txt"
    .byte    0

    # welcome text
    .set     LogWelcome, .
    .incbin  "kernel/welcome.txt"
    .byte    0

    # license text
    .set     LogLicense, .
    .incbin  "kernel/license.txt"
    .byte    0
