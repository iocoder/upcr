;###############################################################################
;# FILE NAME:    KERNEL/REG.ASM
;# DESCRIPTION:  DUMP CPU REGISTERS
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
            PUBLIC   KREGDUMP

;###############################################################################
;#                              TEXT SECTION                                   #
;###############################################################################

            ;# TEXT SECTION
            SEGMENT  ".text"

;#-----------------------------------------------------------------------------#
;#                               KREGDUMP()                                    #
;#-----------------------------------------------------------------------------#

KREGDUMP:   ;# PRINT EXCEPTION NAME
            PUSH     RDI
            LEA      RDI, [RIP+KREGEXPN]
            CALL     KLOGSTR
            POP      RDI
            PUSH     RDI
            MOV      RAX, [RDI+SFRAME_NBR]
            SHL      RAX, 5
            LEA      RDI, [RIP+KREGSTR]
            ADD      RDI, RAX
            CALL     KLOGSTR
            POP      RDI

            ;# NEW LINE
            PUSH     RDI
            MOV      RDI, '\n'
            CALL     KLOGCHR
            POP      RDI

            ;# PRINT EXCEPTION CODE
            PUSH     RDI
            LEA      RDI, [RIP+KREGEXPC]
            CALL     KLOGSTR
            POP      RDI
            PUSH     RDI
            MOV      RDI, [RDI+SFRAME_NBR]
            CALL     KLOGHEX
            POP      RDI

            ;# NEW LINE
            PUSH     RDI
            MOV      RDI, '\n'
            CALL     KLOGCHR
            POP      RDI

            ;# PRINT ERR CODE
            PUSH     RDI
            LEA      RDI, [RIP+KREGCODE]
            CALL     KLOGSTR
            POP      RDI
            PUSH     RDI
            MOV      RDI, [RDI+SFRAME_ERR]
            CALL     KLOGHEX
            POP      RDI

            ;# NEW LINE
            PUSH     RDI
            MOV      RDI, '\n'
            CALL     KLOGCHR
            POP      RDI

            ;# PRINT CPU CORE NUMBER
            PUSH     RDI
            LEA      RDI, [RIP+KREGCORE]
            CALL     KLOGSTR
            POP      RDI
            PUSH     RDI
            XOR      RAX, RAX
            MOV      EAX, [0xFEE00020]
            SHR      EAX, 24        
            MOV      RDI, RAX
            CALL     KLOGDEC
            POP      RDI

            ;# HORIZONTAL LINE
            PUSH     RDI
            LEA      RDI, [RIP+KREGHR]
            CALL     KLOGSTR
            POP      RDI
            
            ;# PRINT CS
            PUSH     RDI
            LEA      RDI, [RIP+KREGCS]
            CALL     KLOGSTR
            POP      RDI
            PUSH     RDI
            MOV      RDI, [RDI+SFRAME_CS]
            CALL     KLOGHEX
            POP      RDI
            
            ;# PRINT RIP
            PUSH     RDI
            LEA      RDI, [RIP+KREGRIP]
            CALL     KLOGSTR
            POP      RDI
            PUSH     RDI
            MOV      RDI, [RDI+SFRAME_RIP]
            CALL     KLOGHEX
            POP      RDI
            
            ;# PRINT RFLAGS
            PUSH     RDI
            LEA      RDI, [RIP+KREGFLG]
            CALL     KLOGSTR
            POP      RDI
            PUSH     RDI
            MOV      RDI, [RDI+SFRAME_RFLAGS]
            CALL     KLOGHEX
            POP      RDI

            ;# NEW LINE
            PUSH     RDI
            MOV      RDI, '\n'
            CALL     KLOGCHR
            POP      RDI
            
            ;# PRINT SS
            PUSH     RDI
            LEA      RDI, [RIP+KREGSS]
            CALL     KLOGSTR
            POP      RDI
            PUSH     RDI
            MOV      RDI, [RDI+SFRAME_SS]
            CALL     KLOGHEX
            POP      RDI
            
            ;# PRINT RSP
            PUSH     RDI
            LEA      RDI, [RIP+KREGRSP]
            CALL     KLOGSTR
            POP      RDI
            PUSH     RDI
            MOV      RDI, [RDI+SFRAME_RSP]
            CALL     KLOGHEX
            POP      RDI

            ;# HORIZONTAL LINE
            PUSH     RDI
            LEA      RDI, [RIP+KREGHR]
            CALL     KLOGSTR
            POP      RDI
            
            ;# PRINT RAX
            PUSH     RDI
            LEA      RDI, [RIP+KREGRAX]
            CALL     KLOGSTR
            POP      RDI
            PUSH     RDI
            MOV      RDI, [RDI+SFRAME_RAX]
            CALL     KLOGHEX
            POP      RDI
            
            ;# PRINT RBX
            PUSH     RDI
            LEA      RDI, [RIP+KREGRBX]
            CALL     KLOGSTR
            POP      RDI
            PUSH     RDI
            MOV      RDI, [RDI+SFRAME_RBX]
            CALL     KLOGHEX
            POP      RDI
            
            ;# PRINT RCX
            PUSH     RDI
            LEA      RDI, [RIP+KREGRCX]
            CALL     KLOGSTR
            POP      RDI
            PUSH     RDI
            MOV      RDI, [RDI+SFRAME_RCX]
            CALL     KLOGHEX
            POP      RDI

            ;# NEW LINE
            PUSH     RDI
            MOV      RDI, '\n'
            CALL     KLOGCHR
            POP      RDI

            ;# PRINT RDX
            PUSH     RDI
            LEA      RDI, [RIP+KREGRDX]
            CALL     KLOGSTR
            POP      RDI
            PUSH     RDI
            MOV      RDI, [RDI+SFRAME_RDX]
            CALL     KLOGHEX
            POP      RDI

            ;# PRINT RSI
            PUSH     RDI
            LEA      RDI, [RIP+KREGRSI]
            CALL     KLOGSTR
            POP      RDI
            PUSH     RDI
            MOV      RDI, [RDI+SFRAME_RSI]
            CALL     KLOGHEX
            POP      RDI

            ;# PRINT RDI
            PUSH     RDI
            LEA      RDI, [RIP+KREGRDI]
            CALL     KLOGSTR
            POP      RDI
            PUSH     RDI
            MOV      RDI, [RDI+SFRAME_RDI]
            CALL     KLOGHEX
            POP      RDI

            ;# NEW LINE
            PUSH     RDI
            MOV      RDI, '\n'
            CALL     KLOGCHR
            POP      RDI
            
            ;# PRINT RBP
            PUSH     RDI
            LEA      RDI, [RIP+KREGRBP]
            CALL     KLOGSTR
            POP      RDI
            PUSH     RDI
            MOV      RDI, [RDI+SFRAME_RBP]
            CALL     KLOGHEX
            POP      RDI

            ;# HORIZONTAL LINE
            PUSH     RDI
            LEA      RDI, [RIP+KREGHR]
            CALL     KLOGSTR
            POP      RDI
            
            ;# PRINT R8
            PUSH     RDI
            LEA      RDI, [RIP+KREGR8]
            CALL     KLOGSTR
            POP      RDI
            PUSH     RDI
            MOV      RDI, [RDI+SFRAME_R8]
            CALL     KLOGHEX
            POP      RDI
            
            ;# PRINT R9
            PUSH     RDI
            LEA      RDI, [RIP+KREGR9]
            CALL     KLOGSTR
            POP      RDI
            PUSH     RDI
            MOV      RDI, [RDI+SFRAME_R9]
            CALL     KLOGHEX
            POP      RDI
            
            ;# PRINT R10
            PUSH     RDI
            LEA      RDI, [RIP+KREGR10]
            CALL     KLOGSTR
            POP      RDI
            PUSH     RDI
            MOV      RDI, [RDI+SFRAME_R10]
            CALL     KLOGHEX
            POP      RDI

            ;# NEW LINE
            PUSH     RDI
            MOV      RDI, '\n'
            CALL     KLOGCHR
            POP      RDI
            
            ;# PRINT R11
            PUSH     RDI
            LEA      RDI, [RIP+KREGR11]
            CALL     KLOGSTR
            POP      RDI
            PUSH     RDI
            MOV      RDI, [RDI+SFRAME_R11]
            CALL     KLOGHEX
            POP      RDI
            
            ;# PRINT R12
            PUSH     RDI
            LEA      RDI, [RIP+KREGR12]
            CALL     KLOGSTR
            POP      RDI
            PUSH     RDI
            MOV      RDI, [RDI+SFRAME_R12]
            CALL     KLOGHEX
            POP      RDI
            
            ;# PRINT R13
            PUSH     RDI
            LEA      RDI, [RIP+KREGR13]
            CALL     KLOGSTR
            POP      RDI
            PUSH     RDI
            MOV      RDI, [RDI+SFRAME_R13]
            CALL     KLOGHEX
            POP      RDI

            ;# NEW LINE
            PUSH     RDI
            MOV      RDI, '\n'
            CALL     KLOGCHR
            POP      RDI
            
            ;# PRINT R14
            PUSH     RDI
            LEA      RDI, [RIP+KREGR14]
            CALL     KLOGSTR
            POP      RDI
            PUSH     RDI
            MOV      RDI, [RDI+SFRAME_R14]
            CALL     KLOGHEX
            POP      RDI
            
            ;# PRINT R15
            PUSH     RDI
            LEA      RDI, [RIP+KREGR15]
            CALL     KLOGSTR
            POP      RDI
            PUSH     RDI
            MOV      RDI, [RDI+SFRAME_R15]
            CALL     KLOGHEX
            POP      RDI

            ;# HORIZONTAL LINE
            PUSH     RDI
            LEA      RDI, [RIP+KREGHR]
            CALL     KLOGSTR
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

            ;# HORIZONTAL LINE
