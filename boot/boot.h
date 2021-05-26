#ifndef BOOT_H
#define BOOT_H

#include "kernel/kernel.h"

#define  EFI_API      __attribute__((ms_abi))
#define  EFI_SUCCESS  0

#define  EFI_GRAPHICS_OUTPUT_PROTOCOL_GUID \
  { \
    0x9042a9de, \
    0x23dc, 0x4a38, \
    {0x96, 0xfb, 0x7a, 0xde, 0xd0, 0x80, 0x51, 0x6a } \
  }

typedef void      VOID;

typedef int8_t    INT8;
typedef int16_t   INT16;
typedef int32_t   INT32;
typedef int64_t   INT64;
typedef intn_t    INTN;

typedef uint8_t   UINT8;
typedef uint16_t  UINT16;
typedef uint32_t  UINT32;
typedef uint64_t  UINT64;
typedef uintn_t   UINTN;

typedef int8_t    CHAR8;
typedef int16_t   CHAR16;

typedef UINT64    EFI_STATUS;
typedef UINT64    EFI_PHYSICAL_ADDRESS;
typedef UINT64    EFI_VIRTUAL_ADDRESS;
typedef VOID     *EFI_HANDLE;

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
  UINT32  Data1;
  UINT16  Data2;
  UINT16  Data3;
  UINT8   Data4[8];
} EFI_GUID;

/* UEFI table header */
typedef struct {
  UINT64  Signature;
  UINT32  Revision;
  UINT32  HeaderSize;
  UINT32  CRC32;
  UINT32  Reserved;
} EFI_TABLE_HEADER;

/* Text output protocol */
typedef struct {
  EFI_STATUS (* EFI_API Reset)();
  EFI_STATUS (* EFI_API OutputString)(VOID *, CHAR16 *);
  EFI_STATUS (* EFI_API TestString)();
  EFI_STATUS (* EFI_API QueryMode)();
  EFI_STATUS (* EFI_API SetMode)();
  EFI_STATUS (* EFI_API SetAttribute)();
  EFI_STATUS (* EFI_API ClearScreen)();
  EFI_STATUS (* EFI_API SetCursorPosition)();
  EFI_STATUS (* EFI_API EnableCursor)();
} EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL;

typedef struct {
  UINT32          RedMask;
  UINT32          GreenMask;
  UINT32          BlueMask;
  UINT32          ReservedMask;
} EFI_PIXEL_BITMASK;

/* graphics output protocol mode information */
typedef struct {
  UINT32                     Version;
  UINT32                     HorizontalResolution;
  UINT32                     VerticalResolution;
  EFI_GRAPHICS_PIXEL_FORMAT  PixelFormat;
  EFI_PIXEL_BITMASK          PixelInformation;
  UINT32                     PixelsPerScanLine;
} EFI_GRAPHICS_OUTPUT_MODE_INFORMATION;

/* graphics output protocol mode */
typedef struct {
  UINT32                                   MaxMode;
  UINT32                                   Mode;
  EFI_GRAPHICS_OUTPUT_MODE_INFORMATION    *Info;
  UINTN                                    SizeOfInfo;
  EFI_PHYSICAL_ADDRESS                     FrameBufferBase;
  UINTN                                    FrameBufferSize;
} EFI_GRAPHICS_OUTPUT_PROTOCOL_MODE;

/* graphics output protocol */
typedef struct {
  EFI_STATUS (* EFI_API QueryMode)(VOID*, UINT32, UINTN*, VOID*);
  EFI_STATUS (* EFI_API SetMode)(VOID*, UINT32);
  EFI_STATUS (* EFI_API Blt)();
  EFI_GRAPHICS_OUTPUT_PROTOCOL_MODE *Mode;
} EFI_GRAPHICS_OUTPUT_PROTOCOL;

typedef struct {
  EFI_MEMORY_TYPE       Type;
  EFI_PHYSICAL_ADDRESS  PhysicalStart;
  EFI_VIRTUAL_ADDRESS   VirtualStart;
  UINT64                NumberOfPages;
  UINT64                Attribute;
} EFI_MEMORY_DESCRIPTOR;

/* BootServices */
typedef struct {
  EFI_TABLE_HEADER Hdr;
  EFI_STATUS (* EFI_API RaiseTPL)();
  EFI_STATUS (* EFI_API RestoreTPL)();
  EFI_STATUS (* EFI_API AllocatePages)();
  EFI_STATUS (* EFI_API FreePages)();
  EFI_STATUS (* EFI_API GetMemoryMap)(UINTN*, VOID*, UINTN*, UINTN*, UINT32*);
  EFI_STATUS (* EFI_API AllocatePool)(EFI_MEMORY_TYPE, UINTN, VOID*);
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
  EFI_STATUS (* EFI_API LocateProtocol)(EFI_GUID*, VOID*, VOID*);
  EFI_STATUS (* EFI_API InstallMultiProtocol)();
  EFI_STATUS (* EFI_API UninstallMultiProtocol)();
  EFI_STATUS (* EFI_API CalculateCrc32)();
  EFI_STATUS (* EFI_API CopyMem)();
  EFI_STATUS (* EFI_API SetMem)();
  EFI_STATUS (* EFI_API CreateEventEx)();
} EFI_BOOT_SERVICES;

/* EFI system table */
typedef struct {
  EFI_TABLE_HEADER                   Hdr;
  CHAR16 *                           FirmwareVendor;
  UINT32                             FirmwareRevision;
  EFI_HANDLE                         ConsoleInHandle;
  VOID                              *ConIn;
  EFI_HANDLE                         ConsoleOutHandle;
  EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL   *ConOut;
  EFI_HANDLE                         StandardErrorHandle;
  VOID                              *StdErr;
  VOID                              *RuntimeServices;
  EFI_BOOT_SERVICES                 *BootServices;
  UINT64                             NumberOfTableEntries;
  VOID                              *ConfigurationTable;
} EFI_SYSTEM_TABLE;

/* bootloader global variables */
extern KernelInitInfoT KernelInitInfo;

/* bootloader functions */
EFI_API VOID BootStart(EFI_HANDLE ImageHandle, EFI_SYSTEM_TABLE *SystemTable);
EFI_API VOID BootVga  (EFI_HANDLE ImageHandle, EFI_SYSTEM_TABLE *SystemTable);
EFI_API VOID BootRam  (EFI_HANDLE ImageHandle, EFI_SYSTEM_TABLE *SystemTable);
EFI_API VOID BootExit (EFI_HANDLE ImageHandle, EFI_SYSTEM_TABLE *SystemTable);
EFI_API VOID BootKern (EFI_HANDLE ImageHandle, EFI_SYSTEM_TABLE *SystemTable);

#endif /* BOOT_H */
