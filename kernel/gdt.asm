;###############################################################################
;# File name:    gdt.S
;# Description:  Kernel global descriptor table
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
            PUBLIC   KGDTINIT

;###############################################################################
;#                              TEXT SECTION                                   #
;###############################################################################

            ;# TEXT SECTION
            SEGMENT  ".text"

;#-----------------------------------------------------------------------------#
;#                                KGDTINIT()                                   #
;#-----------------------------------------------------------------------------#

KGDTINIT:   ;# PRINT INIT MSG
            LEA      RDI, [RIP+KGDTNAME]
            CALL     KLOGMOD
            LEA      RDI, [RIP+KGDTMSG]
            CALL     KLOGSTR
            MOV      RDI, '\n'
            CALL     KLOGCHR

            ;# COPY THE GDTR DESCRIPTOR TO LOWER MEMORY
            MOV      RDI, GDTR_ADDR
            MOV      RAX, [RIP+KGDTDESC]
            MOV      [RDI], RAX

            ;# COPY THE GDT TABLE TO LOWER MEMORY
            MOV      RDI, GDT_ADDR
            LEA      RSI, [RIP+KGDTSTART]
            LEA      RCX, [RIP+KGDTDESC]
            SUB      RCX, RSI

            ;# COPY LOOP
1:          MOV      AL, [RSI]
            MOV      [RDI], AL 
            INC      RSI
            INC      RDI
            LOOP     1b

            ;# LOAD GDTR DESCRIPTOR
            LGDT     [GDTR_ADDR]

            ;# MAKE A FAR JUMP TO RELOAD CS USING LONG-MODE LRETQ
            MOV      RAX, 0x20
            PUSH     RAX
            LEA      RAX, [RIP+2f]
            PUSH     RAX
            LRETQ

            ;# RELOAD OTHER SEGMENT REGISTERS
2:          MOV      AX, 0x28
            MOV      DS, AX
            MOV      ES, AX
            MOV      FS, AX
            MOV      GS, AX
            MOV      SS, AX

            ;# DONE
            XOR      RAX, RAX
            RET

;###############################################################################
;#                              DATA SECTION                                   #
;###############################################################################

            ;# DATA SECTION
            SEGMENT  ".data"

;###############################################################################
;#                              MODULE DATA                                    #
;###############################################################################

KGDTSTART:  ;# GDT TABLE FOR PROTECTED AND LONG MODE
            DQ       0x0000000000000000  ;# 0x00
            DQ       0x0000000000000000  ;# 0x00
            DQ       0x00CF9A000000FFFF  ;# 0x10 (KERN CODE 32-bit)
            DQ       0x00CF92000000FFFF  ;# 0x18 (KERN DATA 32-bit)
            DQ       0x00AF9A000000FFFF  ;# 0x20 (KERN CODE 64-bit)
            DQ       0x00AF92000000FFFF  ;# 0x28 (KERN DATA 64-bit)
            DQ       0x00AFFA000000FFFF  ;# 0x30 (USER CODE 64-bit)
            DQ       0x00AFF2000000FFFF  ;# 0x38 (USER DATA 64-bit)

KGDTDESC:   ;# GDTR DESCRIPTOR
            DW       0xFFF
            DD       GDT_ADDR
            DW       0

;###############################################################################
;#                            LOGGING STRINGS                                  #
;###############################################################################

            ;# GDT HEADING AND ASCII STRINGS
KGDTNAME:   DB       "KERNEL GDT\0"
KGDTMSG:    DB       "INITIALIZING GDT MODULE...\0"
