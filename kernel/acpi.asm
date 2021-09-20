;###############################################################################
;# File name:    KERNEL/ACPI.ASM
;# DESCRIPTION:  KERNEL-MODE ACPI INTERFACE
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
            PUBLIC   KACPINIT
            PUBLIC   KACPIGET

;###############################################################################
;#                              TEXT SECTION                                   #
;###############################################################################

            ;# TEXT SECTION
            SEGMENT  ".text"

;#-----------------------------------------------------------------------------#
;#                               KACPINIT()                                    #
;#-----------------------------------------------------------------------------#

KACPINIT:   ;# LOAD THE ADDRES OF KERNEL ACPI TABLE PTR ARRAY
            LEA      RDI, [RIP+KACPTBLS]

            ;# RETRIEVE RSD PTR FROM BOOT LOADER
            MOV      RSI, [R15+0x00]

            ;# CREATE AN ENTRY FOR RSDP IN KERNEL ACPI TBL
            MOV      EAX, ACPI_TBL_RSDP
            MOV      [RDI+0], EAX
            MOV      EAX, [RSI+20]
            MOV      [RDI+4], EAX
            MOV      [RDI+8], RSI
            ADD      RDI, 16

            ;# GET RSDT ADDRESS
            XOR      RAX, RAX
            MOV      EAX, [RSI+16]
            MOV      R8, RAX

            ;# STORE RSDT INFO IN FIRST ENTRY
            MOV      RAX, [R8]
            MOV      [RDI+0], RAX    ;# TBL SIGNATURE + LENGTH
            MOV      [RDI+8], R8     ;# TBL PTR
            ADD      RDI, 16         ;# MOVE TO NEXT ENTRY

            ;# GET XSDT ADDRESS
            MOV      R8, [RSI+24]

            ;# STORE XSDT INFO IN FIRST ENTRY
            MOV      RAX, [R8]
            MOV      [RDI+0], RAX    ;# TBL SIGNATURE + LENGTH
            MOV      [RDI+8], R8     ;# TBL PTR
            ADD      RDI, 16         ;# MOVE TO NEXT ENTRY

            ;# COMPUTE TABLE PTRS START AND END ADDRESSES
            MOV      RSI, R8
            MOV      RCX, RSI
            XOR      RAX, RAX
            MOV      EAX, [RSI+4]    ;# XSDT LENGTH
            ADD      RCX, RAX        ;# RCX = XSDT END ADDRESS
            ADD      RSI, 36         ;# RSI = XSDT FIRST PTR

            ;# FIRST POINTER IS ACTUALLY FADT
            MOV      R8, [RSI]

            ;# STORE IN KERNEL TABLE
            MOV      RAX, [R8]
            MOV      [RDI+0], RAX    ;# TBL SIGNATURE + LENGTH
            MOV      [RDI+8], R8     ;# TBL PTR
            ADD      RDI, 16         ;# MOVE TO NEXT ENTRY

            ;# NOW RETRIEVE FACT FROM FADT
            MOV      R8, [RSI]
            MOV      RAX, [R8+0x84]
            CMP      RAX, 0
            JNE      2f
            MOV      EAX, [R8+0x24]
2:          MOV      R8, RAX

            ;# STORE IN KERNEL TABLE
            MOV      RAX, [R8]
            MOV      [RDI+0], RAX    ;# TBL SIGNATURE + LENGTH
            MOV      [RDI+8], R8     ;# TBL PTR
            ADD      RDI, 16         ;# MOVE TO NEXT ENTRY

            ;# RETRIEVE DSDT FROM FADT
            MOV      R8, [RSI+0]
            MOV      RAX, [R8+0x8C]
            CMP      RAX, 0
            JNE      3f
            MOV      EAX, [R8+0x28]
3:          MOV      R8, RAX

            ;# STORE IN KERNEL TABLE
            MOV      RAX, [R8]
            MOV      [RDI+0], RAX    ;# TBL SIGNATURE + LENGTH
            MOV      [RDI+8], R8     ;# TBL PTR
            ADD      RDI, 16         ;# MOVE TO NEXT ENTRY

            ;# LOAD NEXT POINTER IN XSDT
11:         ADD      RSI, 8
            CMP      RSI, RCX
            JE       12f
            MOV      R8, [RSI+0]

            ;# STORE IN KERNEL TABLE
            MOV      RAX, [R8]
            MOV      [RDI+0], RAX    ;# TBL SIGNATURE + LENGTH
            MOV      [RDI+8], R8     ;# TBL PTR
            ADD      RDI, 16         ;# MOVE TO NEXT ENTRY

            ;# MOVE TO NEXT ENTRY
            JMP      11b

            ;# WE ARE DONE, COMPUTE NUMBER OF ENTRIES
12:         MOV      RAX, RDI
            LEA      RDI, [RIP+KACPTBLS]
            SUB      RAX, RDI
            SHR      RAX, 4
            MOV      [RIP+KACPCNT], RAX

            ;# DONE
            XOR      RAX, RAX
            RET

;#-----------------------------------------------------------------------------#
;#                               KACPGET()                                     #
;#-----------------------------------------------------------------------------#

;# INPUTS: RDI = Lower 4 bytes are table signature
;#         RSI = Pointer to location to store table info (16-byte)

KACPIGET:   ;# PUT TARGET TABLE SIGNATURE IN EAX
            MOV      EAX, EDI

            ;# Search for the required table
            LEA      RDI, [RIP+KACPTBLS]
            MOV      RCX, [RIP+KACPCNT]
1:          CMP      EAX, [RDI]
            JE       2f
            ADD      RDI, 16
            LOOP     1b

            ;# NOT FOUND
            MOV      RAX, -1
            RET

            ;# FOUND AN ENTRY
2:          MOV      RAX, [RDI+0]
            MOV      [RSI+0], RAX
            MOV      RAX, [RDI+8]
            XOR      [RSI+8], RAX

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

            ;# ALIGN AT PAGE BOUNDARY
            ALIGN    0x1000

            ;# LIST OF ACPI TABLES
            ;# EACH ENTRY CONSISTS OF 16 BYTES:
            ;#  - BYTE 0-3:  TABLE SIGNATURE
            ;#  - BYTE 4-7:  TABLE SIZE
            ;#  - BYTE 8-15: TABLE PTR (64-BITS)
KACPTBLS:   .SPACE   0x1000
KACPCNT:    DQ       0
