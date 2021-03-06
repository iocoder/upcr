;###############################################################################
;# FILE NAME:    KERNEL/VGA.ASM
;# DESCRIPTION:  KERNEL DISPLAY DRIVER
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
            PUBLIC    KVGAINIT
            PUBLIC    KVGAPLOT
            PUBLIC    KVGABUFF

;###############################################################################
;#                              TEXT SECTION                                   #
;###############################################################################

            ;# TEXT SECTION
            SEGMENT  ".text"

;#-----------------------------------------------------------------------------#
;#                               KVGAINIT()                                    #
;#-----------------------------------------------------------------------------#

KVGAINIT:   ;# READ KVGABUFF FROM INIT STRUCT
            MOV      RAX, [R15+0x28]
            MOV      [RIP+KVGABUFF], RAX

            ;# READ KVGASIZE FROM INIT STRUCT
            MOV      RAX, [R15+0x30]
            MOV      [RIP+KVGASIZE], RAX

            ;# READ KVGAWIDE FROM INIT STRUCT
            MOV      RAX, [R15+0x38]
            MOV      [RIP+KVGAWIDE], RAX

            ;# READ KVGAHIGH FROM INIT STRUCT
            MOV      RAX, [R15+0x40]
            MOV      [RIP+KVGAHIGH], RAX

            ;# READ KVGALINE FROM INIT STRUCT
            MOV      RAX, [R15+0x48]
            MOV      [RIP+KVGALINE], RAX

            ;# DRAW HEADING BAR
            MOV      RDI, [RIP+KVGABUFF]
            MOV      RCX, [RIP+KVGALINE]
            MOV      RAX, CONSOLE_HEADROWS*4*16
            MUL      RCX
            MOV      RCX, RAX
            ADD      RCX, RDI
            MOV      EAX, [RIP+KVGAPAL+(CONSOLE_HEADATTR>>24)*8]
1:          MOV      [RDI], EAX
            ADD      RDI, 4
            CMP      RDI, RCX
            JNE      1b

            ;# COMPUTE THE START OF VGA STATUS BAR
            XOR      RDX, RDX
            MOV      RAX, CONSOLE_TOTROWS-1
            SHL      RAX, 4
            MOV      RCX, [RIP+KVGALINE]
            SHL      RCX, 2
            MUL      RCX
            
            ;# DRAW STATUS BAR TO END OF SCREEN
            MOV      RDI, [RIP+KVGABUFF]
            ADD      RDI, RAX
            MOV      RCX, [RIP+KVGABUFF]
            ADD      RCX, [RIP+KVGASIZE]
            MOV      EAX, [RIP+KVGAPAL+(CONSOLE_STATATTR>>24)*8]
1:          MOV      [RDI], EAX
            ADD      RDI, 4
            CMP      RDI, RCX
            JNE      1b

            ;# DONE
            XOR      RAX, RAX
            RET

;#-----------------------------------------------------------------------------#
;#                               KVGAPLOT()                                    #
;#-----------------------------------------------------------------------------#

;# INPUTS:  R8:  X OFFSET
;#          R9:  Y OFFSET
;#          ECX: CHARACTER TO PLOT AND ITS ATTRIBS

;# SUMMARY OF REGISTERS:
;# ---------------------
;#  AL = CURRENT BITMAP BYTE (I.E. ROW)
;# ECX = FOREGROUND COLOUR
;# EDX = BACKGROUND COLOUR
;# RSI = ADDRESS OF CURRENT BITMAP BYTE (IN THE FONT DATA)
;# RDI = ADDRESS OF CURRENT PIXEL IN VGA BUFFER
;# R10 = CURRENTLY PROCESSED BIT IN THE BITMAP BYTE (SEE AL)
;# R11 = HOW MANY BITMAP BYTES ARE REMAINING (TOTAL 16)

KVGAPLOT:   ;# CONVERT Y TO PIXEL OFFSET FROM THE BEGINNING OF THE BUFFER
            MOV      RAX, R9                 ;# RAX = Y
            SHL      RAX, 4                  ;# RAX = Y*16  (LINE HEIGHT IS 16 PIXELS)
            MOV      RDX, [RIP+KVGALINE]     ;# RDX = PPL
            MUL      RDX                     ;# RAX = Y*16*PPL (PPL=PIXELS PER LINE)

            ;# ADJUSTMENT FOR STATUS BAR
            CMP      R9,  CONSOLE_TOTROWS-1
            JNE      1f
            ADD      RAX, [RIP+KVGALINE]
            ADD      RAX, [RIP+KVGALINE]
            ADD      RAX, [RIP+KVGALINE]
            ADD      RAX, [RIP+KVGALINE]

            ;# ADD AMOUNT OF HORIZONTAL PIXELS TO THE OFFSET
