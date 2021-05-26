#ifndef BOOT_EFI_H
#define BOOT_EFI_H

#include "kernel/types.h"

#define  EFI_API      __attribute__((ms_abi))
#define  EFI_SUCCESS  0

#define  EFI_GRAPHICS_OUTPUT_PROTOCOL_GUID \
  { \
    0x9042a9de, \
    0x23dc, 0x4a38, \
    {0x96, 0xfb, 0x7a, 0xde, 0xd0, 0x80, 0x51, 0x6a } \
  }

typedef void      * EFI_HANDLE;
typedef int16_t   * EFI_STRING;
typedef uint64_t    EFI_STATUS;

typedef enum {
  PixelRedGreenBlueReserved8BitPerColor,
  PixelBlueGreenRedReserved8BitPerColor,
  PixelBitMask,
  PixelBltOnly,
  PixelFormatMax
} EFI_GRAPHICS_PIXEL_FORMAT;

typedef enum {
  EfiReservedMemoryType,
  EfiLoaderCode,
  EfiLoaderData,
  EfiBootServicesCode,
  EfiBootServicesData,
  EfiRuntimeServicesCode,
  EfiRuntimeServicesData,
  EfiConventionalMemory,
  EfiUnusableMemory,
  EfiACPIReclaimMemory,
  EfiACPIMemoryNVS,
  EfiMemoryMappedIO,
  EfiMemoryMappedIOPortSpace,
  EfiPalCode,
  EfiPersistentMemory,
  EfiMaxMemoryType
} EFI_MEMORY_TYPE;

typedef struct {
  uint32_t  Data1;
  uint16_t  Data2;
  uint16_t  Data3;
  uint8_t   Data4[8];
} EFI_GUID;

/* UEFI table header */
typedef struct __attribute__((packed)) {
  uint64_t  Signature;
  uint32_t  Revision;
  uint32_t  HeaderSize;
  uint32_t  CRC32;
  uint32_t  Reserved;
} EFI_TABLE_HEADER;

/* Text output protocol */
typedef struct __attribute__((packed)) {
  EFI_STATUS (* EFI_API Reset)();
  EFI_STATUS (* EFI_API OutputString)(void *, EFI_STRING);
  EFI_STATUS (* EFI_API TestString)();
  EFI_STATUS (* EFI_API QueryMode)();
  EFI_STATUS (* EFI_API SetMode)();
  EFI_STATUS (* EFI_API SetAttribute)();
  EFI_STATUS (* EFI_API ClearScreen)();
  EFI_STATUS (* EFI_API SetCursorPosition)();
  EFI_STATUS (* EFI_API EnableCursor)();
} EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL;

typedef struct __attribute__((packed)) {
  uint32_t          RedMask;
  uint32_t          GreenMask;
  uint32_t          BlueMask;
  uint32_t          ReservedMask;
} EFI_PIXEL_BITMASK;

/* graphics output protocol mode information */
typedef struct __attribute__((packed)) {
  uint32_t                   Version;
  uint32_t                   HorizontalResolution;
  uint32_t                   VerticalResolution;
  EFI_GRAPHICS_PIXEL_FORMAT  PixelFormat;
  EFI_PIXEL_BITMASK          PixelInformation;
  uint32_t                   PixelsPerScanLine;
} EFI_GRAPHICS_OUTPUT_MODE_INFORMATION;

/* graphics output protocol mode */
typedef struct __attribute__((packed)) {
  uint32_t                                 MaxMode;
  uint32_t                                 Mode;
  EFI_GRAPHICS_OUTPUT_MODE_INFORMATION    *Info;
  uintn_t                                  SizeOfInfo;
  void                                    *FrameBufferBase;
  uintn_t                                  FrameBufferSize;
} EFI_GRAPHICS_OUTPUT_PROTOCOL_MODE;

/* graphics output protocol */
typedef struct {
  EFI_STATUS (* EFI_API QueryMode)(void *, uint32_t, uintn_t *, void *);
  EFI_STATUS (* EFI_API SetMode)(void *, uint32_t);
  EFI_STATUS (* EFI_API Blt)();
  EFI_GRAPHICS_OUTPUT_PROTOCOL_MODE *Mode;
} EFI_GRAPHICS_OUTPUT_PROTOCOL;

