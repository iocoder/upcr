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
            INCLUDE  "kernel/macro.inc"

;###############################################################################
;#                                GLOBALS                                      #
;###############################################################################

            ;# global symbols
            PUBLIC   KLOGINIT
            PUBLIC   KLOGCHR
            PUBLIC   KLOGDEC
            PUBLIC   KLOGHEX
            PUBLIC   KLOGSTR
            PUBLIC   KLOGATT
            PUBLIC   KLOGCLR

;###############################################################################
;#                              TEXT SECTION                                   #
;###############################################################################

            ;# text section
            SEGMENT  ".text"

;###############################################################################
;#                               KLOGINIT()                                    #
;###############################################################################

KLOGINIT:   ;# clear screen
            CALL     KLOGCLR

            ;# header colour
            MOV      $0x0A, %rdi
            MOV      $-1,   %rsi
            CALL     KLOGATT

            ;# print header
            LEA      KLOGHDR(%rip), %rdi
            CALL     KLOGSTR

            ;# welcome msg colour
            MOV      $0x0E, %rdi
            MOV      $-1,   %rsi
            CALL     KLOGATT

            ;# print welcome msg
            LEA      KLOGWEL(%rip), %rdi
            CALL     KLOGSTR

            ;# license colour
            MOV      $0x0F, %rdi
            MOV      $-1,   %rsi
            CALL     KLOGATT

            ;# print license
            LEA      KLOGLIC(%rip), %rdi
            CALL     KLOGSTR

            ;# set printing colour to yellow
            MOV      $0x0B, %rdi
            MOV      $-1,   %rsi
            CALL     KLOGATT

            ;# done
            XOR      %rax, %rax
            RET

;###############################################################################
;#                               KLOGCHR()                                     #
;###############################################################################

KLOGCHR:    # print character to VGA
            PUSH     %rdi
            CALL     KVGAPUT
            POP      %rdi

            ;# done
            XOR      %rax, %rax
            RET

;###############################################################################
;#                              KLOGDEC()                                      #
;###############################################################################

KLOGDEC:    ;# we will keep dividing RDX:RAX by 10
            MOV      %rdi, %rax
            XOR      %ecx, %ecx
            MOV      $10,  %r8

            ;# divide by 10
1:          XOR      %rdx, %rdx
            DIV      %r8

            ;# use CPU stack as a PUSH-down automaton
            PUSH     %rdx
            INC      %ecx

            ;# done?
            AND      %rax, %rax
            JNZ      1b

            ;# now print all the digits
2:          POP      %rdx
            add      $'0', %rdx
            AND      $0xFF, %rdx
            MOV      %rdx, %rdi
            PUSH     %rcx
            CALL     KLOGCHR
            POP      %rcx

            ;# all digits printed?
            DEC      %ecx
            JNZ      2b

            ;# done
            XOR      %rax, %rax
            RET

;###############################################################################
;#                               KLOGHEX()                                     #
;###############################################################################

KLOGHEX:    ;# print 0x
            PUSH     %rdi
            MOV      $'0', %rdi
            CALL     KVGAPUT
            MOV      $'x', %rdi
            CALL     KVGAPUT
            POP      %rdi

            ;# print hexadecimal number (8 bytes - 16 hexdigits)
            MOV      $16, %cl

            ;# put next byte in RDI[3:0] (ROL unrolled to prevent stall)
1:          ROL      %rdi
            ROL      %rdi
            ROL      %rdi
            ROL      %rdi

            ;# print DL[0:3]
            PUSH     %rcx
            PUSH     %rdi
            LEA      KLOGDIGS(%rip), %rsi
            AND      $0x0F, %rdi
            ADD      %rdi, %rsi
            XOR      %rax, %rax
            MOV      (%rsi), %al
            MOV      %rax, %rdi
            CALL     KLOGCHR
            POP      %rdi
            POP      %rcx

            ;# next digit
            DEC      %cl
            JNZ      1b

            ;# done
            XOR      %rax, %rax
            RET

;###############################################################################
;#                                KLOGSTR()                                    #
;###############################################################################

KLOGSTR:    ;# fetch next character
1:          XOR      %rax, %rax
            MOV      (%rdi), %al

            ;# terminate if zero
            AND      %al, %al
            JZ       2f

            ;# print character
            PUSH     %rdi
            MOV      %rax, %rdi
            CALL     KVGAPUT
            POP      %rdi

            ;# LOOP again
            INC      %rdi
            JMP      1b

            ;# done
2:          XOR      %rax, %rax
            RET

;##############################################################################
;#                                 KLOGATT()                                  #
;##############################################################################

KLOGATT:    ;# set vga colours
            PUSH     %rdi
            PUSH     %rsi
            CALL     KVGAATT
            POP      %rsi
            POP      %rdi

            ;# done
            XOR      %rax, %rax
            RET


;##############################################################################
;#                                KLOGCLR()                                   #
;##############################################################################

KLOGCLR:    ;# clear vga screen
            PUSH     %rdi
            PUSH     %rsi
            PUSH     %rcx
            CALL     KVGACLR
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
            SEGMENT  ".data"

;###############################################################################
;#                              MODULE DATA                                    #
;###############################################################################

            ;# digits to print
KLOGDIGS:   DB       "0123456789ABCDEF"

;###############################################################################
;#                            LOGGING STRINGS                                  #
;###############################################################################

            ;# header text
KLOGHDR:    .INCBIN  "kernel/header.txt"
            DB       "\0"

            ;# welcome text
KLOGWEL:    .INCBIN  "kernel/welcome.txt"
            DB       "\0"

            ;# license text
KLOGLIC:    .INCBIN  "kernel/license.txt"
            DB       "\0"
