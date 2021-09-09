TARGET=kernel

CCASFLAGS=-I${top_srcdir}
LDFLAGS=

SFILES_IN=$(shell ls ${srcdir}/*.asm)
SFILES_OUT=$(shell cd ${srcdir}; ls *.asm | sed 's/\.asm/\.o/g')

all: ${TARGET}.o

clean:
	rm -rf ${SFILES_OUT} ${TARGET}

${TARGET}.o: ${SFILES_OUT}
	${LD} -r ${LDFLAGS} -o $@ $^

%.S:%.asm
	@cp $< $@

%.o:%.S
	${CC} -c ${CCASFLAGS} -o $@ ${ASFLAGS} $<
