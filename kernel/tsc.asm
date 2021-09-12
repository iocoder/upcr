;###############################################################################
;# File name:    KERNEL/TSC.ASM
;# DESCRIPTION:  CPU INTEGRATED TIME-STAMP COUNTER
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
            PUBLIC   KTSCINIT
            PUBLIC   KTSCUS

;###############################################################################
;#                              TEXT SECTION                                   #
;###############################################################################

            ;# TEXT SECTION
            SEGMENT  ".text"

;#-----------------------------------------------------------------------------#
;#                               KTSCINIT()                                    #
;#-----------------------------------------------------------------------------#

KTSCINIT:   ;# READ TSC STAMP
            XOR      RAX, RAX
            RDTSC
            SHL      RDX, 32
            ADD      RAX, RDX
            PUSH     RAX

            ;# WAIT FOR 10 MS.
            MOV      RDI, PIT_CTR_10MS
            CALL     KPITCH0

            ;# READ TSC STAMP AGAIN
            XOR      RAX, RAX
            RDTSC
            SHL      RDX, 32
            ADD      RAX, RDX

            ;# COMPUTE DELTA
            POP      RDX
            SUB      RAX, RDX

            ;# COMPUTE FREQUENCY
            XOR      RDX, RDX
            MOV      RCX, 10000
            DIV      RCX
            MOV      [RIP+KTSCFREQ], RAX

            ;# PRINT INIT MSG
            LEA      RDI, [RIP+KTSCNAME]
            CALL     KCONMOD
            LEA      RDI, [RIP+KTSCMSG]
            CALL     KCONSTR
            MOV      RDI, [RIP+KTSCFREQ]
            CALL     KCONDEC
            MOV      RDI, 'M'
            CALL     KCONCHR
            MOV      RDI, 'H'
            CALL     KCONCHR
            MOV      RDI, 'z'
            CALL     KCONCHR
            MOV      RDI, '\n'
            CALL     KCONCHR

            ;# DONE
            XOR      RAX, RAX
            RET

;#-----------------------------------------------------------------------------#
;#                                KTSCUS()                                     #
;#-----------------------------------------------------------------------------#

KTSCUS:     MOV      RDI, 2000000

            MOV      RAX, [RIP+KTSCFREQ]
            MUL      RDI
            MOV      RCX, RAX

            PUSH     RCX
            XOR      RAX, RAX
            MOV      ECX, MSR_TSC
            RDMSR
            SHL      RDX, 32
            ADD      RAX, RDX
            POP      RCX
 
            ADD      RAX, RCX

            MOV      RDX, RAX
            SHR      RDX, 32
            MOV      RCX, 0xFFFFFFFF
            AND      RAX, RCX
            MOV      RCX, MSR_TSC_DEADLN
            WRMSR

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

            ;# TSC COUNTER FREQUENCY
KTSCFREQ:   DQ       0

;#-----------------------------------------------------------------------------#
;#                            LOGGING STRINGS                                  #
;#-----------------------------------------------------------------------------#

            ;# TSC HEADING AND ASCII STRINGS
KTSCNAME:   DB       "KERNEL TSC\0"
KTSCMSG:    DB       "TSC  TIMER FREQUENCY: \0"
