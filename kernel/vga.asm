;###############################################################################
;# File name:    vga.S
;# Description:  Kernel display driver
;# Author:       Ramses A.
;###############################################################################
;#
;# UPCR Operating System for x86_64 architecture
;# Copyright (c) 2021 Ramses A.
;#
;# Permission is hereby granted, free of charge, to any person obtaining a copy
;# of this software AND associated documentation files (the "Software"), to deal
;# in the Software without restriction, including without limitation the rights
;# to use, copy, modify, merge, publish, distribute, sublicense, AND/or sell
;# copies of the Software, AND to permit persons to whom the Software is
;# furnished to do so, subject to the following conditions:
;#
;# The above copyright notice AND this permission notice shall be included in all
;# copies or substantial portions of the Software.
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

            ;# common definitions used by kernel
            INCLUDE  "kernel/macro.inc"

;###############################################################################
;#                                GLOBALS                                      #
;###############################################################################

            ;# global symbols
            PUBLIC    KVGAINIT
            PUBLIC    KVGACLR
            PUBLIC    KVGAPUT
            PUBLIC    KVGAATT

;###############################################################################
;#                              TEXT SECTION                                   #
;###############################################################################

            ;# text section
            SEGMENT  ".text"

;#-----------------------------------------------------------------------------#
;#                               KVGAINIT()                                    #
;#-----------------------------------------------------------------------------#

KVGAINIT:   ;# read KVGAAVL from init struct
            MOV      RAX, [R15+0x00]
            MOV      [RIP+KVGAAVL], RAX

            ;# read KVGAVMEM from init struct
            MOV      RAX, [R15+0x08]
            MOV      [RIP+KVGAVMEM], RAX

            ;# read KVGAPMEM from init struct
            MOV      RAX, [R15+0x10]
            MOV      [RIP+KVGAPMEM], RAX

            ;# read KVGASIZE from init struct
            MOV      RAX, [R15+0x18]
            MOV      [RIP+KVGASIZE], RAX

            ;# read KVGAWIDE from init struct
            MOV      RAX, [R15+0x20]
            MOV      [RIP+KVGAWIDE], RAX

            ;# read KVGAHIGH from init struct
            MOV      RAX, [R15+0x28]
            MOV      [RIP+KVGAHIGH], RAX

            ;# read KVGALINE from init struct
            MOV      RAX, [R15+0x30]
            MOV      [RIP+KVGALINE], RAX

            ;# did the user provide VGA information anyways?
            MOV      RAX, [RIP+KVGAAVL]
            CMP      RAX, 0
            JZ       1f

            ;# compute number of text columns
            MOV      RAX, [RIP+KVGAWIDE]   ;# RAX = WidthInPixels
            SHR      RAX, 3                     ;# RAX = WidthInPixels/8
            MOV      [RIP+KVGACOLS], RAX    ;# i.e. number of glyphs per row

            ;# compute number of text rows
            MOV      RAX, [RIP+KVGAHIGH]  ;# RAX = HeightInPixels
            SHR      RAX, 4                     ;# RAX = HeightInPixels/16
            MOV      [RIP+KVGAROWS], RAX    ;# i.e. number of glyphs per column

            ;# done
1:          XOR      RAX, RAX
            RET

;#-----------------------------------------------------------------------------#
;#                               KVGACLR()                                     #
;#-----------------------------------------------------------------------------#

KVGACLR:    ;# load buffer addresses AND size to registers
            MOV      RSI, [RIP+KVGAVMEM]
            MOV      RDI, [RIP+KVGAPMEM]
            MOV      RCX, [RIP+KVGASIZE]

            ;# load default background colour
            MOV      EAX, [RIP+KVGABG]

            ;# LOOP over all pixels AND cLEAr them
1:          MOV      [RSI], EAX
            MOV      [RDI], EAX
            ADD      RSI, 4
            ADD      RDI, 4
            SUB      RCX, 4
            JNZ      1b

            ;# set (X,Y) to (0,0)
            XOR      RAX, RAX
            MOV      [RIP+KVGAX], RAX
            MOV      [RIP+KVGAY], RAX

            ;# done
            XOR      RAX, RAX
            RET

;#-----------------------------------------------------------------------------#
;#                               KVGAPUT()                                     #
;#-----------------------------------------------------------------------------#

