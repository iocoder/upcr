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
            PUBLIC    KVGACLR
            PUBLIC    KVGAPUT
            PUBLIC    KVGAATT
            PUBLIC    KVGAVMEM
            PUBLIC    KVGAPMEM

;###############################################################################
;#                              TEXT SECTION                                   #
;###############################################################################

            ;# TEXT SECTION
            SEGMENT  ".text"

;#-----------------------------------------------------------------------------#
;#                               KVGAINIT()                                    #
;#-----------------------------------------------------------------------------#

KVGAINIT:   ;# READ KVGAAVL FROM INIT STRUCT
            MOV      RAX, [R15+0x00]
            MOV      [RIP+KVGAAVL], RAX

            ;# READ KVGAVMEM FROM INIT STRUCT
            MOV      RAX, [R15+0x08]
            MOV      [RIP+KVGAVMEM], RAX

            ;# READ KVGAPMEM FROM INIT STRUCT
            MOV      RAX, [R15+0x10]
            MOV      [RIP+KVGAPMEM], RAX

            ;# READ KVGASIZE FROM INIT STRUCT
            MOV      RAX, [R15+0x18]
            MOV      [RIP+KVGASIZE], RAX

            ;# READ KVGAWIDE FROM INIT STRUCT
            MOV      RAX, [R15+0x20]
            MOV      [RIP+KVGAWIDE], RAX

            ;# READ KVGAHIGH FROM INIT STRUCT
            MOV      RAX, [R15+0x28]
            MOV      [RIP+KVGAHIGH], RAX

            ;# READ KVGALINE FROM INIT STRUCT
            MOV      RAX, [R15+0x30]
            MOV      [RIP+KVGALINE], RAX

            ;# DID THE USER PROVIDE VGA INFORMATION ANYWAYS?
            MOV      RAX, [RIP+KVGAAVL]
            CMP      RAX, 0
            JZ       1f

            ;# COMPUTE NUMBER OF TEXT COLUMNS
            MOV      RAX, [RIP+KVGAWIDE]        ;# RAX = WIDTH_IN_PIXELS
            SHR      RAX, 3                     ;# RAX = WIDTH_IN_PIXELS/8
            MOV      [RIP+KVGACOLS], RAX        ;# I.E. NUMBER OF GLYPHS PER ROW

            ;# COMPUTE NUMBER OF TEXT ROWS
            MOV      RAX, [RIP+KVGAHIGH]        ;# RAX = HEIGHT_IN_PIXELS
            SHR      RAX, 4                     ;# RAX = HEIGHT_IN_PIXELS/16
            MOV      [RIP+KVGAROWS], RAX        ;# I.E. NUMBER OF GLYPHS PER COLUMN

            ;# DONE
1:          XOR      RAX, RAX
            RET

;#-----------------------------------------------------------------------------#
;#                               KVGACLR()                                     #
;#-----------------------------------------------------------------------------#

KVGACLR:    ;# LOAD BUFFER ADDRESSES AND SIZE TO REGISTERS
            MOV      RSI, [RIP+KVGAVMEM]
            MOV      RDI, [RIP+KVGAPMEM]
            MOV      RCX, [RIP+KVGASIZE]

            ;# LOAD DEFAULT BACKGROUND COLOUR
            MOV      EAX, [RIP+KVGABG]

            ;# LOOP OVER ALL PIXELS AND CLEAR THEM
1:          MOV      [RSI], EAX
            MOV      [RDI], EAX
            ADD      RSI, 4
            ADD      RDI, 4
            SUB      RCX, 4
            JNZ      1b

            ;# SET (X,Y) TO (0,0)
            XOR      RAX, RAX
            MOV      [RIP+KVGAX], RAX
            MOV      [RIP+KVGAY], RAX

            ;# DONE
            XOR      RAX, RAX
            RET

;#-----------------------------------------------------------------------------#
;#                               KVGAPUT()                                     #
;#-----------------------------------------------------------------------------#