/* BootServices */
typedef struct __attribute__((packed)) {
  EFI_TABLE_HEADER Hdr;
  EFI_STATUS (* EFI_API RaiseTPL)();
  EFI_STATUS (* EFI_API RestoreTPL)();
  EFI_STATUS (* EFI_API AllocatePages)();
  EFI_STATUS (* EFI_API FreePages)();
  EFI_STATUS (* EFI_API GetMemoryMap)();
  EFI_STATUS (* EFI_API AllocatePool)(EFI_MEMORY_TYPE, uintn_t, void *);
  EFI_STATUS (* EFI_API FreePool)();
  EFI_STATUS (* EFI_API CreateEvent)();
  EFI_STATUS (* EFI_API SetTimer)();
  EFI_STATUS (* EFI_API WaitForEvent)();
  EFI_STATUS (* EFI_API SignalEvent)();
  EFI_STATUS (* EFI_API CloseEvent)();
  EFI_STATUS (* EFI_API CheckEvent)();
  EFI_STATUS (* EFI_API InstallProtocol)();
  EFI_STATUS (* EFI_API ReinstallProtocol)();
  EFI_STATUS (* EFI_API UninstallProtocol)();
  EFI_STATUS (* EFI_API HandleProtocol)();
  EFI_STATUS (* EFI_API Reserved)();
  EFI_STATUS (* EFI_API RegisterProtocolNotify)();
  EFI_STATUS (* EFI_API LocateHandle)();
  EFI_STATUS (* EFI_API LocateDevicePath)();
  EFI_STATUS (* EFI_API InstallConfigTable)();
  EFI_STATUS (* EFI_API LoadImage)();
  EFI_STATUS (* EFI_API StartImage)();
  EFI_STATUS (* EFI_API Exit)();
  EFI_STATUS (* EFI_API UnloadImage)();
  EFI_STATUS (* EFI_API ExitBootServices)();
  EFI_STATUS (* EFI_API GetNextMonotonicCount)();
  EFI_STATUS (* EFI_API Stall)();
  EFI_STATUS (* EFI_API SetWatchdogTimer)();
  EFI_STATUS (* EFI_API ConnectController)();
  EFI_STATUS (* EFI_API DisconnectController)();
  EFI_STATUS (* EFI_API OpenProtocol)();
  EFI_STATUS (* EFI_API CloseProtocol)();
  EFI_STATUS (* EFI_API OpenProtocolInfo)();
  EFI_STATUS (* EFI_API ProtocolsPerHandle)();
  EFI_STATUS (* EFI_API LocateHandleBuffer)();
  EFI_STATUS (* EFI_API LocateProtocol)(EFI_GUID *, void *, void *);
  EFI_STATUS (* EFI_API InstallMultiProtocol)();
  EFI_STATUS (* EFI_API UninstallMultiProtocol)();
  EFI_STATUS (* EFI_API CalculateCrc32)();
  EFI_STATUS (* EFI_API CopyMem)();
  EFI_STATUS (* EFI_API SetMem)();
  EFI_STATUS (* EFI_API CreateEventEx)();
} EFI_BOOT_SERVICES;

/* EFI system table */
typedef struct __attribute__((packed)) {
  EFI_TABLE_HEADER                   Hdr;
  EFI_STRING                         FirmwareVendor;
  uint32_t                           FirmwareRevision;
  uint32_t                           Padding;
  EFI_HANDLE                         ConsoleInHandle;
  void                              *ConIn;
  EFI_HANDLE                         ConsoleOutHandle;
  EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL   *ConOut;
  EFI_HANDLE                         StandardErrorHandle;
  void                              *StdErr;
  void                              *RuntimeServices;
  EFI_BOOT_SERVICES                 *BootServices;
  uint64_t                           NumberOfTableEntries;
  void                              *ConfigurationTable;
} EFI_SYSTEM_TABLE;

#endif /* BOOT_EFI_H */
