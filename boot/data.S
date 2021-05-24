
/* C includes */
#include "asm.h"

/* assembler includes */
.include "efi.inc"

/* linker symbols to export */
.globl ImageHandle
.globl SystemTable
.globl MapSize
.globl MemoryMap
.globl MapKey
.globl DescSize
.globl DescVersion
.globl RamStart
.globl RamEnd
.globl RamSize
.globl RspValue
.globl BannerData

/* data section */
.data

  /* UEFI entry arguments */
ImageHandle:   .quad  0
SystemTable:   .quad  0

  /* Memory Map variables */
MapSize:       .quad  0
MemoryMap:     .quad  0
MapKey:        .quad  0
DescSize:      .quad  0
DescVersion:   .quad  0

  /* Ram Info */
RamStart:      .quad  0
RamEnd:        .quad  0
RamSize:       .quad  0

  /* Copy of RSP */
RspValue:      .quad  0

  /* Message to print on start up */
BannerData:    .short 'B', 'o', 'o', 't', 'i', 'n', 'g', ' '
               .short 'u', 'p', '.', '.', '.'
               .short 0x0A, 0x00
