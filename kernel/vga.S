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
    .include "kernel/macro.inc"

;###############################################################################
;#                                GLOBALS                                      #
;###############################################################################

    ;# global symbols
    .global KernelVgaInit
    .global KernelVgaCLEAr
    .global KernelVgaPut
    .global KernelVgaColour

;###############################################################################
;#                              TEXT SECTION                                   #
;###############################################################################

    ;# text section
    .text

;###############################################################################
;#                           KernelVgaInit()                                   #
;###############################################################################

    ;# declare a linker symbol
    .set     KernelVgaInit, .

    ;# read VgaAvailable from init struct
    MOV      0x00(%rdi), %rax
    MOV      %rax, VgaAvailable(%rip)

    ;# read VgaMemVirt from init struct
    MOV      0x08(%rdi), %rax
    MOV      %rax, VgaMemVirt(%rip)

    ;# read VgaMemPhys from init struct
    MOV      0x10(%rdi), %rax
    MOV      %rax, VgaMemPhys(%rip)

    ;# read VgaMemSize from init struct
    MOV      0x18(%rdi), %rax
    MOV      %rax, VgaMemSize(%rip)

    ;# read VgaScreenWidth from init struct
    MOV      0x20(%rdi), %rax
    MOV      %rax, VgaScreenWidth(%rip)

    ;# read VgaScreenHeight from init struct
    MOV      0x28(%rdi), %rax
    MOV      %rax, VgaScreenHeight(%rip)

    ;# read VgaScreenLine from init struct
    MOV      0x30(%rdi), %rax
    MOV      %rax, VgaScreenLine(%rip)

    ;# did the user provide VGA information anyways?
    MOV      VgaAvailable(%rip), %rax
    CMP      $0, %rax
    JZ       2f

    ;# compute number of text columns
    MOV      VgaScreenWidth(%rip), %rax   ;# RAX = WidthInPixels
    SHR      $3, %rax                     ;# RAX = WidthInPixels/8
    MOV      %rax, VgaOutputCols(%rip)    ;# i.e. number of glyphs per row

    ;# compute number of text rows
    MOV      VgaScreenHeight(%rip), %rax  ;# RAX = HeightInPixels
    SHR      $4, %rax                     ;# RAX = HeightInPixels/16
    MOV      %rax, VgaOutputRows(%rip)    ;# i.e. number of glyphs per column

    ;# done
2:  XOR      %rax, %rax
    RET

;###############################################################################
;#                           KernelVgaCLEAr()                                  #
;###############################################################################

    ;# declare a linker symbol
    .set     KernelVgaCLEAr, .

    ;# load buffer addresses AND size to registers
    MOV      VgaMemVirt(%rip), %rsi
    MOV      VgaMemPhys(%rip), %rdi
    MOV      VgaMemSize(%rip), %rcx

    ;# load default background colour
    MOV      VgaColourBg(%rip), %eax

    ;# LOOP over all pixels AND cLEAr them
1:  MOV      %eax, (%rsi)
    MOV      %eax, (%rdi)
    ADD      $4, %rsi
    ADD      $4, %rdi
    SUB      $4, %rcx
    JNZ      1b

    ;# set (X,Y) to (0,0)
    XOR      %rax, %rax
    MOV      %rax, VgaCursorX(%rip)
    MOV      %rax, VgaCursorY(%rip)

    ;# done
2:  XOR      %rax, %rax
    RET

;###############################################################################
;#                            KernelVgaPut()                                   #
;###############################################################################

    ;# declare a linker symbol
    .set     KernelVgaPut, .

    ########
    ;# (I) process control characters
    ########
    MOV      %edi, %ecx
    AND      $0xFF, %rcx
    CMP      $'\n', %cl
    JZ       10f

    ########
    ;# (II) collect all needed information for plotting the glyph
    ########

    ;# convert Y to pixel offset from the beginning of the buffer
    MOV      VgaCursorY(%rip), %rax    ;# RAX = Y
    SHL      $4, %rax                  ;# RAX = Y*16  (line height is 16 pixels)
    MOV      VgaScreenLine(%rip), %rdx ;# RDX = PPL
    MUL      %rdx                      ;# RAX = Y*16*PPL (PPL=pixels per line)

    ;# add amount of horizontal pixels to the offset
    MOV      VgaCursorX(%rip), %rdx    ;# RDX = X
    SHL      $3, %rdx                  ;# RDX = X*8 (char width is 8 pixels)
    ADD      %rdx, %rax                ;# RAX = Y*16*PPL + X*8

    ;# store memory address of the pixel in %rsi AND %rdi
    MOV      VgaMemVirt(%rip), %rsi    ;# RSI = &buf[0]
    MOV      VgaMemPhys(%rip), %rdi    ;# RDI = &vga[0]
    SHL      $2, %rax                  ;# RAX = (Y*16*PPL + X*8)*4 (4=bytes/pxl)
    ADD      %rax, %rsi                ;# RSI = &buf[pixel]
    ADD      %rax, %rdi                ;# RDI = &vga[pixel]

    ;# store scan line size in R9
    MOV      VgaScreenLine(%rip), %r9
    SHL      $2, %r9                   ;# R9  = PPL*4 (scan line size in bytes)

    ;# get offset of the character pixel image to draw
    LEA      VgaFontData(%rip), %r8    ;# R8 = &font[0]
    SHL      $4, %rcx                  ;# RCX = IDX*16 (each glyph is 16 bytes)
    ADD      %rcx, %r8                 ;# R8 = &font[IDX*16]

    ;# load colours
    MOV      VgaColourFg(%rip), %rcx
    MOV      VgaColourBg(%rip), %rdx

    ;# load first byte in the bitmap
    MOV      (%r8), %al

    ;# LOOP over pixel rows/cols to draw
    MOV      $7, %r10                 ;# start from bit 7 AND end at bit 0
    MOV      $16, %r11                ;# total 16 bytes in the font bitmap

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

    ########
    ;# (III) LOOP over glyph pixels AND plot them
    ########

    ;# plot the pixel if its corresponding bit is 1
