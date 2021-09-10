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
            PUBLIC   KSMPEN

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
            LGDT     [GDTR_ADDR]

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
            MOV      EAX, PM4L_ADDR
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
            MOV      EAX, [0xFEE00020]
            SHR      EAX, 24

            ;# USE THIS PARTICULAR CPU STACK
            MOV      RSP, RAX
            SHL      RSP, 12
            ADD      RSP, STACK_ADDR
            ADD      RSP, 0x1000
            MOV      RBP, RSP
            NOP

            ;# INITIALIZE IDT
            LIDT     [IDTR_ADDR]

            ;# JUMP TO KSMPEN
            MOV      RAX, [SmpFunAddress-KSMP16]
            CALL     RAX

            ;# LOOP FOREVER
            JMP      .

            ;# ALIGNMENT FOR DATA
            ALIGN    8

            ;# SMPFUNADDRESS
            EQU      SmpFunAddress, .
            DQ       0

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

            ;# store the address of KSMPEN to be fetched by trampoline
            LEA      RAX, [RIP+KSMPEN]
            MOV      [RIP+SmpFunAddress], RAX

            ;# COPY THE TRAMPOLINE TO LOWER MEMORY
            MOV      RDI, TRUMP_ADDR
            LEA      RSI, [RIP+KSMP16]
            LEA      RCX, [RIP+KSMPINIT]
            SUB      RCX, RSI

            ;# COPY LOOP
1:          MOV      AL, [RSI]
            MOV      [RDI], AL
            INC      RSI
            INC      RDI
            LOOP     1b

            ;# FIRST WE NEED TO INITIALIZE CORE 0
            CALL     KSMPEN

            ;# SEND INIT-SIPI-SIPI SEQUENCE TO OTHER CPUS
            CALL     KIRQIIPI
            CALL     KIRQSIPI
            CALL     KIRQSIPI

            ;# DONE
            XOR      RAX, RAX
            RET

;#-----------------------------------------------------------------------------#
;#                               KSMPEN()                                      #
;#-----------------------------------------------------------------------------#

;# TODO: move lock instructions to IDT

KSMPEN:     ;# ACQUIRE KERNEL LOCK TO AVOID RACE CONDITIONS WITH OTHER CPUS
            CALL     KLOCPEND

            ;# INITIALIZE LAPIC AND ENABLE IRQS
            CALL     KIRQEN

            ;# PRINT MODULE NAME
            LEA      RDI, [RIP+KSMPNAME]
            CALL     KLOGMOD

            ;# PRINT LAPIC DETECTION STRING
            LEA      RDI, [RIP+KSMPID]
            CALL     KLOGSTR

            ;# PRINT LAPIC ID
            XOR      RAX, RAX
            MOV      EAX, [0xFEE00020]
            SHR      EAX, 24
            MOV      RDI, RAX
            CALL     KLOGDEC

            ;# PRINT NEW LINE
            MOV      RDI, '\n'
            CALL     KLOGCHR

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

            ;# SMP MODULE NAME AND MESSAGES
KSMPNAME:   DB       "KERNEL SMP\0"
KSMPMSG:    DB       "DETECTING CPU CORES AVAILABLE IN THE SYSTEM...\0"
KSMPID:     DB       "SUCCESSFULLY INITIALIZED CPU CORE WITH LAPIC ID: \0"
