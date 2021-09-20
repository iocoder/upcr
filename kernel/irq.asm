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
            PUBLIC   KIRQGSI
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

KIRQINIT:   ;# RETRIEVE ACPI MADT TABLE
            MOV      RDI, ACPI_TBL_MADT
            LEA      RSI, [RIP+KIRQMADT]
            CALL     KACPIGET
            MOV      RAX, [RIP+KIRQMADT+0]

            ;# PROCESS PICS
            MOV      RSI, [RIP+KIRQMADT+8] ;# MADT BASE ADDRESS
            MOV      EAX, [RSI+0x28]
            AND      EAX, 1
            JZ       1f
            MOV      RAX, 2
            MOV      [RIP+KIRQPICC], RAX

            ;# PRINT PIC MSG
1:          LEA      RDI, [RIP+KIRQNAME]
            CALL     KCONMOD
            LEA      RDI, [RIP+KIRQPICS]
            CALL     KCONSTR
            MOV      RDI, [RIP+KIRQPICC]
            CALL     KCONDEC
            MOV      RDI, '\n'
            CALL     KCONCHR

            ;# PROCESS LAPICS
            MOV      RSI, [RIP+KIRQMADT+8] ;# MADT BASE ADDRESS
            XOR      RCX, RCX
            MOV      ECX, [RIP+KIRQMADT+4]
            ADD      RCX, RSI              ;# MADT LAST ADDRESS
            ADD      RSI, 0x2C

            ;# LOOP OVER RECORDS
2:          MOV      AL, [RSI+0]
            CMP      AL, 0
            JNE      3f

            ;# FOUND A LAPIC
            MOV      RAX, [RIP+KIRQLAPC]
            INC      RAX
            MOV      [RIP+KIRQLAPC], RAX

            ;# NEXT RECORD
3:          XOR      RAX, RAX
            MOV      AL, [RSI+1]
            ADD      RSI, RAX
            CMP      RSI, RCX
            JNE      2b

            ;# PRINT LAPIC MSG
            LEA      RDI, [RIP+KIRQNAME]
            CALL     KCONMOD
            LEA      RDI, [RIP+KIRQLAPS]
            CALL     KCONSTR
            MOV      RDI, [RIP+KIRQLAPC]
            CALL     KCONDEC
            MOV      RDI, '\n'
            CALL     KCONCHR

            ;# PROCESS I/O APICS
            MOV      RSI, [RIP+KIRQMADT+8] ;# MADT BASE ADDRESS
            XOR      RCX, RCX
            MOV      ECX, [RIP+KIRQMADT+4]
            ADD      RCX, RSI              ;# MADT LAST ADDRESS
            ADD      RSI, 0x2C

            ;# LOOP OVER RECORDS
11:         MOV      AL, [RSI+0]
            CMP      AL, 1
            JNE      13f

            ;# FOUND AN I/O APIC
            LEA      RDI, [RIP+KIRQRANG]
            MOV      RAX, [RIP+KIRQIOAC]
            SHL      RAX, 4
            ADD      RDI, RAX           ;# RDI = ENTRY IN KIRQRANG

            ;# STORE I/O APIC PTR
            XOR      RAX, RAX
            MOV      EAX, [RSI+4]
            MOV      [RDI+0], RAX       ;# STORE I/O APIC ADDRESS
            MOV      R8, RAX

            ;# COMPUTE AND STORE RANGE
            MOV      EAX, [RSI+8]
            MOV      [RDI+8], EAX       ;# STORE BASE INTERRUPT (0)
            MOV      EAX, 1
            MOV      [R8+0x00], EAX
            MOV      EAX, [R8+0x10]
            SHR      EAX, 16
            AND      EAX, 0xFF
            ADD      EAX, [RSI+8]
            MOV      [RDI+12], EAX      ;# STORE LAST INTERRUPT (23)

            ;# INCREASE THE COUNTER
            MOV      RAX, [RIP+KIRQIOAC]
            INC      RAX
            MOV      [RIP+KIRQIOAC], RAX

            ;# LOOP OVER IRQ RANGE
            MOV      EDX, [RDI+8]       ;# EDX = Current IRQ number

            ;# SETUP I/O APIC INTERRUPT
12:         PUSH     RDI
            PUSH     RSI
            PUSH     RDX
            PUSH     RCX
            XOR      RDI, RDI
            MOV      EDI, EDX
            XOR      RSI, RSI
            MOV      ESI, EDI
            XOR      EDX, EDX
            CALL     KIRQGSI
            POP      RCX
            POP      RDX
            POP      RSI
            POP      RDI

            ;# LOOP IF NOT DONE YET
            CMP      EDX, [RDI+12]
            JE       13f
            INC      EDX
            JMP      12b

            ;# NEXT RECORD
13:         XOR      RAX, RAX
            MOV      AL, [RSI+1]
            ADD      RSI, RAX
            CMP      RSI, RCX
            JNE      11b

            ;# PRINT I/O APIC MSG
            LEA      RDI, [RIP+KIRQNAME]
            CALL     KCONMOD
            LEA      RDI, [RIP+KIRQIOAS]
            CALL     KCONSTR
            MOV      RDI, [RIP+KIRQIOAC]
            CALL     KCONDEC
            MOV      RDI, '\n'
            CALL     KCONCHR

            ;# PROCESS IRQ OVERRIDE
            MOV      RSI, [RIP+KIRQMADT+8] ;# MADT BASE ADDRESS
            XOR      RCX, RCX
            MOV      ECX, [RIP+KIRQMADT+4]
            ADD      RCX, RSI              ;# MADT LAST ADDRESS
            ADD      RSI, 0x2C

            ;# LOOP OVER RECORDS
