
  /* System table offsets */
  .equ   Hdr,                0x00
  .equ   FirmwareVendor,     0x18
  .equ   FirmwareRevision,   0x20
  .equ   ConsoleInHandle,    0x28
  .equ   ConIn,              0x30
  .equ   ConsoleOutHandle,   0x38
  .equ   ConOut,             0x40

  /* Text output protocol */
  .equ   Reset,              0x00
  .equ   OutputString,       0x08
  .equ   TestString,         0x10
  .equ   QueryMode,          0x18
  .equ   SetMode,            0x20
  .equ   SetAttribute,       0x28
  .equ   ClearScreen,        0x30
  .equ   SetCursorPosition,  0x38
  .equ   EnableCursor,       0x40