1:  BT       %r10, %rax               ;# current bit is 0 or 1?
    JNC      2f                       ;# if 0, draw using EDX
    MOV      %ecx, (%rsi)             ;# draw fore colour in virtual buffer
    MOV      %ecx, (%rdi)             ;# draw fore colour in VGA buffer
    JMP      3f                       ;# skip next two lines
2:  MOV      %edx, (%rsi)             ;# draw back colour in virtual buffer
    MOV      %edx, (%rdi)             ;# draw back colour in VGA buffer

3:  ;# next pixel
    ADD      $4, %rsi                 ;# MOVe to next pixel
    ADD      $4, %rdi                 ;# MOVe to next pixel (VGA)
    CMP      $0, %r10                 ;# are we done with this bitmap byte?
    JZ       4f                       ;# yes we are done
    DEC      %r10                     ;# next bit to draw
    JMP      1b                       ;# jump back to pixel plotting

4:  ;# next row
    DEC      %r11                     ;# decrease bitmap byte counter
    JZ       5f                       ;# 16 bytes are all done?
    MOV      $7, %r10                 ;# re-init R10 (start from bit 7 again)
    SUB      $32, %rsi                ;# reset RSI by 8 pixels (glyph width)
    SUB      $32, %rdi                ;# reset RDI by 8 pixels (glyph width)
    ADD      %r9, %rsi                ;# MOVe to next scan line
    ADD      %r9, %rdi                ;# MOVe to next scan line (VGA)
    INC      %r8                      ;# address of next byte in font bitmap
    MOV      (%r8), %al               ;# grab that byte
    JMP      1b                       ;# jump back to pixel plotting

    ########
    ;# (IV) increase cursor position
    ########

5:  MOV      VgaCursorX(%rip), %rax
    INC      %rax                      ;# VgaCursorX++
    MOV      %rax, VgaCursorX(%rip)
    CMP      VgaOutputCols(%rip), %rax ;# VgaCursorX == VgaOutputCols?
    JNE      90f                       ;# jump to done if no new line is needed

    ########
    ;# (V) new line processing
    ########

    ;# reset VgaCursorX to 0
10: XOR      %rax, %rax
    MOV      %rax, VgaCursorX(%rip)

    ;# do we need to scroll?
    MOV      VgaOutputRows(%rip), %rax
    DEC      %rax
    CMP      %rax, VgaCursorY(%rip)
    JE       11f

    ;# increase VgaCursorY AND skip scrolling
    MOV      VgaCursorY(%rip), %rax
    INC      %rax
    MOV      %rax, VgaCursorY(%rip)
    JMP      18f

11: ;# load destination addresses for scrolling
    MOV      VgaMemVirt(%rip), %rsi
    MOV      VgaMemPhys(%rip), %rdi

    ;# set RBX to the base source address for scrolling
    MOV      VgaScreenLine(%rip), %rax
    SHL      $4, %rax                 ;# each glyph takes 16 lines
    SHL      $2, %rax                 ;# each pixel is 4 bytes
    LEA      (%rsi, %rax), %r8

    ;# obtain size of memory region to scroll up
    MOV      VgaMemSize(%rip), %rcx
    SUB      %rax, %rcx

    ;# we are all good, copy AND LOOP until rcx is 0
12: MOV      (%r8), %eax
    MOV      %eax, (%rsi)
    MOV      %eax, (%rdi)
    ADD      $4, %r8
    ADD      $4, %rsi
    ADD      $4, %rdi
    SUB      $4, %rcx
    JNZ      12b

    ;# compute address of the first pixel in the line
