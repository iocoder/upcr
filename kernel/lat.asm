;###############################################################################
;# File name:    KERNEL/LAT.ASM
;# DESCRIPTION:  LOCAL APIC TIMER
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
            PUBLIC   KLATINIT

;###############################################################################
;#                              TEXT SECTION                                   #
;###############################################################################

            ;# TEXT SECTION
            SEGMENT  ".text"

;#-----------------------------------------------------------------------------#
;#                               KLATINIT()                                    #
;#-----------------------------------------------------------------------------#

KLATINIT:   ;# INITIALIZE TIMER DIVIDER REGISTER
            MOV      EAX, 0x0A
            MOV      EDI, LAPIC_TMRDIVD
            MOV      [EDI], EAX

            ;# START TIMER
            MOV      EAX, 0xFFFFFFFF
            MOV      EDI, LAPIC_TMRINIT
            MOV      [EDI], EAX

            ;# WAIT FOR 10 MS.
            MOV      RDI, PIT_CTR_10MS
            CALL     KPITCH2

            ;# READ TIMER
            MOV      EDI, LAPIC_TMRCURR
            MOV      ECX, [EDI]

            ;# STOP TIMER
            XOR      EAX, EAX
            MOV      EDI, LAPIC_TMRINIT
            MOV      [EDI], EAX

            ;# RESET TIMER DIVIDER REGISTER
            MOV      EAX, 0x0B
            MOV      EDI, LAPIC_TMRDIVD
            MOV      [EDI], EAX

            ;# COMPUTE TIMER FREQUENCY
            SUB      EAX, ECX
            DEC      EAX
            SHL      EAX, 7
            XOR      EDX, EDX
            MOV      ECX, 10000
            DIV      ECX
            MOV      [RIP+KLATFREQ], EAX

            ;# PRINT TIMER FREQUENCY
            LEA      RDI, [RIP+KLATNAME]
            CALL     KCONMOD
            LEA      RDI, [RIP+KLATMSG]
            CALL     KCONSTR
            MOV      RDI, [RIP+KLATFREQ]
            CALL     KCONDEC
            MOV      RDI, 'M'
            CALL     KCONCHR
            MOV      RDI, 'H'
            CALL     KCONCHR
            MOV      RDI, 'z'
            CALL     KCONCHR
            MOV      RDI, '\n'
            CALL     KCONCHR

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

            ;# TIMER FREQUENCY
KLATFREQ:   DQ       0

;#-----------------------------------------------------------------------------#
;#                            LOGGING STRINGS                                  #
;#-----------------------------------------------------------------------------#

            ;# LAT HEADING AND ASCII STRINGS
KLATNAME:   DB       "KERNEL LAT\0"
KLATMSG:    DB       "APIC TIMER FREQUENCY: \0"