KVGAPUT:    ;########
            ;# (I) PROCESS CONTROL CHARACTERS
            ;########
            MOV      ECX, EDI
            AND      RCX, 0xFF
            CMP      CL, '\n'
            JZ       10f

            ;########
            ;# (II) COLLECT ALL NEEDED INFORMATION FOR PLOTTING THE GLYPH
            ;########

            ;# CONVERT Y TO PIXEL OFFSET FROM THE BEGINNING OF THE BUFFER
            MOV      RAX, [RIP+KVGAY]        ;# RAX = Y
            SHL      RAX, 4                  ;# RAX = Y*16  (LINE HEIGHT IS 16 PIXELS)
            MOV      RDX, [RIP+KVGALINE]     ;# RDX = PPL
            MUL      RDX                     ;# RAX = Y*16*PPL (PPL=PIXELS PER LINE)

            ;# ADD AMOUNT OF HORIZONTAL PIXELS TO THE OFFSET
            MOV      RDX, [RIP+KVGAX]        ;# RDX = X
            SHL      RDX, 3                  ;# RDX = X*8 (CHAR WIDTH IS 8 PIXELS)
            ADD      RAX, RDX                ;# RAX = Y*16*PPL + X*8

            ;# STORE MEMORY ADDRESS OF THE PIXEL IN RSI AND RDI
            MOV      RSI, [RIP+KVGAVMEM]     ;# RSI = &BUF[0]
            MOV      RDI, [RIP+KVGAPMEM]     ;# RDI = &VGA[0]
            SHL      RAX, 2                  ;# RAX = (Y*16*PPL + X*8)*4 (4=BYTES/PXL)
            ADD      RSI, RAX                ;# RSI = &BUF[PIXEL]
            ADD      RDI, RAX                ;# RDI = &VGA[PIXEL]

            ;# STORE SCAN LINE SIZE IN R9
            MOV      R9, [RIP+KVGALINE]
            SHL      R9, 2                   ;# R9  = PPL*4 (SCAN LINE SIZE IN BYTES)

            ;# GET OFFSET OF THE CHARACTER PIXEL IMAGE TO DRAW
            LEA      R8, [RIP+KVGAFONT]      ;# R8 = &FONT[0]
            SHL      RCX, 4                  ;# RCX = IDX*16 (EACH GLYPH IS 16 BYTES)
            ADD      R8, RCX                 ;# R8 = &FONT[IDX*16]

            ;# LOAD COLOURS
            MOV      RCX, [RIP+KVGAFG]
            MOV      RDX, [RIP+KVGABG]

            ;# LOAD FIRST BYTE IN THE BITMAP
            MOV      AL, [R8]

            ;# LOOP OVER PIXEL ROWS/COLS TO DRAW
            MOV      R10, 7                  ;# START FROM BIT 7 AND END AT BIT 0
            MOV      R11, 16                 ;# TOTAL 16 BYTES IN THE FONT BITMAP

            ;# SUMMARY OF REGISTERS:
            ;# ---------------------
            ;#  AL = CURRENT BITMAP BYTE (I.E. ROW)
            ;# ECX = FOREGROUND COLOUR
            ;# EDX = BACKGROUND COLOUR
            ;# RSI = ADDRESS OF CURRENT PIXEL IN VIRTUAL BUFFER
            ;# RDI = ADDRESS OF CURRENT PIXEL IN VGA BUFFER
            ;# R8  = ADDRESS OF CURRENT BITMAP BYTE (IN THE FONT DATA)
            ;# R9  = SCAN LINE SIZE IN BYTES
            ;# R10 = CURRENTLY PROCESSED BIT IN THE BITMAP BYTE (SEE AL)
            ;# R11 = HOW MANY BITMAP BYTES ARE REMAINING (TOTAL 16)

            ;########
            ;# (III) LOOP OVER GLYPH PIXELS AND PLOT THEM
            ;########

            ;# PLOT THE PIXEL IF ITS CORRESPONDING BIT IS 1
1:          BT       RAX, R10                ;# CURRENT BIT IS 0 OR 1?
            JNC      2f                      ;# IF 0, DRAW USING EDX
            MOV      [RSI], ECX              ;# DRAW FORE COLOUR IN VIRTUAL BUFFER
            MOV      [RDI], ECX              ;# DRAW FORE COLOUR IN VGA BUFFER
            JMP      3f                      ;# SKIP NEXT TWO LINES
2:          MOV      [RSI], EDX              ;# DRAW BACK COLOUR IN VIRTUAL BUFFER
            MOV      [RDI], EDX              ;# DRAW BACK COLOUR IN VGA BUFFER

3:          ;# NEXT PIXEL
            ADD      RSI, 4                  ;# MOVE TO NEXT PIXEL
            ADD      RDI, 4                  ;# MOVE TO NEXT PIXEL (VGA)
            CMP      R10, 0                  ;# ARE WE DONE WITH THIS BITMAP BYTE?
            JZ       4f                      ;# YES WE ARE DONE
            DEC      R10                     ;# NEXT BIT TO DRAW
            JMP      1b                      ;# JUMP BACK TO PIXEL PLOTTING

