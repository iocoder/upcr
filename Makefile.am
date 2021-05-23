SUBDIRS=boot

TARGET=${PACKAGE}-${PACKAGE_VERSION}.efi
LDSCRIPT=${srcdir}/package.ld

MODULES=boot/boot.o

${TARGET}: ${LDSCRIPT} ${MODULES}
	${LD} --oformat=binary -e 0 -T ${LDSCRIPT} -o $@ ${MODULES}

all-local: ${TARGET}

