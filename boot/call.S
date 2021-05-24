
/* C includes */
#include "boot/macros.h"

/* assembler includes */
.include "boot/efi.inc"

/* linker symbols to export */
.globl EfiCall

/* text section */
.text

/* EfiCall function */
EfiCall:

    /* save a copy RSP first */
    mov    %rsp, PTR(RspValue)

    /* make sure stack pointer is aligned */
    and    $0xFFFFFFF0, %esp

    /* push a qword if num of args is odd (for alignment) */
    bt     $0, %rax
    jnc    1f
    push   $0

    /* push %rdi */
1:  cmp    $11, %al
    jb     1f
    push   %rdi

    /* push %rsi */
1:  cmp    $10, %al
    jb     1f
    push   %rsi

    /* push %r14 */
1:  cmp    $9, %al
    jb     1f
    push   %r14

    /* push %r13 */
1:  cmp    $8, %al
    jb     1f
    push   %r13

    /* push %r12 */
1:  cmp    $7, %al
    jb     1f
    push   %r12

    /* push %r11 */
1:  cmp    $6, %al
    jb     1f
    push   %r11

    /* push %r10 */
1:  cmp    $5, %al
    jb     1f
    push   %r10

    /* push first 4 arguments */
1:  push   %r9
    push   %r8
    push   %rdx
    push   %rcx

    /* call the UEFI function */
    call   *%rbx

    /* restore stack pointer */
    mov    PTR(RspValue), %rsp

    /* done */
    ret
