;###############################################################################
;# File name:    KERNEL/CON.ASM
;# DESCRIPTION:  KERNEL CONSOLE
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
            PUBLIC   KCONINIT
            PUBLIC   KCONCHR
            PUBLIC   KCONDEC
            PUBLIC   KCONHEX
            PUBLIC   KCONSTR
            PUBLIC   KCONATT
            PUBLIC   KCONCLR
            PUBLIC   KCONMOD

;###############################################################################
;#                              TEXT SECTION                                   #
;###############################################################################

            ;# TEXT SECTION
            SEGMENT  ".text"

;#-----------------------------------------------------------------------------#
;#                               KCONINIT()                                    #
;#-----------------------------------------------------------------------------#

KCONINIT:   ;# CLEAR SCREEN
            CALL     KCONCLR

            ;# DONE
            XOR      RAX, RAX
            RET

;#-----------------------------------------------------------------------------#
;#                               KCONUPD()                                     #
;#-----------------------------------------------------------------------------#
;#
;# @BRIEF:  DRAW A CHAR ON ACTIVE DISPLAY
;# @INPUT:  R8:  X OFFSET OF THE WHOLE SCREEN
;#          R9:  Y OFFSET OF THE WHOLE SCREEN
;#          ECX: CHARACTER TO DRAW AND ITS ATTRIBS
KCONDRAW:   ;# PLOT THE CHARACTER ON VGA
            PUSH     RCX
            PUSH     R8
            PUSH     R9
            CALL     KVGAPLOT
            POP      R9
            POP      R8
            POP      RCX

            ;# DONE
            XOR      RAX, RAX
            RET

;#-----------------------------------------------------------------------------#
;#                               KCONPUT()                                     #
;#-----------------------------------------------------------------------------#

KCONPUT:    ;# CHECK FOR CONTROL CHARS
            CMP      RDI, '\n'
            JE       20f

            ;# ---------------------------
            ;# - REGULAR CHAR
            ;# ---------------------------

            ;# CREATE 32-BIT DWORD
10:         MOV      ECX, EDI
            AND      ECX, 0xFF
            MOV      EDI, [RIP+KCONATTR]
            SHL      EDI, 16
            OR       ECX, EDI

            ;# APPEND THE DWORD AT CURRENT CURSOR POSITION
            LEA      RDI, [RIP+KCONPAGE]
            ADD      RDI, [RIP+KCONCUR]
            MOV      [RDI], ECX

            ;# PLOT CHAR TO ACTIVE SCREEN
            MOV      RAX, [RIP+KCONCUR]
            SUB      RAX, [RIP+KCONOFF]
            SHR      RAX, 2
            XOR      RDX, RDX
            MOV      R8, CONSOLE_WIDTH
            DIV      R8
            MOV      R8, RDX
            MOV      R9, RAX
            ADD      R9, 3
            CALL     KCONDRAW

            ;# MOVE CURSOR TO NEXT POSITION
            MOV      RAX, [RIP+KCONCUR]
            ADD      RAX, 4
            MOV      [RIP+KCONCUR], RAX
            JMP      90f

            ;# ---------------------------
            ;# - NEW LINE
            ;# ---------------------------

            ;# MOVE TO NEXT ROW
20:         MOV      RAX, [RIP+KCONCUR]
            XOR      RDX, RDX
            MOV      R8, CONSOLE_WIDTH*4
            DIV      R8
            MOV      RAX, [RIP+KCONCUR]
            SUB      RAX, RDX
            ADD      RAX, CONSOLE_WIDTH*4
            MOV      [RIP+KCONCUR], RAX

            ;# CLEAN THE ROW
            LEA      RDI, [RIP+KCONPAGE]
            ADD      RDI, [RIP+KCONCUR]
            MOV      RCX, CONSOLE_WIDTH*4
            MOV      RAX, [RIP+KCONATTR]
            SHL      RAX, 16