1:          MOV      RDX, R8                 ;# RDX = X
            SHL      RDX, 3                  ;# RDX = X*8 (CHAR WIDTH IS 8 PIXELS)
            ADD      RAX, RDX                ;# RAX = Y*16*PPL + X*8

            ;# EACH PIXEL IS 4 BYTES
            SHL      RAX, 2                  ;# RAX = (Y*16*PPL + X*8)*4

            ;# STORE MEMORY ADDRESS OF THE PIXEL IN RDI
            MOV      RDI, [RIP+KVGABUFF]     ;# RDI = &VGA[0]
            ADD      RDI, RAX                ;# RDI = &BUF[PIXEL]

            ;# GET OFFSET OF THE FONT GLYPH TO DRAW IN RSI
            XOR      RAX, RAX                ;# RAX = 0
            MOV      AL, CL                  ;# RAX = ASCII
            SHL      RAX, 4                  ;# RCX = ASCII*16 (EACH GLYPH IS 16 BYTES)
            LEA      RSI, [RIP+KVGAFONT]
            ADD      RSI, 0x65A
            ADD      RSI, RAX                ;# RSI = &FONT[IDX*16]

            ;# LOAD BG COLOUR IN EDX
            MOV      RAX, RCX
            SHR      RAX, 24
            AND      RAX, 0xFF
            SHL      RAX, 3
            LEA      RDX, [RIP+KVGAPAL]
            MOV      EDX, [RDX+RAX]

            ;# LOAD FG COLOUR IN ECX
            MOV      RAX, RCX
            SHR      RAX, 16
            AND      RAX, 0xFF
            SHL      RAX, 3
            LEA      RCX, [RIP+KVGAPAL]
            MOV      ECX, [RCX+RAX]

            ;# LOOP OVER 16 BYTES IN THE FONT BITMAP
            MOV      R11, 16                 

            ;# LOAD NEXT BYTE IN THE BITMAP
0:          MOV      AL, [RSI]

            ;# LOOP OVER 8 PIXELS TO DRAW
            MOV      R10, 7

            ;# PLOT THE PIXEL IF ITS CORRESPONDING BIT IS 1
1:          BT       RAX, R10                ;# CURRENT BIT IS 0 OR 1?
            JNC      2f                      ;# IF 0, DRAW USING EDX
            MOV      [RDI], ECX              ;# DRAW FORE COLOUR IN VGA BUFFER
            JMP      3f                      ;# SKIP NEXT TWO LINES
2:          MOV      [RDI], EDX              ;# DRAW BACK COLOUR IN VGA BUFFER
3:          ADD      RDI, 4                  ;# MOVE TO NEXT PIXEL (VGA)
            CMP      R10, 0                  ;# ARE WE DONE WITH THIS BITMAP BYTE?
            JZ       4f                      ;# YES WE ARE DONE
            DEC      R10                     ;# NEXT BIT TO DRAW
            JMP      1b                      ;# JUMP BACK TO PIXEL PLOTTING

4:          ;# NEXT ROW
            DEC      R11                     ;# DECREASE BITMAP BYTE COUNTER
            JZ       5f                      ;# 16 BYTES ARE ALL DONE?
            SUB      RDI, 32                 ;# RESET RDI BY 8 PIXELS (GLYPH WIDTH)
            MOV      RAX, [RIP+KVGALINE]     ;# LOAD SIZE OF SCAN LINE IN PIXELS
            SHL      RAX, 2                  ;# EACH PIXEL IS 4 BYTES
            ADD      RDI, RAX                ;# MOVE RDI TO NEXT SCAN LINE
            INC      RSI                     ;# MOVE RSI TO NEXT ROW IN GLYPH
            JMP      0b                      ;# JUMP BACK TO PIXEL PLOTTING

            ;# DONE
5:          XOR      RAX, RAX
            RET

;###############################################################################
;#                              DATA SECTION                                   #
;###############################################################################

            ;# DATA SECTION
            SEGMENT  ".data"

;#-----------------------------------------------------------------------------#
;#                              MODULE DATA                                    #
;#-----------------------------------------------------------------------------#

            ;# VGAINITINFO STRUCTURE
KVGABUFF:   DQ       0
KVGASIZE:   DQ       0
KVGAWIDE:   DQ       0
KVGALINE:   DQ       0
KVGAHIGH:   DQ       0

            ;# COLOUR PALETTE
KVGAPAL:    DQ       0x00000000  ;# 00: BLACK
            DQ       0x00800000  ;# 01: MAROON
            DQ       0x00002000  ;# 02: GREEN
            DQ       0x00308000  ;# 03: OLIVE
            DQ       0x00000030  ;# 04: NAVY
            DQ       0x00400040  ;# 05: PURBLE
            DQ       0x00008080  ;# 06: TEAL
            DQ       0x00808080  ;# 07: SILVER
            DQ       0x00C0C0C0  ;# 08: GREY
            DQ       0x00FF0000  ;# 09: RED
            DQ       0x0000FF00  ;# 0A: LIME
            DQ       0x00FFDB58  ;# 0B: YELLOW
            DQ       0x0000009F  ;# 0C: BLUE
            DQ       0x00FF00FF  ;# 0D: PURBLE
            DQ       0x0000FFFF  ;# 0E: CYAN
            DQ       0x00FFFFFF  ;# 0F: WHITE

            ;# FONT DATA
            ALIGN    256
KVGAFONT:   INCBIN   "fonts/ACM_VGA.FON"