4:          ;# NEXT ROW
            DEC      R11                     ;# DECREASE BITMAP BYTE COUNTER
            JZ       5f                      ;# 16 BYTES ARE ALL DONE?
            MOV      R10, 7                  ;# RE-INIT R10 (START FROM BIT 7 AGAIN)
            SUB      RSI, 32                 ;# RESET RSI BY 8 PIXELS (GLYPH WIDTH)
            SUB      RDI, 32                 ;# RESET RDI BY 8 PIXELS (GLYPH WIDTH)
            ADD      RSI, R9                 ;# MOVE TO NEXT SCAN LINE
            ADD      RDI, R9                 ;# MOVE TO NEXT SCAN LINE (VGA)
            INC      R8                      ;# ADDRESS OF NEXT BYTE IN FONT BITMAP
            MOV      AL, [R8]                ;# GRAB THAT BYTE
            JMP      1b                      ;# JUMP BACK TO PIXEL PLOTTING

            ;########
            ;# (IV) INCREASE CURSOR POSITION
            ;########

5:          MOV      RAX, [RIP+KVGAX]
            INC      RAX                     ;# KVGAX++
            MOV      [RIP+KVGAX], RAX
            CMP      RAX, [RIP+KVGACOLS]     ;# KVGAX == KVGACOLS?
            JNE      90f                     ;# JUMP TO DONE IF NO NEW LINE IS NEEDED

            ;########
            ;# (V) NEW LINE PROCESSING
            ;########

            ;# RESET KVGAX TO 0
10:         XOR      RAX, RAX
            MOV      [RIP+KVGAX], RAX

            ;# DO WE NEED TO SCROLL?
            MOV      RAX, [RIP+KVGAROWS]
            DEC      RAX
            CMP      [RIP+KVGAY], RAX
            JE       11f

            ;# INCREASE KVGAY AND SKIP SCROLLING
            MOV      RAX, [RIP+KVGAY]
            INC      RAX
            MOV      [RIP+KVGAY], RAX
            JMP      18f

11:         ;# COMPUTE AMOUNT OF BYTES TO SHIFT
            MOV      RAX, [RIP+KVGALINE]
            SHL      RAX, 4                  ;# EACH GLYPH TAKES 16 LINES
            SHL      RAX, 2                  ;# EACH PIXEL IS 4 BYTES

            ;# FIRST: TRANSFER FROM MEMBUF TO VGABUF
            MOV      RSI, [RIP+KVGAVMEM]
            MOV      RDI, [RIP+KVGAPMEM]
            MOV      RCX, [RIP+KVGASIZE]
            ADD      RSI, RAX
            SUB      RCX, RAX
            SHR      RCX, 8

            ;# PREFETCH DATA TO SPEED UP THE PIPELINE
