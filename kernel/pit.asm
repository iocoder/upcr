;###############################################################################
;# File name:    KERNEL/PIT.ASM
;# DESCRIPTION:  INTEL 8253/8254 PROGRAMMABLE INTERRUPT TIMER
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
            PUBLIC   KPITINIT
            PUBLIC   KPITCH0
            PUBLIC   KPITCH1
            PUBLIC   KPITCH2

;###############################################################################
;#                                 MACROS                                      #
;###############################################################################

            ;# TIMER CHANNELS
            EQU      CHANNEL0,       0x00
            EQU      CHANNEL1,       0x40
            EQU      CHANNEL2,       0x80

            ;# REGISTER SELECTION
            EQU      BYTE_LATCH,     0x00
            EQU      BYTE_LO,        0x10
            EQU      BYTE_HI,        0x20
            EQU      BYTE_BOTH,      0x30

            ;# COUNTING MODES
            EQU      MODE_INTR,      0x00
            EQU      MODE_ONESHOT,   0x02
            EQU      MODE_RATE,      0x04
            EQU      MODE_SQUARE,    0x06
            EQU      MODE_SWSTROBE,  0x08
            EQU      MODE_HWSTROBE,  0x0A

            ;# BINARY OR BCD
            EQU      BCD_ENABLE,     0x01

            ;# READ BACK COUNT
            EQU      RD_COUNT0,      0xD2
            EQU      RD_COUNT1,      0xD4
            EQU      RD_COUNT2,      0xD8

            ;# READ BACK STATUS
            EQU      RD_STATUS0,     0xE2
            EQU      RD_STATUS1,     0xE4
            EQU      RD_STATUS2,     0xE8

            ;# OUTPUT AND NULL COUNT FLAG
            EQU      FLAG_OUTPUT,    0x80
            EQU      FLAG_NULL,      0x40

            ;# I/O PORTS
            EQU      PORT_CH0,       0x40
            EQU      PORT_CH1,       0x41
            EQU      PORT_CH2,       0x42
            EQU      PORT_CWD,       0x43

;###############################################################################
;#                              TEXT SECTION                                   #
;###############################################################################

            ;# TEXT SECTION
            SEGMENT  ".text"

;#-----------------------------------------------------------------------------#
;#                               KPITINIT()                                    #
;#-----------------------------------------------------------------------------#

KPITINIT:   ;# PRINT INIT MSG
            LEA      RDI, [RIP+KPITNAME]
            CALL     KCONMOD
            LEA      RDI, [RIP+KPITMSG]
            CALL     KCONSTR
            MOV      RDI, '\n'
            CALL     KCONCHR

            ;# DONE
            XOR      RAX, RAX
            RET

;#-----------------------------------------------------------------------------#
;#                                KPITCH0()                                    #
;#-----------------------------------------------------------------------------#

;#  @BRIEF: THIS ROUTINE SETS PIT COUNTER 0 TO AN INITIAL VALUE
;#          ALLOWING THE COUNTER TO FREE RUN UNTIL IT RAISES OUTPUT
;#          SIGNAL WHEN COUNTER REACHES 0. WE KEEP MONITORING THE OUTPUT
;#          SIGNAL IN A BUSY WAIT LOOP, AND RETURN WHEN IT BECOMES
;#          HIGH. PIT COUNTER WILL ROLL BACK TO 0xFFFF AND KEEP RUNNING
;#          LIKE AN IDIOT, BUT WILL NOT AFFECT OUTPUT SIGNAL SO WE ARE
;#          GOOD. THIS MODE IS CALLED INTERRUPT MODE (MODE 0).

;#  @IN:    RDI: LOWER 16-BIT ARE USED TO INIT THE COUNTER
;#  @OUT:   RAX: ERROR CODE

;#  @REGS:  RDX: USED FOR IN AND OUT COMMANDS

