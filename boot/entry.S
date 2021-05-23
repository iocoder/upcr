
  /* includes */
  .include "efi.inc"

  /* globals */
  .globl Entry

  /* text section */
  .text

Entry:
  /* entry point */
  mov    %rcx, ImageHandle@GOTPCREL(%rip)
  mov    %rdx, SystemTable@GOTPCREL(%rip)

  /* get (SystemTable->ConOut, Msg) */
  mov    SystemTable@GOTPCREL(%rip), %rsi
  mov    ConOut(%rsi), %rcx
  lea    Msg@GOTPCREL(%rip), %rdx

  /* call SystemTable->ConOut->OutputString */
  mov    OutputString(%rcx), %rsi
  call   *%rsi

  /* halt */
  jmp    .
