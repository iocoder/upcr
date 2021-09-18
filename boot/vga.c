#include "boot/boot.h"

/* the resolution that the graphics card will be initialized with */
#define BOOT_VGA_RES_WIDTH        800
#define BOOT_VGA_RES_HEIGHT       600

EFI_API VOID BootVga(EFI_HANDLE ImageHandle, EFI_SYSTEM_TABLE *SystemTable)
{
  /* GOP related data (GOP here has nothing to do with politics I swear) */
  EFI_GRAPHICS_OUTPUT_PROTOCOL *Gop = NULL;
  EFI_GUID GopGuid = EFI_GRAPHICS_OUTPUT_PROTOCOL_GUID;

  /* GOP mode information */
  UINT32 CurMode   = 0;
  INTN   InfoSize  = 0;
  UINT32 ModeFound = 0;
  EFI_GRAPHICS_OUTPUT_MODE_INFORMATION *ModeInfo = NULL;

  /* BootService pointer retrieved from EFI system table */
  EFI_BOOT_SERVICES *BootServices = NULL;

  /* EFI operation status */
  EFI_STATUS Status = EFI_SUCCESS;

  /* obtain pointer to boot services structure */
  if (Status == EFI_SUCCESS) {
    BootServices = SystemTable->BootServices;
  }

  /* get pointer to graphics protocol if exists */
  if (Status == EFI_SUCCESS) {
    Status = BootServices->LocateProtocol(&GopGuid, NULL, &Gop);
  }

  /* search for mode that satisfies our resolution requirements */
  if (Status == EFI_SUCCESS) {
    for (CurMode = 0; CurMode <= Gop->Mode->MaxMode && !ModeFound; CurMode++) {
      Status = Gop->QueryMode(Gop, CurMode, &InfoSize, &ModeInfo);
      if (ModeInfo->HorizontalResolution == BOOT_VGA_RES_WIDTH  &&
          ModeInfo->VerticalResolution   == BOOT_VGA_RES_HEIGHT &&
          ModeInfo->PixelFormat == PixelBlueGreenRedReserved8BitPerColor) {
        Gop->SetMode(Gop, CurMode);
        ModeFound = 1;
      }
    }
  }

  /* finally, store information in BootVgaInfo structure */
  if (Status == EFI_SUCCESS) {
    if (ModeFound) {
      /* load framebuffer info */
      BootDataKernInit.FrameBuffBase = Gop->Mode->FrameBufferBase;
      BootDataKernInit.FrameBuffSize = Gop->Mode->FrameBufferSize;

      /* load mode info */
      BootDataKernInit.FrameBuffWidt = ModeInfo->HorizontalResolution;
      BootDataKernInit.FrameBuffHigt = ModeInfo->VerticalResolution;
      BootDataKernInit.FrameBuffLine = ModeInfo->PixelsPerScanLine;
    }
  }
}
