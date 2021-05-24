TARGET=kernel

CCASFLAGS=-I${top_srcdir}
LDFLAGS=--oformat=binary -e 0 -pie -T ${top_srcdir}/ld/binary.ld

SFILES_IN=$(shell ls ${srcdir}/*.S)
SFILES_OUT=$(shell cd ${srcdir}; ls *.S | sed 's/\.S/\.o/g')

all: ${TARGET}.o

${TARGET}.o: ${TARGET}.bin
	objcopy -I binary -O elf64-x86-64 $< $@

clean:
	rm -rf ${SFILES_OUT} ${TARGET}

${TARGET}.bin: ${SFILES_OUT}
	${LD} ${LDFLAGS} -o $@ $^

%.o:%.S
	${CC} -c ${CCASFLAGS} -o $@ ${ASFLAGS} $<