21:         MOV      [RDI], RAX
            ADD      RDI, 4
            LOOP     21b

            ;# ---------------------------
            ;# - SCROLLING
            ;# ---------------------------

            ;# CHECK IF WE NEED TO SCROLL THE SCREEN
90:         MOV      RAX, [RIP+KCONCUR]
            MOV      RCX, [RIP+KCONOFF]
            SUB      RAX, RCX
            CMP      RAX, CONSOLE_WIDTH*CONSOLE_HEIGHT*4
            JNE      99f

            ;# UPDATE SCREEN OFFSET
            MOV      RSI, [RIP+KCONOFF]
            ADD      RSI, CONSOLE_WIDTH*4
            MOV      [RIP+KCONOFF], RSI

            ;# REDRAW EVERYTHING
            LEA      RCX, [RIP+KCONPAGE]
            ADD      RSI, RCX
            XOR      R8, R8
            XOR      R9, R9

            ;# DRAW CUR CHAR
91:         PUSH     RSI
            MOV      ECX, [RSI]
            ADD      R9, 3
            CALL     KCONDRAW
            SUB      R9, 3
            POP      RSI

            ;# MOVE TO NEXT ONE
            ADD      RSI, 4
            INC      R8
            CMP      R8, CONSOLE_WIDTH
            JNE      91b
            XOR      R8, R8
            INC      R9
            CMP      R9, CONSOLE_HEIGHT
            JNE      91b

            ;# DONE
99:         XOR      RAX, RAX
            RET

;#-----------------------------------------------------------------------------#
;#                               KCONCHR()                                     #
;#-----------------------------------------------------------------------------#

KCONCHR:    ;# PRINT SINGLE CHAR
            PUSH     RDI
            CALL     KCONPUT
            POP      RDI

            ;# SYNCHRONIZE OUTPUT DEVICES
            PUSH     RDI
            POP      RDI            

            ;# DONE
            XOR      RAX, RAX
            RET

;#-----------------------------------------------------------------------------#
;#                              KCONDEC()                                      #
;#-----------------------------------------------------------------------------#

KCONDEC:    ;# WE WILL KEEP DIVIDING RDX:RAX BY 10
            MOV      RAX, RDI
            XOR      ECX, ECX
            MOV      R8, 10

            ;# DIVIDE BY 10
1:          XOR      RDX, RDX
            DIV      R8

            ;# USE CPU STACK AS A PUSH-DOWN AUTOMATON
            PUSH     RDX
            INC      ECX

            ;# DONE?
            AND      RAX, RAX
            JNZ      1b

            ;# NOW PRINT ALL THE DIGITS
2:          POP      RDX
            ADD      RDX, '0'
            AND      RDX, 0xFF
            MOV      RDI, RDX
            PUSH     RCX
            CALL     KCONPUT
            POP      RCX

            ;# ALL DIGITS PRINTED?
            DEC      ECX
            JNZ      2b

            ;# SYNCHRONIZE OUTPUT DEVICES
            PUSH     RDI
            POP      RDI

            ;# DONE
            XOR      RAX, RAX
            RET

;#-----------------------------------------------------------------------------#
;#                               KCONHEX()                                     #
;#-----------------------------------------------------------------------------#

KCONHEX:    ;# PRINT HEXADECIMAL NUMBER (8 bytes - 16 hexdigits)
            MOV      CL, 16

            ;# PUT NEXT BYTE IN RDI[3:0] (ROL unrolled to prevent stall)
1:          ROL      RDI
            ROL      RDI
            ROL      RDI
            ROL      RDI

            ;# PRINT DL[0:3]
            PUSH     RCX
            PUSH     RDI
            LEA      RSI, [RIP+KCONDIGS]
            AND      RDI, 0x0F
            ADD      RSI, RDI
            XOR      RAX, RAX
            MOV      AL, [RSI]
            MOV      RDI, RAX
            CALL     KCONPUT
            POP      RDI
            POP      RCX

            ;# NEXT DIGIT
            DEC      CL
            JNZ      1b

            ;# SYNCHRONIZE OUTPUT DEVICES
            PUSH     RDI
            POP      RDI

            ;# DONE
            XOR      RAX, RAX
            RET

