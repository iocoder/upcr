#ifndef BOOT_INTERNAL_H
#define BOOT_INTERNAL_H

#include "kernel/types.h"
#include "kernel/api.h"

#include "boot/efi.h"

EFI_API void BootInit(EFI_HANDLE ImageHandle, EFI_SYSTEM_TABLE *SystemTable);
EFI_API void BootBanner(EFI_HANDLE ImageHandle, EFI_SYSTEM_TABLE *SystemTable);
EFI_API void BootVga(EFI_HANDLE ImageHandle, EFI_SYSTEM_TABLE *SystemTable);

#endif /* BOOT_INTERNAL_H */
