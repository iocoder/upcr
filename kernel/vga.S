
# C includes
#include "kernel/asm.h"

# symbols to export to linker
.globl KernelVgaInit
.globl KernelVgaPut
.globl KernelVgaFg
.globl KernelVgaBg

# framebuffer symbols
.globl FrameBufVirt
.globl FrameBufPhys
.globl FrameBufSize
.globl FrameBufWidth
.globl FrameBufHeight
.globl FrameBufScanLn

# text section
.text

##############################################################################
#                           KernelVgaInit()                                  #
##############################################################################

KernelVgaInit:

    # compute terminal width/height
    mov    PTR(FrameBufWidth), %rax
    shr    $3, %rax
    mov    %rax, PTR(TerminalWidth)
    mov    PTR(FrameBufHeight), %rax
    shr    $4, %rax
    mov    %rax, PTR(TerminalHeight)

    # obtain frame buffer info
    mov    PTR(FrameBufVirt), %rsi
    mov    PTR(FrameBufPhys), %rdi
    mov    PTR(FrameBufSize), %rcx

    # load colour
    movl   PTR(BackColour), %eax

    # loop over all pixels and clear them
1:  movl   %eax, (%rsi)
    movl   %eax, (%rdi)
    add    $4, %rsi
    add    $4, %rdi
    sub    $4, %rcx
    jnz    1b

    # done
    ret

##############################################################################
#                            KernelVgaPut()                                  #
##############################################################################

KernelVgaPut:

    ########
    # (I) process control characters
    ########
    cmp    $'\n', %cl
    jz     10f

    ########
    # (II) collect all needed information for plotting the glyph
    ########

    # convert (X,Y) to pixel offset from the beginning of the buffer
    mov    PTR(TerminalY), %rax     # RAX = Y
    shl    $4, %rax                 # RAX = Y*16  (line height is 16 pixels)
    mulq   PTR(FrameBufScanLn)      # RAX = Y*16*PPL (PPL=pixels per line)
    mov    PTR(TerminalX), %rbx     # RBX = X
    shl    $3, %rbx                 # RBX = X*8 (char width is 8 pixels)
    add    %rbx, %rax               # RAX = Y*16*PPL + X*8

    # store memory address of the pixel in %rsi and %rdi
    mov    PTR(FrameBufVirt), %rsi  # RSI = &buf[0]
    mov    PTR(FrameBufPhys), %rdi  # RDI = &vga[0]
    shl    $2, %rax                 # RAX = (Y*16*PPL + X*8)*4 (4=bytes/pixel)
    add    %rax, %rsi               # RSI = &buf[pixel]
    add    %rax, %rdi               # RDI = &vga[pixel]

    # store scan line size in R9
    mov    PTR(FrameBufScanLn), %r9
    shl    $2, %r9                  # R9  = PPL*4 (scan line size in bytes)

    # get offset of the character pixel image to draw
    lea    PTR(Font), %rbx          # RBX = &font[0]
    shl    $4, %rcx                 # RCX = IDX*16 # each char map is 16 bytes
    add    %rcx, %rbx               # RBX = &font[IDX*16]

    # load colours
    mov    PTR(ForeColour), %rcx
    mov    PTR(BackColour), %rdx

    # load first byte in the bitmap
    mov    (%rbx), %al

    # loop over pixel rows/cols to draw
    mov    $7, %r10                 # start from bit 7 and end at bit 0
    mov    $16, %r11                # total 16 bytes in the font bitmap

    # Summary of registers:
    # ---------------------
    #  AL = current bitmap byte (i.e. row)
    # RBX = address of current bitmap byte (in the font data)
    # ECX = foreground colour
    # EDX = background colour
    # RSI = address of current pixel in virtual buffer
    # RDI = address of current pixel in VGA buffer
    # R9  = scan line size in bytes
    # R10 = currently processed bit in the bitmap byte (see AL)
    # R11 = how many bitmap bytes are remaining (total 16)

    ########
    # (III) loop over glyph pixels and plot them
    ########

    # plot the pixel if its corresponding bit is 1
1:  bt     %r10, %rax               # current bit is 0 or 1?
    jnc    2f                       # if 0, draw using EDX
    movl   %ecx, (%rsi)             # draw fore colour in virtual buffer
    movl   %ecx, (%rdi)             # draw fore colour in VGA buffer
    jmp    3f                       # skip next two lines
2:  movl   %edx, (%rsi)             # draw back colour in virtual buffer
    movl   %edx, (%rdi)             # draw back colour in VGA buffer

3:  # next pixel
    add    $4, %rsi                 # move to next pixel
    add    $4, %rdi                 # move to next pixel (VGA)
    cmp    $0, %r10                 # are we done with this bitmap byte?
    jz     4f                       # yes we are done
    dec    %r10                     # next bit to draw
    jmp    1b                       # jump back to pixel plotting

