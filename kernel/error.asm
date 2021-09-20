;###############################################################################
;# FILE NAME:    KERNEL/ERROR.ASM
;# DESCRIPTION:  KERNEL PANIC PROCEDURE
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
            PUBLIC   KERRPANIC

;###############################################################################
;#                              TEXT SECTION                                   #
;###############################################################################

            ;# TEXT SECTION
            SEGMENT  ".text"

;#-----------------------------------------------------------------------------#
;#                              KERRPANIC()                                    #
;#-----------------------------------------------------------------------------#

KERRPANIC:  ;# SEND INIT IPI TO ALL CPU CORES 
            CALL     KIRQIIPI

            ;# SET PANIC COLOUR
            MOV      RDI, 0x0A
            MOV      RSI, 0x01
            CALL     KCONATT

            ;# CLEAR SCREEN
            ;#CALL     KLOGCLR

            ;# PRINT PANIC HEADING
            LEA      RDI, [RIP+KERRHDR]
            CALL     KCONSTR

            ;# DUMP ALL CPU REGISTERS
            MOV      RDI, RSP
            CALL     KREGDUMP

            ;# HALT FOREVER
            JMP      .

;###############################################################################
;#                              DATA SECTION                                   #
;###############################################################################

            ;# DATA SECTION
            SEGMENT  ".data"

;#-----------------------------------------------------------------------------#
;#                            LOGGING STRINGS                                  #
;#-----------------------------------------------------------------------------#

            ;# PANIC HEADER
KERRHDR:    DB       "\n"
            DB       "\n"
            DB       "  "
            DB       "================================================"
            DB       "================================================"
            DB       "\n"
            DB       "                                          "
            DB       "KERNEL PANIC !!!"
            DB       "\n"
            DB       "  "
            DB       "================================================"
            DB       "================================================"
            DB       "\n"
            DB       "\n"
            DB       "  "
            DB       "KERNEL HAS PANICKED DUE TO AN EXCEPTION SIGNAL "
            DB       "WHILST IN KERNEL MODE."
            DB       "\n"
            DB       "\0"