;#-----------------------------------------------------------------------------#
;#                                KCONSTR()                                    #
;#-----------------------------------------------------------------------------#

KCONSTR:    ;# FETCH NEXT CHARACTER
1:          XOR      RAX, RAX
            MOV      AL, [RDI]

            ;# TERMINATE IF ZERO
            AND      AL, AL
            JZ       2f

            ;# PRINT CHARACTER
            PUSH     RDI
            MOV      RDI, RAX
            CALL     KCONPUT
            POP      RDI

            ;# LOOP AGAIN
            INC      RDI
            JMP      1b

            ;# SYNCHRONIZE OUTPUT DEVICES
            PUSH     RDI
            POP      RDI

            ;# DONE
2:          XOR      RAX, RAX
            RET

;#-----------------------------------------------------------------------------#
;#                                 KCONATT()                                   #
;#-----------------------------------------------------------------------------#

KCONATT:    ;# FOREGROUND COLOUR SPECIFIED?
            CMP      RDI, 0x10
            JNB      1f

            ;# UPDATE FOREGROUND COLOUR
            MOV      RAX, RDI
            MOV      [RIP+KCONATTR+0], AL

            ;# BACKGROUND COLOUR SPECIFIED?
1:          CMP      RSI, 0x10
            JNB      2f

            ;# UPDATE BACKGROUND COLOUR
            MOV      RAX, RSI
            MOV      [RIP+KCONATTR+1], AL

            ;# DONE
2:          XOR      RAX, RAX
            RET

;#-----------------------------------------------------------------------------#
;#                                KCONCLR()                                    #
;#-----------------------------------------------------------------------------#

KCONCLR:    ;# CLEAR THE CONSOLE WINDOW 
            MOV      RCX, CONSOLE_HEIGHT
1:          PUSH     RCX
            MOV      RDI, '\n'
            CALL     KCONPUT
            POP      RCX
            LOOP     1b

            ;# RESET CURSOR POSITION
            MOV      RAX, [RIP+KCONOFF]
            MOV      [RIP+KCONCUR], RAX

            ;# DONE
            XOR      RAX, RAX
            RET

;#-----------------------------------------------------------------------------#
;#                                KCONMOD()                                    #
;#-----------------------------------------------------------------------------#

KCONMOD:    ;# SAVE A COPY OF RDI
            PUSH     RDI

            ;# CHANGE COLOUR TO YELLOW
            MOV      RDI, 0x0A
            MOV      RSI, -1
            CALL     KCONATT

            ;# PRINT " ["
            MOV      RDI, ' '
            CALL     KCONCHR
            MOV      RDI, '['
            CALL     KCONCHR

            ;# RESTORE RDI
            POP      RDI

            ;# PRINT THE NAME OF THE MODULE
            CALL     KCONSTR

            ;# PRINT "] "
            MOV      RDI, ']'
            CALL     KCONCHR
            MOV      RDI, ' '
            CALL     KCONCHR

            ;# RESET COLOUR TO WHITE
            MOV      RDI, 0x0B
            MOV      RSI, -1
            CALL     KCONATT

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

            ;# ALIGN AT PAGE BOUNDARY
            ALIGN    0x1000

            ;# CONSOLE PAGE 0
KCONPAGE:   .SPACE   (CONSOLE_PAGESIZE*4)
KCONCUR:    DQ       0
KCONATTR:   DQ       0x0600
KCONOFF:    DQ       0

            ;# ALL HEX DIGIT SYMBOLS
KCONDIGS:   DB       "0123456789ABCDEF"
