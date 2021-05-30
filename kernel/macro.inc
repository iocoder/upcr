
    #########################################
    # COMMON DEFINITIONS USED ACROSS KERNEL #
    #########################################

    # LOWER 1MB OF MEMORY

    # 16-bit to 64-bit transitional code
    .equ     TrampolineCodeBase,  0x00000000
    .equ     TrampolineCodeSize,  0x00001000

    # 16-bit to 64-bit transitional stack
    .equ     TrampolineStackBase, 0x00001000
    .equ     TrampolineStackSize, 0x00002000

    # PML4 page table
    .equ     PML4PageTableBase,   0x00001000
    .equ     PML4PageTableSize,   0x00002000

    # MSR REGISTERS
    # -------------
    .equ     ApicBaseAddrMsr,     0x0000001B
    .equ     EferMsr,             0xC0000080
