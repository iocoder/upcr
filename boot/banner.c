#include "boot/internal.h"

EFI_API void BootBanner(EFI_HANDLE ImageHandle, EFI_SYSTEM_TABLE *SystemTable)
{
  /* let the user know that bootloader has successfully started*/
  SystemTable->ConOut->OutputString(SystemTable->ConOut, L"Booting up...\r\n");
}
