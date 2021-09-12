;###############################################################################
;# File name:    KERNEL/SPL.ASM
;# DESCRIPTION:  PRINT SPLASH AND WELCOME MESSAGES
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
            PUBLIC   KSPLINIT

;###############################################################################
;#                              TEXT SECTION                                   #
;###############################################################################

            ;# TEXT SECTION
            SEGMENT  ".text"

;#-----------------------------------------------------------------------------#
;#                               KSPLINIT()                                    #
;#-----------------------------------------------------------------------------#

KSPLINIT:   ;# HEADER COLOUR
            MOV      RDI, 0x0A
            MOV      RSI, -1
            CALL     KCONATT

            ;# PRINT HEADER
            LEA      RDI, [RIP+KSPLHDR]
            CALL     KCONSTR

            ;# WELCOME MSG COLOUR
            MOV      RDI, 0x0E
            MOV      RSI, -1
            CALL     KCONATT

            ;# PRINT WELCOME MSG
            LEA      RDI, [RIP+KSPLWEL]
            CALL     KCONSTR

            ;# LICENSE COLOUR
            MOV      RDI, 0x0F
            MOV      RSI, -1
            CALL     KCONATT

            ;# PRINT LICENSE
            LEA      RDI, [RIP+KSPLLIC]
            CALL     KCONSTR

            ;# SET PRINTING COLOUR TO YELLOW
            MOV      RDI, 0x0B
            MOV      RSI, -1
            CALL     KCONATT

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

            ;# HEADER TEXT
KSPLHDR:    INCBIN   "kernel/header.txt"
            DB       "\0"

            ;# WELCOME TEXT
KSPLWEL:    INCBIN   "kernel/welcome.txt"
            DB       "\0"

            ;# LICENSE TEXT
KSPLLIC:    INCBIN   "kernel/license.txt"
            DB       "\0"
