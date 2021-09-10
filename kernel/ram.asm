;###############################################################################
;# File name:    ram.S
;# Description:  Kernel physical memory module
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
            PUBLIC   KRAMINIT

;###############################################################################
;#                              TEXT SECTION                                   #
;###############################################################################

            ;# TEXT SECTION
            SEGMENT  ".text"

;#-----------------------------------------------------------------------------#
;#                              KRAMINIT()                                     #
;#-----------------------------------------------------------------------------#

KRAMINIT:   ;# READ KRAMAVL FROM INIT STRUCT
            MOV      RAX, [R15+0x38]
            MOV      [RIP+KRAMAVL], RAX

            ;# READ KRAMSTART FROM INIT STRUCT
            MOV      RAX, [R15+0x40]
            MOV      [RIP+KRAMSTART], RAX

            ;# READ KRAMEND FROM INIT STRUCT
            MOV      RAX, [R15+0x48]
            MOV      [RIP+KRAMEND], RAX

            ;# PRINT RAM START
            LEA      RDI, [RIP+KRAMNAME]
            CALL     KLOGMOD
            LEA      RDI, [RIP+KRAMSTARTS]
            CALL     KLOGSTR
            MOV      RDI, [RIP+KRAMSTART]
            CALL     KLOGHEX
            MOV      RDI, '\n'
            CALL     KLOGCHR

            ;# PRINT RAM END
            LEA      RDI, [RIP+KRAMNAME]
            CALL     KLOGMOD
            LEA      RDI, [RIP+KRAMENDS]
            CALL     KLOGSTR
            MOV      RDI, [RIP+KRAMEND]
            CALL     KLOGHEX
            MOV      RDI, '\n'
            CALL     KLOGCHR

            ;# PRINT RAM SIZE
            LEA      RDI, [RIP+KRAMNAME]
            CALL     KLOGMOD
            LEA      RDI, [RIP+KRAMESIZES]
            CALL     KLOGSTR
            MOV      RDI, [RIP+KRAMEND]
            SUB      RDI, [RIP+KRAMSTART]
            SHR      RDI, 20
            CALL     KLOGDEC
            MOV      RDI, 'M'
            CALL     KLOGCHR
            MOV      RDI, 'B'
            CALL     KLOGCHR
            MOV      RDI, '\n'
            CALL     KLOGCHR

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

            ;# RAMINITINFO STRUCTURE
KRAMAVL:    DQ       0
KRAMSTART:  DQ       0
KRAMEND:    DQ       0

;#-----------------------------------------------------------------------------#
;#                            LOGGING STRINGS                                  #
;#-----------------------------------------------------------------------------#

            ;# RAM HEADING AND MESSAGES
KRAMNAME:   DB       "KERNEL RAM\0"
KRAMSTARTS: DB       "DETECTED RAM START: \0"
KRAMENDS:   DB       "DETECTED RAM END:   \0"
KRAMESIZES: DB       "DETECTED RAM SIZE:  \0"
