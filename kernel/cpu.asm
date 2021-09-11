;###############################################################################
;# File name:    KERNEL/CPU.ASM
;# DESCRIPTION:  CPU CORE SETUP PROCEDURE
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
            PUBLIC   KCPUINIT
            PUBLIC   KCPUSETUP

;###############################################################################
;#                              TEXT SECTION                                   #
;###############################################################################

            ;# TEXT SECTION
            SEGMENT  ".text"

;#-----------------------------------------------------------------------------#
;#                               KCPUINIT()                                    #
;#-----------------------------------------------------------------------------#

KCPUINIT:   ;# GET CPU MANUFACTURER
            MOV      EAX, 0
            CPUID
            MOV      [RIP+KCPUMAN+0], EBX
            MOV      [RIP+KCPUMAN+4], EDX
            MOV      [RIP+KCPUMAN+8], ECX

            ;# PRINT CPU MANUFACTURER
            LEA      RDI, [RIP+KCPUNAME]
            CALL     KLOGMOD
            LEA      RDI, [RIP+KCPUMANS]
            CALL     KLOGSTR
            LEA      RDI, [RIP+KCPUMAN]
            CALL     KLOGSTR
            MOV      RDI, '\n'
            CALL     KLOGCHR

            ;# GET CPU BRAND NAME
            MOV      EAX, 0x80000002
            CPUID
            MOV      [RIP+KCPUBRND+ 0], EAX
            MOV      [RIP+KCPUBRND+ 4], EBX
            MOV      [RIP+KCPUBRND+ 8], ECX
            MOV      [RIP+KCPUBRND+12], EDX
            MOV      EAX, 0x80000003
            CPUID
            MOV      [RIP+KCPUBRND+16], EAX
            MOV      [RIP+KCPUBRND+20], EBX
            MOV      [RIP+KCPUBRND+24], ECX
            MOV      [RIP+KCPUBRND+28], EDX
            MOV      EAX, 0x80000004
            CPUID
            MOV      [RIP+KCPUBRND+32], EAX
            MOV      [RIP+KCPUBRND+36], EBX
            MOV      [RIP+KCPUBRND+40], ECX
            MOV      [RIP+KCPUBRND+44], EDX

            ;# PRINT CPU BRAND NAME
            LEA      RDI, [RIP+KCPUNAME]
            CALL     KLOGMOD
            LEA      RDI, [RIP+KCPUBRNDS]
            CALL     KLOGSTR
            LEA      RDI, [RIP+KCPUBRND]
            CALL     KLOGSTR
            MOV      RDI, '\n'
            CALL     KLOGCHR

            ;# DONE
            XOR      RAX, RAX
            RET

;#-----------------------------------------------------------------------------#
;#                              KCPUSETUP()                                    #
;#-----------------------------------------------------------------------------#

KCPUSETUP:  ;# INVALIDATE CACHE
            WBINVD

            ;# INITIALIZE CR0
            MOV      RAX, 0x80010033   ;# CACHE EN, WR THRU, X87 FPU EN, PM
            MOV      CR0, RAX

            ;# INITIALIZE CR4
            MOV      RAX, 0x00000668   ;# DEBUG, PAE, MACHINE, SIMD 
            MOV      CR4, RAX

            ;# INITIALIZE CR8
            MOV      RAX, 0x00000000   ;# PRI = 0
            MOV      CR8, RAX

            ;# DONE
            XOR      RAX, RAX
            RET

;###############################################################################
;#                              DATA SECTION                                   #
;###############################################################################

            ;# DATA SECTION
            SEGMENT  ".data"

            ;# THE NAME OF THE CPU MANUFACTURER
KCPUMAN:    DQ       0
            DQ       0

            ;# THE NAME OF THE CPU BRAND
KCPUBRND:   DQ       0
            DQ       0
            DQ       0
            DQ       0
            DQ       0
            DQ       0
            DQ       0
            DQ       0

;#-----------------------------------------------------------------------------#
;#                            LOGGING STRINGS                                  #
;#-----------------------------------------------------------------------------#

            ;# CPU HEADING AND ASCII STRINGS
KCPUNAME:   DB       "KERNEL CPU\0"
KCPUMANS:   DB       "CPU MANUFACTURER: \0"
KCPUBRNDS:  DB       "CPU BRAND NAME: \0"
