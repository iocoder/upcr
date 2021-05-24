
/* C includes */
#include "boot/macros.h"

/* assembler includes */
.include "boot/efi.inc"

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

.globl GopGuid
.globl Gop

.globl FrameBufVirt
.globl FrameBufPhys
.globl FrameBufSize
.globl FrameBufWidth
.globl FrameBufHeight
.globl FrameBufScanLn

.globl RspValue

.globl BannerData

/* data section */
.data

  /* UEFI entry arguments */
ImageHandle:    .quad   0
SystemTable:    .quad   0

  /* Memory Map variables */
MapSize:        .quad   0
MemoryMap:      .quad   0
MapKey:         .quad   0
DescSize:       .quad   0
DescVersion:    .quad   0

  /* Ram Info */
RamStart:       .quad   0
RamEnd:         .quad   0
RamSize:        .quad   0

  /* GopGuid */
GopGuid:        .long   0x9042a9de
                .short  0x23dc
                .short  0x4a38
                .byte   0x96, 0xfb, 0x7a, 0xde, 0xd0, 0x80, 0x51, 0x6a
Gop:            .quad   0

  /* Framebuffer info */
FrameBufVirt:   .quad   0
FrameBufPhys:   .quad   0
FrameBufSize:   .quad   0
FrameBufWidth:  .quad   0
FrameBufHeight: .quad   0
FrameBufScanLn: .quad   0

  /* Copy of RSP */
RspValue:       .quad   0

  /* Message to print on start up */
BannerData:     .short  'B', 'o', 'o', 't', 'i', 'n', 'g', ' '
                .short  'u', 'p', '.', '.', '.'
                .short  0x0A, 0x00
