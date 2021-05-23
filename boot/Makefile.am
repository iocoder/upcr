TARGET=boot.o

ASFLAGS=
LDFLAGS=-r

SFILES_IN=$(shell ls ${srcdir}/*.S)
SFILES_OUT=$(shell cd ${srcdir}; ls *.S | sed 's/\.S/\.o/g')

all: ${TARGET}

clean:
	rm -rf ${SFILES_OUT} ${TARGET}

${TARGET}: ${SFILES_OUT}
	${LD} -o $@ ${LDFLAGS} $^

%.o:%.S
	${CC} -c -o $@ ${ASFLAGS} $<
