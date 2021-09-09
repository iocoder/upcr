;###############################################################################
;# File name:    err.S
;# Description:  Print errors and dump CPU registers
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
            .global  KERRPANIC

;###############################################################################
;#                              TEXT SECTION                                   #
;###############################################################################

            ;# text section
            .text

;###############################################################################
;#                              KERRPANIC()                                    #
;###############################################################################

KERRPANIC:  ;# set panic colour
            PUSH     %rdi
            MOV      $0x0A, %rdi
            MOV      $0x01, %rsi
            CALL     KLOGATT
            POP      %rdi 

            ;# clear screen
            PUSH     %rdi
            CALL     KLOGCLR
            POP      %rdi

            ;# print panic heading
            PUSH     %rdi
            LEA      KERRHDR(%rip), %rdi
            CALL     KLOGSTR
            POP      %rdi

            ;# print exception name
            PUSH     %rdi
            LEA      KERREXPN(%rip), %rdi
            CALL     KLOGSTR
            POP      %rdi
            PUSH     %rdi
            MOV      SFRAME_NBR(%rdi), %rax
            SHL      $5, %rax
            LEA      KERRSTR(%rip), %rdi
            ADD      %rax, %rdi
            CALL     KLOGSTR
            POP      %rdi

            ;# new line
            PUSH     %rdi
            MOV      $'\n', %rdi
            CALL     KLOGCHR
            POP      %rdi

            ;# print exception code
            PUSH     %rdi
            LEA      KERREXPC(%rip), %rdi
            CALL     KLOGSTR
            POP      %rdi
            PUSH     %rdi
            MOV      SFRAME_NBR(%rdi), %rdi
            CALL     KLOGHEX
            POP      %rdi

            ;# new line
            PUSH     %rdi
            MOV      $'\n', %rdi
            CALL     KLOGCHR
            POP      %rdi

            ;# print err code
            PUSH     %rdi
            LEA      KERRCODE(%rip), %rdi
            CALL     KLOGSTR
            POP      %rdi
            PUSH     %rdi
            MOV      SFRAME_ERR(%rdi), %rdi
            CALL     KLOGHEX
            POP      %rdi

            ;# new line
            PUSH     %rdi
            MOV      $'\n', %rdi
            CALL     KLOGCHR
            POP      %rdi

            ;# print cpu core number
            PUSH     %rdi
            LEA      KERRCORE(%rip), %rdi
            CALL     KLOGSTR
            POP      %rdi
            PUSH     %rdi
            XOR      %rax, %rax
            MOV      0xFEE00020, %eax
            SHR      $24, %eax
            MOV      %rax, %rdi
            CALL     KLOGDEC
            POP      %rdi

            ;# horizontal line
            PUSH     %rdi
            LEA      KERRHR(%rip), %rdi
            CALL     KLOGSTR
            POP      %rdi
            
            ;# print CS
            PUSH     %rdi
            LEA      KERRCS(%rip), %rdi
            CALL     KLOGSTR
            POP      %rdi
            PUSH     %rdi
            MOV      SFRAME_CS(%rdi), %rdi
            CALL     KLOGHEX
            POP      %rdi
            
            ;# print RIP
            PUSH     %rdi
            LEA      KERRRIP(%rip), %rdi
            CALL     KLOGSTR
            POP      %rdi
            PUSH     %rdi
            MOV      SFRAME_RIP(%rdi), %rdi
            CALL     KLOGHEX
            POP      %rdi
            
            ;# print RFLAGS
            PUSH     %rdi
            LEA      KERRFLG(%rip), %rdi
            CALL     KLOGSTR
            POP      %rdi
            PUSH     %rdi
            MOV      SFRAME_RFLAGS(%rdi), %rdi
            CALL     KLOGHEX
            POP      %rdi

            ;# new line
            PUSH     %rdi
            MOV      $'\n', %rdi
            CALL     KLOGCHR
            POP      %rdi
            
            ;# print SS
            PUSH     %rdi
            LEA      KERRSS(%rip), %rdi
            CALL     KLOGSTR
            POP      %rdi
            PUSH     %rdi
            MOV      SFRAME_SS(%rdi), %rdi
            CALL     KLOGHEX
            POP      %rdi
            
            ;# print RSP
            PUSH     %rdi
            LEA      KERRRSP(%rip), %rdi
            CALL     KLOGSTR
            POP      %rdi
            PUSH     %rdi
            MOV      SFRAME_RSP(%rdi), %rdi
            CALL     KLOGHEX
            POP      %rdi

            ;# horizontal line
            PUSH     %rdi
            LEA      KERRHR(%rip), %rdi
            CALL     KLOGSTR
            POP      %rdi
            
            ;# print RAX
            PUSH     %rdi
            LEA      KERRRAX(%rip), %rdi
            CALL     KLOGSTR
            POP      %rdi
            PUSH     %rdi
            MOV      SFRAME_RAX(%rdi), %rdi
            CALL     KLOGHEX
            POP      %rdi
            
            ;# print RBX
            PUSH     %rdi
            LEA      KERRRBX(%rip), %rdi
            CALL     KLOGSTR
            POP      %rdi
            PUSH     %rdi
            MOV      SFRAME_RBX(%rdi), %rdi
            CALL     KLOGHEX
            POP      %rdi
            
            ;# print RCX
            PUSH     %rdi
            LEA      KERRRCX(%rip), %rdi
            CALL     KLOGSTR
            POP      %rdi
            PUSH     %rdi
            MOV      SFRAME_RCX(%rdi), %rdi
            CALL     KLOGHEX
            POP      %rdi

            ;# new line
            PUSH     %rdi
            MOV      $'\n', %rdi
            CALL     KLOGCHR
            POP      %rdi

            ;# print RDX
            PUSH     %rdi
            LEA      KERRRDX(%rip), %rdi
            CALL     KLOGSTR
            POP      %rdi
            PUSH     %rdi
            MOV      SFRAME_RDX(%rdi), %rdi
            CALL     KLOGHEX
            POP      %rdi

            ;# print RSI
            PUSH     %rdi
            LEA      KERRRSI(%rip), %rdi
            CALL     KLOGSTR
            POP      %rdi
            PUSH     %rdi
            MOV      SFRAME_RSI(%rdi), %rdi
            CALL     KLOGHEX
            POP      %rdi

            ;# print RDI
            PUSH     %rdi
            LEA      KERRRDI(%rip), %rdi
            CALL     KLOGSTR
            POP      %rdi
            PUSH     %rdi
            MOV      SFRAME_RDI(%rdi), %rdi
            CALL     KLOGHEX
            POP      %rdi

            ;# new line
            PUSH     %rdi
            MOV      $'\n', %rdi
            CALL     KLOGCHR
            POP      %rdi
            
            ;# print RBP
            PUSH     %rdi
            LEA      KERRRBP(%rip), %rdi
            CALL     KLOGSTR
            POP      %rdi
            PUSH     %rdi
            MOV      SFRAME_RBP(%rdi), %rdi
            CALL     KLOGHEX
            POP      %rdi

            ;# horizontal line
            PUSH     %rdi
            LEA      KERRHR(%rip), %rdi
            CALL     KLOGSTR
            POP      %rdi
            
            ;# print R8
            PUSH     %rdi
            LEA      KERRR8(%rip), %rdi
            CALL     KLOGSTR
            POP      %rdi
            PUSH     %rdi
            MOV      SFRAME_R8(%rdi), %rdi
            CALL     KLOGHEX
            POP      %rdi
            
            ;# print R9
            PUSH     %rdi
            LEA      KERRR9(%rip), %rdi
            CALL     KLOGSTR
            POP      %rdi
            PUSH     %rdi
            MOV      SFRAME_R9(%rdi), %rdi
            CALL     KLOGHEX
            POP      %rdi
            
            ;# print R10
            PUSH     %rdi
            LEA      KERRR10(%rip), %rdi
            CALL     KLOGSTR
            POP      %rdi
            PUSH     %rdi
            MOV      SFRAME_R10(%rdi), %rdi
            CALL     KLOGHEX
            POP      %rdi

            ;# new line
            PUSH     %rdi
            MOV      $'\n', %rdi
            CALL     KLOGCHR
            POP      %rdi
            
            ;# print R11
            PUSH     %rdi
            LEA      KERRR11(%rip), %rdi
            CALL     KLOGSTR
            POP      %rdi
            PUSH     %rdi
            MOV      SFRAME_R11(%rdi), %rdi
            CALL     KLOGHEX
            POP      %rdi
            
            ;# print R12
            PUSH     %rdi
            LEA      KERRR12(%rip), %rdi
            CALL     KLOGSTR
            POP      %rdi
            PUSH     %rdi
            MOV      SFRAME_R12(%rdi), %rdi
            CALL     KLOGHEX
            POP      %rdi
            
            ;# print R13
            PUSH     %rdi
            LEA      KERRR13(%rip), %rdi
            CALL     KLOGSTR
            POP      %rdi
            PUSH     %rdi
            MOV      SFRAME_R13(%rdi), %rdi
            CALL     KLOGHEX
            POP      %rdi

            ;# new line
            PUSH     %rdi
            MOV      $'\n', %rdi
            CALL     KLOGCHR
            POP      %rdi
            
            ;# print R14
            PUSH     %rdi
            LEA      KERRR14(%rip), %rdi
            CALL     KLOGSTR
            POP      %rdi
            PUSH     %rdi
            MOV      SFRAME_R14(%rdi), %rdi
            CALL     KLOGHEX
            POP      %rdi
            
            ;# print R15
            PUSH     %rdi
            LEA      KERRR15(%rip), %rdi
            CALL     KLOGSTR
            POP      %rdi
            PUSH     %rdi
            MOV      SFRAME_R15(%rdi), %rdi
            CALL     KLOGHEX
            POP      %rdi

            ;# horizontal line
            PUSH     %rdi
            LEA      KERRHR(%rip), %rdi
            CALL     KLOGSTR
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

            ;# Panic header
