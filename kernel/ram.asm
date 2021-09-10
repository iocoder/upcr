;###############################################################################
;# File name:    KERNEL/RAM.ASM
;# DESCRIPTION:  KERNEL PHYSICAL MEMORY MODULE
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
            PUBLIC   KRAMINIT

;###############################################################################
;#                              TEXT SECTION                                   #
;###############################################################################

            ;# TEXT SECTION
            SEGMENT  ".text"

;#-----------------------------------------------------------------------------#
;#                              KRAMINIT()                                     #
;#-----------------------------------------------------------------------------#

KRAMINIT:   ;# READ KRAMAVL FROM INIT STRUCT
            MOV      RAX, [R15+0x38]
            MOV      [RIP+KRAMAVL], RAX

            ;# READ KRAMSTART FROM INIT STRUCT
            MOV      RAX, [R15+0x40]
            MOV      [RIP+KRAMSTART], RAX

            ;# READ KRAMEND FROM INIT STRUCT
            MOV      RAX, [R15+0x48]
            MOV      [RIP+KRAMEND], RAX

            ;# PRINT RAM START
            LEA      RDI, [RIP+KRAMNAME]
            CALL     KLOGMOD
            LEA      RDI, [RIP+KRAMSTARTS]
            CALL     KLOGSTR
            MOV      RDI, [RIP+KRAMSTART]
            CALL     KLOGHEX
            MOV      RDI, '\n'
            CALL     KLOGCHR

            ;# PRINT RAM END
            LEA      RDI, [RIP+KRAMNAME]
            CALL     KLOGMOD
            LEA      RDI, [RIP+KRAMENDS]
            CALL     KLOGSTR
            MOV      RDI, [RIP+KRAMEND]
            CALL     KLOGHEX
            MOV      RDI, '\n'
            CALL     KLOGCHR

            ;# PRINT RAM SIZE
            LEA      RDI, [RIP+KRAMNAME]
            CALL     KLOGMOD
            LEA      RDI, [RIP+KRAMESIZES]
            CALL     KLOGSTR
            MOV      RDI, [RIP+KRAMEND]
            SUB      RDI, [RIP+KRAMSTART]
            SHR      RDI, 20
            CALL     KLOGDEC
            MOV      RDI, 'M'
            CALL     KLOGCHR
            MOV      RDI, 'B'
            CALL     KLOGCHR
            MOV      RDI, '\n'
            CALL     KLOGCHR

            ;# DONE
            XOR      RAX, RAX
            RET

;###############################################################################
;#                              DATA SECTION                                   #
;###############################################################################

            ;# DATA SECTION
            SEGMENT  ".data"

;#-----------------------------------------------------------------------------#
;#                              MODULE DATA                                    #
;#-----------------------------------------------------------------------------#

            ;# RAMINITINFO STRUCTURE
KRAMAVL:    DQ       0
KRAMSTART:  DQ       0
KRAMEND:    DQ       0

;#-----------------------------------------------------------------------------#
;#                            LOGGING STRINGS                                  #
;#-----------------------------------------------------------------------------#

            ;# RAM HEADING AND MESSAGES
KRAMNAME:   DB       "KERNEL RAM\0"
KRAMSTARTS: DB       "DETECTED RAM START: \0"
KRAMENDS:   DB       "DETECTED RAM END:   \0"
KRAMESIZES: DB       "DETECTED RAM SIZE:  \0"
