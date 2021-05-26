TARGET=boot.o

CFLAGS=-I${top_srcdir} --save-temps -Werror -fshort-wchar -fpie \
        -ffreestanding -nostdlib -nostdinc -fno-stack-protector -O3
CCASFLAGS=-I${top_srcdir}
LDFLAGS=

SFILES_IN=$(shell ls ${srcdir}/*.S)
SFILES_OUT=$(shell cd ${srcdir}; ls *.S | sed 's/\.S/\.o/g')

CFILES_IN=$(shell ls ${srcdir}/*.c)
CFILES_OUT=$(shell cd ${srcdir}; ls *.c | sed 's/\.c/\.o/g')

all: ${TARGET}

clean:
	rm -rf ${SFILES_OUT} ${CFILES_OUT} ${TARGET}

${TARGET}: ${SFILES_OUT} ${CFILES_OUT}
	${LD} -r ${LDFLAGS} -o $@ $^

%.o:%.S
	${CC} -c ${CCASFLAGS} -o $@ $<

%.o:%.c
	${CC} -c ${CFLAGS} -o $@ $<
