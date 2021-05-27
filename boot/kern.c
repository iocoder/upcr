#include "boot/boot.h"

EFI_API VOID BootKern(EFI_HANDLE ImageHandle, EFI_SYSTEM_TABLE *SystemTable)
{
  /* boot up the kernel */
  KernelBootInit(&BootDataKernInit);

  /* create init task */
  /* KernelTaskCreate() */

  /* start the operating system */
  KernelSystemStart();
}
