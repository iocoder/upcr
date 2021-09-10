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

            ;# common definitions used by kernel
            INCLUDE  "kernel/macro.inc"

;###############################################################################
;#                                GLOBALS                                      #
;###############################################################################

            ;# global symbols
            PUBLIC   KRAMINIT

;###############################################################################
;#                              TEXT SECTION                                   #
;###############################################################################

            ;# text section
            SEGMENT  ".text"

;#-----------------------------------------------------------------------------#
;#                              KRAMINIT()                                     #
;#-----------------------------------------------------------------------------#

KRAMINIT:   ;# read KRAMAVL from init struct
            MOV      RAX, [R15+0x38]
            MOV      [RIP+KRAMAVL], RAX

            ;# read KRAMSTART from init struct
            MOV      RAX, [R15+0x40]
            MOV      [RIP+KRAMSTART], RAX

            ;# read KRAMEND from init struct
            MOV      RAX, [R15+0x48]
            MOV      [RIP+KRAMEND], RAX

            ;# print ram start
            LEA      RDI, [RIP+KRAMNAME]
            CALL     KLOGMOD
            LEA      RDI, [RIP+KRAMSTARTS]
            CALL     KLOGSTR
            MOV      RDI, [RIP+KRAMSTART]
            CALL     KLOGHEX
            MOV      RDI, '\n'
            CALL     KLOGCHR

            ;# print ram end
            LEA      RDI, [RIP+KRAMNAME]
            CALL     KLOGMOD
            LEA      RDI, [RIP+KRAMENDS]
            CALL     KLOGSTR
            MOV      RDI, [RIP+KRAMEND]
            CALL     KLOGHEX
            MOV      RDI, '\n'
            CALL     KLOGCHR

            ;# print ram size
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

            ;# RamInitInfo structure
KRAMAVL:    DQ       0
KRAMSTART:  DQ       0
KRAMEND:    DQ       0

;#-----------------------------------------------------------------------------#
;#                            LOGGING STRINGS                                  #
;#-----------------------------------------------------------------------------#

            ;# RAM heading and messages
KRAMNAME:   DB       "KERNEL RAM\0"
KRAMSTARTS: DB       "Detected RAM Start: \0"
KRAMENDS:   DB       "Detected RAM End:   \0"
KRAMESIZES: DB       "Detected RAM Size:  \0"
