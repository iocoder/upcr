#ifndef MACROS_H
#define MACROS_H

/* assist with position-independent code */
#define PTR(SomeVariable)   SomeVariable@GOTPCREL(%rip)

#endif
