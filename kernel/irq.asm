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
            PUBLIC   KIRQSETUP
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
            CALL     KCONMOD
            LEA      RDI, [RIP+KIRQMSG]
            CALL     KCONSTR
            MOV      RDI, '\n'
            CALL     KCONCHR

            ;# DONE
            XOR      RAX, RAX
            RET

;#-----------------------------------------------------------------------------#
;#                              KIRQSETUP()                                    #
;#-----------------------------------------------------------------------------#

KIRQSETUP:  ;# MASK SPURIOUS IVT REGISTER
            MOV      EAX, 0x10000
            MOV      EDI, LAPIC_SPUIVT
            MOV      [EDI], EAX

            ;# MASK TIMER IVT REGISTER
            MOV      EAX, 0x10000
            MOV      EDI, LAPIC_TIMERIVT
            MOV      [EDI], EAX

            ;# MASK THERMAL SENSOR IVT REGISTER
            MOV      EAX, 0x10000
            MOV      EDI, LAPIC_THERMIVT
            MOV      [EDI], EAX

            ;# MASK PERF COUNTER IVT REGISTER
            MOV      EAX, 0x10000
            MOV      EDI, LAPIC_PERFCIVT
            MOV      [EDI], EAX

            ;# MASK LINT0 IVT REGISTER
            MOV      EAX, 0x10000
            MOV      EDI, LAPIC_LINT0IVT
            MOV      [EDI], EAX

            ;# MASK LINT1 IVT REGISTER
            MOV      EAX, 0x10000
            MOV      EDI, LAPIC_LINT1IVT
            MOV      [EDI], EAX

            ;# MASK ERROR IVT REGISTER
            MOV      EAX, 0x10000
            MOV      EDI, LAPIC_ERRORIVT
            MOV      [EDI], EAX

            ;# INITIALIZE SPURIOUS IVT REGISTER
            MOV      EAX, IVT_IRQ_SPURI | 0x100
            MOV      EDI, LAPIC_SPUIVT
            MOV      [EDI], EAX

            ;# INITIALIZE TIMER IVT REGISTER
            MOV      EAX, IVT_IRQ_TIMER | 0x40000
            MOV      EDI, LAPIC_TIMERIVT
            MOV      [EDI], EAX

            ;# INITIALIZE THERMAL SENSOR IVT REGISTER
            MOV      EAX, IVT_IRQ_THERM
            MOV      EDI, LAPIC_THERMIVT
            MOV      [EDI], EAX

            ;# INITIALIZE PERF COUNTER IVT REGISTER
            MOV      EAX, IVT_IRQ_PERFC
            MOV      EDI, LAPIC_PERFCIVT
            MOV      [EDI], EAX

            ;# INITIALIZE LINT0 IVT REGISTER
            MOV      EAX, IVT_IRQ_LINT0
            MOV      EDI, LAPIC_LINT0IVT
            MOV      [EDI], EAX

            ;# INITIALIZE LINT1 IVT REGISTER
            MOV      EAX, IVT_IRQ_LINT1
            MOV      EDI, LAPIC_LINT1IVT
            MOV      [EDI], EAX

            ;# INITIALIZE ERROR IVT REGISTER
            MOV      EAX, IVT_IRQ_ERROR
            MOV      EDI, LAPIC_ERRORIVT
            MOV      [EDI], EAX

            ;# INITIALIZE TASK PRIORITY REGISTER
            MOV      EAX, 0
            MOV      EDI, LAPIC_TASKPRI
            MOV      [EDI], EAX

            ;# MAKE SURE ALL WRITES ARE HANDLED
            MFENCE

            ;# ENABLE LAPIC
            MOV      ECX, MSR_APIC_BASE
            RDMSR
            OR       EAX, 0x800
            WRMSR

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

            ;# WAIT FOR 10 MS.
            MOV      RDI, PIT_CTR_10MS
            CALL     KPITCH0

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

            ;# WAIT FOR 10 MS.
            MOV      RDI, PIT_CTR_10MS
            CALL     KPITCH0

            ;# DONE
            XOR      RAX, RAX
            RET

;#-----------------------------------------------------------------------------#
;#                               KIRQISR()                                     #
;#-----------------------------------------------------------------------------#

KIRQISR:    ;# WE JUST RECEIVED AN IRQ DELIVERED BY LAPIC
            CALL     KTMRINTR

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
