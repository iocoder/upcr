SECTIONS {

	.image   : {
    FILL(0)

    *(.header)

    . = ALIGN(0x1000);
    *(.text .text.*)

    . = ALIGN(0x1000);
    *(.rodata .rodata.*)

    . = ALIGN(0x1000);
    *(.data .bss)

    . = ALIGN(0x1000);
    *(.footer)
  }

  /DISCARD/ : {*(*)}

}
