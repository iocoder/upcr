#ifndef KERNEL_H
#define KERNEL_H

#define NULL   0

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
  uint64_t  FrameBufferAvailable;
  void     *FrameBufferVirt;
  void     *FrameBufferPhys;
  uint64_t  FrameBufferSize;
  uint64_t  FrameBufferWidth;
  uint64_t  FrameBufferHeight;
  uint64_t  FrameBufferScanLine;
} KernelInitVga;


#endif /* KERNEL_TYPES_H */
