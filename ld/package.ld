
SECTIONS {

	.text   : {
    *(.header)
    *(.text)
    *(.rodata)
    *(.data)
    *(.bss)
    *(.footer)
  }

}
