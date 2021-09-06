
    #########################################
    # COMMON DEFINITIONS USED ACROSS KERNEL #
    #########################################

    # --------------------------------------
    # LOWER 1MB OF MEMORY
    # --------------------------------------

    # 16-bit to 64-bit transitional code
    .equ     TrampolineCodeBase,  0x00000000
    .equ     TrampolineCodeSize,  0x00001000

    # 16-bit to 64-bit transitional stack
    .equ     TrampolineStackBase, 0x00001000
    .equ     TrampolineStackSize, 0x00001000

    # GDT Table
    .equ     GdtTableBase,        0x00003000
    .equ     GdtTableSize,        0x00001000

    # IDT Table
    .equ     IdtTableBase,        0x00004000
    .equ     IdtTableSize,        0x00001000

    # TSS Segments (32 segments for 32 CPUs)
    .equ     TssSegmentsBase,     0x00005000
    .equ     TssSegmentsSize,     0x00001000 # 0x80*32

    # Kernel Stacks (32 stacks for 32 CPUs)
    .equ     KernelStacksBase,    0x00010000
    .equ     KernelStacksSize,    0x00020000 # 0x1000*32

    # --------------------------------------
    # MSR REGISTERS
    # --------------------------------------

    .equ     ApicBaseAddrMsr,     0x0000001B
    .equ     EferMsr,             0xC0000080
