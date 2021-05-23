
SECTIONS {

    .header : {*(.header         )}
	.text   : {*(.text .rodata   )}
	.data   : {*(.data           )}
	.bss    : {*(.bss            )}

}