12:         PREFETCHNTA [RSI + 256]
            PREFETCHNTA [RSI + 288]
            PREFETCHNTA [RSI + 320]
            PREFETCHNTA [RSI + 352]
            PREFETCHNTA [RSI + 384]
            PREFETCHNTA [RSI + 416]
            PREFETCHNTA [RSI + 448]
            PREFETCHNTA [RSI + 480]

            ;# COPY 256 BYTES AT ONCE
            MOVDQA  XMM0,  [RSI + 0  ]
            MOVDQA  XMM1,  [RSI + 16 ]
            MOVDQA  XMM2,  [RSI + 32 ]
            MOVDQA  XMM3,  [RSI + 48 ]
            MOVDQA  XMM4,  [RSI + 64 ]
            MOVDQA  XMM5,  [RSI + 80 ]
            MOVDQA  XMM6,  [RSI + 96 ]
            MOVDQA  XMM7,  [RSI + 112]
            MOVDQA  XMM8,  [RSI + 128]
            MOVDQA  XMM9,  [RSI + 144]
            MOVDQA  XMM10, [RSI + 160]
            MOVDQA  XMM11, [RSI + 176]
            MOVDQA  XMM12, [RSI + 192]
            MOVDQA  XMM13, [RSI + 208]
            MOVDQA  XMM14, [RSI + 224]
            MOVDQA  XMM15, [RSI + 240]

            ;# STORE 256 BYTES AT ONCE
            MOVNTDQ [RDI + 0  ], XMM0
            MOVNTDQ [RDI + 16 ], XMM1
            MOVNTDQ [RDI + 32 ], XMM2
            MOVNTDQ [RDI + 48 ], XMM3
            MOVNTDQ [RDI + 64 ], XMM4
            MOVNTDQ [RDI + 80 ], XMM5
            MOVNTDQ [RDI + 96 ], XMM6
            MOVNTDQ [RDI + 112], XMM7
            MOVNTDQ [RDI + 128], XMM8
            MOVNTDQ [RDI + 144], XMM9
            MOVNTDQ [RDI + 160], XMM10
            MOVNTDQ [RDI + 176], XMM11
            MOVNTDQ [RDI + 192], XMM12
            MOVNTDQ [RDI + 208], XMM13
            MOVNTDQ [RDI + 224], XMM14
            MOVNTDQ [RDI + 240], XMM15

            ;# MOVE TO NEXT 256 BYTES
            ADD     RSI, 256
            ADD     RDI, 256
            DEC     RCX
            JNZ     12b

            ;# SECOND: TRANSFER FROM MEMBUF TO MEMBUF
            MOV      RSI, [RIP+KVGAVMEM]
            MOV      RDI, [RIP+KVGAVMEM]
            MOV      RCX, [RIP+KVGASIZE]
            ADD      RSI, RAX
            SUB      RCX, RAX
            SHR      RCX, 8

            ;# PREFETCH DATA TO SPEED UP THE PIPELINE
13:         PREFETCHNTA [RSI + 256]
            PREFETCHNTA [RSI + 288]
            PREFETCHNTA [RSI + 320]
            PREFETCHNTA [RSI + 352]
            PREFETCHNTA [RSI + 384]
            PREFETCHNTA [RSI + 416]
            PREFETCHNTA [RSI + 448]
            PREFETCHNTA [RSI + 480]

            ;# COPY 256 BYTES AT ONCE
            MOVDQA  XMM0,  [RSI + 0  ]
            MOVDQA  XMM1,  [RSI + 16 ]
            MOVDQA  XMM2,  [RSI + 32 ]
            MOVDQA  XMM3,  [RSI + 48 ]
            MOVDQA  XMM4,  [RSI + 64 ]
            MOVDQA  XMM5,  [RSI + 80 ]
            MOVDQA  XMM6,  [RSI + 96 ]
            MOVDQA  XMM7,  [RSI + 112]
            MOVDQA  XMM8,  [RSI + 128]
            MOVDQA  XMM9,  [RSI + 144]
            MOVDQA  XMM10, [RSI + 160]
            MOVDQA  XMM11, [RSI + 176]
            MOVDQA  XMM12, [RSI + 192]
            MOVDQA  XMM13, [RSI + 208]
            MOVDQA  XMM14, [RSI + 224]
            MOVDQA  XMM15, [RSI + 240]

            ;# STORE 256 BYTES AT ONCE
            MOVNTDQ [RDI + 0  ], XMM0
            MOVNTDQ [RDI + 16 ], XMM1
            MOVNTDQ [RDI + 32 ], XMM2
            MOVNTDQ [RDI + 48 ], XMM3
            MOVNTDQ [RDI + 64 ], XMM4
            MOVNTDQ [RDI + 80 ], XMM5
            MOVNTDQ [RDI + 96 ], XMM6
            MOVNTDQ [RDI + 112], XMM7
            MOVNTDQ [RDI + 128], XMM8
            MOVNTDQ [RDI + 144], XMM9
            MOVNTDQ [RDI + 160], XMM10
            MOVNTDQ [RDI + 176], XMM11
            MOVNTDQ [RDI + 192], XMM12
            MOVNTDQ [RDI + 208], XMM13
            MOVNTDQ [RDI + 224], XMM14
            MOVNTDQ [RDI + 240], XMM15

            ;# MOVE TO NEXT 256 BYTES
            ADD     RSI, 256
            ADD     RDI, 256
            DEC     RCX
            JNZ     13b

            ;# COMPUTE ADDRESS OF THE FIRST PIXEL IN THE LINE