21:         MOV      AL, [RSI+0]
            CMP      AL, 2
            JNE      22f

            ;# FOUND AN IRQ OVERRIDE
            PUSH     RDI
            PUSH     RSI
            PUSH     RDX
            PUSH     RCX
            XOR      EDX, EDX
            MOV      DL,  [RSI+8]
            AND      DL, 0x0A
            SHL      DL, 4
            XOR      RDI, RDI
            MOV      EDI, [RSI+4]
            XOR      RAX, RAX
            MOV      AL, [RSI+3]
            MOV      RSI, RAX
            CALL     KIRQGSI
            POP      RCX
            POP      RDX
            POP      RSI
            POP      RDI

            ;# NEXT RECORD
22:         XOR      RAX, RAX
            MOV      AL, [RSI+1]
            ADD      RSI, RAX
            CMP      RSI, RCX
            JNE      21b

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
;#                               KIRQGSI()                                     #
;#-----------------------------------------------------------------------------#
;#
;# THIS FUNCTION SETS AN I/O APIC ENTRY TO HANDLE A GLOBAL SYSTEM INTERRUPT.
;# THIS CAN BE USED BY PCI DEVICE DRIVER TO SETUP PCI INTERRUPTS.
;#
;# INPUTS: RDI = GLOBAL SYSTEM INTERRUPT NUMBER (0->24 for first I/O APIC)
;#         RSI = WHICH VECTOR (0->32 - DEPENDS ON IDT SIZE)
;#         RDX = FLAGS: BITS0-2 = (000: FIXED, 100: NMI, etc.)
;#                      BIT5 = 0 (ACTIVE HIGH),    1 (ACTIVE LOW)
;#                      BIT7 = 0 (EDGE TRIGGERED), 1 (LEVEL TRIGGERED)

KIRQGSI:    ;# FIND AN I/O APIC THAT MATCHES RDI
            MOV      RAX, RSI
            LEA      RSI, [RIP+KIRQRANG]
            MOV      RCX, [RIP+KIRQIOAC]

            ;# LOOP OVER I/O APICS
1:          CMP      RCX, 0
            JE       10f
            CMP      EDI, [RSI+8]
            JB       2f
            CMP      EDI, [RSI+12]
            JA       2f

            ;# FIND WHICH I/O APIC REGISTER TO UPDATE
            MOV      R8, [RSI+0]
            SUB      EDI, [RSI+8]
            SHL      EDI, 1
            ADD      EDI, 0x10

            ;# STORE FIRST 32-BITS IN I/O APIC
            ADD      EAX, IVT_IRQ_IOAPIC0
            MOV      AH, DL
            MOV      [R8], EDI
            MOV      [R8+0x10], EAX

            ;# STORE SECOND 32-BITS IN I/O APIC
            XOR      EAX, EAX
            INC      EDI
            MOV      [R8], EDI
            MOV      [R8+0x10], EAX

            ;# I/O APIC ENTRY INITIALIZED SUCCESSFULLY
            JMP      11f

            ;# NEXT ENTRY
2:          ADD      RSI, 16
            DEC      RCX
            JMP      1b

            ;# I/O APIC NOT FOUND
10:         MOV      RAX, 1
            RET

11:         ;# DONE
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
            CALL     KPITCH2

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
            CALL     KPITCH2

            ;# DONE
            XOR      RAX, RAX
            RET

;#-----------------------------------------------------------------------------#
;#                               KIRQISR()                                     #
;#-----------------------------------------------------------------------------#

KIRQISR:    ;# WE JUST RECEIVED AN IRQ DELIVERED BY LAPIC
            PUSH     RDI
            LEA      RDI, [RIP+KIRQRECV]
            CALL     KCONSTR
            POP      RDI

            PUSH     RDI
            MOV      RDI, [RDI+SFRAME_NBR]
            CALL     KCONHEX
            POP      RDI

            PUSH     RDI
            MOV      RDI, '\n'
            CALL     KCONCHR
            POP      RDI

            ;# CALL ALL CONSUMERS
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
;#                             MODULE DATA                                     #
;#-----------------------------------------------------------------------------#

            ;# ALIGNMENT
            ALIGN    16

            ;# MADT INFORMATION
KIRQMADT:   DQ       0
            DQ       0

            ;# MADT INFORMATION
KIRQRANG:   .SPACE   16*16  ;# 16 ENTRIES FOR MAX 16 I/O APICS

            ;# COUNTS FOR EACH CONTROLLER
KIRQPICC:   DQ       0      ;# PIC
KIRQLAPC:   DQ       0      ;# LAPIC
KIRQIOAC:   DQ       0      ;# I/O APIC

;#-----------------------------------------------------------------------------#
;#                            LOGGING STRINGS                                  #
;#-----------------------------------------------------------------------------#

            ;# IRQ HEADING AND ASCII STRINGS
KIRQNAME:   DB       "KERNEL IRQ\0"
KIRQPICS:   DB       "NUMBER OF LEGACY PIC CONTROLLERS: \0"
KIRQLAPS:   DB       "NUMBER OF LOCAL APIC CONTROLLERS: \0"
KIRQIOAS:   DB       "NUMBER OF  I/O  APIC CONTROLLERS: \0"
KIRQRECV:   DB       "WE RECEIVED AN IRQ: \0"
