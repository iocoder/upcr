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
            PUBLIC   KLOGMOD

;###############################################################################
;#                              TEXT SECTION                                   #
;###############################################################################

            ;# text section
            SEGMENT  ".text"

;#-----------------------------------------------------------------------------#
;#                               KLOGINIT()                                    #
;#-----------------------------------------------------------------------------#

KLOGINIT:   ;# clear screen
            CALL     KLOGCLR

            ;# header colour
            MOV      RDI, 0x0A
            MOV      RSI, -1
            CALL     KLOGATT

            ;# print header
            LEA      RDI, [RIP+KLOGHDR]
            CALL     KLOGSTR

            ;# welcome msg colour
            MOV      RDI, 0x0E
            MOV      RSI, -1
            CALL     KLOGATT

            ;# print welcome msg
            LEA      RDI, [RIP+KLOGWEL]
            CALL     KLOGSTR

            ;# license colour
            MOV      RDI, 0x0F
            MOV      RSI, -1
            CALL     KLOGATT

            ;# print license
            LEA      RDI, [RIP+KLOGLIC]
            CALL     KLOGSTR

            ;# set printing colour to yellow
            MOV      RDI, 0x0B
            MOV      RSI, -1
            CALL     KLOGATT

            ;# done
            XOR      RAX, RAX
            RET

;#-----------------------------------------------------------------------------#
;#                               KLOGCHR()                                     #
;#-----------------------------------------------------------------------------#

KLOGCHR:    # print character to VGA
            PUSH     RDI
            CALL     KVGAPUT
            POP      RDI

            ;# done
            XOR      RAX, RAX
            RET

;#-----------------------------------------------------------------------------#
;#                              KLOGDEC()                                      #
;#-----------------------------------------------------------------------------#

KLOGDEC:    ;# we will keep dividing RDX:RAX by 10
            MOV      RAX, RDI
            XOR      ECX, ECX
            MOV      R8, 10

            ;# divide by 10
1:          XOR      RDX, RDX
            DIV      R8

            ;# use CPU stack as a PUSH-down automaton
            PUSH     RDX
            INC      ECX

            ;# done?
            AND      RAX, RAX
            JNZ      1b

            ;# now print all the digits
2:          POP      RDX
            ADD      RDX, '0'
            AND      RDX, 0xFF
            MOV      RDI, RDX
            PUSH     RCX
            CALL     KLOGCHR
            POP      RCX

            ;# all digits printed?
            DEC      ECX
            JNZ      2b

            ;# done
            XOR      RAX, RAX
            RET

;#-----------------------------------------------------------------------------#
;#                               KLOGHEX()                                     #
;#-----------------------------------------------------------------------------#

KLOGHEX:    ;# print 0x
            PUSH     RDI
            MOV      RDI, '0'
            CALL     KVGAPUT
            MOV      RDI, 'x'
            CALL     KVGAPUT
            POP      RDI

            ;# print hexadecimal number (8 bytes - 16 hexdigits)
            MOV      CL, 16

            ;# put next byte in RDI[3:0] (ROL unrolled to prevent stall)
1:          ROL      RDI
            ROL      RDI
            ROL      RDI
            ROL      RDI

            ;# print DL[0:3]
            PUSH     RCX
            PUSH     RDI
            LEA      RSI, [RIP+KLOGDIGS]
            AND      RDI, 0x0F
            ADD      RSI, RDI
            XOR      RAX, RAX
            MOV      AL, [RSI]
            MOV      RDI, RAX
            CALL     KLOGCHR
            POP      RDI
            POP      RCX

            ;# next digit
            DEC      CL
            JNZ      1b

            ;# done
            XOR      RAX, RAX
            RET

;#-----------------------------------------------------------------------------#
;#                                KLOGSTR()                                    #
;#-----------------------------------------------------------------------------#

KLOGSTR:    ;# fetch next character
1:          XOR      RAX, RAX
            MOV      AL, [RDI]

            ;# terminate if zero
            AND      AL, AL
            JZ       2f

            ;# print character
            PUSH     RDI
            MOV      RDI, RAX
            CALL     KVGAPUT
            POP      RDI

            ;# LOOP again
            INC      RDI
            JMP      1b

            ;# done
2:          XOR      RAX, RAX
            RET

;#-----------------------------------------------------------------------------#
;#                                 KLOGATT()                                   #
;#-----------------------------------------------------------------------------#

KLOGATT:    ;# set vga colours
            PUSH     RDI
            PUSH     RSI
            CALL     KVGAATT
            POP      RSI
            POP      RDI

            ;# done
            XOR      RAX, RAX
            RET

;#-----------------------------------------------------------------------------#
;#                                KLOGCLR()                                   #
;#-----------------------------------------------------------------------------#

KLOGCLR:    ;# clear vga screen
            PUSH     RDI
            PUSH     RSI
            PUSH     RCX
            CALL     KVGACLR
            POP      RSI
            POP      RDI
            POP      RCX

            ;# done
            XOR      RAX, RAX
            RET

;#-----------------------------------------------------------------------------#
;#                                KLOGMOD()                                    #
;#-----------------------------------------------------------------------------#

KLOGMOD:    ;# save a copy of RDI
            PUSH     RDI

            ;# change colour to yellow
            MOV      RDI, 0x0A
            MOV      RSI, -1
            CALL     KLOGATT

            ;# print " ["
            MOV      RDI, ' '
            CALL     KLOGCHR
            MOV      RDI, '['
            CALL     KLOGCHR

            ;# restore RDI
            POP      RDI

            ;# print the name of the module
            CALL     KLOGSTR

            ;# print "] "
            MOV      RDI, ']'
            CALL     KLOGCHR
            MOV      RDI, ' '
            CALL     KLOGCHR

            ;# reset colour to white
            MOV      RDI, 0x0B
            MOV      RSI, -1
            CALL     KLOGATT

            ;# done
            XOR      RAX, RAX
            RET

;###############################################################################
;#                              DATA SECTION                                   #
;###############################################################################

            ;# data section
            SEGMENT  ".data"

;#-----------------------------------------------------------------------------#
;#                              MODULE DATA                                    #
;#-----------------------------------------------------------------------------#

            ;# digits to print
KLOGDIGS:   DB       "0123456789ABCDEF"

;#-----------------------------------------------------------------------------#
;#                            LOGGING STRINGS                                  #
;#-----------------------------------------------------------------------------#

            ;# header text
KLOGHDR:    INCBIN   "kernel/header.txt"
            DB       "\0"

            ;# welcome text
KLOGWEL:    INCBIN   "kernel/welcome.txt"
            DB       "\0"

            ;# license text
KLOGLIC:    INCBIN   "kernel/license.txt"
            DB       "\0"
