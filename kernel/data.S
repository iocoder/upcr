
/* assist with position-independent code */
#define PTR(SomeVariable)   SomeVariable@GOTPCREL(%rip)


# symbols to export to linker
.globl KernelDataInit

# text section
.text

##############################################################################
#                           KernelDataInit()                                 #
##############################################################################

KernelDataInit:



    # done
    ret
