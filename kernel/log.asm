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

            ;# COMMON DEFINITIONS USED BY KERNEL
            INCLUDE  "kernel/macro.inc"

;###############################################################################
;#                                GLOBALS                                      #
;###############################################################################

            ;# GLOBAL SYMBOLS
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

            ;# TEXT SECTION
            SEGMENT  ".text"

;#-----------------------------------------------------------------------------#
;#                               KLOGINIT()                                    #
;#-----------------------------------------------------------------------------#

KLOGINIT:   ;# CLEAR SCREEN
            CALL     KLOGCLR

            ;# HEADER COLOUR
            MOV      RDI, 0x0A
            MOV      RSI, -1
            CALL     KLOGATT

            ;# PRINT HEADER
            LEA      RDI, [RIP+KLOGHDR]
            CALL     KLOGSTR

            ;# WELCOME MSG COLOUR
            MOV      RDI, 0x0E
            MOV      RSI, -1
            CALL     KLOGATT

            ;# PRINT WELCOME MSG
            LEA      RDI, [RIP+KLOGWEL]
            CALL     KLOGSTR

            ;# LICENSE COLOUR
            MOV      RDI, 0x0F
            MOV      RSI, -1
            CALL     KLOGATT

            ;# PRINT LICENSE
            LEA      RDI, [RIP+KLOGLIC]
            CALL     KLOGSTR

            ;# SET PRINTING COLOUR TO YELLOW
            MOV      RDI, 0x0B
            MOV      RSI, -1
            CALL     KLOGATT

            ;# DONE
            XOR      RAX, RAX
            RET

;#-----------------------------------------------------------------------------#
;#                               KLOGCHR()                                     #
;#-----------------------------------------------------------------------------#

KLOGCHR:    # print character to VGA
            PUSH     RDI
            CALL     KVGAPUT
            POP      RDI

            ;# DONE
            XOR      RAX, RAX
            RET

;#-----------------------------------------------------------------------------#
;#                              KLOGDEC()                                      #
;#-----------------------------------------------------------------------------#

KLOGDEC:    ;# WE WILL KEEP DIVIDING RDX:RAX BY 10
            MOV      RAX, RDI
            XOR      ECX, ECX
            MOV      R8, 10

            ;# DIVIDE BY 10
1:          XOR      RDX, RDX
            DIV      R8

            ;# USE CPU STACK AS A PUSH-DOWN AUTOMATON
            PUSH     RDX
            INC      ECX

            ;# DONE?
            AND      RAX, RAX
            JNZ      1b

            ;# NOW PRINT ALL THE DIGITS
2:          POP      RDX
            ADD      RDX, '0'
            AND      RDX, 0xFF
            MOV      RDI, RDX
            PUSH     RCX
            CALL     KLOGCHR
            POP      RCX

            ;# ALL DIGITS PRINTED?
            DEC      ECX
            JNZ      2b

            ;# DONE
            XOR      RAX, RAX
            RET

;#-----------------------------------------------------------------------------#
;#                               KLOGHEX()                                     #
;#-----------------------------------------------------------------------------#

KLOGHEX:    ;# PRINT HEXADECIMAL NUMBER (8 bytes - 16 hexdigits)
            MOV      CL, 16

            ;# PUT NEXT BYTE IN RDI[3:0] (ROL unrolled to prevent stall)
1:          ROL      RDI
            ROL      RDI
            ROL      RDI
            ROL      RDI

            ;# PRINT DL[0:3]
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

            ;# NEXT DIGIT
            DEC      CL
            JNZ      1b

            ;# DONE
            XOR      RAX, RAX
            RET

;#-----------------------------------------------------------------------------#
;#                                KLOGSTR()                                    #
;#-----------------------------------------------------------------------------#

KLOGSTR:    ;# FETCH NEXT CHARACTER
1:          XOR      RAX, RAX
            MOV      AL, [RDI]

            ;# TERMINATE IF ZERO
            AND      AL, AL
            JZ       2f

            ;# PRINT CHARACTER
            PUSH     RDI
            MOV      RDI, RAX
            CALL     KVGAPUT
            POP      RDI

            ;# LOOP AGAIN
            INC      RDI
            JMP      1b

            ;# DONE
2:          XOR      RAX, RAX
            RET

;#-----------------------------------------------------------------------------#
;#                                 KLOGATT()                                   #
;#-----------------------------------------------------------------------------#

KLOGATT:    ;# SET VGA COLOURS
            PUSH     RDI
            PUSH     RSI
            CALL     KVGAATT
            POP      RSI
            POP      RDI

            ;# DONE
            XOR      RAX, RAX
            RET

;#-----------------------------------------------------------------------------#
;#                                KLOGCLR()                                   #
;#-----------------------------------------------------------------------------#

KLOGCLR:    ;# CLEAR VGA SCREEN
            PUSH     RDI
            PUSH     RSI
            PUSH     RCX
            CALL     KVGACLR
            POP      RSI
            POP      RDI
            POP      RCX

            ;# DONE
            XOR      RAX, RAX
            RET

;#-----------------------------------------------------------------------------#
;#                                KLOGMOD()                                    #
;#-----------------------------------------------------------------------------#

KLOGMOD:    ;# SAVE A COPY OF RDI
            PUSH     RDI

            ;# CHANGE COLOUR TO YELLOW
            MOV      RDI, 0x0A
            MOV      RSI, -1
            CALL     KLOGATT

            ;# PRINT " ["
            MOV      RDI, ' '
            CALL     KLOGCHR
            MOV      RDI, '['
            CALL     KLOGCHR

            ;# RESTORE RDI
            POP      RDI

            ;# PRINT THE NAME OF THE MODULE
            CALL     KLOGSTR

            ;# PRINT "] "
            MOV      RDI, ']'
            CALL     KLOGCHR
            MOV      RDI, ' '
            CALL     KLOGCHR

            ;# RESET COLOUR TO WHITE
            MOV      RDI, 0x0B
            MOV      RSI, -1
            CALL     KLOGATT

            ;# DONE
            XOR      RAX, RAX
            RET

;###############################################################################
;#                              DATA SECTION                                   #
;###############################################################################

            ;# DATA SECTION
            SEGMENT  ".data"

;#-----------------------------------------------------------------------------#
;#                              MODULE DATA                                    #
;#-----------------------------------------------------------------------------#

            ;# DIGITS TO PRINT
KLOGDIGS:   DB       "0123456789ABCDEF"

;#-----------------------------------------------------------------------------#
;#                            LOGGING STRINGS                                  #
;#-----------------------------------------------------------------------------#

            ;# HEADER TEXT
KLOGHDR:    INCBIN   "kernel/header.txt"
            DB       "\0"

            ;# WELCOME TEXT
KLOGWEL:    INCBIN   "kernel/welcome.txt"
            DB       "\0"

            ;# LICENSE TEXT
KLOGLIC:    INCBIN   "kernel/license.txt"
            DB       "\0"
