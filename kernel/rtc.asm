;###############################################################################
;# File name:    KERNEL/RTC.ASM
;# DESCRIPTION:  KERNEL REAL TIME CLOCK
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
            PUBLIC   KRTCINIT
            PUBLIC   KRTCSYNC

;###############################################################################
;#                              TEXT SECTION                                   #
;###############################################################################

            ;# TEXT SECTION
            SEGMENT  ".text"

;#-----------------------------------------------------------------------------#
;#                               KRTCINIT()                                    #
;#-----------------------------------------------------------------------------#

KRTCINIT:   ;# SET FORMAT TO 12-HOUR BCD
            XOR      RAX, RAX
            MOV      DX, 0x70
            MOV      AL, 0x0B
            OUT      DX, AL
            MOV      DX, 0x71
            MOV      AL, 0x02
            OUT      DX, AL

            ;# SYNCHRONIZE RTC TIMER
            CALL     KRTCSYNC

            ;# PRINT CURRENT DATE/TIME
            LEA      RDI, [RIP+KRTCNAME]
            CALL     KCONMOD
            LEA      RDI, [RIP+KRTCMSG]
            CALL     KCONSTR
            LEA      RDI, [RIP+KRTCSTR]
            CALL     KCONSTR
            MOV      RDI, '\n'
            CALL     KCONCHR

            ;# DONE
            XOR      RAX, RAX
            RET

;#-----------------------------------------------------------------------------#
;#                               KRTCSYNC()                                    #
;#-----------------------------------------------------------------------------#

KRTCSYNC:   ;# GET PTR TO DATETIME STRING
            LEA      RDI, [RIP+KRTCSTR]

#if 0
            ;# OBTAIN WEEKDAY
            XOR      RAX, RAX
            MOV      DX, 0x70
            MOV      AL, 0x06
            OUT      DX, AL
            MOV      DX, 0x71
            IN       AL, DX
            
            ;# OBTAIN WEEKDAY NAME
            DEC      RAX
            SHL      RAX, 4
            LEA      RSI, [RIP+KRTCDAYS]
            ADD      RSI, RAX

            ;# WRITE WEEKDAY ONTO THE STRING
            MOV      RAX, [RSI]
            MOV      [RDI+0], RAX
            MOV      RAX, [RSI+8]
            MOV      [RDI+8], RAX
#endif

            ;# OBTAIN MONTH
            XOR      RAX, RAX
            MOV      DX, 0x70
            MOV      AL, 0x08
            OUT      DX, AL
            MOV      DX, 0x71
            IN       AL, DX

            ;# OBTAIN MONTH NAME
            DEC      RAX
            SHL      RAX, 4
            LEA      RSI, [RIP+KRTCMONS]
            ADD      RSI, RAX

            ;# WRITE MONTH ONTO THE STRING
            MOV      RAX, [RSI]
            MOV      [RDI+12], RAX
            MOV      RAX, [RSI+8]
            MOV      [RDI+20], RAX

            ;# OBTAIN DAY OF MONTH
            XOR      RAX, RAX
            MOV      DX, 0x70
            MOV      AL, 0x07
            OUT      DX, AL
            MOV      DX, 0x71
            IN       AL, DX

            ;# WRITE DAY ONTO THE STRING
            MOV      DL, AL
            SHR      DL, 4
            ADD      DL, '0'
            MOV      [RDI+22], DL
            MOV      DL, AL
            AND      DL, 0x0F
            ADD      DL, '0'
            MOV      [RDI+23], DL

            ;# OBTAIN YEAR
            XOR      RAX, RAX
            MOV      DX, 0x70
            MOV      AL, 0x09
            OUT      DX, AL
            MOV      DX, 0x71
            IN       AL, DX

            ;# WRITE YEAR ONTO THE STRING
            MOV      DL, AL
            SHR      DL, 4
            ADD      DL, '0'
            MOV      [RDI+28], DL
            MOV      DL, AL
            AND      DL, 0x0F
            ADD      DL, '0'
            MOV      [RDI+29], DL

            ;# OBTAIN HOUR
            XOR      RAX, RAX
            MOV      DX, 0x70
            MOV      AL, 0x04
            OUT      DX, AL
            MOV      DX, 0x71
            IN       AL, DX

            ;# ADJUST IF HOURS >= 22
            AND      AL, 0x7F
            CMP      AL, 0x22
            JB       1f
            SUB      AL, 0x12
            JMP      3f

            ;# ADJUST IF HOURS >= 20
