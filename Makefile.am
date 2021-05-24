SUBDIRS=boot kernel
MODULES=boot/boot.o kernel/kernel.o

TARGET=${PACKAGE}-${PACKAGE_VERSION}.efi
LDFLAGS=--oformat=binary -e 0 -pie -T ${top_srcdir}/ld/package.ld

${TARGET}: ${MODULES}
	${LD} ${LDFLAGS} -o $@ ${MODULES}

all-local: ${TARGET}