KVGAPUT:    ;########
            ;# (I) process control characters
            ;########
            MOV      ECX, EDI
            AND      RCX, 0xFF
            CMP      CL, '\n'
            JZ       10f

            ;########
            ;# (II) collect all needed information for plotting the glyph
            ;########

            ;# convert Y to pixel offset from the beginning of the buffer
            MOV      RAX, [RIP+KVGAY]    ;# RAX = Y
            SHL      RAX, 4                  ;# RAX = Y*16  (line height is 16 pixels)
            MOV      RDX, [RIP+KVGALINE] ;# RDX = PPL
            MUL      RDX                      ;# RAX = Y*16*PPL (PPL=pixels per line)

            ;# add amount of horizontal pixels to the offset
            MOV      RDX, [RIP+KVGAX]    ;# RDX = X
            SHL      RDX, 3                  ;# RDX = X*8 (char width is 8 pixels)
            ADD      RAX, RDX                ;# RAX = Y*16*PPL + X*8

            ;# store memory address of the pixel in RSI AND RDI
            MOV      RSI, [RIP+KVGAVMEM]    ;# RSI = &buf[0]
            MOV      RDI, [RIP+KVGAPMEM]    ;# RDI = &vga[0]
            SHL      RAX, 2                  ;# RAX = (Y*16*PPL + X*8)*4 (4=bytes/pxl)
            ADD      RSI, RAX                ;# RSI = &buf[pixel]
            ADD      RDI, RAX                ;# RDI = &vga[pixel]

            ;# store scan line size in R9
            MOV      R9, [RIP+KVGALINE]
            SHL      R9, 2                   ;# R9  = PPL*4 (scan line size in bytes)

            ;# get offset of the character pixel image to draw
            LEA      R8, [RIP+KVGAFONT]    ;# R8 = &font[0]
            SHL      RCX, 4                  ;# RCX = IDX*16 (each glyph is 16 bytes)
            ADD      R8, RCX                 ;# R8 = &font[IDX*16]

            ;# load colours
            MOV      RCX, [RIP+KVGAFG]
            MOV      RDX, [RIP+KVGABG]

            ;# load first byte in the bitmap
            MOV      AL, [R8]

            ;# LOOP over pixel rows/cols to draw
            MOV      R10, 7                 ;# start from bit 7 AND end at bit 0
            MOV      R11, 16                ;# total 16 bytes in the font bitmap

            ;# Summary of registers:
            ;# ---------------------
            ;#  AL = current bitmap byte (i.e. row)
            ;# ECX = foreground colour
            ;# EDX = background colour
            ;# RSI = address of current pixel in virtual buffer
            ;# RDI = address of current pixel in VGA buffer
            ;# R8  = address of current bitmap byte (in the font data)
            ;# R9  = scan line size in bytes
            ;# R10 = currently processed bit in the bitmap byte (see AL)
            ;# R11 = how many bitmap bytes are remaining (total 16)

            ;########
            ;# (III) LOOP over glyph pixels AND plot them
            ;########

            ;# plot the pixel if its corresponding bit is 1
1:          BT       RAX, R10               ;# current bit is 0 or 1?
            JNC      2f                       ;# if 0, draw using EDX
            MOV      [RSI], ECX             ;# draw fore colour in virtual buffer
            MOV      [RDI], ECX             ;# draw fore colour in VGA buffer
            JMP      3f                       ;# skip next two lines
2:          MOV      [RSI], EDX             ;# draw back colour in virtual buffer
            MOV      [RDI], EDX             ;# draw back colour in VGA buffer

3:          ;# next pixel
            ADD      RSI, 4                 ;# MOVe to next pixel
            ADD      RDI, 4                 ;# MOVe to next pixel (VGA)
            CMP      R10, 0                 ;# are we done with this bitmap byte?
            JZ       4f                       ;# yes we are done
            DEC      R10                     ;# next bit to draw
            JMP      1b                       ;# jump back to pixel plotting

4:          ;# next row
            DEC      R11                     ;# decrease bitmap byte counter
            JZ       5f                       ;# 16 bytes are all done?
            MOV      R10, 7                 ;# re-init R10 (start from bit 7 again)
            SUB      RSI, 32                ;# reset RSI by 8 pixels (glyph width)
            SUB      RDI, 32                ;# reset RDI by 8 pixels (glyph width)
            ADD      RSI, R9                ;# MOVe to next scan line
            ADD      RDI, R9                ;# MOVe to next scan line (VGA)
            INC      R8                      ;# address of next byte in font bitmap
            MOV      AL, [R8]               ;# grab that byte
            JMP      1b                       ;# jump back to pixel plotting

            ;########
            ;# (IV) increase cursor position
            ;########

5:          MOV      RAX, [RIP+KVGAX]
            INC      RAX                      ;# KVGAX++
            MOV      [RIP+KVGAX], RAX
            CMP      RAX, [RIP+KVGACOLS] ;# KVGAX == KVGACOLS?
            JNE      90f                       ;# jump to done if no new line is needed

            ;########
            ;# (V) new line processing
            ;########

            ;# reset KVGAX to 0
