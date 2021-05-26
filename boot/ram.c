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

  /* variables used to loop over descriptors */
  UINTN                   DescOff = 0;
  EFI_MEMORY_DESCRIPTOR  *DescAddr = 0;

  /* ram information collected so far */
  UINT64  RamFound = 0;
  UINT64  RamPages = 0;
  UINT64  RamStart = 0;
  UINT64  RamEnd   = 0;

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
    Status = BootServices->GetMemoryMap(&MapSize,
                                        MapBuff,
                                        &MapKey,
                                        &DescSize,
                                        &DescVersion);
  }

  /* (IV) loop over entries to detect RAM information */
  if (Status == EFI_SUCCESS) {
    /* loop over all the descriptors */
    for (DescOff = 0; DescOff < MapSize; DescOff += DescSize) {
      /* cast descriptor address into a descriptor pointer */
      DescAddr = MapBuff + DescOff;
      /* is it a memory region? the biggest one? */
      if (DescAddr->Type == EfiConventionalMemory &&
          DescAddr->NumberOfPages > RamPages) {
        /* RAM detected */
        RamFound = 1;
        /* get descriptor data */
        RamPages = DescAddr->NumberOfPages;
        RamStart = DescAddr->PhysicalStart;
        /* compute RAM boundary */
        RamEnd   = RamStart + RamPages * KERNEL_PAGE_SIZE;
      }
    }
  }

  /* (V) store data in kernel init structure */
  if (Status == EFI_SUCCESS) {
    if (RamFound == 1) {
      KernelInitInfo.RamInfo.RamAvailable = 1;
      KernelInitInfo.RamInfo.RamStart     = RamStart;
      KernelInitInfo.RamInfo.RamEnd       = RamEnd;
    }
  }
}