4:  # next row
    dec    %r11                     # decrease bitmap byte counter
    jz     5f                       # 16 bytes are all done?
    mov    $7, %r10                 # re-init R10 (start from bit 7 again)
    sub    $32, %rsi                # reset RSI by 8 pixels (glyph width)
    sub    $32, %rdi                # reset RDI by 8 pixels (glyph width)
    add    %r9, %rsi                # move to next scan line
    add    %r9, %rdi                # move to next scan line (VGA)
    inc    %rbx                     # address of next byte in font bitmap
    mov    (%rbx), %al              # grab that byte
    jmp    1b                       # jump back to pixel plotting

    ########
    # (IV) increase cursor position
    ########

5:  incq   PTR(TerminalX)           # TerminalX++
    mov    PTR(TerminalWidth), %rax
    cmp    PTR(TerminalX), %rax     # TerminalX == TerminalWidth?
    jne    90f                      # jump to done if no new line is needed

    ########
    # (V) new line processing
    ########

    # increase line counter
10: xor    %rax, %rax
    mov    %rax, PTR(TerminalX)     # reset TerminalX to 0
    # TODO: check if we need to scroll screen
    incq   PTR(TerminalY)           # TerminalY++

    # compute address of the first pixel in the line
    mov    PTR(TerminalY), %rax     # RAX = TerminalY
    shl    $4, %rax                 # RAX = TerminalY*16
    mulq   PTR(FrameBufScanLn)      # RAX = TerminalY*16*PPL
    shl    $2, %rax                 # RAX = (TerminalY*16*PPL)*4
    mov    PTR(FrameBufVirt), %rsi
    mov    PTR(FrameBufPhys), %rdi
    add    %rax, %rsi               # RSI = &buf[first-pixel-in-new-line]
    add    %rax, %rdi               # RDI = &vga[first-pixel-in-new-line]

    # compute number of pixels to erase
    mov    PTR(FrameBufScanLn), %rcx
    shl    $4, %rcx                 # RCX = PPL*16 (glyph/line height)
    shl    $2, %rcx                 # RCX = PPL*16*4 (4 bytes/pixel)

    # load colour
    movl   PTR(BackColour), %eax

    # draw current pixel
11: movl   %eax, (%rsi)             # draw pixel in virtual buffer
    movl   %eax, (%rdi)             # draw pixel in physical buffer

    # next pixel
    add    $4, %rsi                 # each pixel is 4 bytes
    add    $4, %rdi
    sub    $4, %rcx
    jnz    11b

    ########
    # (VI) return to caller
    ########

90: # done
    ret

##############################################################################
#                              KernelVgaFg()                                 #
##############################################################################

KernelVgaFg:

    # load palette address
    lea    PTR(Palette), %rsi

    # get colour offset and add it to paletter
    shl    $3, %rcx
    add    %rcx, %rsi

    # read colour and store it in ForeColour
    mov    (%rsi), %eax
    mov    %eax, PTR(ForeColour)

    # done
    ret

##############################################################################
#                              KernelVgaBg()                                 #
##############################################################################

KernelVgaBg:


    # load palette address
    lea    PTR(Palette), %rsi

    # get colour offset and add it to paletter
    shl    $3, %rcx
    add    %rcx, %rsi

    # read colour and store it in BackColour
    mov    (%rsi), %eax
    mov    %eax, PTR(BackColour)

    # done
    ret

##############################################################################

# data section
.data

/* FrameBufferInfo structure */
FrameBufVirt:   .quad   0
FrameBufPhys:   .quad   0
FrameBufSize:   .quad   0
FrameBufWidth:  .quad   0
FrameBufHeight: .quad   0
FrameBufScanLn: .quad   0

/* TermialInfo */
TerminalX:      .quad   0
TerminalY:      .quad   0
TerminalWidth:  .quad   0
TerminalHeight: .quad   0

/* Attributes */
ForeColour:     .quad   0x00FFFF00
BackColour:     .quad   0x0012192b

/* Colour Palette */
Palette:        .quad   0x00000000  /* 00: BLACK */
                .quad   0x00800000  /* 01: MAROON */
                .quad   0x00008000  /* 02: GREEN */
                .quad   0x00808000  /* 03: OLIVE */
                .quad   0x00000080  /* 04: NAVY */
                .quad   0x00800080  /* 05: PURBLE */
                .quad   0x00008080  /* 06: TEAL */
                .quad   0x00808080  /* 07: SILVER */
                .quad   0x00C0C0C0  /* 08: GREY */
                .quad   0x00FF0000  /* 09: RED */
                .quad   0x0000FF00  /* 0A: LIME */
                .quad   0x00FFFF00  /* 0B: YELLOW */
                .quad   0x000000FF  /* 0C: BLUE */
                .quad   0x00FF00FF  /* 0D: PURBLE */
                .quad   0x0000FFFF  /* 0E: CYAN */
                .quad   0x00FFFFFF  /* 0F: WHITE */

/* Font data */
Font:           .incbin "kernel/8x16.fnt"