10:         XOR      RAX, RAX
            MOV      [RIP+KVGAX], RAX

            ;# do we need to scroll?
            MOV      RAX, [RIP+KVGAROWS]
            DEC      RAX
            CMP      [RIP+KVGAY], RAX
            JE       11f

            ;# increase KVGAY AND skip scrolling
            MOV      RAX, [RIP+KVGAY]
            INC      RAX
            MOV      [RIP+KVGAY], RAX
            JMP      18f

11:         ;# load destination addresses for scrolling
            MOV      RSI, [RIP+KVGAVMEM]
            MOV      RDI, [RIP+KVGAPMEM]

            ;# set RBX to the base source address for scrolling
            MOV      RAX, [RIP+KVGALINE]
            SHL      RAX, 4                 ;# each glyph takes 16 lines
            SHL      RAX, 2                 ;# each pixel is 4 bytes
            LEA      R8, [RSI+RAX]

            ;# obtain size of memory region to scroll up
            MOV      RCX, [RIP+KVGASIZE]
            SUB      RCX, RAX

            ;# we are all good, copy AND LOOP until rcx is 0
12:         MOV      EAX, [R8]
            MOV      [RSI], EAX
            MOV      [RDI], EAX
            ADD      R8, 4
            ADD      RSI, 4
            ADD      RDI, 4
            SUB      RCX, 4
            JNZ      12b

            ;# compute address of the first pixel in the line
18:         MOV      RAX, [RIP+KVGAY]    ;# RAX = KVGAY
            SHL      RAX, 4                  ;# RAX = KVGAY*16
            MOV      RDX, [RIP+KVGALINE] ;# RDX = PPL
            MUL      RDX                      ;# RAX = KVGAY*16*PPL
            SHL      RAX, 2                  ;# RAX = (KVGAY*16*PPL)*4
            MOV      RSI, [RIP+KVGAVMEM]
            MOV      RDI, [RIP+KVGAPMEM]
            ADD      RSI, RAX                ;# RSI = &buf[first-pixel-in-new-line]
            ADD      RDI, RAX                ;# RDI = &vga[first-pixel-in-new-line]

            ;# compute number of pixels to erase
            MOV      RCX, [RIP+KVGALINE]
            SHL      RCX, 4                  ;# RCX = PPL*16 (glyph/line height)
            SHL      RCX, 2                  ;# RCX = PPL*16*4 (4 bytes/pixel)

            ;# load colour
            MOV      EAX, [RIP+KVGABG]

            ;# draw current pixel
19:         MOV      [RSI], EAX              ;# draw pixel in virtual buffer
            MOV      [RDI], EAX              ;# draw pixel in physical buffer

            ;# next pixel
            ADD      RSI, 4                  ;# each pixel is 4 bytes
            ADD      RDI, 4
            SUB      RCX, 4
            JNZ      19b

            ;########
            ;# (VI) return to caller
            ;########

            ;# done
90:         XOR      RAX, RAX
            RET

;#-----------------------------------------------------------------------------#
;#                                KVGAATT()                                    #
;#-----------------------------------------------------------------------------#

KVGAATT:    ;# load KVGAPAL address
            LEA      R8, [RIP+KVGAPAL]

            ;# foreground colour specified?
1:          CMP      RDI, 0x10
            JNB      2f

            ;# read the RGB value from palette AND store it
            SHL      RDI, 3
            MOV      EAX, [R8+RDI]
            MOV      [RIP+KVGAFG], EAX

            ;# background colour specified?
2:          CMP      RSI, 0x10
            JNB      3f

            ;# read the RGB value from palette AND store it
            SHL      RSI, 3
            MOV      EAX, [R8+RSI]
            MOV      [RIP+KVGABG], EAX

            ;# done
3:          XOR      RAX, RAX
            RET

;###############################################################################
;#                              DATA SECTION                                   #
;###############################################################################

            ;# data section
            SEGMENT  ".data"

;#-----------------------------------------------------------------------------#
;#                              MODULE DATA                                    #
;#-----------------------------------------------------------------------------#

            ;# VgaInitInfo structure
KVGAAVL:    DQ       0
KVGAVMEM:   DQ       0
KVGAPMEM:   DQ       0
KVGASIZE:   DQ       0
KVGAWIDE:   DQ       0
KVGALINE:   DQ       0
KVGAHIGH:   DQ       0

            ;# Cursor location
KVGAX:      DQ       0
KVGAY:      DQ       0

            ;# output window size (number of glyphs per row/col)
KVGACOLS:   DQ       0
KVGAROWS:   DQ       0

            ;# default colours
KVGAFG:     DQ       0x00FFFF00  ;# DEFAULT FOREGROUND COLOUR
KVGABG:     DQ       0x00010410  ;# DEFAULT BACKGROUND COLOUR

            ;# colour palette
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

            ;# font data
KVGAFONT:   .incbin  "kernel/font.bin"
