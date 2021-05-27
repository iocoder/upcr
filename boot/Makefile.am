TARGET=boot

CFLAGS=-I${top_srcdir} --save-temps -Werror -nostdlib -nostdinc -O3 \
        -ffreestanding -fpie -fshort-wchar -fno-stack-protector \
        -fno-asynchronous-unwind-tables
LDFLAGS=

CFILES_IN=$(shell ls ${srcdir}/*.c)
CFILES_OUT=$(shell cd ${srcdir}; ls *.c | sed 's/\.c/\.o/g')
IFILES_OUT=$(shell cd ${srcdir}; ls *.c | sed 's/\.i/\.o/g')
SFILES_OUT=$(shell cd ${srcdir}; ls *.c | sed 's/\.s/\.o/g')

all: ${TARGET}.o

clean:
	rm -rf ${CFILES_OUT} ${IFILES_OUT} ${SFILES_OUT} ${TARGET}.o

${TARGET}.o: ${CFILES_OUT}
	${LD} -r ${LDFLAGS} -o $@ $^

%.o:%.c
	${CC} -c ${CFLAGS} -o $@ $<