1:          CMP      AL, 0x20
            JB       2f
            SUB      AL, 0x18
            JMP      3f

            ;# ADJUST IF HOURS >= 13
2:          CMP      AL, 0x13
            JB       3f
            SUB      AL, 0x12
            JMP      3f

            ;# WRITE HOURS ONTO STRING
3:          MOV      DL, AL
            SHR      DL, 4
            ADD      DL, '0'
            MOV      [RDI+33], DL
            MOV      DL, AL
            AND      DL, 0x0F
            ADD      DL, '0'
            MOV      [RDI+34], DL

            ;# OBTAIN MINUTE
            XOR      RAX, RAX
            MOV      DX, 0x70
            MOV      AL, 0x02
            OUT      DX, AL
            MOV      DX, 0x71
            IN       AL, DX

            ;# WRITE MINUTE ONTO THE STRING
            MOV      DL, AL
            SHR      DL, 4
            ADD      DL, '0'
            MOV      [RDI+36], DL
            MOV      DL, AL
            AND      DL, 0x0F
            ADD      DL, '0'
            MOV      [RDI+37], DL

            ;# OBTAIN SECOND
            XOR      RAX, RAX
            MOV      DX, 0x70
            MOV      AL, 0x00
            OUT      DX, AL
            MOV      DX, 0x71
            IN       AL, DX

            ;# WRITE SECOND ONTO THE STRING
            MOV      DL, AL
            SHR      DL, 4
            ADD      DL, '0'
            MOV      [RDI+39], DL
            MOV      DL, AL
            AND      DL, 0x0F
            ADD      DL, '0'
            MOV      [RDI+40], DL

            ;# OBTAIN AM/PM
            XOR      RAX, RAX
            MOV      DX, 0x70
            MOV      AL, 0x04
            OUT      DX, AL
            MOV      DX, 0x71
            IN       AL, DX

            ;# WRITE AM/PM ONTO THE STRING
            AND      AL, 0x7F
            CMP      AL, 0x12
            JB       1f
            MOV      AX, 0x4D50
            JMP      2f
1:          MOV      AX, 0x4D41
2:          MOV      [RDI+42], AX

            ;# UPDATE DATE ON CONSOLE STATUS BAR
            CALL     KCONDATE

            ;# DONE
            XOR      RAX, RAX
            RET

;###############################################################################
;#                              DATA SECTION                                   #
;###############################################################################

            ;# DATA SECTION
            SEGMENT  ".data"

;#-----------------------------------------------------------------------------#
;#                             MODULE DATA                                     #
;#-----------------------------------------------------------------------------#

            ;# MAKE SURE DATA IS ALIGNED FOR FAST ACCESS
            ALIGN    8

            ;# WEEK DAYS
KRTCDAYS:   DB       "SUNDAY  -       "
            DB       "MONDAY  -       "
            DB       "TUESDAY  -      "
            DB       "WEDNESDAY -     "
            DB       "THURSDAY  -     "
            DB       "FRIDAY  -       "
            DB       "SATURDAY  -     "

KRTCMONS:   DB       "JANUARY   DD, 20"
            DB       "FEBRUARY  DD, 20"
            DB       "MARCH     DD, 20"
            DB       "APRIL     DD, 20"
            DB       "MAY       DD, 20"
            DB       "JUNE      DD, 20"
            DB       "JULY      DD, 20"
            DB       "AUGUST    DD, 20"
            DB       "SEPTEMBER DD, 20"
            DB       "OCTOBER   DD, 20"
            DB       "NOVEMBER  DD, 20"
            DB       "DECEMBER  DD, 20"

            ;# TYPICAL DATE/TIME STRING
KRTCSTR:    DB       "WWWWWWWWW - MMMMMMMMM DD, YYYY | HH:MM:SS XM\0"

;#-----------------------------------------------------------------------------#
;#                            LOGGING STRINGS                                  #
;#-----------------------------------------------------------------------------#

            ;# RTC HEADING AND ASCII STRINGS
KRTCNAME:   DB       "KERNEL RTC\0"
KRTCMSG:    DB       "CMOS DATE/TIME: \0"