KERRHDR:    .ascii   "\n"
            .ascii   "\n"
            .ascii   "  =========================================="
            .ascii   "=========================================\n"
            .ascii   "                                   KERNEL PANIC !!!\n"
            .ascii   "  =========================================="
            .ascii   "=========================================\n"
            .ascii   "\n"
            .ascii   "\0"

            ;# panic horizontal line
KERRHR:     .ascii   "\n"
            .ascii   "\n"
            .ascii   "  ------------------------------------------"
            .ascii   "-----------------------------------------\n"
            .ascii   "\n"
            .ascii   "\0"

            ;# registers
KERREXPN:   .ascii   "  EXCEPTION NAME: \0"
KERREXPC:   .ascii   "  EXCEPTION CODE: \0"
KERRCODE:   .ascii   "  ERROR CODE:     \0"
KERRCORE:   .ascii   "  CPU CORE:       \0"
KERRCS:     .ascii   "  CS:  \0"
KERRRIP:    .ascii   "  RIP: \0"
KERRFLG:    .ascii   "  RFLAGS: \0"
KERRSS:     .ascii   "  SS:  \0"
KERRRSP:    .ascii   "  RSP: \0"
KERRRAX:    .ascii   "  RAX: \0"
KERRRBX:    .ascii   "  RBX: \0"
KERRRCX:    .ascii   "  RCX: \0"
KERRRDX:    .ascii   "  RDX: \0"
KERRRSI:    .ascii   "  RSI: \0"
KERRRDI:    .ascii   "  RDI: \0"
KERRRBP:    .ascii   "  RBP: \0"
KERRR8:     .ascii   "  R8:  \0"
KERRR9:     .ascii   "  R9:  \0"
KERRR10:    .ascii   "  R10: \0"
KERRR11:    .ascii   "  R11: \0"
KERRR12:    .ascii   "  R12: \0"
KERRR13:    .ascii   "  R13: \0"
KERRR14:    .ascii   "  R14: \0"
KERRR15:    .ascii   "  R15: \0"

            ;# exception names
