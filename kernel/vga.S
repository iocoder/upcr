###############################################################################
# File name:    vga.S
# Description:  Kernel display driver
# Author:       Ramses A.
###############################################################################
#
# UPCR Operating System for x86_64 architecture
# Copyright (c) 2021 Ramses A.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
###############################################################################
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
###############################################################################

###############################################################################
#                                INCLUDES                                     #
###############################################################################

    # common definitions used by kernel
    .include "kernel/macro.inc"

###############################################################################
#                              TEXT SECTION                                   #
###############################################################################

    # text section
    .text

###############################################################################
#                           KernelVgaInit()                                   #
###############################################################################

    # declare a linker symbol
    .global  KernelVgaInit
    .set     KernelVgaInit, .

    # read VgaAvailable from init struct
    mov      0x00(%rdi), %rax
    mov      %rax, VgaAvailable(%rip)

    # read VgaMemVirt from init struct
    mov      0x08(%rdi), %rax
    mov      %rax, VgaMemVirt(%rip)

    # read VgaMemPhys from init struct
    mov      0x10(%rdi), %rax
    mov      %rax, VgaMemPhys(%rip)

    # read VgaMemSize from init struct
    mov      0x18(%rdi), %rax
    mov      %rax, VgaMemSize(%rip)

    # read VgaScreenWidth from init struct
    mov      0x20(%rdi), %rax
    mov      %rax, VgaScreenWidth(%rip)

    # read VgaScreenHeight from init struct
    mov      0x28(%rdi), %rax
    mov      %rax, VgaScreenHeight(%rip)

    # read VgaScreenLine from init struct
    mov      0x30(%rdi), %rax
    mov      %rax, VgaScreenLine(%rip)

    # did the user provide VGA information anyways?
    cmpb     $0, VgaAvailable(%rip)
    jz       2f

    # compute number of text columns
    mov      VgaScreenWidth(%rip), %rax   # RAX = WidthInPixels
    shr      $3, %rax                     # RAX = WidthInPixels/8
    mov      %rax, VgaOutputCols(%rip)    # i.e. number of glyphs per row

    # compute number of text rows
    mov      VgaScreenHeight(%rip), %rax  # RAX = HeightInPixels
    shr      $4, %rax                     # RAX = HeightInPixels/16
    mov      %rax, VgaOutputRows(%rip)    # i.e. number of glyphs per column

    # load buffer addresses and size to registers
    mov      VgaMemVirt(%rip), %rsi
    mov      VgaMemPhys(%rip), %rdi
    mov      VgaMemSize(%rip), %rcx

    # load default background colour
    movl     VgaColourBg(%rip), %eax

    # loop over all pixels and clear them
1:  movl     %eax, (%rsi)
    movl     %eax, (%rdi)
    add      $4, %rsi
    add      $4, %rdi
    sub      $4, %rcx
    jnz      1b

    # done
2:  xor      %rax, %rax
    ret

