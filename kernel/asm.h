#ifndef ASM_H
#define ASM_H

/* assist with position-independent code */
#define PTR(SomeVariable)   SomeVariable@GOTPCREL(%rip)

#endif
