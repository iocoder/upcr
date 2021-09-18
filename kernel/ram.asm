;###############################################################################
;# File name:    KERNEL/RAM.ASM
;# DESCRIPTION:  KERNEL PHYSICAL MEMORY MODULE
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
            PUBLIC   KRAMINIT

;###############################################################################
;#                              TEXT SECTION                                   #
;###############################################################################

            ;# TEXT SECTION
            SEGMENT  ".text"

;#-----------------------------------------------------------------------------#
;#                              KRAMINIT()                                     #
;#-----------------------------------------------------------------------------#

KRAMINIT:   ;# READ MEMORY MAP INFO
            MOV      RSI, [R15+0x08]  ;# MemoryMapBase
            MOV      RCX, [R15+0x10]  ;# MemoryMapSize

            ;# LOOP OVER MAP ENTRIES
1:          MOV      RAX, [RSI+0x00]
            CMP      RAX, [R15+0x20]  ;# MemoryMapType
            JNE      2f

            ;# SAVE REGISTERS
            PUSH     RSI
            PUSH     RCX

            ;# LOAD REGION INFORMATION
            MOV      RDI, [RSI+0x08]  ;# RDI = BASE ADDRESS
            MOV      RCX, [RSI+0x18]  ;# RCX = SIZE IN PAGES

            ;# PRINT MODULE NAME
            PUSH     RDI
            PUSH     RCX
            LEA      RDI, [RIP+KRAMNAME]
            CALL     KCONMOD
            POP      RCX
            POP      RDI

            ;# PRINT REGION STRING
            PUSH     RDI
            PUSH     RCX
            LEA      RDI, [RIP+KRAMREGION]
            CALL     KCONSTR
            POP      RCX
            POP      RDI

            ;# PRINT REGION START
            PUSH     RDI
            PUSH     RCX
            CALL     KCONHEX
            POP      RCX
            POP      RDI

            ;# PRINT SEPARATOR
            PUSH     RDI
            PUSH     RCX
            MOV      RDI, ' '
            CALL     KCONCHR
            MOV      RDI, '-'
            CALL     KCONCHR
            MOV      RDI, '>'
            CALL     KCONCHR
            MOV      RDI, ' '
            CALL     KCONCHR
            POP      RCX
            POP      RDI

            ;# PRINT REGION END
            PUSH     RDI
            PUSH     RCX
            SHL      RCX, 12
            ADD      RDI, RCX
            CALL     KCONHEX
            POP      RCX
            POP      RDI

            ;# PRINT NEWLINE
            PUSH     RDI
            PUSH     RCX
            MOV      RDI, '\n'
            CALL     KCONCHR
            POP      RCX
            POP      RDI

            ;# TODO: LOOP OVER PAGES AND
            ;# PUT THEM IN LINKED LIST
            ADD      [RIP+KRAMSIZE], RCX

            ;# RESTORE REGISTERS
            POP      RCX
            POP      RSI

            ;# NEXT ENTRY
2:          ADD      RSI, [R15+0x18]  ;# MemoryMapDesc
            SUB      RCX, [R15+0x18]  ;# MemoryMapDesc
            JNZ      1b

            ;# PRINT RAM SIZE
            LEA      RDI, [RIP+KRAMNAME]
            CALL     KCONMOD
            LEA      RDI, [RIP+KRAMTOTS]
            CALL     KCONSTR
            MOV      RDI, [RIP+KRAMSIZE]
            SHL      RDI, 12
            SHR      RDI, 20
            CALL     KCONDEC
            MOV      RDI, 'M'
            CALL     KCONCHR
            MOV      RDI, 'B'
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

            ;# LINKED LIST OF FRAMES
KRAMHEAD:   DQ       0
KRAMSIZE:   DQ       0

;#-----------------------------------------------------------------------------#
;#                            LOGGING STRINGS                                  #
;#-----------------------------------------------------------------------------#

            ;# RAM HEADING AND MESSAGES
KRAMNAME:   DB       "KERNEL RAM\0"
KRAMREGION: DB       "DETECTED RAM REGION: \0"
KRAMTOTS:   DB       "TOTAL RAM SIZE: \0"
