;###############################################################################
;# File name:    KERNEL/SMP.ASM
;# DESCRIPTION:  KERNEL CPU INITIALIZATION CODE
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
            PUBLIC   KSMPINIT
            PUBLIC   KSMPISR

;###############################################################################
;#                              TEXT SECTION                                   #
;###############################################################################

            ;# TEXT SECTION
            SEGMENT  ".text"

;#-----------------------------------------------------------------------------#
;#                          REAL MODE TRAMPOLINE                               #
;#-----------------------------------------------------------------------------#

KSMP16:     ;# 16-BIT CODE
            CODE16

            ;# FIRST INSTRUCTION EXECUTED BY CPU CORE!!!
            MOV      AX, 0x55AA

            ;# MAKE SURE INTERRUPTS ARE DISABLED
            cli

            ;# INITIALIZE SEGMENT REGISTERS
            XOR      BX, BX
            MOV      DS, BX
            MOV      ES, BX
            MOV      SS, BX

            ;# LOAD GDTR REGISTER
            LGDT     [MEM_GDTR]

            ;# ENTER PROTECTED MODE
            MOV      EAX, CR0
            OR       EAX, 1
            MOV      CR0, EAX

            ;# FAR JUMP INTO 32-BIT MODE
            LJMP     0x10, KSMP32-KSMP16

;#-----------------------------------------------------------------------------#
;#                        PROTECTED MODE TRAMPOLINE                            #
;#-----------------------------------------------------------------------------#

KSMP32:     ;# 32-BIT CODE
            CODE32

            ;# INITIALIZE SEGMENT REGISTERS
            MOV      AX, 0x18
            MOV      DS, AX
            MOV      ES, AX
            MOV      FS, AX
            MOV      GS, AX
            MOV      SS, AX

            ;# ENABLE PHYSICAL ADDRESS EXTENSION
            MOV      EAX, CR4
            OR       EAX, 0x00000020
            MOV      CR4, EAX

            ;# ENABLE LONG-MODE IN EFER
            MOV      ECX, MSR_EFER
            RDMSR
            OR       EAX, 0x00000100
            WRMSR

            ;# LOAD CR3 WITH PML4 TABLE BASE
            MOV      EAX, MEM_CPU_PTABLES
            MOV      CR3, EAX

            ;# ENABLE PAGING; THIS ACTIVATES LONG MODE
            MOV      EAX, CR0
            OR       EAX, 0x80000000
            MOV      CR0, EAX

            ;# WE ARE IN COMPATIBILITY MODE NOW! JUMP TO CODE64
            LJMP     0x20, KSMP64-KSMP16

;#-----------------------------------------------------------------------------#
;#                          LONG MODE TRAMPOLINE                               #
;#-----------------------------------------------------------------------------#

KSMP64:     ;# 64-BIT CODE
            CODE64

            ;# INITIALIZE SEGMENT REGISTERS
            MOV      AX, 0x0028
            MOV      DS, AX
            MOV      ES, AX
            MOV      FS, AX
            MOV      GS, AX
            MOV      SS, AX

            ;# INITIALIZE ALL 64-BIT GPRS
            MOV      RAX, 0x1111111111111111
            MOV      RBX, 0x2222222222222222
            MOV      RCX, 0x3333333333333333
            MOV      RDX, 0x4444444444444444
            MOV      RSI, 0xAAAAAAAAAAAAAAAA
            MOV      RDI, 0xBBBBBBBBBBBBBBBB
            MOV      RBP, 0xCCCCCCCCCCCCCCCC
            MOV      RSP, 0xDDDDDDDDDDDDDDDD
            MOV      R8,  0x1111111111111111
            MOV      R9,  0x2222222222222222
            MOV      R10, 0x3333333333333333
            MOV      R11, 0x4444444444444444
            MOV      R12, 0xAAAAAAAAAAAAAAAA
            MOV      R13, 0xBBBBBBBBBBBBBBBB
            MOV      R14, 0xCCCCCCCCCCCCCCCC
            MOV      R15, 0xDDDDDDDDDDDDDDDD

            ;# READ LOCAL APIC ID
            XOR      RAX, RAX
            MOV      EAX, [LAPIC_ID]
            SHR      EAX, 24

            ;# USE THIS PARTICULAR CPU STACK
            MOV      RSP, RAX
            SHL      RSP, 12
            ADD      RSP, MEM_CPU_STACKS
            ADD      RSP, 0x1000
            MOV      RBP, RSP
            NOP

            ;# INITIALIZE IDT
            LIDT     [MEM_IDTR]

            ;# ENABLE THE CORE
            INT      IVT_SMP_EN

            ;# WAIT UNTIL CPU0 SENDS SCHED IRQ
            JMP      .