###############################################################################
#                            KernelVgaPut()                                   #
###############################################################################

    # declare a linker symbol
    .global  KernelVgaPut
    .set     KernelVgaPut, .

    ########
    # (I) process control characters
    ########
    mov      %edi, %ecx
    and      $0xFF, %rcx
    cmp      $'\n', %cl
    jz       10f

    ########
    # (II) collect all needed information for plotting the glyph
    ########

    # convert Y to pixel offset from the beginning of the buffer
    mov      VgaCursorY(%rip), %rax   # RAX = Y
    shl      $4, %rax                 # RAX = Y*16  (line height is 16 pixels)
    mulq     VgaScreenLine(%rip)      # RAX = Y*16*PPL (PPL=pixels per line)

    # add amount of horizontal pixels to the offset
    mov      VgaCursorX(%rip), %rdx   # RDX = X
    shl      $3, %rdx                 # RDX = X*8 (char width is 8 pixels)
    add      %rdx, %rax               # RAX = Y*16*PPL + X*8

    # store memory address of the pixel in %rsi and %rdi
    mov      VgaMemVirt(%rip), %rsi   # RSI = &buf[0]
    mov      VgaMemPhys(%rip), %rdi   # RDI = &vga[0]
    shl      $2, %rax                 # RAX = (Y*16*PPL + X*8)*4 (4=bytes/pxl)
    add      %rax, %rsi               # RSI = &buf[pixel]
    add      %rax, %rdi               # RDI = &vga[pixel]

    # store scan line size in R9
    mov      VgaScreenLine(%rip), %r9
    shl      $2, %r9                  # R9  = PPL*4 (scan line size in bytes)

    # get offset of the character pixel image to draw
    lea      VgaFontData(%rip), %r8   # R8 = &font[0]
    shl      $4, %rcx                 # RCX = IDX*16 (each glyph is 16 bytes)
    add      %rcx, %r8                # R8 = &font[IDX*16]

    # load colours
    mov      VgaColourFg(%rip), %rcx
    mov      VgaColourBg(%rip), %rdx

    # load first byte in the bitmap
    mov      (%r8), %al

    # loop over pixel rows/cols to draw
    mov      $7, %r10                 # start from bit 7 and end at bit 0
    mov      $16, %r11                # total 16 bytes in the font bitmap

    # Summary of registers:
    # ---------------------
    #  AL = current bitmap byte (i.e. row)
    # ECX = foreground colour
    # EDX = background colour
    # RSI = address of current pixel in virtual buffer
    # RDI = address of current pixel in VGA buffer
    # R8  = address of current bitmap byte (in the font data)
    # R9  = scan line size in bytes
    # R10 = currently processed bit in the bitmap byte (see AL)
    # R11 = how many bitmap bytes are remaining (total 16)

    ########
    # (III) loop over glyph pixels and plot them
    ########

    # plot the pixel if its corresponding bit is 1
1:  bt       %r10, %rax               # current bit is 0 or 1?
    jnc      2f                       # if 0, draw using EDX
    movl     %ecx, (%rsi)             # draw fore colour in virtual buffer
    movl     %ecx, (%rdi)             # draw fore colour in VGA buffer
    jmp      3f                       # skip next two lines
2:  movl     %edx, (%rsi)             # draw back colour in virtual buffer
    movl     %edx, (%rdi)             # draw back colour in VGA buffer

3:  # next pixel
    add      $4, %rsi                 # move to next pixel
    add      $4, %rdi                 # move to next pixel (VGA)
    cmp      $0, %r10                 # are we done with this bitmap byte?
    jz       4f                       # yes we are done
    dec      %r10                     # next bit to draw
    jmp      1b                       # jump back to pixel plotting

4:  # next row
    dec      %r11                     # decrease bitmap byte counter
    jz       5f                       # 16 bytes are all done?
    mov      $7, %r10                 # re-init R10 (start from bit 7 again)
    sub      $32, %rsi                # reset RSI by 8 pixels (glyph width)
    sub      $32, %rdi                # reset RDI by 8 pixels (glyph width)
    add      %r9, %rsi                # move to next scan line
    add      %r9, %rdi                # move to next scan line (VGA)
    inc      %r8                      # address of next byte in font bitmap
    mov      (%r8), %al               # grab that byte
    jmp      1b                       # jump back to pixel plotting

    ########
    # (IV) increase cursor position
    ########

5:  incq     VgaCursorX(%rip)         # VgaCursorX++
    mov      VgaOutputCols(%rip), %rax
    cmp      VgaCursorX(%rip), %rax   # VgaCursorX == VgaOutputCols?
    jne      90f                      # jump to done if no new line is needed

    ########
    # (V) new line processing
    ########

    # reset VgaCursorX to 0
10: xor      %rax, %rax
    mov      %rax, VgaCursorX(%rip)

    # do we need to scroll?
    mov      VgaOutputRows(%rip), %rax
    dec      %rax
    cmp      %rax, VgaCursorY(%rip)
    je       11f

    # increase VgaCursorY and skip scrolling
    incq     VgaCursorY(%rip)
    jmp      18f

11: # load destination addresses for scrolling
    mov      VgaMemVirt(%rip), %rsi
    mov      VgaMemPhys(%rip), %rdi

    # set RBX to the base source address for scrolling
    mov      VgaScreenLine(%rip), %rax
    shl      $4, %rax                 # each glyph takes 16 lines
    shl      $2, %rax                 # each pixel is 4 bytes
    lea      (%rsi, %rax), %r8

    # obtain size of memory region to scroll up
    mov      VgaMemSize(%rip), %rcx
    sub      %rax, %rcx

    # we are all good, copy and loop until rcx is 0
