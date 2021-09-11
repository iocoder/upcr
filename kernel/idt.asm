;###############################################################################
;# FILE NAME:    KERNEL/IDT.ASM
;# DESCRIPTION:  KERNEL INTERRUPT DESCRIPTOR TABLE
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
            PUBLIC   KIDTINIT

;###############################################################################
;#                                 MACROS                                      #
;###############################################################################

            ;# DPL LEVELS
            EQU      DPL0,          0x0000
            EQU      DPL1,          0x2000
            EQU      DPL2,          0x4000
            EQU      DPL3,          0x6000

            ;# GATE TYPES
            EQU      GATE_CALL,     0x0C00    ;# NOT EVEN IN IDT
            EQU      GATE_INTR,     0x0E00    ;# DISABLES INTERRUPTS
            EQU      GATE_TRAP,     0x0F00    ;# DOES NOT DISABLE INTERRUPTS

            ;# PRESENT FIELD
            EQU      PRESENT,       0x8000

            ;# GATE SIZE
            EQU      GATE_SIZE,     0x100

;###############################################################################
;#                              TEXT SECTION                                   #
;###############################################################################

            ;# TEXT SECTION
            SEGMENT  ".text"

;#-----------------------------------------------------------------------------#
;#                            EXCEPTION GATES                                  #
;#-----------------------------------------------------------------------------#

            ;# MACRO TO PUSH A DUMMY ERROR CODE IF NEEDED
            MACRO    PUSHE   DummyErr
            IF       \DummyErr
            PUSH     0x00                      
            ENDIF
            ENDM

            ;# MACRO TO POP A DUMMY ERROR CODE IF NEEDED
            MACRO    POPE   DummyErr
            IF       \DummyErr
            ADD      RSP, 8
            ENDIF
            ENDM

            ;# MACRO TO HALT THE KERNEL IN CASE OF DPL ERROR
            MACRO    CHKDPL   CheckDPL
            IF       \CheckDPL
            MOV      RAX, [RSP+SFRAME_CS]       ;# LOAD ORIGIN'S CS
            AND      RAX, 3                     ;# MASK DPL BITS
            JZ       KERRPANIC                  ;# PANIC IF DPL IS 0
            ENDIF
            ENDM

            ;# TEMPLATE MACRO FOR ALL IDT GATES
            MACRO    GATE  Handler, ExpNbr, DummyErr, CheckDPL
            ALIGN    GATE_SIZE
            PUSHE    \DummyErr                  ;# PUSH DUMMY ERROR IF NEEDED
            PUSH     \ExpNbr                    ;# PUSH EXCEPTION NUMBER
            PUSH     R15                        ;# PUSH A COPY OF R15
            PUSH     R14                        ;# PUSH A COPY OF R14
            PUSH     R13                        ;# PUSH A COPY OF R13
            PUSH     R12                        ;# PUSH A COPY OF R12
            PUSH     R11                        ;# PUSH A COPY OF R11
            PUSH     R10                        ;# PUSH A COPY OF R10
            PUSH     R9                         ;# PUSH A COPY OF R9
            PUSH     R8                         ;# PUSH A COPY OF R8
            PUSH     RBP                        ;# PUSH A COPY OF RBP
            PUSH     RDI                        ;# PUSH A COPY OF RDI
            PUSH     RSI                        ;# PUSH A COPY OF RSI
            PUSH     RDX                        ;# PUSH A COPY OF RDX
            PUSH     RCX                        ;# PUSH A COPY OF RCX
            PUSH     RBX                        ;# PUSH A COPY OF RBX
            PUSH     RAX                        ;# PUSH A COPY OF RAX
            SUB      RSP, 0x50                  ;# PUSH PADDING
            CHKDPL   \CheckDPL                  ;# CHECK DPL IF NEEDED
            MOV      RDI, RSP                   ;# STORE FRAME BASE
            CALL     \Handler                   ;# HANDLE INTERRUPT
            ADD      RSP, 0x50                  ;# POP PADDING
            POP      RAX                        ;# POP A COPY OF RAX
            POP      RBX                        ;# POP A COPY OF RBX
            POP      RCX                        ;# POP A COPY OF RCX
            POP      RDX                        ;# POP A COPY OF RDX
            POP      RSI                        ;# POP A COPY OF RSI
            POP      RDI                        ;# POP A COPY OF RDI
            POP      RBP                        ;# POP A COPY OF RBP
            POP      R8                         ;# POP A COPY OF R8
            POP      R9                         ;# POP A COPY OF R9
            POP      R10                        ;# POP A COPY OF R10
            POP      R11                        ;# POP A COPY OF R11
            POP      R12                        ;# POP A COPY OF R12
            POP      R13                        ;# POP A COPY OF R13
            POP      R14                        ;# POP A COPY OF R14
            POP      R15                        ;# POP A COPY OF R15
            ADD      RSP, 8                     ;# POP EXCEPTION NUMBER
            POPE     \DummyErr                  ;# POP DUMMY ERROR IF NEEDED
            IRETQ                               ;# RETURN FROM EXCEPTION
            ALIGN    GATE_SIZE
            ENDM

