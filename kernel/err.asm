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
            INCLUDE  "kernel/macro.inc"

;###############################################################################
;#                                GLOBALS                                      #
;###############################################################################

            ;# global symbols
            PUBLIC   KERRPANIC

;###############################################################################
;#                              TEXT SECTION                                   #
;###############################################################################

            ;# text section
            SEGMENT  ".text"

;#-----------------------------------------------------------------------------#
;#                              KERRPANIC()                                    #
;#-----------------------------------------------------------------------------#

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
            SEGMENT  ".data"

;#-----------------------------------------------------------------------------#
;#                            LOGGING STRINGS                                  #
;#-----------------------------------------------------------------------------#

            ;# Panic header
KERRHDR:    DB       "\n"
            DB       "\n"
            DB       "  "
            DB       "=========================================="
            DB       "=========================================="
            DB       "\n"
            DB       "                                   "
            DB       "KERNEL PANIC !!!"
            DB       "\n"
            DB       "=========================================="
            DB       "=========================================="
            DB       "\n"
            DB       "\n"
            DB       "\0"

            ;# panic horizontal line
KERRHR:     DB       "\n"
            DB       "\n"
            DB       "  "
            DB       "------------------------------------------"
            DB       "------------------------------------------"
            DB       "\n"
            DB       "\n"
            DB       "\0"

            ;# registers
KERREXPN:   DB       "  EXCEPTION NAME: \0"
KERREXPC:   DB       "  EXCEPTION CODE: \0"
KERRCODE:   DB       "  ERROR CODE:     \0"
KERRCORE:   DB       "  CPU CORE:       \0"
KERRCS:     DB       "  CS:  \0"
KERRRIP:    DB       "  RIP: \0"
KERRFLG:    DB       "  RFLAGS: \0"
KERRSS:     DB       "  SS:  \0"
KERRRSP:    DB       "  RSP: \0"
KERRRAX:    DB       "  RAX: \0"
KERRRBX:    DB       "  RBX: \0"
KERRRCX:    DB       "  RCX: \0"
KERRRDX:    DB       "  RDX: \0"
KERRRSI:    DB       "  RSI: \0"
KERRRDI:    DB       "  RDI: \0"
KERRRBP:    DB       "  RBP: \0"
KERRR8:     DB       "  R8:  \0"
KERRR9:     DB       "  R9:  \0"
KERRR10:    DB       "  R10: \0"
KERRR11:    DB       "  R11: \0"
KERRR12:    DB       "  R12: \0"
KERRR13:    DB       "  R13: \0"
KERRR14:    DB       "  R14: \0"
KERRR15:    DB       "  R15: \0"

            ;# exception names
KERRSTR:    DB       "DIVISION BY ZERO EXCEPTION     \0"  ;# 0x00
            DB       "DEBUG EXCEPTION                \0"  ;# 0x01
            DB       "NON MASKABLE INTERRUPT         \0"  ;# 0x02
            DB       "BREAKPOINT EXCEPTION           \0"  ;# 0x03
            DB       "OVERFLOW EXCEPTION             \0"  ;# 0x04
            DB       "BOUND RANGE                    \0"  ;# 0x05
            DB       "INVALID OPCODE                 \0"  ;# 0x06
            DB       "DEVICE NOT AVAILABLE           \0"  ;# 0x07
            DB       "DOUBLE FAULT                   \0"  ;# 0x08
            DB       "UNSUPPORTED                    \0"  ;# 0x09
            DB       "INVALID TSS                    \0"  ;# 0x0A
            DB       "SEGMENT NOT PRESENT            \0"  ;# 0x0B
            DB       "STACK EXCEPTION                \0"  ;# 0x0C
            DB       "GENERAL PROTECTION ERROR       \0"  ;# 0x0D
            DB       "PAGE FAULT                     \0"  ;# 0x0E
            DB       "RESERVED                       \0"  ;# 0x0F
            DB       "X87 FLOATING POINT EXCEPTION   \0"  ;# 0x10
            DB       "ALIGNMENT CHECK                \0"  ;# 0x11
            DB       "MACHINE CHECK                  \0"  ;# 0x12
            DB       "SIMD FLOATING POINT EXCEPTION  \0"  ;# 0x13
            DB       "RESERVED                       \0"  ;# 0x14
            DB       "CONTROL PROTECTION EXCEPTION   \0"  ;# 0x15
            DB       "RESERVED                       \0"  ;# 0x16
            DB       "RESERVED                       \0"  ;# 0x17
            DB       "RESERVED                       \0"  ;# 0x18
            DB       "RESERVED                       \0"  ;# 0x19
            DB       "RESERVED                       \0"  ;# 0x1A
            DB       "RESERVED                       \0"  ;# 0x1B
            DB       "HYPERVISOR INJECTION EXCEPTION \0"  ;# 0x1C
            DB       "VMM COMMUNICATION EXCEPTION    \0"  ;# 0x1D
            DB       "SECURITY EXCEPTION             \0"  ;# 0x1E
            DB       "RESERVED                       \0"  ;# 0x1F
            ;#       "0123456789ABCDEF0123456789ABCDEF"