KPITCH0:    ;# WRITE CWD COMMAND
            MOV      AL, CHANNEL0|BYTE_BOTH|MODE_INTR
            MOV      DX, PORT_CWD
            OUT      DX, AL

            ;# WRITE COUNTER
            MOV      EAX, EDI
            MOV      DX, PORT_CH0
            OUT      DX, AL
            MOV      AL, AH
            MOV      DX, PORT_CH0
            OUT      DX, AL

            ;# READ OUTPUT PIN STATUS
1:          XOR      RAX, RAX
            MOV      AL, RD_STATUS0
            MOV      DX, PORT_CWD
            OUT      DX, AL
            MOV      DX, PORT_CH0
            IN       AL, DX
            AND      AL, FLAG_OUTPUT
            JZ       1b

            ;# DONE
            XOR      RAX, RAX
            RET

;#-----------------------------------------------------------------------------#
;#                                KPITCH1()                                    #
;#-----------------------------------------------------------------------------#

;#  @BRIEF: SAME AS KPITCH0 BUT ACTS ON CHANNEL 1

;#  @IN:    RDI: LOWER 16-BIT ARE USED TO INIT THE COUNTER
;#  @OUT:   RAX: ERROR CODE

;#  @REGS:  RDX: USED FOR IN AND OUT COMMANDS

KPITCH1:    ;# WRITE CWD COMMAND
            MOV      AL, CHANNEL1|BYTE_BOTH|MODE_INTR
            MOV      DX, PORT_CWD
            OUT      DX, AL

            ;# WRITE COUNTER
            MOV      EAX, EDI
            MOV      DX, PORT_CH1
            OUT      DX, AL
            MOV      AL, AH
            MOV      DX, PORT_CH1
            OUT      DX, AL

            ;# READ OUTPUT PIN STATUS
1:          XOR      RAX, RAX
            MOV      AL, RD_STATUS1
            MOV      DX, PORT_CWD
            OUT      DX, AL
            MOV      DX, PORT_CH1
            IN       AL, DX
            AND      AL, FLAG_OUTPUT
            JZ       1b

            ;# DONE
            XOR      RAX, RAX
            RET

;#-----------------------------------------------------------------------------#
;#                                KPITCH2()                                    #
;#-----------------------------------------------------------------------------#

;#  @BRIEF: SAME AS KPITCH0 BUT ACTS ON CHANNEL 2

;#  @IN:    RDI: LOWER 16-BIT ARE USED TO INIT THE COUNTER
;#  @OUT:   RAX: ERROR CODE

;#  @REGS:  RDX: USED FOR IN AND OUT COMMANDS

KPITCH2:    ;# WRITE CWD COMMAND
            MOV      AL, CHANNEL2|BYTE_BOTH|MODE_INTR
            MOV      DX, PORT_CWD
            OUT      DX, AL

            ;# WRITE COUNTER
            MOV      EAX, EDI
            MOV      DX, PORT_CH2
            OUT      DX, AL
            MOV      AL, AH
            MOV      DX, PORT_CH2
            OUT      DX, AL

            ;# READ OUTPUT PIN STATUS
1:          XOR      RAX, RAX
            MOV      AL, RD_STATUS2
            MOV      DX, PORT_CWD
            OUT      DX, AL
            MOV      DX, PORT_CH2
            IN       AL, DX
            AND      AL, FLAG_OUTPUT
            JZ       1b

            ;# DONE
            XOR      RAX, RAX
            RET

;###############################################################################
;#                              DATA SECTION                                   #
;###############################################################################

            ;# DATA SECTION
            SEGMENT  ".data"

;#-----------------------------------------------------------------------------#
;#                            LOGGING STRINGS                                  #
;#-----------------------------------------------------------------------------#

            ;# PIT HEADING AND ASCII STRINGS
KPITNAME:   DB       "KERNEL PIT\0"
KPITMSG:    DB       "8254 TIMER FREQUENCY: 11.931MHz\0"