18:         MOV      RAX, [RIP+KVGAY]        ;# RAX = KVGAY
            SHL      RAX, 4                  ;# RAX = KVGAY*16
            MOV      RDX, [RIP+KVGALINE]     ;# RDX = PPL
            MUL      RDX                     ;# RAX = KVGAY*16*PPL
            SHL      RAX, 2                  ;# RAX = (KVGAY*16*PPL)*4
            MOV      RSI, [RIP+KVGAVMEM]
            MOV      RDI, [RIP+KVGAPMEM]
            ADD      RSI, RAX                ;# RSI = &BUF[FIRST-PIXEL-IN-NEW-LINE]
            ADD      RDI, RAX                ;# RDI = &VGA[FIRST-PIXEL-IN-NEW-LINE]

            ;# COMPUTE NUMBER OF PIXELS TO ERASE
            MOV      RCX, [RIP+KVGALINE]
            SHL      RCX, 4                  ;# RCX = PPL*16 (GLYPH/LINE HEIGHT)
            SHL      RCX, 2                  ;# RCX = PPL*16*4 (4 BYTES/PIXEL)

            ;# LOAD COLOUR
            MOV      EAX, [RIP+KVGABG]

            ;# DRAW CURRENT PIXEL
19:         MOV      [RSI], EAX              ;# DRAW PIXEL IN VIRTUAL BUFFER
            MOV      [RDI], EAX              ;# DRAW PIXEL IN PHYSICAL BUFFER

            ;# NEXT PIXEL
            ADD      RSI, 4                  ;# EACH PIXEL IS 4 BYTES
            ADD      RDI, 4
            SUB      RCX, 4
            JNZ      19b

            ;########
            ;# (VI) RETURN TO CALLER
            ;########

            ;# DONE
90:         XOR      RAX, RAX
            RET

;#-----------------------------------------------------------------------------#
;#                                KVGAATT()                                    #
;#-----------------------------------------------------------------------------#

KVGAATT:    ;# LOAD KVGAPAL ADDRESS
            LEA      R8, [RIP+KVGAPAL]

            ;# FOREGROUND COLOUR SPECIFIED?
1:          CMP      RDI, 0x10
            JNB      2f

            ;# READ THE RGB VALUE FROM PALETTE AND STORE IT
            SHL      RDI, 3
            MOV      EAX, [R8+RDI]
            MOV      [RIP+KVGAFG], EAX

            ;# BACKGROUND COLOUR SPECIFIED?
2:          CMP      RSI, 0x10
            JNB      3f

            ;# READ THE RGB VALUE FROM PALETTE AND STORE IT
            SHL      RSI, 3
            MOV      EAX, [R8+RSI]
            MOV      [RIP+KVGABG], EAX

            ;# DONE
3:          XOR      RAX, RAX
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
KVGAAVL:    DQ       0
KVGAVMEM:   DQ       0
KVGAPMEM:   DQ       0
KVGASIZE:   DQ       0
KVGAWIDE:   DQ       0
KVGALINE:   DQ       0
KVGAHIGH:   DQ       0

            ;# CURSOR LOCATION
KVGAX:      DQ       0
KVGAY:      DQ       0

            ;# OUTPUT WINDOW SIZE (NUMBER OF GLYPHS PER ROW/COL)
KVGACOLS:   DQ       0
KVGAROWS:   DQ       0

            ;# DEFAULT COLOURS
KVGAFG:     DQ       0x00FFFF00  ;# DEFAULT FOREGROUND COLOUR
KVGABG:     DQ       0x00010410  ;# DEFAULT BACKGROUND COLOUR

            ;# COLOUR PALETTE
KVGAPAL:    DQ       0x00000000  ;# 00: BLACK
            DQ       0x00800000  ;# 01: MAROON
            DQ       0x00008000  ;# 02: GREEN
            DQ       0x00808000  ;# 03: OLIVE
            DQ       0x00000080  ;# 04: NAVY
            DQ       0x00800080  ;# 05: PURBLE
            DQ       0x00008080  ;# 06: TEAL
            DQ       0x00808080  ;# 07: SILVER
            DQ       0x00C0C0C0  ;# 08: GREY
            DQ       0x00FF0000  ;# 09: RED
            DQ       0x0000FF00  ;# 0A: LIME
            DQ       0x00FFFF00  ;# 0B: YELLOW
            DQ       0x000000FF  ;# 0C: BLUE
            DQ       0x00FF00FF  ;# 0D: PURBLE
            DQ       0x0000FFFF  ;# 0E: CYAN
            DQ       0x00FFFFFF  ;# 0F: WHITE

            ;# FONT DATA
KVGAFONT:   INCBIN   "kernel/font.bin"
