TARGET=boot.o

ASFLAGS=
LDFLAGS=-r

SFILES_IN=$(shell ls ${srcdir}/*.s)
SFILES_OUT=$(shell cd ${srcdir}; ls *.s | sed 's/\.s/\.o/g')

all: ${TARGET}

clean:
	rm -rf ${SFILES_OUT} ${TARGET}

${TARGET}: ${SFILES_OUT}
	${LD} -o $@ ${LDFLAGS} $^

%.o:%.s
	${AS} -o $@ ${ASFLAGS} $<

