#include "boot/internal.h"

EFI_API void BootInit(EFI_HANDLE ImageHandle, EFI_SYSTEM_TABLE *SystemTable)
{
  /* get graphics card information */
  BootVga(ImageHandle, SystemTable);

  /* print banner */
  BootBanner(ImageHandle, SystemTable);

  while (1);
}
