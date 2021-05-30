
    # common definitions used by kernel
    .include "kernel/macro.inc"

    # text section
    .text

###############################################################################
#                            KernelRamInit()                                  #
###############################################################################

    # declare a linker symbol
    .global  KernelRamInit
    .set     KernelRamInit, .

    # read RamAvailable from init struct
    mov      0x38(%rdi), %rax
    mov      %rax, RamAvailable(%rip)

    # read RamStart from init struct
    mov      0x40(%rdi), %rax
    mov      %rax, RamStart(%rip)

    # read RamEnd from init struct
    mov      0x48(%rdi), %rax
    mov      %rax, RamEnd(%rip)

    # did the user provide RAM information anyways?
    cmpb     $0, RamAvailable(%rip)
    jz       1f

    # print heading of line
    mov      $0x0A, %rdi
    mov      $-1, %rsi
    call     KernelLogColour
    leaq     RamModuleStr(%rip), %rdi
    call     KernelLogString
    mov      $0x0B, %rdi
    mov      $-1, %rsi
    call     KernelLogColour

    # print ram start
    leaq     RamStartStr(%rip), %rdi
    call     KernelLogString
    movq     RamStart(%rip), %rdi
    call     KernelLogHex
    mov      $'\n', %rdi
    call     KernelLogChar

    # print heading of line
    mov      $0x0A, %rdi
    mov      $-1, %rsi
    call     KernelLogColour
    leaq     RamModuleStr(%rip), %rdi
    call     KernelLogString
    mov      $0x0B, %rdi
    mov      $-1, %rsi
    call     KernelLogColour

    # print ram end line
    leaq     RamEndStr(%rip), %rdi
    call     KernelLogString
    movq     RamEnd(%rip), %rdi
    call     KernelLogHex
    mov      $'\n', %rdi
    call     KernelLogChar

    # print heading of line
    mov      $0x0A, %rdi
    mov      $-1, %rsi
    call     KernelLogColour
    leaq     RamModuleStr(%rip), %rdi
    call     KernelLogString
    mov      $0x0B, %rdi
    mov      $-1, %rsi
    call     KernelLogColour

    # print ram size line
    leaq     RamSizeStr(%rip), %rdi
    call     KernelLogString
    movq     RamEnd(%rip), %rdi
    subq     RamStart(%rip), %rdi
    shr      $20, %rdi
    call     KernelLogDecimal
    mov      $'M', %rdi
    call     KernelLogChar
    mov      $'B', %rdi
    call     KernelLogChar
    mov      $'\n', %rdi
    call     KernelLogChar

    # done
1:  xor      %rax, %rax
    ret

##############################################################################

    # data section
    .data

    # RamInitInfo structure
    .set     RamAvailable, .
    .quad    0
    .set     RamStart, .
    .quad    0
    .set     RamEnd, .
    .quad    0

    # RAM heading
    .set     RamModuleStr, .
    .string  " [KERNEL MEMORY MGMT] "

    # RAM start ascii string
    .set     RamStartStr, .
    .string  "Detected RAM Start: "

    # RAM end ascii string
    .set     RamEndStr, .
    .string  "Detected RAM End:   "

    # RAM size ascii string
    .set     RamSizeStr, .
    .string  "Detected RAM Size:  "
