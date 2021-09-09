#ifndef COMPAT_H
#define COMPAT_H

#define INCLUDE     .include
#define PUBLIC      .global
#define EQU         .equ
#define SEGMENT     .section
#define ALIGN       .align

#define CODE16      .code16
#define CODE32      .code32
#define CODE64      .code64

#define MACRO       .macro
#define ENDM        .endm
#define IF          .if
#define ENDIF       .endif

#define DB          .ascii
#define DW          .short
#define DD          .long
#define DQ          .quad

#endif /* COMPAT_H */
