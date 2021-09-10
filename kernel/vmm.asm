;###############################################################################
;# FILE NAME:    KERNEL/VMM.ASM
;# DESCRIPTION:  KERNEL VIRTUAL MEMORY MODULE
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

            ;# common definitions used by kernel
            INCLUDE  "kernel/macro.inc"

;###############################################################################
;#                                GLOBALS                                      #
;###############################################################################

            ;# global symbols
            PUBLIC   KVMMINIT

;###############################################################################
;#                              TEXT SECTION                                   #
;###############################################################################

            ;# text section
            SEGMENT  ".text"

;#-----------------------------------------------------------------------------#
;#                               KVMMINIT()                                    #
;#-----------------------------------------------------------------------------#

KVMMINIT:   ;# print init msg
            LEA      RDI, [RIP+KVMMNAME]
            CALL     KLOGMOD
            LEA      RDI, [RIP+KVMMMSG]
            CALL     KLOGSTR
            MOV      RDI, '\n'
            CALL     KLOGCHR

            ;# initialize PML4Table
            MOV      RSI, CR3
            MOV      RDI, PM4L_ADDR
            MOV      RCX, 0x1000

            ;# copy LOOP
1:          MOV      AL, [RSI]
            MOV      [RDI], AL
            INC      RSI
            INC      RDI
            LOOP     1b

            ;# load CR3 with PML4 table base
            MOV      RAX, PM4L_ADDR
            MOV      CR3, RAX

            ;# done
            XOR      RAX, RAX
            RET

;###############################################################################
;#                              DATA SECTION                                   #
;###############################################################################

            ;# data section
            SEGMENT  ".data"

;#-----------------------------------------------------------------------------#
;#                            LOGGING STRINGS                                  #
;#-----------------------------------------------------------------------------#

            ;# VMM heading and ascii strings
KVMMNAME:   DB       "KERNEL VMM\0"
KVMMMSG:    DB       "INITIALIZING VIRTUAL MEMORY MANAGER...\0"
