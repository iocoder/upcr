TARGET=kernel

CCASFLAGS=-I${top_srcdir}
LDFLAGS=

SFILES_IN=$(shell ls ${srcdir}/*.S)
SFILES_OUT=$(shell cd ${srcdir}; ls *.S | sed 's/\.S/\.o/g')

all: ${TARGET}.o

clean:
	rm -rf ${SFILES_OUT} ${TARGET}

${TARGET}.o: ${SFILES_OUT}
	${LD} -r ${LDFLAGS} -o $@ $^

%.o:%.S
	${CC} -c ${CCASFLAGS} -o $@ ${ASFLAGS} $<
