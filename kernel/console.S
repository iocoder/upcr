
/* assist with position-independent code */
#define PTR(SomeVariable)   SomeVariable@GOTPCREL(%rip)

# symbols to export to linker
.globl KernelConsoleInit
.globl KernelConsolePrintChar
.globl KernelConsolePrintString
.globl KernelConsoleSetFg
.globl KernelConsoleSetBg

# text section
.text

##############################################################################
#                          KernelConsoleInit()                               #
##############################################################################

KernelConsoleInit:

    # initialize vga
    call  KernelVgaInit

    # done
    ret

##############################################################################
#                        KernelConsolePrintChar()                            #
##############################################################################

KernelConsolePrintChar:

    # print character to VGA
    push  %rcx
    call  KernelVgaPut
    pop   %rcx

    # done
    ret

##############################################################################
#                        KernelConsolePrintString()                          #
##############################################################################

KernelConsolePrintString:

    # store string address in index register
    mov   %rcx, %rsi

    # print current character
1:  push  %rsi
    xor   %rcx, %rcx
    mov   (%rsi), %cl
    call  KernelVgaPut
    pop   %rsi

    # next character
    inc   %rsi
    cmpb  $0, (%rsi)
    jne   1b

    # done
    ret

##############################################################################
#                            KernelConsoleSetFg()                            #
##############################################################################

KernelConsoleSetFg:

    # set vga foreground colour
    push  %rcx
    call  KernelVgaFg
    pop   %rcx

    # done
    ret

##############################################################################
#                            KernelConsoleSetBg()                            #
##############################################################################

KernelConsoleSetBg:

    # set vga background colour
    push  %rcx
    call  KernelVgaBg
    pop   %rcx

    # done
    ret
