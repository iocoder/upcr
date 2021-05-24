
# C includes
#include "kernel/asm.h"

# symbols to export to linker
.globl KernelSplashInit

# text section
.text

##############################################################################
#                           KernelSplashInit()                               #
##############################################################################

KernelSplashInit:

    # header colour
    mov   $0x0A, %rcx
    call  KernelConsoleSetFg

    # print header
    lea   PTR(Header), %rcx
    call  KernelConsolePrintString

    # welcome msg colour
    mov   $0x0E, %rcx
    call  KernelConsoleSetFg

    # print welcome msg
    lea   PTR(Welcome), %rcx
    call  KernelConsolePrintString

    # license colour
    mov   $0x0F, %rcx
    call  KernelConsoleSetFg

    # print license
    lea   PTR(License), %rcx
    call  KernelConsolePrintString

    # set printing colour to yellow
    mov   $0x0B, %rcx
    call  KernelConsoleSetFg

    # done
    ret

##############################################################################

# data section
.data

Header:
.ascii   "\n"
.ascii   "\n"
.ascii   "                  *************************************************\n"
.ascii   "                  *  Universal Platform for Configurable Routing  *\n"
.ascii   "                  *      UPCR Version 21.09 - x86_64 Kernel       *\n"
.ascii   "                  *************************************************\n"
.ascii   "                  *       Copyright (C) 2021  Ramses Nagib        *\n"
.ascii   "                  *************************************************\n"
.ascii   "\n"
.ascii   "\n"
.ascii   "\0"

Welcome:
.ascii   "      Welcome to UPCR operating system. UPCR is a free software platform designed\n"
.ascii   "      for networking applications where configurability and software performance\n"
.ascii   "      are of big importance.\n"
.ascii   "\n"
.ascii   "\0"

License:
.ascii   "      Permission is hereby granted, free of charge, to any person obtaining a copy\n"
.ascii   "      of this software and associated documentation files (the 'Software'), to deal\n"
.ascii   "      in the Software without restriction, including without limitation the rights\n"
.ascii   "      to use, copy, modify, merge, publish, distribute, sublicense, and/or sell\n"
.ascii   "      copies of the Software, and to permit persons to whom the Software is\n"
.ascii   "      furnished to do so, subject to the following conditions:\n"
.ascii   "\n"
.ascii   "      The above copyright notice and this permission notice shall be included in all\n"
.ascii   "      copies or substantial portions of the Software.\n"
.ascii   "\n"
.ascii   "      THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR\n"
.ascii   "      IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,\n"
.ascii   "      FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE\n"
.ascii   "      AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER\n"
.ascii   "      LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,\n"
.ascii   "      OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE\n"
.ascii   "      SOFTWARE.\n"
.ascii   "\n"
.ascii   "\0"
