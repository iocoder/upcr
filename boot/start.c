#include "boot/boot.h"

EFI_API VOID BootStart(EFI_HANDLE ImageHandle, EFI_SYSTEM_TABLE *SystemTable)
{
  /* initialize graphics card framebuffer */
  BootVga(ImageHandle, SystemTable);

  /* initialize memory map */
  BootRam(ImageHandle, SystemTable);

  /* retrieve ACPI table */
  BootAcpi(ImageHandle, SystemTable);

  /* exit boot services */
  BootExit(ImageHandle, SystemTable);

  /* boot up the kernel */
  BootKern(ImageHandle, SystemTable);
}
