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
            PUSH     RDI
            MOV      RDI, 0x0A
            MOV      RSI, 0x01
            CALL     KLOGATT
            POP      RDI 

            ;# clear screen
            PUSH     RDI
            CALL     KLOGCLR
            POP      RDI

            ;# print panic heading
            PUSH     RDI
            LEA      RDI, [RIP+KERRHDR]
            CALL     KLOGSTR
            POP      RDI

            ;# print exception name
            PUSH     RDI
            LEA      RDI, [RIP+KERREXPN]
            CALL     KLOGSTR
            POP      RDI
            PUSH     RDI
            MOV      RAX, [RDI+SFRAME_NBR]
            SHL      RAX, 5
            LEA      RDI, [RIP+KERRSTR]
            ADD      RDI, RAX
            CALL     KLOGSTR
            POP      RDI

            ;# new line
            PUSH     RDI
            MOV      RDI, '\n'
            CALL     KLOGCHR
            POP      RDI

            ;# print exception code
            PUSH     RDI
            LEA      RDI, [RIP+KERREXPC]
            CALL     KLOGSTR
            POP      RDI
            PUSH     RDI
            MOV      RDI, [RDI+SFRAME_NBR]
            CALL     KLOGHEX
            POP      RDI

            ;# new line
            PUSH     RDI
            MOV      RDI, '\n'
            CALL     KLOGCHR
            POP      RDI

            ;# print err code
            PUSH     RDI
            LEA      RDI, [RIP+KERRCODE]
            CALL     KLOGSTR
            POP      RDI
            PUSH     RDI
            MOV      RDI, [RDI+SFRAME_ERR]
            CALL     KLOGHEX
            POP      RDI

            ;# new line
            PUSH     RDI
            MOV      RDI, '\n'
            CALL     KLOGCHR
            POP      RDI

            ;# print cpu core number
            PUSH     RDI
            LEA      RDI, [RIP+KERRCORE]
            CALL     KLOGSTR
            POP      RDI
            PUSH     RDI
            XOR      RAX, RAX
            MOV      EAX, [0xFEE00020]
            SHR      EAX, 24        
            MOV      RDI, RAX
            CALL     KLOGDEC
            POP      RDI

            ;# horizontal line
            PUSH     RDI
            LEA      RDI, [RIP+KERRHR]
            CALL     KLOGSTR
            POP      RDI
            
            ;# print CS
            PUSH     RDI
            LEA      RDI, [RIP+KERRCS]
            CALL     KLOGSTR
            POP      RDI
            PUSH     RDI
            MOV      RDI, [RDI+SFRAME_CS]
            CALL     KLOGHEX
            POP      RDI
            
            ;# print RIP
            PUSH     RDI
            LEA      RDI, [RIP+KERRRIP]
            CALL     KLOGSTR
            POP      RDI
            PUSH     RDI
            MOV      RDI, [RDI+SFRAME_RIP]
            CALL     KLOGHEX
            POP      RDI
            
            ;# print RFLAGS
            PUSH     RDI
            LEA      RDI, [RIP+KERRFLG]
            CALL     KLOGSTR
            POP      RDI
            PUSH     RDI
            MOV      RDI, [RDI+SFRAME_RFLAGS]
            CALL     KLOGHEX
            POP      RDI

            ;# new line
            PUSH     RDI
            MOV      RDI, '\n'
            CALL     KLOGCHR
            POP      RDI
            
            ;# print SS
            PUSH     RDI
            LEA      RDI, [RIP+KERRSS]
            CALL     KLOGSTR
            POP      RDI
            PUSH     RDI
            MOV      RDI, [RDI+SFRAME_SS]
            CALL     KLOGHEX
            POP      RDI
            
            ;# print RSP
            PUSH     RDI
            LEA      RDI, [RIP+KERRRSP]
            CALL     KLOGSTR
            POP      RDI
            PUSH     RDI
            MOV      RDI, [RDI+SFRAME_RSP]
            CALL     KLOGHEX
            POP      RDI

            ;# horizontal line
            PUSH     RDI
            LEA      RDI, [RIP+KERRHR]
            CALL     KLOGSTR
            POP      RDI
            
            ;# print RAX
            PUSH     RDI
            LEA      RDI, [RIP+KERRRAX]
            CALL     KLOGSTR
            POP      RDI
            PUSH     RDI
            MOV      RDI, [RDI+SFRAME_RAX]
            CALL     KLOGHEX
            POP      RDI
            
            ;# print RBX
            PUSH     RDI
            LEA      RDI, [RIP+KERRRBX]
            CALL     KLOGSTR
            POP      RDI
            PUSH     RDI
            MOV      RDI, [RDI+SFRAME_RBX]
            CALL     KLOGHEX
            POP      RDI
            
            ;# print RCX
            PUSH     RDI
            LEA      RDI, [RIP+KERRRCX]
            CALL     KLOGSTR
            POP      RDI
            PUSH     RDI
            MOV      RDI, [RDI+SFRAME_RCX]
            CALL     KLOGHEX
            POP      RDI

            ;# new line
            PUSH     RDI
            MOV      RDI, '\n'
            CALL     KLOGCHR
            POP      RDI

            ;# print RDX
            PUSH     RDI
            LEA      RDI, [RIP+KERRRDX]
            CALL     KLOGSTR
            POP      RDI
            PUSH     RDI
            MOV      RDI, [RDI+SFRAME_RDX]
            CALL     KLOGHEX
            POP      RDI

            ;# print RSI
            PUSH     RDI
            LEA      RDI, [RIP+KERRRSI]
            CALL     KLOGSTR
            POP      RDI
            PUSH     RDI
            MOV      RDI, [RDI+SFRAME_RSI]
            CALL     KLOGHEX
            POP      RDI

            ;# print RDI
            PUSH     RDI
            LEA      RDI, [RIP+KERRRDI]
            CALL     KLOGSTR
            POP      RDI
            PUSH     RDI
            MOV      RDI, [RDI+SFRAME_RDI]
            CALL     KLOGHEX
            POP      RDI

            ;# new line
            PUSH     RDI
            MOV      RDI, '\n'
            CALL     KLOGCHR
            POP      RDI
            
            ;# print RBP
            PUSH     RDI
            LEA      RDI, [RIP+KERRRBP]
            CALL     KLOGSTR
            POP      RDI
            PUSH     RDI
            MOV      RDI, [RDI+SFRAME_RBP]
            CALL     KLOGHEX
            POP      RDI

            ;# horizontal line
            PUSH     RDI
            LEA      RDI, [RIP+KERRHR]
            CALL     KLOGSTR
            POP      RDI
            
            ;# print R8
            PUSH     RDI
            LEA      RDI, [RIP+KERRR8]
            CALL     KLOGSTR
            POP      RDI
            PUSH     RDI
            MOV      RDI, [RDI+SFRAME_R8]
            CALL     KLOGHEX
            POP      RDI
            
            ;# print R9
            PUSH     RDI
            LEA      RDI, [RIP+KERRR9]
            CALL     KLOGSTR
            POP      RDI
            PUSH     RDI
            MOV      RDI, [RDI+SFRAME_R9]
            CALL     KLOGHEX
            POP      RDI
            
            ;# print R10
            PUSH     RDI
            LEA      RDI, [RIP+KERRR10]
            CALL     KLOGSTR
            POP      RDI
            PUSH     RDI
            MOV      RDI, [RDI+SFRAME_R10]
            CALL     KLOGHEX
            POP      RDI

            ;# new line
            PUSH     RDI
            MOV      RDI, '\n'
            CALL     KLOGCHR
            POP      RDI
            
            ;# print R11
            PUSH     RDI
            LEA      RDI, [RIP+KERRR11]
            CALL     KLOGSTR
            POP      RDI
            PUSH     RDI
            MOV      RDI, [RDI+SFRAME_R11]
            CALL     KLOGHEX
            POP      RDI
            
            ;# print R12
            PUSH     RDI
            LEA      RDI, [RIP+KERRR12]
            CALL     KLOGSTR
            POP      RDI
            PUSH     RDI
            MOV      RDI, [RDI+SFRAME_R12]
            CALL     KLOGHEX
            POP      RDI
            
            ;# print R13
            PUSH     RDI
            LEA      RDI, [RIP+KERRR13]
            CALL     KLOGSTR
            POP      RDI
            PUSH     RDI
            MOV      RDI, [RDI+SFRAME_R13]
            CALL     KLOGHEX
            POP      RDI

            ;# new line
            PUSH     RDI
            MOV      RDI, '\n'
            CALL     KLOGCHR
            POP      RDI
            
            ;# print R14
            PUSH     RDI
            LEA      RDI, [RIP+KERRR14]
            CALL     KLOGSTR
            POP      RDI
            PUSH     RDI
            MOV      RDI, [RDI+SFRAME_R14]
            CALL     KLOGHEX
            POP      RDI
            
            ;# print R15
            PUSH     RDI
            LEA      RDI, [RIP+KERRR15]
            CALL     KLOGSTR
            POP      RDI
            PUSH     RDI
            MOV      RDI, [RDI+SFRAME_R15]
            CALL     KLOGHEX
            POP      RDI

            ;# horizontal line
            PUSH     RDI
            LEA      RDI, [RIP+KERRHR]
            CALL     KLOGSTR
            POP      RDI

            ;# done
            XOR      RAX, RAX
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
            DB       "  "
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