12: movl     (%r8), %eax
    movl     %eax, (%rsi)
    movl     %eax, (%rdi)
    add      $4, %r8
    add      $4, %rsi
    add      $4, %rdi
    sub      $4, %rcx
    jnz      12b

    # compute address of the first pixel in the line
18: mov      VgaCursorY(%rip), %rax   # RAX = VgaCursorY
    shl      $4, %rax                 # RAX = VgaCursorY*16
    mulq     VgaScreenLine(%rip)      # RAX = VgaCursorY*16*PPL
    shl      $2, %rax                 # RAX = (VgaCursorY*16*PPL)*4
    mov      VgaMemVirt(%rip), %rsi
    mov      VgaMemPhys(%rip), %rdi
    add      %rax, %rsi               # RSI = &buf[first-pixel-in-new-line]
    add      %rax, %rdi               # RDI = &vga[first-pixel-in-new-line]

    # compute number of pixels to erase
    mov      VgaScreenLine(%rip), %rcx
    shl      $4, %rcx                 # RCX = PPL*16 (glyph/line height)
    shl      $2, %rcx                 # RCX = PPL*16*4 (4 bytes/pixel)

    # load colour
    movl     VgaColourBg(%rip), %eax

    # draw current pixel
19: movl     %eax, (%rsi)             # draw pixel in virtual buffer
    movl     %eax, (%rdi)             # draw pixel in physical buffer

    # next pixel
    add      $4, %rsi                 # each pixel is 4 bytes
    add      $4, %rdi
    sub      $4, %rcx
    jnz      19b

    ########
    # (VI) return to caller
    ########

    # done
90: xor      %rax, %rax
    ret

###############################################################################
#                             KernelVgaColour()                               #
###############################################################################

    # declare a linker symbol
    .global  KernelVgaColour
    .set     KernelVgaColour, .

    # load VgaColourPalette address
    lea      VgaColourPalette(%rip), %r8

    # foreground colour specified?
1:  cmp      $0x10, %rdi
    jnb      2f

    # read the RGB value from palette and store it
    shl      $3, %rdi
    mov      (%r8, %rdi), %eax
    mov      %eax, VgaColourFg(%rip)

    # background colour specified?
2:  cmp      $0x10, %rsi
    jnb      3f

    # read the RGB value from palette and store it
    shl      $3, %rsi
    mov      (%r8, %rsi), %eax
    mov      %eax, VgaColourBg(%rip)

    # done
3:  xor      %rax, %rax
    ret

###############################################################################
#                              DATA SECTION                                   #
###############################################################################

    # data section
    .data

###############################################################################
#                              MODULE DATA                                    #
###############################################################################

    # VgaInitInfo structure
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

    # Cursor attributes
    .set     VgaCursorX, .
    .quad    0
    .set     VgaCursorY, .
    .quad    0

    # output window size (number of glyphs per row/col)
    .set     VgaOutputCols, .
    .quad    0
    .set     VgaOutputRows, .
    .quad    0

    # default colours and colour palette
    .set     VgaColourFg, .
    .quad    0x00FFFF00  # DEFAULT FOREGROUND COLOUR
    .set     VgaColourBg, .
    .quad    0x00010410  # DEFAULT BACKGROUND COLOUR
    .set     VgaColourPalette, .
    .quad    0x00000000  # 00: BLACK
    .quad    0x00800000  # 01: MAROON
    .quad    0x00008000  # 02: GREEN
    .quad    0x00808000  # 03: OLIVE
    .quad    0x00000080  # 04: NAVY
    .quad    0x00800080  # 05: PURBLE
    .quad    0x00008080  # 06: TEAL
    .quad    0x00808080  # 07: SILVER
    .quad    0x00C0C0C0  # 08: GREY
    .quad    0x00FF0000  # 09: RED
    .quad    0x0000FF00  # 0A: LIME
    .quad    0x00FFFF00  # 0B: YELLOW
    .quad    0x000000FF  # 0C: BLUE
    .quad    0x00FF00FF  # 0D: PURBLE
    .quad    0x0000FFFF  # 0E: CYAN
    .quad    0x00FFFFFF  # 0F: WHITE

    # font data
    .set     VgaFontData, .
    .incbin  "kernel/font.bin"