;#-----------------------------------------------------------------------------#
;#                               IDT GATES                                     #
;#-----------------------------------------------------------------------------#

            ;# ALIGN TO 256-BYTE BORDER
            ALIGN    GATE_SIZE

KIDTEXPS:   ;# EXCEPTION GATES (TRIGGERED BY CPU)
            GATE     KIDTEXP, 0x00, 1, 1
            GATE     KIDTEXP, 0x01, 1, 1
            GATE     KIDTEXP, 0x02, 1, 1
            GATE     KIDTEXP, 0x03, 1, 1
            GATE     KIDTEXP, 0x04, 1, 1
            GATE     KIDTEXP, 0x05, 1, 1
            GATE     KIDTEXP, 0x06, 1, 1
            GATE     KIDTEXP, 0x07, 1, 1
            GATE     KIDTEXP, 0x08, 0, 1
            GATE     KIDTEXP, 0x09, 0, 1
            GATE     KIDTEXP, 0x0A, 0, 1
            GATE     KIDTEXP, 0x0B, 0, 1
            GATE     KIDTEXP, 0x0C, 0, 1
            GATE     KIDTEXP, 0x0D, 0, 1
            GATE     KIDTEXP, 0x0E, 0, 1
            GATE     KIDTEXP, 0x0F, 0, 1
            GATE     KIDTEXP, 0x10, 1, 1
            GATE     KIDTEXP, 0x11, 0, 1
            GATE     KIDTEXP, 0x12, 1, 1
            GATE     KIDTEXP, 0x13, 1, 1
            GATE     KIDTEXP, 0x14, 0, 1
            GATE     KIDTEXP, 0x15, 0, 1
            GATE     KIDTEXP, 0x16, 0, 1
            GATE     KIDTEXP, 0x17, 0, 1
            GATE     KIDTEXP, 0x18, 0, 1
            GATE     KIDTEXP, 0x19, 0, 1
            GATE     KIDTEXP, 0x1A, 0, 1
            GATE     KIDTEXP, 0x1B, 0, 1
            GATE     KIDTEXP, 0x1C, 0, 1
            GATE     KIDTEXP, 0x1D, 0, 1
            GATE     KIDTEXP, 0x1E, 0, 1
            GATE     KIDTEXP, 0x1F, 0, 1

KIDTSVCS:   ;# SVC GATES (TRIGGERED BY PROGRAM)
            GATE     KIDTSVC, 0x20, 1, 0

KIDTSMPS:   ;# SMP GATES (TRIGGERED BY KERNEL)
            GATE     KIDTSMP, 0x21, 1, 0

KIDTIRQS:   ;# IRQ GATES (TRIGGERED BY LAPIC)
            GATE     KIDTIRQ, 0x22, 1, 0
            GATE     KIDTIRQ, 0x23, 1, 0
            GATE     KIDTIRQ, 0x24, 1, 0
            GATE     KIDTIRQ, 0x25, 1, 0
            GATE     KIDTIRQ, 0x26, 1, 0
            GATE     KIDTIRQ, 0x27, 1, 0
            GATE     KIDTIRQ, 0x28, 1, 0
            GATE     KIDTIRQ, 0x29, 1, 0
            GATE     KIDTIRQ, 0x2A, 1, 0
            GATE     KIDTIRQ, 0x2B, 1, 0
            GATE     KIDTIRQ, 0x2C, 1, 0
            GATE     KIDTIRQ, 0x2D, 1, 0
            GATE     KIDTIRQ, 0x2E, 1, 0
            GATE     KIDTIRQ, 0x2F, 1, 0
            GATE     KIDTIRQ, 0x30, 1, 0
            GATE     KIDTIRQ, 0x31, 1, 0
            GATE     KIDTIRQ, 0x32, 1, 0
            GATE     KIDTIRQ, 0x33, 1, 0
            GATE     KIDTIRQ, 0x34, 1, 0
            GATE     KIDTIRQ, 0x35, 1, 0
            GATE     KIDTIRQ, 0x36, 1, 0
            GATE     KIDTIRQ, 0x37, 1, 0
            GATE     KIDTIRQ, 0x38, 1, 0
            GATE     KIDTIRQ, 0x39, 1, 0
            GATE     KIDTIRQ, 0x3A, 1, 0
            GATE     KIDTIRQ, 0x3B, 1, 0
            GATE     KIDTIRQ, 0x3C, 1, 0
            GATE     KIDTIRQ, 0x3D, 1, 0
            GATE     KIDTIRQ, 0x3E, 1, 0
            GATE     KIDTIRQ, 0x3F, 1, 0

