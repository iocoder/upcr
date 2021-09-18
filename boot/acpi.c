#include "boot/boot.h"

EFI_API VOID BootAcpi(EFI_HANDLE ImageHandle, EFI_SYSTEM_TABLE *SystemTable)
{
  UINT64                   Ctr         = 0;
  EFI_CONFIGURATION_TABLE *ConfigTable = NULL;
  EFI_GUID                 AcpiGuid    = EFI_ACPI_TABLE_GUID;
  UINT64                   AcpiG0      = 0;
  UINT64                   AcpiG1      = 0;
  UINT64                   TableG0     = 0;
  UINT64                   TableG1     = 0;
  UINT64                   TableAddr   = 0;

  /* process ACPI GUID */
  AcpiG0 = ((UINT64*)&AcpiGuid)[0];
  AcpiG1 = ((UINT64*)&AcpiGuid)[1];

  /* loop over configuration tables to find ACPI table */
  for (Ctr = 0; Ctr < SystemTable->NumberOfTableEntries; Ctr++) {
    /* get a pointer to current config table */
    ConfigTable = &SystemTable->ConfigurationTable[Ctr];

    /* process table GUID */
    TableG0 = ((UINT64*)&ConfigTable->VendorGuid)[0];
    TableG1 = ((UINT64*)&ConfigTable->VendorGuid)[1];

    /* convert the address into integer */
    TableAddr = (UINT64) ConfigTable->VendorTable;

    /* is this the ACPI table? */
    if (AcpiG0 == TableG0 && AcpiG1 == TableG1) {
      /* store in kernel boot info */
      BootDataKernInit.AcpiTableBase = TableAddr;
    }
  }
}
