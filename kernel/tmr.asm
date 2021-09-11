;###############################################################################
;# File name:    KERNEL/TMR.ASM
;# DESCRIPTION:  KERNEL TIMER MANAGEMENT
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
            PUBLIC   KTMRINIT

;###############################################################################
;#                              TEXT SECTION                                   #
;###############################################################################

            ;# TEXT SECTION
            SEGMENT  ".text"

;#-----------------------------------------------------------------------------#
;#                               KTMRINIT()                                    #
;#-----------------------------------------------------------------------------#

KTMRINIT:   ;# PRINT INIT MSG
            LEA      RDI, [RIP+KTMRNAME]
            CALL     KLOGMOD
            LEA      RDI, [RIP+KTMRMSG]
            CALL     KLOGSTR
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
;#                            LOGGING STRINGS                                  #
;#-----------------------------------------------------------------------------#

            ;# TMR HEADING AND ASCII STRINGS
KTMRNAME:   DB       "KERNEL TMR\0"
KTMRMSG:    DB       "TSC IS SELECTED TO BE THE MAIN TIMER.\0"