;#-----------------------------------------------------------------------------#
;#                                KIDTINIT()                                   #
;#-----------------------------------------------------------------------------#

KIDTINIT:   ;# PRINT INIT MSG
            LEA      RDI, [RIP+KIDTNAME]
            CALL     KLOGMOD
            LEA      RDI, [RIP+KIDTMSG]
            CALL     KLOGSTR
            MOV      RDI, '\n'
            CALL     KLOGCHR

            ;# INITIALIZE IDT EXCEPTION ENTRIES
            ;# RDI: ADDRESS OF FIRST IDT DESCRIPTOR TO FILL
            ;# RCX: ADDRESS OF THE IDT DESCRIPTOR TO STOP AT
            ;# RSI: ADDRESS OF KIDTEXPS
            MOV      RDI, IDT_ADDR
            MOV      RCX, IDT_ADDR
            ADD      RDI, IVT_EXP_START*16
            ADD      RCX, IVT_EXP_START*16+IVT_EXP_COUNT*16
            LEA      RSI, [RIP+KIDTEXPS]

            ;# STORE AN IDT DESCRIPTOR USING GATE ADDRESS IN RAX
1:          MOV      RAX, RSI
            MOV      [RDI+ 0], AX 
            MOV      AX, 0x20
            MOV      [RDI+ 2], AX
            MOV      AX, GATE_INTR|PRESENT|DPL0
            MOV      [RDI+ 4], AX
            SHR      RAX, 16
            MOV      [RDI+ 6], AX
            SHR      RAX, 16
            MOV      [RDI+ 8], EAX
            MOV      EAX, 0
            MOV      [RDI+12], EAX

            ;# UPDATE RAX TO NEXT GATE ADDRESS, RDI TO NEXT DESCRIPTOR
            ADD      RSI, GATE_SIZE
            ADD      RDI, 16

            ;# DONE YET?
            CMP      RCX, RDI
            JNZ      1b

            ;# INITIALIZE IDT SVC ENTRIES
            ;# RDI: ADDRESS OF FIRST IDT DESCRIPTOR TO FILL
            ;# RCX: ADDRESS OF THE IDT DESCRIPTOR TO STOP AT
            ;# RSI: ADDRESS OF KIDTSVCS
            MOV      RDI, IDT_ADDR
            MOV      RCX, IDT_ADDR
            ADD      RDI, IVT_SVC_START*16
            ADD      RCX, IVT_SVC_START*16+IVT_SVC_COUNT*16
            LEA      RSI, [RIP+KIDTSVCS]

            ;# STORE AN IDT DESCRIPTOR USING GATE ADDRESS IN RAX
1:          MOV      RAX, RSI
            MOV      [RDI+ 0], AX
            MOV      AX, 0x20
            MOV      [RDI+ 2], AX
            MOV      AX, GATE_INTR|PRESENT|DPL3
            MOV      [RDI+ 4], AX
            SHR      RAX, 16
            MOV      [RDI+ 6], AX
            SHR      RAX, 16
            MOV      [RDI+ 8], EAX
            MOV      EAX, 0
            MOV      [RDI+12], EAX

            ;# UPDATE RAX TO NEXT GATE ADDRESS, RDI TO NEXT DESCRIPTOR
            ADD      RSI, GATE_SIZE
            ADD      RDI, 16

            ;# DONE YET?
            CMP      RCX, RDI
            JNZ      1b

            ;# INITIALIZE IDT SMP ENTRIES
            ;# RDI: ADDRESS OF FIRST IDT DESCRIPTOR TO FILL
            ;# RCX: ADDRESS OF THE IDT DESCRIPTOR TO STOP AT
            ;# RSI: ADDRESS OF KIDTSMPS
            MOV      RDI, IDT_ADDR
            MOV      RCX, IDT_ADDR
            ADD      RDI, IVT_SMP_START*16
            ADD      RCX, IVT_SMP_START*16+IVT_SMP_COUNT*16
            LEA      RSI, [RIP+KIDTSMPS]

            ;# STORE AN IDT DESCRIPTOR USING GATE ADDRESS IN RAX
