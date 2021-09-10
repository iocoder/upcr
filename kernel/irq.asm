;###############################################################################
;# File name:    irq.S
;# Description:  Kernel I/O APIC AND LAPIC driver
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
            PUBLIC   KIRQINIT
            PUBLIC   KIRQEN
            PUBLIC   KIRQIIPI
            PUBLIC   KIRQSIPI

;###############################################################################
;#                              TEXT SECTION                                   #
;###############################################################################

            ;# TEXT SECTION
            SEGMENT  ".text"

;#-----------------------------------------------------------------------------#
;#                               KIRQINIT()                                    #
;#-----------------------------------------------------------------------------#

KIRQINIT:   ;# PRINT INIT MSG
            LEA      RDI, [RIP+KIRQNAME]
            CALL     KLOGMOD
            LEA      RDI, [RIP+KIRQMSG]
            CALL     KLOGSTR
            MOV      RDI, '\n'
            CALL     KLOGCHR

            ;# DONE
            XOR      RAX, RAX
            RET

;#-----------------------------------------------------------------------------#
;#                               KIRQEN()                                      #
;#-----------------------------------------------------------------------------#

KIRQEN:     ;# INITIALIZE APIC ADDRESS MSR
            XOR      RAX, RAX
            XOR      RCX, RCX
            XOR      RDX, RDX
            MOV      EAX, 0xFEE00800
            MOV      ECX, MSR_APIC_BASE
            WRMSR
            NOP
            NOP

            ;# DONE
            XOR      RAX, RAX
            RET

;#-----------------------------------------------------------------------------#
;#                               KIRQIIPI()                                    #
;#-----------------------------------------------------------------------------#

KIRQIIPI:   ;# BROADCAST THE INIT IPI TO ALL PROCESSORS EXCEPT SELF
            MOV      RSI, LAPIC_INTCMDL
            MOV      EAX, 0x000C4500
            MOV      [RSI], EAX

            ;# 10-MILLISECOND DELAY LOOP.
            ;# TBD
            MOV      RCX, 0x1000000
            LOOP     .

            ;# DONE
            XOR      RAX, RAX
            RET

;#-----------------------------------------------------------------------------#
;#                                KIRQSIPI()                                   #
;#-----------------------------------------------------------------------------#

KIRQSIPI:   ;# BROADCAST THE SIPI IPI TO ALL PROCESSORS EXCEPT SELF
            MOV      RSI, LAPIC_INTCMDL
            MOV      EAX, 0x000C4600     ;# VECTOR 0x0000:0x0000
            MOV      [RSI], EAX

            ;# 200-MICROSECOND DELAY LOOP
            ;# TBD
            MOV      RCX, 0x1000000
            LOOP     .

            ;# DONE
            XOR      RAX, RAX
            RET

;###############################################################################
;#                              DATA SECTION                                   #
;###############################################################################

            ;# DATA SECTION
            SEGMENT  ".data"

;#-----------------------------------------------------------------------------#
;#                            LOGGING STRINGS                                  #
;#-----------------------------------------------------------------------------#

            ;# IRQ HEADING AND ASCII STRINGS
KIRQNAME:   DB       "KERNEL IRQ\0"
KIRQMSG:    DB       "SUPPORTED X86 INTERRUPT CONTROLLERS: LAPIC, I/O APIC.\0"
