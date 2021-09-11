;###############################################################################
;# File name:    KERNEL/IRQ.ASM
;# DESCRIPTION:  KERNEL I/O APIC AND LAPIC DRIVER
;# AUTHOR:       RAMSES A.
;###############################################################################
;#
;# UPCR OPERATING SYSTEM FOR X86_64 ARCHITECTURE
;# COPYRIGHT (C) 2021 RAMSES A.
;#
;# PERMISSION IS HEREBY GRANTED, FREE OF CHARGE, TO ANY PERSON OBTAINING A COPY
;# OF THIS SOFTWARE AND ASSOCIATED DOCUMENTATION FILES (THE "SOFTWARE"), TO DEAL
;# IN THE SOFTWARE WITHOUT RESTRICTION, INCLUDING WITHOUT LIMITATION THE RIGHTS
;# TO USE, COPY, MODIFY, MERGE, PUBLISH, DISTRIBUTE, SUBLICENSE, AND/OR SELL
;# COPIES OF THE SOFTWARE, AND TO PERMIT PERSONS TO WHOM THE SOFTWARE IS
;# FURNISHED TO DO SO, SUBJECT TO THE FOLLOWING CONDITIONS:
;#
;# THE ABOVE COPYRIGHT NOTICE AND THIS PERMISSION NOTICE SHALL BE INCLUDED IN ALL
;# COPIES OR SUBSTANTIAL PORTIONS OF THE SOFTWARE.
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
            PUBLIC   KIRQISR

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

            ;# INITIALIZE TIMER IVT
            MOV      EAX, IVT_IRQ_TIMER | 0x20000
            MOV      EDI, LAPIC_TIMERIVT
            MOV      [EDI], EAX

            ;# RUN TIMER
            MOV      EAX, 0x00
            MOV      EDI, LAPIC_TMRDIVD
            MOV      [EDI], EAX
            MOV      EAX, 0x80000000
            MOV      EDI, LAPIC_TMRINIT
            MOV      [EDI], EAX

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

;#-----------------------------------------------------------------------------#
;#                               KIRQISR()                                     #
;#-----------------------------------------------------------------------------#

KIRQISR:    ;# WE JUST RECEIVED AN IRQ DELIVERED BY LAPIC
            PUSH     RDI
            LEA      RDI, [RIP+KIRQNAME]
            CALL     KLOGMOD
            LEA      RDI, [RIP+KIRQRECV]
            CALL     KLOGSTR
            MOV      RDI, '\n'
            CALL     KLOGCHR
            POP      RDI

            ;# PRINT REGISTER DUMP
            CALL     KREGDUMP

            ;# SEND END OF INTERRUPT SIGNAL
            MOV      EAX, 0x00
            MOV      EDI, LAPIC_EOI
            MOV      [EDI], EAX

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
KIRQRECV:   DB       "WE RECEIVED AN IRQ!\0"