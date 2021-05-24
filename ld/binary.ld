
SECTIONS {

	.text   : {
    *(.init)
    *(.text)
    *(.rodata)
    *(.data)
    *(.bss)
  }

}
