  /* globals */
  .globl ImageHandle
  .globl SystemTable
  .globl Msg

  /* data section */
  .data

ImageHandle:
  .quad  0

SystemTable:
  .quad  0

Msg:
  .short 'h', 'e', 'l', 'l', 'o', 0x0A, 0x00
