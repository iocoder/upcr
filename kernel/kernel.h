#ifndef KERNEL_H
#define KERNEL_H

#define NULL                    0
#define KERNEL_PAGE_SIZE        4096

typedef signed char             int8_t;
typedef signed short int        int16_t;
typedef signed int              int32_t;
typedef signed long int         int64_t;
typedef signed long int         intn_t;

typedef unsigned char           uint8_t;
typedef unsigned short int      uint16_t;
typedef unsigned int            uint32_t;
typedef unsigned long int       uint64_t;
typedef unsigned long int       uintn_t;

typedef struct {
  /* the base address of ACPI root table, obtained by UEFI */
  uint64_t  AcpiTableBase;

  /* memory map info as ACPI specs specify, obtained by UEFI */
  uint64_t  MemoryMapBase;
  uint64_t  MemoryMapSize;
  uint64_t  MemoryMapDesc;
  uint64_t  MemoryMapType;

  /* frame buffer to use by kernel, obtained by UEFI */
  uint64_t  FrameBuffBase;
  uint64_t  FrameBuffSize;
  uint64_t  FrameBuffWidt;
  uint64_t  FrameBuffHigt;
  uint64_t  FrameBuffLine;
} KernelInitInfoT;

#define KernelBootInit KSYSINIT

/* boot module */
uint64_t KernelBootInit(KernelInitInfoT *InitInfo);

/* system module */
uint64_t KernelSystemInit(KernelInitInfoT *InitInfo);
uint64_t KernelSystemStart(void);
uint64_t KernelSystemStop(void);

#endif /* KERNEL_TYPES_H */