KERRSTR:    .ascii   "DIVISION BY ZERO EXCEPTION     \0"  ;# 0x00
            .ascii   "DEBUG EXCEPTION                \0"  ;# 0x01
            .ascii   "NON MASKABLE INTERRUPT         \0"  ;# 0x02
            .ascii   "BREAKPOINT EXCEPTION           \0"  ;# 0x03
            .ascii   "OVERFLOW EXCEPTION             \0"  ;# 0x04
            .ascii   "BOUND RANGE                    \0"  ;# 0x05
            .ascii   "INVALID OPCODE                 \0"  ;# 0x06
            .ascii   "DEVICE NOT AVAILABLE           \0"  ;# 0x07
            .ascii   "DOUBLE FAULT                   \0"  ;# 0x08
            .ascii   "UNSUPPORTED                    \0"  ;# 0x09
            .ascii   "INVALID TSS                    \0"  ;# 0x0A
            .ascii   "SEGMENT NOT PRESENT            \0"  ;# 0x0B
            .ascii   "STACK EXCEPTION                \0"  ;# 0x0C
            .ascii   "GENERAL PROTECTION ERROR       \0"  ;# 0x0D
            .ascii   "PAGE FAULT                     \0"  ;# 0x0E
            .ascii   "RESERVED                       \0"  ;# 0x0F
            .ascii   "X87 FLOATING POINT EXCEPTION   \0"  ;# 0x10
            .ascii   "ALIGNMENT CHECK                \0"  ;# 0x11
            .ascii   "MACHINE CHECK                  \0"  ;# 0x12
            .ascii   "SIMD FLOATING POINT EXCEPTION  \0"  ;# 0x13
            .ascii   "RESERVED                       \0"  ;# 0x14
            .ascii   "CONTROL PROTECTION EXCEPTION   \0"  ;# 0x15
            .ascii   "RESERVED                       \0"  ;# 0x16
            .ascii   "RESERVED                       \0"  ;# 0x17
            .ascii   "RESERVED                       \0"  ;# 0x18
            .ascii   "RESERVED                       \0"  ;# 0x19
            .ascii   "RESERVED                       \0"  ;# 0x1A
            .ascii   "RESERVED                       \0"  ;# 0x1B
            .ascii   "HYPERVISOR INJECTION EXCEPTION \0"  ;# 0x1C
            .ascii   "VMM COMMUNICATION EXCEPTION    \0"  ;# 0x1D
            .ascii   "SECURITY EXCEPTION             \0"  ;# 0x1E
            .ascii   "RESERVED                       \0"  ;# 0x1F
            ;#       "0123456789ABCDEF0123456789ABCDEF"
