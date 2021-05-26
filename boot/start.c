#include "boot/boot.h"

EFI_API void BootStart(EFI_HANDLE ImageHandle, EFI_SYSTEM_TABLE *SystemTable)
{
  /* initialize graphics card framebuffer to be used by kernel */
  BootVga(ImageHandle, SystemTable);

  /* initialize memory map */
  BootRam(ImageHandle, SystemTable);

  /* exit boot services */
  BootExit(ImageHandle, SystemTable);

  /* boot up the kernel */
  BootKern(ImageHandle, SystemTable);
}
