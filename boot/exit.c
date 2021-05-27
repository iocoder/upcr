#include "boot/boot.h"

EFI_API VOID BootExit(EFI_HANDLE ImageHandle, EFI_SYSTEM_TABLE *SystemTable)
{
  /* BootService pointer retrieved from EFI system table */
  EFI_BOOT_SERVICES *BootServices = NULL;

  /* get BootServices pointer */
  BootServices = SystemTable->BootServices;

  /* ask UEFI to terminate all boot services  */
  SystemTable->BootServices->ExitBootServices(ImageHandle, BootDataMemKey);
}