KREGHR:     DB       "\n"
            DB       "\n"
            DB       "  "
            DB       "------------------------------------------"
            DB       "------------------------------------------"
            DB       "\n"
            DB       "\n"
            DB       "\0"

            ;# REGISTERS
KREGEXPN:   DB       "  EXCEPTION NAME: \0"
KREGEXPC:   DB       "  EXCEPTION CODE: \0"
KREGCODE:   DB       "  ERROR CODE:     \0"
KREGCORE:   DB       "  CPU CORE:       \0"
KREGCS:     DB       "  CS:  \0"
KREGRIP:    DB       "  RIP: \0"
KREGFLG:    DB       "  RFLAGS: \0"
KREGSS:     DB       "  SS:  \0"
KREGRSP:    DB       "  RSP: \0"
KREGRAX:    DB       "  RAX: \0"
KREGRBX:    DB       "  RBX: \0"
KREGRCX:    DB       "  RCX: \0"
KREGRDX:    DB       "  RDX: \0"
KREGRSI:    DB       "  RSI: \0"
KREGRDI:    DB       "  RDI: \0"
KREGRBP:    DB       "  RBP: \0"
KREGR8:     DB       "  R8:  \0"
KREGR9:     DB       "  R9:  \0"
KREGR10:    DB       "  R10: \0"
KREGR11:    DB       "  R11: \0"
KREGR12:    DB       "  R12: \0"
KREGR13:    DB       "  R13: \0"
KREGR14:    DB       "  R14: \0"
KREGR15:    DB       "  R15: \0"

            ;# EXCEPTION NAMES
