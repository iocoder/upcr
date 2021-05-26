#ifndef KERNEL_API_H
#define KERNEL_API_H

#include "kernel/types.h"

typedef struct {
  uint64_t  FrameBufferAvailable;
  void     *FrameBufferVirt;
  void     *FrameBufferPhys;
  uint64_t  FrameBufferSize;
  uint64_t  FrameBufferWidth;
  uint64_t  FrameBufferHeight;
  uint64_t  FrameBufferScanLine;
} KernelInitVga;


#endif /* KERNEL_API_H */
