#include "boot/boot.h"

KernelInitInfoT KernelInitInfo = {0};

EFI_API VOID BootKern(EFI_HANDLE ImageHandle, EFI_SYSTEM_TABLE *SystemTable)
{
  while (1);
}
