#include "boot/boot.h"

EFI_API VOID BootRam(EFI_HANDLE ImageHandle, EFI_SYSTEM_TABLE *SystemTable)
{
  /* EFI operation status */
  EFI_STATUS Status = EFI_SUCCESS;

  /* BootService pointer retrieved from EFI system table */
  EFI_BOOT_SERVICES *BootServices = NULL;

  /* memory map information */
  UINTN   MapSize     = 0;
  VOID   *MapBuff     = NULL;
  UINTN   MapKey      = 0;

  /* descriptor information */
  UINTN   DescSize    = 0;
  UINT32  DescVersion = 0;

  /* (I) obtain pointer to boot services structure */
  if (Status == EFI_SUCCESS) {
    BootServices = SystemTable->BootServices;
  }

  /* (II) allocate buffer to load memory map into */
  if (Status == EFI_SUCCESS) {
    /* first, we fake call GetMemoryMap which returns the size in MapSize */
    BootServices->GetMemoryMap(&MapSize, NULL, NULL, &DescSize, &DescVersion);

    /* AllocatePool will add 2 more descriptors to memory map! */
    MapSize += 2*DescSize;

    /* now call AllocatePool to allocate the buffer */
    Status = BootServices->AllocatePool(EfiLoaderData, MapSize, &MapBuff);
  }

  /* (III) now load the whole memory map into ther buffer */
  if (Status == EFI_SUCCESS) {
    /* retrieve memory map */
    Status = BootServices->GetMemoryMap(&MapSize,
                                        MapBuff,
                                        &MapKey,
                                        &DescSize,
                                        &DescVersion);
    /* store the key in a global variable */
    BootDataMemKey = MapKey;
  }

  /* (V) store data in kernel init structure */
  if (Status == EFI_SUCCESS) {
    BootDataKernInit.MemoryMapBase = (UINT64) MapBuff;
    BootDataKernInit.MemoryMapSize = (UINT64) MapSize;
    BootDataKernInit.MemoryMapDesc = (UINT64) DescSize;
    BootDataKernInit.MemoryMapType = (UINT64) EfiConventionalMemory;
  }
}
