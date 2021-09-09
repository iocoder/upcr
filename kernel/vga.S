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
    .INCLUDE "kernel/macro.inc"

;###############################################################################
;#                                GLOBALS                                      #
;###############################################################################

    ;# global symbols
    .global KVGAINIT
    .global KVGACLR
    .global KVGAPUT
    .global KVGAATT

;###############################################################################
;#                              TEXT SECTION                                   #
;###############################################################################

    ;# text section
    .text

;###############################################################################
;#                               KVGAINIT()                                    #
;###############################################################################

    ;# declare a linker symbol
    .set     KVGAINIT, .

    ;# read KVGAAVL from init struct
    MOV      0x00(%rdi), %rax
    MOV      %rax, KVGAAVL(%rip)

    ;# read KVGAVMEM from init struct
    MOV      0x08(%rdi), %rax
    MOV      %rax, KVGAVMEM(%rip)

    ;# read KVGAPMEM from init struct
    MOV      0x10(%rdi), %rax
    MOV      %rax, KVGAPMEM(%rip)

    ;# read KVGASIZE from init struct
    MOV      0x18(%rdi), %rax
    MOV      %rax, KVGASIZE(%rip)

    ;# read KVGAWIDE from init struct
    MOV      0x20(%rdi), %rax
    MOV      %rax, KVGAWIDE(%rip)

    ;# read KVGAHIGH from init struct
    MOV      0x28(%rdi), %rax
    MOV      %rax, KVGAHIGH(%rip)

    ;# read KVGALINE from init struct
    MOV      0x30(%rdi), %rax
    MOV      %rax, KVGALINE(%rip)

    ;# did the user provide VGA information anyways?
    MOV      KVGAAVL(%rip), %rax
    CMP      $0, %rax
    JZ       2f

    ;# compute number of text columns
    MOV      KVGAWIDE(%rip), %rax   ;# RAX = WidthInPixels
    SHR      $3, %rax                     ;# RAX = WidthInPixels/8
    MOV      %rax, KVGACOLS(%rip)    ;# i.e. number of glyphs per row

    ;# compute number of text rows
    MOV      KVGAHIGH(%rip), %rax  ;# RAX = HeightInPixels
    SHR      $4, %rax                     ;# RAX = HeightInPixels/16
    MOV      %rax, KVGAROWS(%rip)    ;# i.e. number of glyphs per column

    ;# done
2:  XOR      %rax, %rax
    RET

;###############################################################################
;#                               KVGACLR()                                     #
;###############################################################################

    ;# declare a linker symbol
    .set     KVGACLR, .

    ;# load buffer addresses AND size to registers
    MOV      KVGAVMEM(%rip), %rsi
    MOV      KVGAPMEM(%rip), %rdi
    MOV      KVGASIZE(%rip), %rcx

    ;# load default background colour
    MOV      KVGABG(%rip), %eax

    ;# LOOP over all pixels AND cLEAr them
1:  MOV      %eax, (%rsi)
    MOV      %eax, (%rdi)
    ADD      $4, %rsi
    ADD      $4, %rdi
    SUB      $4, %rcx
    JNZ      1b

    ;# set (X,Y) to (0,0)
    XOR      %rax, %rax
    MOV      %rax, KVGAX(%rip)
    MOV      %rax, KVGAY(%rip)

    ;# done
2:  XOR      %rax, %rax
    RET

;###############################################################################
;#                               KVGAPUT()                                     #
;###############################################################################

    ;# declare a linker symbol
    .set     KVGAPUT, .

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
    MOV      KVGAY(%rip), %rax    ;# RAX = Y
    SHL      $4, %rax                  ;# RAX = Y*16  (line height is 16 pixels)
    MOV      KVGALINE(%rip), %rdx ;# RDX = PPL
    MUL      %rdx                      ;# RAX = Y*16*PPL (PPL=pixels per line)

    ;# add amount of horizontal pixels to the offset
    MOV      KVGAX(%rip), %rdx    ;# RDX = X
    SHL      $3, %rdx                  ;# RDX = X*8 (char width is 8 pixels)
    ADD      %rdx, %rax                ;# RAX = Y*16*PPL + X*8

    ;# store memory address of the pixel in %rsi AND %rdi
    MOV      KVGAVMEM(%rip), %rsi    ;# RSI = &buf[0]
    MOV      KVGAPMEM(%rip), %rdi    ;# RDI = &vga[0]
    SHL      $2, %rax                  ;# RAX = (Y*16*PPL + X*8)*4 (4=bytes/pxl)
    ADD      %rax, %rsi                ;# RSI = &buf[pixel]
    ADD      %rax, %rdi                ;# RDI = &vga[pixel]

    ;# store scan line size in R9
    MOV      KVGALINE(%rip), %r9
    SHL      $2, %r9                   ;# R9  = PPL*4 (scan line size in bytes)

    ;# get offset of the character pixel image to draw
    LEA      KVGAFONT(%rip), %r8    ;# R8 = &font[0]
    SHL      $4, %rcx                  ;# RCX = IDX*16 (each glyph is 16 bytes)
    ADD      %rcx, %r8                 ;# R8 = &font[IDX*16]

    ;# load colours
    MOV      KVGAFG(%rip), %rcx
    MOV      KVGABG(%rip), %rdx

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

