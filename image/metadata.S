/* place in header section */
.section  .header, "ax"

/* image starts here */
ImageStart:

/* MS-DOS header */
DosHeader:
.ascii  "MZ"                // MZ signature
.skip   0x3A                // skip to offset 0x3C
.long   PeHeader            // offset of PE header

/* PE header */
PeHeader:
.ascii  "PE"                // PE signature
.short  0

/* Standard COFF header */
CoffHeader:
.short  0x8664              // Machine (amd64)
.short  2                   // NumberOfSections
.long   0                   // TimeDateStamp
.long   0                   // PointerToSymbolTable
.long   1                   // NumberOfSymbols
.short  SectTable-OptHeader // SizeOfOptionalHeader
.short  0x0206              // Characteristics (EXEC | NOLINENUMS | NODEBUG)

/* optional header */
OptHeader:
                            // :: Standard COFF fields
.short  0x020B              // Magic (PE32+)
.byte   0x02                // MajorLinkerVersion
.byte   0x22                // MinorLinkerVersion
.long   ImageEnd-CodeBase   // SizeOfCode (sum of all sections)
.long   0                   // SizeOfInitializedData
.long   0                   // SizeOfUninitializedData
.long   BootStart           // AddressOfEntryPoint
.long   CodeBase            // BaseOfCode
.long   0                   // BaseOfData
                            // :: Windows-specific fields
.long   0                   // ImageBase
.long   0x1000              // SectionAlignment
.long   0x2000              // FileAlignment
.short  0                   // MajorOperatingSystemVersion
.short  0                   // MinorOperatingSystemVersion
.short  0                   // MajorImageVersion
.short  0                   // MinorImageVersion
.short  0                   // MajorSubsystemVersion
.short  0                   // MinorSubsystemVersion
.long   0                   // Win32VersionValue
.long   ImageEnd            // SizeOfImage
.long   CodeBase            // SizeOfHeaders
.long   0                   // CheckSum
.short  0x0A                // Subsystem
.short  0                   // DllCharacteristics
.quad   0                   // SizeOfStackReserve
.quad   0                   // SizeOfStackCommit
.quad   0                   // SizeOfHeapReserve
.quad   0                   // SizeOfHeapCommit
.long   0                   // LoaderFlags
.long   0x06                // NumberOfRvaAndSizes
                            // :: RVA and sizes
.quad   0                   // ExportTable
.quad   0                   // ImportTable
.quad   0                   // ResourceTable
.quad   0                   // ExceptionTable
.quad   0                   // CertificationTable
.quad   0                   // BaseRelocationTable

/* section table */
SectTable:

/* Dummy section */
.ascii  ".dummy\0\0"
.long   0                   // VirtualSize
.long   0                   // VirtualAddress
.long   0                   // SizeOfRawData
.long   0                   // PointerToRawData
.long   0                   // PointerToRelocations
.long   0                   // PointerToLineNumbers
.short  0                   // NumberOfRelocations
.short  0                   // NumberOfLineNumbers
.long   0x42100040          // Characteristics (section flags)

/* Code section */
.ascii  ".text\0\0\0"
.long   ImageEnd-CodeBase   // VirtualSize
.long   CodeBase            // VirtualAddress
.long   ImageEnd-CodeBase   // SizeOfRawData
.long   CodeBase            // PointerToRawData
.long   0                   // PointerToRelocations
.long   0                   // PointerToLineNumbers
.short  0                   // NumberOfRelocations
.short  0                   // NumberOfLineNumbers
.long   0xE0000020          // Characteristics (section flags)

/* Make sure code is page-aligned */
.align  0x1000, 0

/* Start of code section from Windows point of view */
CodeBase:

/* place the following symbol in footer section */
.section  .footer, "ax"

/* end of image symbol */
ImageEnd:
