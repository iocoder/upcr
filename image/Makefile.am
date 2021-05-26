TARGET=${PACKAGE}-${PACKAGE_VERSION}

MODULES=${top_builddir}/boot/boot.o \
        ${top_builddir}/kernel/kernel.o \
        ${top_builddir}/image/metadata.o

CCASFLAGS=-I${top_srcdir}
LDFLAGS=--oformat=binary -e 0 -T ${srcdir}/layout.ld

all: ${TARGET}.efi

clean:
	rm -rf ${TARGET}.efi

${TARGET}.efi: ${MODULES}
	${LD} ${LDFLAGS} -o $@ ${MODULES}

%.o:%.S
	${CC} -c ${CCASFLAGS} -o $@ $<