1:          MOV      RAX, RSI
            MOV      [RDI+ 0], AX
            MOV      AX, 0x20
            MOV      [RDI+ 2], AX
            MOV      AX, GATE_INTR|PRESENT|DPL0
            MOV      [RDI+ 4], AX
            SHR      RAX, 16
            MOV      [RDI+ 6], AX
            SHR      RAX, 16
            MOV      [RDI+ 8], EAX
            MOV      EAX, 0
            MOV      [RDI+12], EAX

            ;# UPDATE RAX TO NEXT GATE ADDRESS, RDI TO NEXT DESCRIPTOR
            ADD      RSI, GATE_SIZE
            ADD      RDI, 16

            ;# DONE YET?
            CMP      RCX, RDI
            JNZ      1b

            ;# INITIALIZE IDT IRQ ENTRIES
            ;# RDI: ADDRESS OF FIRST IDT DESCRIPTOR TO FILL
            ;# RCX: ADDRESS OF THE IDT DESCRIPTOR TO STOP AT
            ;# RSI: ADDRESS OF KIDTIRQS
            MOV      RDI, IDT_ADDR
            MOV      RCX, IDT_ADDR
            ADD      RDI, IVT_IRQ_START*16
            ADD      RCX, IVT_IRQ_START*16+IVT_IRQ_COUNT*16
            LEA      RSI, [RIP+KIDTIRQS]

            ;# STORE AN IDT DESCRIPTOR USING GATE ADDRESS IN RAX
1:          MOV      RAX, RSI
            MOV      [RDI+ 0], AX
            MOV      AX, 0x20
            MOV      [RDI+ 2], AX
            MOV      AX, GATE_INTR|PRESENT|DPL0
            MOV      [RDI+ 4], AX
            SHR      RAX, 16
            MOV      [RDI+ 6], AX
            SHR      RAX, 16
            MOV      [RDI+ 8], EAX
            MOV      EAX, 0
            MOV      [RDI+12], EAX

            ;# UPDATE RAX TO NEXT GATE ADDRESS, RDI TO NEXT DESCRIPTOR
            ADD      RSI, GATE_SIZE
            ADD      RDI, 16

            ;# DONE YET?
            CMP      RCX, RDI
            JNZ      1b

            ;# INITIALIZE IDTR DESCRIPTOR
            MOV      AX, 0xFFF
            MOV      [IDTR_ADDR+0], AX
            MOV      EAX, IDT_ADDR 
            MOV      [IDTR_ADDR+2], EAX

            ;# LOAD IDT TABLE
            LIDT     [IDTR_ADDR]

            ;# DONE
3:          XOR      RAX, RAX
            RET

;#-----------------------------------------------------------------------------#
;#                              KIDTEXP()                                      #
;#-----------------------------------------------------------------------------#

KIDTEXP:    ;# ACQUIRE KERNEL LOCK
            PUSH     RDI
            CALL     KLOCPEND
            POP      RDI

            ;# INFINTE LOOP (TODO: KSCHISR/KTSKISR/KSIGISR)
            JMP      .

            ;# RELEASE THE LOCK
            PUSH     RDI
            CALL     KLOCPOST
            POP      RDI

            ;# DONE
            XOR      RAX, RAX
            RET

;#-----------------------------------------------------------------------------#
;#                               KIDTSVC()                                     #
;#-----------------------------------------------------------------------------#

KIDTSVC:    ;# ACQUIRE KERNEL LOCK
            PUSH     RDI
            CALL     KLOCPEND
            POP      RDI

            ;# INFINTE LOOP (TODO: KSVCISR)
            JMP      .

            ;# RELEASE THE LOCK
            PUSH     RDI
            CALL     KLOCPOST
            POP      RDI

            ;# DONE
            XOR      RAX, RAX
            RET

;#-----------------------------------------------------------------------------#
;#                               KIDTSMP()                                     #
;#-----------------------------------------------------------------------------#

KIDTSMP:    ;# ACQUIRE KERNEL LOCK
            PUSH     RDI
            CALL     KLOCPEND
            POP      RDI

            ;# ENABLE SMP CORE
            PUSH     RDI
            CALL     KSMPISR
            POP      RDI

            ;# RELEASE THE LOCK
            PUSH     RDI
            CALL     KLOCPOST
            POP      RDI

            ;# DONE
            XOR      RAX, RAX
            RET

;#-----------------------------------------------------------------------------#
;#                               KIDTIRQ()                                     #
;#-----------------------------------------------------------------------------#

KIDTIRQ:    ;# ACQUIRE KERNEL LOCK
            PUSH     RDI
            CALL     KLOCPEND
            POP      RDI

            ;# CALL IRQ MODULE ISR
            CALL     KIRQISR

            ;# RELEASE THE LOCK
            PUSH     RDI
            CALL     KLOCPOST
            POP      RDI

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

            ;# IDT HEADING AND ASCII STRINGS
KIDTNAME:   DB       "KERNEL IDT\0"
KIDTMSG:    DB       "INITIALIZING IDT MODULE...\0"
