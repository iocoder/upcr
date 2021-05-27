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
  uint64_t  VgaAvailable;
  uint64_t  VgaMemVirt;
  uint64_t  VgaMemPhys;
  uint64_t  VgaMemSize;
  uint64_t  VgaScreenWidth;
  uint64_t  VgaScreenHeight;
  uint64_t  VgaScreenLine;
} KernelInitVgaT;

typedef struct {
  uint64_t  RamAvailable;
  uint64_t  RamStart;
  uint64_t  RamEnd;
} KernelInitRamT;

typedef struct {
  uint64_t  ProcAvailable;
} KernelInitProcT;

typedef struct {
  KernelInitVgaT   VgaInfo;
  KernelInitRamT   RamInfo;
  KernelInitProcT  ProcInfo;
} KernelInitInfoT;

/* boot module */
uint64_t KernelBootInit(KernelInitInfoT *InitInfo);

/* system module */
uint64_t KernelSystemInit(KernelInitInfoT *InitInfo);
uint64_t KernelSystemStart(void);
uint64_t KernelSystemStop(void);

#endif /* KERNEL_TYPES_H */
