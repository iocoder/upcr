
  /* globals */
  .globl  last

  /* place in footer section */
  .section  .footer, "ax"

  /* make sure file end is page aligned */
  .align 0x1000, 0

last:
  /* end of image */