;#-----------------------------------------------------------------------------#
;#                              KSMPINIT()                                     #
;#-----------------------------------------------------------------------------#

KSMPINIT:   ;# PRINT INIT MSG
            LEA      RDI, [RIP+KSMPNAME]
            CALL     KLOGMOD
            LEA      RDI, [RIP+KSMPMSG]
            CALL     KLOGSTR
            MOV      RDI, '\n'
            CALL     KLOGCHR

            ;# COPY THE TRAMPOLINE TO LOWER MEMORY
            MOV      RDI, MEM_TRUMP
            LEA      RSI, [RIP+KSMP16]
            LEA      RCX, [RIP+KSMPINIT]
            SUB      RCX, RSI

            ;# COPY LOOP
1:          MOV      AL, [RSI]
            MOV      [RDI], AL
            INC      RSI
            INC      RDI
            LOOP     1b

            ;# WE NEED TO INITIALIZE CORE 0 FIRST
            INT      IVT_SMP_EN

            ;# SEND INIT-SIPI-SIPI SEQUENCE TO OTHER CPUS
            CALL     KIRQIIPI
            CALL     KIRQSIPI
            CALL     KIRQSIPI

            ;# PRINT NUMBER OF DETECTED CORES
            LEA      RDI, [RIP+KSMPNAME]
            CALL     KLOGMOD
            LEA      RDI, [RIP+KSMPDET]
            CALL     KLOGSTR
            MOV      RDI, [RIP+KSMPCORES]
            CALL     KLOGDEC
            MOV      RDI, '\n'
            CALL     KLOGCHR

            ;# PRINT SUCCESS MESSAGE
            LEA      RDI, [RIP+KSMPNAME]
            CALL     KLOGMOD
            LEA      RDI, [RIP+KSMPSUC]
            CALL     KLOGSTR
            MOV      RDI, '\n'
            CALL     KLOGCHR

            ;# DONE
            XOR      RAX, RAX
            RET

;#-----------------------------------------------------------------------------#
;#                               KSMPISR()                                     #
;#-----------------------------------------------------------------------------#

KSMPISR:    ;# INITIALIZE CPU CORE
            PUSH     RDI
            CALL     KCPUSETUP
            POP      RDI

            ;# INITIALIZE LAPIC AND ENABLE IRQS
            PUSH     RDI
            CALL     KIRQSETUP
            POP      RDI

            ;# SCHEDULE TIMER INTERRUPTS
            PUSH     RDI
            CALL     KTMRSETUP
            POP      RDI

            ;# ENABLE INTERRUPTS ON RETURN
            MOV      RAX, [RDI+SFRAME_RFLAGS]
            OR       RAX, 0x0200
            MOV      [RDI+SFRAME_RFLAGS], RAX

            ;# INCREASE CORE COUNT
            MOV      RAX, [RIP+KSMPCORES]
            INC      RAX
            MOV      [RIP+KSMPCORES], RAX

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

            ;# HOW MANY CORES IN THE SYSTEM
KSMPCORES:  DQ       0

;#-----------------------------------------------------------------------------#
;#                            LOGGING STRINGS                                  #
;#-----------------------------------------------------------------------------#

            ;# SMP MODULE NAME AND MESSAGES
KSMPNAME:   DB       "KERNEL SMP\0"
KSMPMSG:    DB       "DETECTING CPU CORES AVAILABLE IN THE SYSTEM...\0"
KSMPDET:    DB       "TOTAL NUMBER OF DETECTED CPU CORES: \0"
KSMPSUC:    DB       "ALL CORES INITIALIZED SUCCESSFULLY.\0"