5:  MOV      KVGAX(%rip), %rax
    INC      %rax                      ;# KVGAX++
    MOV      %rax, KVGAX(%rip)
    CMP      KVGACOLS(%rip), %rax ;# KVGAX == KVGACOLS?
    JNE      90f                       ;# jump to done if no new line is needed

    ########
    ;# (V) new line processing
    ########

    ;# reset KVGAX to 0
10: XOR      %rax, %rax
    MOV      %rax, KVGAX(%rip)

    ;# do we need to scroll?
    MOV      KVGAROWS(%rip), %rax
    DEC      %rax
    CMP      %rax, KVGAY(%rip)
    JE       11f

    ;# increase KVGAY AND skip scrolling
    MOV      KVGAY(%rip), %rax
    INC      %rax
    MOV      %rax, KVGAY(%rip)
    JMP      18f

11: ;# load destination addresses for scrolling
    MOV      KVGAVMEM(%rip), %rsi
    MOV      KVGAPMEM(%rip), %rdi

    ;# set RBX to the base source address for scrolling
    MOV      KVGALINE(%rip), %rax
    SHL      $4, %rax                 ;# each glyph takes 16 lines
    SHL      $2, %rax                 ;# each pixel is 4 bytes
    LEA      (%rsi, %rax), %r8

    ;# obtain size of memory region to scroll up
    MOV      KVGASIZE(%rip), %rcx
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
18: MOV      KVGAY(%rip), %rax    ;# RAX = KVGAY
    SHL      $4, %rax                  ;# RAX = KVGAY*16
    MOV      KVGALINE(%rip), %rdx ;# RDX = PPL
    MUL      %rdx                      ;# RAX = KVGAY*16*PPL
    SHL      $2, %rax                  ;# RAX = (KVGAY*16*PPL)*4
    MOV      KVGAVMEM(%rip), %rsi
    MOV      KVGAPMEM(%rip), %rdi
    ADD      %rax, %rsi                ;# RSI = &buf[first-pixel-in-new-line]
    ADD      %rax, %rdi                ;# RDI = &vga[first-pixel-in-new-line]

    ;# compute number of pixels to erase
    MOV      KVGALINE(%rip), %rcx
    SHL      $4, %rcx                  ;# RCX = PPL*16 (glyph/line height)
    SHL      $2, %rcx                  ;# RCX = PPL*16*4 (4 bytes/pixel)

    ;# load colour
    MOV      KVGABG(%rip), %eax

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
;#                                KVGAATT()                                    #
;###############################################################################

    ;# declare a linker symbol
    .set     KVGAATT, .

    ;# load KVGAPAL address
    LEA      KVGAPAL(%rip), %r8

    ;# foreground colour specified?
1:  CMP      $0x10, %rdi
    JNB      2f

    ;# read the RGB value from palette AND store it
    SHL      $3, %rdi
    MOV      (%r8, %rdi), %eax
    MOV      %eax, KVGAFG(%rip)

    ;# background colour specified?
2:  CMP      $0x10, %rsi
    JNB      3f

    ;# read the RGB value from palette AND store it
    SHL      $3, %rsi
    MOV      (%r8, %rsi), %eax
    MOV      %eax, KVGABG(%rip)

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
KVGAAVL:    DQ    0
KVGAVMEM:   DQ    0
KVGAPMEM:   DQ    0
KVGASIZE:   DQ    0
KVGAWIDE:   DQ    0
KVGALINE:   DQ    0
KVGAHIGH:   DQ    0

            ;# Cursor location
KVGAX:      DQ    0
KVGAY:      DQ    0

            ;# output window size (number of glyphs per row/col)
KVGACOLS:   DQ    0
KVGAROWS:   DQ    0

            ;# default colours
KVGAFG:     DQ    0x00FFFF00  ;# DEFAULT FOREGROUND COLOUR
KVGABG:     DQ    0x00010410  ;# DEFAULT BACKGROUND COLOUR

            ;# colour palette
KVGAPAL:    DQ    0x00000000  ;# 00: BLACK
            DQ    0x00800000  ;# 01: MAROON
            DQ    0x00008000  ;# 02: GREEN
            DQ    0x00808000  ;# 03: OLIVE
            DQ    0x00000080  ;# 04: NAVY
            DQ    0x00800080  ;# 05: PURBLE
            DQ    0x00008080  ;# 06: TEAL
            DQ    0x00808080  ;# 07: SILVER
            DQ    0x00C0C0C0  ;# 08: GREY
            DQ    0x00FF0000  ;# 09: RED
            DQ    0x0000FF00  ;# 0A: LIME
            DQ    0x00FFFF00  ;# 0B: YELLOW
            DQ    0x000000FF  ;# 0C: BLUE
            DQ    0x00FF00FF  ;# 0D: PURBLE
            DQ    0x0000FFFF  ;# 0E: CYAN
            DQ    0x00FFFFFF  ;# 0F: WHITE

            ;# font data
KVGAFONT:   .incbin  "kernel/font.bin"