18: MOV      VgaCursorY(%rip), %rax    ;# RAX = VgaCursorY
    SHL      $4, %rax                  ;# RAX = VgaCursorY*16
    MOV      VgaScreenLine(%rip), %rdx ;# RDX = PPL
    MUL      %rdx                      ;# RAX = VgaCursorY*16*PPL
    SHL      $2, %rax                  ;# RAX = (VgaCursorY*16*PPL)*4
    MOV      VgaMemVirt(%rip), %rsi
    MOV      VgaMemPhys(%rip), %rdi
    ADD      %rax, %rsi                ;# RSI = &buf[first-pixel-in-new-line]
    ADD      %rax, %rdi                ;# RDI = &vga[first-pixel-in-new-line]

    ;# compute number of pixels to erase
    MOV      VgaScreenLine(%rip), %rcx
    SHL      $4, %rcx                  ;# RCX = PPL*16 (glyph/line height)
    SHL      $2, %rcx                  ;# RCX = PPL*16*4 (4 bytes/pixel)

    ;# load colour
    MOV      VgaColourBg(%rip), %eax

    ;# draw current pixel
19: MOV      %eax, (%rsi)              ;# draw pixel in virtual buffer
    MOV      %eax, (%rdi)              ;# draw pixel in physical buffer

    ;# next pixel
    ADD      $4, %rsi                  ;# each pixel is 4 bytes
    ADD      $4, %rdi
    SUB      $4, %rcx
    JNZ      19b

    ########
    ;# (VI) RETurn to CALLer
    ########

    ;# done
90: XOR      %rax, %rax
    RET

;###############################################################################
;#                             KernelVgaColour()                               #
;###############################################################################

    ;# declare a linker symbol
    .set     KernelVgaColour, .

    ;# load VgaColourPalette address
    LEA      VgaColourPalette(%rip), %r8

    ;# foreground colour specified?
1:  CMP      $0x10, %rdi
    JNB      2f

    ;# read the RGB value from palette AND store it
    SHL      $3, %rdi
    MOV      (%r8, %rdi), %eax
    MOV      %eax, VgaColourFg(%rip)

    ;# background colour specified?
2:  CMP      $0x10, %rsi
    JNB      3f

    ;# read the RGB value from palette AND store it
    SHL      $3, %rsi
    MOV      (%r8, %rsi), %eax
    MOV      %eax, VgaColourBg(%rip)

    ;# done
3:  XOR      %rax, %rax
    RET

;###############################################################################
;#                              DATA SECTION                                   #
;###############################################################################

    ;# data section
    .data

;###############################################################################
;#                              MODULE DATA                                    #
;###############################################################################

    ;# VgaInitInfo structure
    .set     VgaAvailable, .
    .quad    0
    .set     VgaMemVirt, .
    .quad    0
    .set     VgaMemPhys, .
    .quad    0
    .set     VgaMemSize, .
    .quad    0
    .set     VgaScreenWidth, .
    .quad    0
    .set     VgaScreenLine, .
    .quad    0
    .set     VgaScreenHeight, .
    .quad    0

    ;# Cursor attributes
    .set     VgaCursorX, .
    .quad    0
    .set     VgaCursorY, .
    .quad    0

    ;# output window size (number of glyphs per row/col)
    .set     VgaOutputCols, .
    .quad    0
    .set     VgaOutputRows, .
    .quad    0

    ;# default colours AND colour palette
    .set     VgaColourFg, .
    .quad    0x00FFFF00  ;# DEFAULT FOREGROUND COLOUR
    .set     VgaColourBg, .
    .quad    0x00010410  ;# DEFAULT BACKGROUND COLOUR
    .set     VgaColourPalette, .
    .quad    0x00000000  ;# 00: BLACK
    .quad    0x00800000  ;# 01: MAROON
    .quad    0x00008000  ;# 02: GREEN
    .quad    0x00808000  ;# 03: OLIVE
    .quad    0x00000080  ;# 04: NAVY
    .quad    0x00800080  ;# 05: PURBLE
    .quad    0x00008080  ;# 06: TEAL
    .quad    0x00808080  ;# 07: SILVER
    .quad    0x00C0C0C0  ;# 08: GREY
    .quad    0x00FF0000  ;# 09: RED
    .quad    0x0000FF00  ;# 0A: LIME
    .quad    0x00FFFF00  ;# 0B: YELLOW
    .quad    0x000000FF  ;# 0C: BLUE
    .quad    0x00FF00FF  ;# 0D: PURBLE
    .quad    0x0000FFFF  ;# 0E: CYAN
    .quad    0x00FFFFFF  ;# 0F: WHITE

    ;# font data
    .set     VgaFontData, .
    .incbin  "kernel/font.bin"