KREGSTR:    DB       "DIVISION BY ZERO EXCEPTION     \0"  ;# 0x00
            DB       "DEBUG EXCEPTION                \0"  ;# 0x01
            DB       "NON MASKABLE INTERRUPT         \0"  ;# 0x02
            DB       "BREAKPOINT EXCEPTION           \0"  ;# 0x03
            DB       "OVERFLOW EXCEPTION             \0"  ;# 0x04
            DB       "BOUND RANGE                    \0"  ;# 0x05
            DB       "INVALID OPCODE                 \0"  ;# 0x06
            DB       "DEVICE NOT AVAILABLE           \0"  ;# 0x07
            DB       "DOUBLE FAULT                   \0"  ;# 0x08
            DB       "UNSUPPORTED                    \0"  ;# 0x09
            DB       "INVALID TSS                    \0"  ;# 0x0A
            DB       "SEGMENT NOT PRESENT            \0"  ;# 0x0B
            DB       "STACK EXCEPTION                \0"  ;# 0x0C
            DB       "GENERAL PROTECTION ERROR       \0"  ;# 0x0D
            DB       "PAGE FAULT                     \0"  ;# 0x0E
            DB       "RESERVED                       \0"  ;# 0x0F
            DB       "X87 FLOATING POINT EXCEPTION   \0"  ;# 0x10
            DB       "ALIGNMENT CHECK                \0"  ;# 0x11
            DB       "MACHINE CHECK                  \0"  ;# 0x12
            DB       "SIMD FLOATING POINT EXCEPTION  \0"  ;# 0x13
            DB       "RESERVED                       \0"  ;# 0x14
            DB       "CONTROL PROTECTION EXCEPTION   \0"  ;# 0x15
            DB       "RESERVED                       \0"  ;# 0x16
            DB       "RESERVED                       \0"  ;# 0x17
            DB       "RESERVED                       \0"  ;# 0x18
            DB       "RESERVED                       \0"  ;# 0x19
            DB       "RESERVED                       \0"  ;# 0x1A
            DB       "RESERVED                       \0"  ;# 0x1B
            DB       "HYPERVISOR INJECTION EXCEPTION \0"  ;# 0x1C
            DB       "VMM COMMUNICATION EXCEPTION    \0"  ;# 0x1D
            DB       "SECURITY EXCEPTION             \0"  ;# 0x1E
            DB       "RESERVED                       \0"  ;# 0x1F
            ;#       "0123456789ABCDEF0123456789ABCDEF"
