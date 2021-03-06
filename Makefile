SHELL = /bin/sh
.PHONY: clean, mkdir, install, uninstall, html, pdf

ifndef release.version
    release.version = 0.0.1
endif

# TODO list
# * Static libraries instead of shared?
# * This file is getting big, maybe it's
#   a good idea to split. Create a Makefile
#   for each library.

SYSTEM := $(shell uname -s)
MACHINE := $(shell uname -m)

# determine current platform
BUILD_TYPE ?= debug
ifeq ($(OS),Windows_NT)
    ifeq ($(findstring CYGWIN_NT,${SYSTEM}),CYGWIN_NT)
	OSTYPE ?= CYGWIN_NT
	MACHINETYPE ?= $(MACHINE)
	build.level = $(shell date)
    else
	OSTYPE ?= $(OS)
	MACHINETYPE ?= $(PROCESSOR_ARCHITECTURE)
    endif
else
    OSTYPE ?= $(SYSTEM)
    MACHINETYPE ?= $(MACHINE)
    build.level = $(shell date)
endif # OS
ifeq ($(OSTYPE),linux)
    OSTYPE = Linux
endif

# assume this is normally run in the main Paho directory
ifndef srcdir
    srcdir = src
endif

ifndef incdir
    incdir = include
endif

ifndef blddir
    blddir = build/output
endif

ifndef prefix
    prefix = /usr/local
endif

ifndef exec_prefix
    exec_prefix = ${prefix}
endif

bindir = $(exec_prefix)/bin
includedir = $(prefix)/include
libdir = $(exec_prefix)/lib

SOURCE_FILES_STR = $(wildcard $(srcdir)/lib/str/*.c)
SOURCE_FILES_BYTE = $(wildcard $(srcdir)/lib/byte/*.c)
SOURCE_FILES_UINT = $(wildcard $(srcdir)/lib/uint/*.c)
SOURCE_FILES_FMT = $(wildcard $(srcdir)/lib/fmt/*.c)
SOURCE_FILES_STRALLOC = $(wildcard $(srcdir)/lib/stralloc/*.c)
SOURCE_FILES_TAI = $(wildcard $(srcdir)/lib/tai/*.c)
SOURCE_FILES_TAIA = $(wildcard $(srcdir)/lib/taia/*.c)

HEADERS_STR = $(incdir)/str/*.h
HEADERS_BYTE = $(incdir)/byte/*.h
HEADERS_UINT = $(incdir)/uint/*.h
HEADERS_FMT = $(incdir)/fmt/*.h
HEADERS_STRALLOC = $(incdir)/stralloc/*.h
HEADERS_TAI = $(incdir)/tai/*.h
HEADERS_TAIA = $(incdir)/taia/*.h

# The names of the libraries to be built
LIB_STR = str
LIB_BYTE = byte
LIB_UINT = uint
LIB_FMT = fmt
LIB_STRALLOC = stralloc
LIB_TAI = tai
LIB_TAIA = taia

CC ?= gcc

ifndef INSTALL
INSTALL = install
endif
INSTALL_PROGRAM = $(INSTALL)
ifeq ($(OSTYPE),CYGWIN_NT)
# The library needs executable permissions in Cygwin
INSTALL_DATA =  $(INSTALL)
else
INSTALL_DATA =  $(INSTALL) -m 0644
endif
DOXYGEN_COMMAND = doxygen

MAJOR_VERSION = 0
MINOR_VERSION = 0
VERSION = ${MAJOR_VERSION}.${MINOR_VERSION}

ifeq ($(OSTYPE),CYGWIN_NT)
# The library in Cygwin has a specific format,
# check the link https://cygwin.com/cygwin-ug-net/dll.html
LIBNAME_PREFIX = cyg
LIBNAME_EXT = dll
else ifeq ($(OSTYPE),Darwin)
LIBNAME_PREFIX = lib
LIBNAME_EXT = dylib
else
LIBNAME_PREFIX = lib
LIBNAME_EXT = so
endif

LIB_STR_LIBNAME = ${LIBNAME_PREFIX}${LIB_STR}.${LIBNAME_EXT}
LIB_BYTE_LIBNAME = ${LIBNAME_PREFIX}${LIB_BYTE}.${LIBNAME_EXT}
LIB_UINT_LIBNAME = ${LIBNAME_PREFIX}${LIB_UINT}.${LIBNAME_EXT}
LIB_FMT_LIBNAME = ${LIBNAME_PREFIX}${LIB_FMT}.${LIBNAME_EXT}
LIB_STRALLOC_LIBNAME = ${LIBNAME_PREFIX}${LIB_STRALLOC}.${LIBNAME_EXT}
LIB_TAI_LIBNAME = ${LIBNAME_PREFIX}${LIB_TAI}.${LIBNAME_EXT}
LIB_TAIA_LIBNAME = ${LIBNAME_PREFIX}${LIB_TAIA}.${LIBNAME_EXT}

LIB_STR_TARGET = ${blddir}/${LIB_STR_LIBNAME}.${VERSION}
LIB_BYTE_TARGET = ${blddir}/${LIB_BYTE_LIBNAME}.${VERSION}
LIB_UINT_TARGET = ${blddir}/${LIB_UINT_LIBNAME}.${VERSION}
LIB_FMT_TARGET = ${blddir}/${LIB_FMT_LIBNAME}.${VERSION}
LIB_STRALLOC_TARGET = ${blddir}/${LIB_STRALLOC_LIBNAME}.${VERSION}
LIB_TAI_TARGET = ${blddir}/${LIB_TAI_LIBNAME}.${VERSION}
LIB_TAIA_TARGET = ${blddir}/${LIB_TAIA_LIBNAME}.${VERSION}

#FLAGS_EXE = $(LDFLAGS) -I ${incdir} -lpthread -L ${blddir}
#FLAGS_EXES = $(LDFLAGS) -I ${incdir} ${START_GROUP} -lpthread -lssl -lcrypto ${END_GROUP} -L ${blddir}

ifeq ($(OSTYPE),CYGWIN_NT)
LDFLAGS_CYGWIN = -Wl,--export-all-symbols -Wl,--enable-auto-import

CCFLAGS_SO_STR = -g $(CFLAGS) -I $(incdir)/str/ -Os -Wall -fvisibility=hidden
CCFLAGS_SO_BYTE = -g $(CFLAGS) -I $(incdir)/byte/ -Os -Wall -fvisibility=hidden
CCFLAGS_SO_UINT = -g $(CFLAGS) -I $(incdir)/uint/ -Os -Wall -fvisibility=hidden
CCFLAGS_SO_FMT = -g $(CFLAGS) -I $(incdir)/byte/ -I $(incdir)/fmt/ -Os -Wall -fvisibility=hidden
CCFLAGS_SO_STRALLOC = -g $(CFLAGS) -I $(incdir)/byte/ -I $(incdir)/str/ -I $(incdir)/fmt/ -I $(incdir)/stralloc/ -Os -Wall -fvisibility=hidden
CCFLAGS_SO_TAI = -g $(CFLAGS) -I $(incdir)/uint/ -I $(incdir)/tai/ -Os -Wall -fvisibility=hidden
CCFLAGS_SO_TAIA = -g $(CFLAGS) -I $(incdir)/uint/ -I $(incdir)/tai/ -I $(incdir)/taia/ -Os -Wall -fvisibility=hidden
LDFLAGS_STR = $(LDFLAGS) -shared -Wl,--no-whole-archive -lpthread $(LDFLAGS_CYGWIN)
LDFLAGS_BYTE = $(LDFLAGS) -shared -Wl,--no-whole-archive -lpthread $(LDFLAGS_CYGWIN)
LDFLAGS_UINT = $(LDFLAGS) -shared -Wl,--no-whole-archive -lpthread $(LDFLAGS_CYGWIN)
LDFLAGS_FMT = $(LDFLAGS) -shared -Wl,--no-whole-archive -L ${blddir} -lbyte -lpthread $(LDFLAGS_CYGWIN)
LDFLAGS_STRALLOC = $(LDFLAGS) -shared -Wl,--no-whole-archive -L ${blddir} -lbyte -lstr -lfmt -lpthread $(LDFLAGS_CYGWIN)
LDFLAGS_TAI = $(LDFLAGS) -shared -Wl,--no-whole-archive -L ${blddir} -lpthread $(LDFLAGS_CYGWIN)
LDFLAGS_TAIA = $(LDFLAGS) -shared -Wl,--no-whole-archive -L ${blddir} -ltai -lpthread $(LDFLAGS_CYGWIN)
else
CCFLAGS_SO_STR = -g -fPIC $(CFLAGS) -I $(incdir)/str/ -Os -Wall -fvisibility=hidden
CCFLAGS_SO_BYTE = -g -fPIC $(CFLAGS) -I $(incdir)/byte/ -Os -Wall -fvisibility=hidden
CCFLAGS_SO_UINT = -g -fPIC $(CFLAGS) -I $(incdir)/uint/ -Os -Wall -fvisibility=hidden
CCFLAGS_SO_FMT = -g -fPIC $(CFLAGS) -I $(incdir)/byte/ -I $(incdir)/fmt/ -Os -Wall -fvisibility=hidden
CCFLAGS_SO_STRALLOC = -g -fPIC $(CFLAGS) -I $(incdir)/byte/ -I $(incdir)/str/ -I $(incdir)/fmt/ -I $(incdir)/stralloc/ -Os -Wall -fvisibility=hidden
CCFLAGS_SO_TAI = -g -fPIC $(CFLAGS) -I $(incdir)/uint/ -I $(incdir)/tai/ -Os -Wall -fvisibility=hidden
CCFLAGS_SO_TAIA = -g -fPIC $(CFLAGS) -I $(incdir)/uint/ -I $(incdir)/tai/ -I $(incdir)/taia/ -Os -Wall -fvisibility=hidden
LDFLAGS_STR = $(LDFLAGS) -shared -lpthread
LDFLAGS_BYTE = $(LDFLAGS) -shared -lpthread
LDFLAGS_UINT = $(LDFLAGS) -shared -lpthread
LDFLAGS_FMT = $(LDFLAGS) -shared -lpthread
LDFLAGS_STRALLOC = $(LDFLAGS) -shared -lpthread
LDFLAGS_TAI = $(LDFLAGS) -shared -lpthread
LDFLAGS_TAIA = $(LDFLAGS) -shared -lpthread
endif

ifeq ($(OSTYPE),Linux)

EXTRA_LIB = -ldl

LDFLAGS_STR += -Wl,-soname,${LIB_STR_LIBNAME}.${MAJOR_VERSION}
LDFLAGS_BYTE += -Wl,-soname,${LIB_BYTE_LIBNAME}.${MAJOR_VERSION}
LDFLAGS_UINT += -Wl,-soname,${LIB_UINT_LIBNAME}.${MAJOR_VERSION}
LDFLAGS_FMT += -Wl,-soname,${LIB_FMT_LIBNAME}.${MAJOR_VERSION}
LDFLAGS_STRALLOC += -Wl,-soname,${LIB_STRALLOC_LIBNAME}.${MAJOR_VERSION}
LDFLAGS_TAI += -Wl,-soname,${LIB_TAI_LIBNAME}.${MAJOR_VERSION}
LDFLAGS_TAIA += -Wl,-soname,${LIB_TAIA_LIBNAME}.${MAJOR_VERSION}

else ifeq ($(OSTYPE),Darwin)

EXTRA_LIB = -ldl

CCFLAGS_SO_STR += -dynamiclib -Wno-deprecated-declarations -undefined dynamic_lookup -DUSE_NAMED_SEMAPHORES
CCFLAGS_SO_BYTE += -dynamiclib -Wno-deprecated-declarations -undefined dynamic_lookup -DUSE_NAMED_SEMAPHORES
CCFLAGS_SO_UINT += -dynamiclib -Wno-deprecated-declarations -undefined dynamic_lookup -DUSE_NAMED_SEMAPHORES
CCFLAGS_SO_FMT += -dynamiclib -Wno-deprecated-declarations -undefined dynamic_lookup -DUSE_NAMED_SEMAPHORES
CCFLAGS_SO_STRALLOC += -dynamiclib -Wno-deprecated-declarations -undefined dynamic_lookup -DUSE_NAMED_SEMAPHORES
CCFLAGS_SO_TAI += -dynamiclib -Wno-deprecated-declarations -undefined dynamic_lookup -DUSE_NAMED_SEMAPHORES
CCFLAGS_SO_TAIA += -dynamiclib -Wno-deprecated-declarations -undefined dynamic_lookup -DUSE_NAMED_SEMAPHORES
LDFLAGS_STR += -Wl,-install_name,${LIB_STR_LIBNAME}.${MAJOR_VERSION}
LDFLAGS_BYTE += -Wl,-install_name,${LIB_BYTE_LIBNAME}.${MAJOR_VERSION}
LDFLAGS_UINT += -Wl,-install_name,${LIB_UINT_LIBNAME}.${MAJOR_VERSION}
LDFLAGS_FMT += -Wl,-install_name,${LIB_FMT_LIBNAME}.${MAJOR_VERSION}
LDFLAGS_STRALLOC += -Wl,-install_name,${LIB_STRALLOC_LIBNAME}.${MAJOR_VERSION}
LDFLAGS_TAI += -Wl,-install_name,${LIB_TAI_LIBNAME}.${MAJOR_VERSION}
LDFLAGS_TAIA += -Wl,-install_name,${LIB_TAIA_LIBNAME}.${MAJOR_VERSION}

else ifeq ($(OSTYPE),CYGWIN_NT)

LDFLAGS_STR += -Wl,--out-implib=${blddir}/lib$(LIB_STR).${LIBNAME_EXT}.a
LDFLAGS_BYTE += -Wl,--out-implib=${blddir}/lib$(LIB_BYTE).${LIBNAME_EXT}.a
LDFLAGS_UINT += -Wl,--out-implib=${blddir}/lib$(LIB_UINT).${LIBNAME_EXT}.a
LDFLAGS_FMT += -Wl,--out-implib=${blddir}/lib$(LIB_FMT).${LIBNAME_EXT}.a
LDFLAGS_STRALLOC += -Wl,--out-implib=${blddir}/lib$(LIB_STRALLOC).${LIBNAME_EXT}.a
LDFLAGS_TAI += -Wl,--out-implib=${blddir}/lib$(LIB_TAI).${LIBNAME_EXT}.a
LDFLAGS_TAIA += -Wl,--out-implib=${blddir}/lib$(LIB_TAIA).${LIBNAME_EXT}.a

endif

all: build

build: | mkdir ${LIB_STR_TARGET} ${LIB_BYTE_TARGET} ${LIB_UINT_TARGET} ${LIB_FMT_TARGET} ${LIB_STRALLOC_TARGET} ${LIB_TAI_TARGET} ${LIB_TAIA_TARGET}

${LIB_STR}: | mkdir ${LIB_STR_TARGET}

${LIB_BYTE}: | mkdir ${LIB_BYTE_TARGET}

${LIB_UINT}: | mkdir ${LIB_UINT_TARGET}

${LIB_FMT}: | mkdir ${LIB_BYTE_TARGET} ${LIB_FMT_TARGET}

${LIB_STRALLOC}: | mkdir ${LIB_BYTE_TARGET} ${LIB_STR_TARGET} ${LIB_FMT_TARGET} ${LIB_STRALLOC_TARGET}

${LIB_TAI}: | mkdir ${LIB_TAI_TARGET}

${LIB_TAIA}: | mkdir ${LIB_TAI_TARGET} ${LIB_TAIA_TARGET}

clean:
	rm -rf ${blddir}/*

mkdir:
	-mkdir -p ${blddir}/samples
	-mkdir -p ${blddir}/test
	echo OSTYPE is $(OSTYPE)

${LIB_STR_TARGET}: ${SOURCE_FILES_STR} ${HEADERS_STR}
	${CC} ${CCFLAGS_SO_STR} -o $@ ${SOURCE_FILES_STR} ${LDFLAGS_STR}
	-ln -s ${LIB_STR_LIBNAME}.${VERSION}  ${blddir}/${LIB_STR_LIBNAME}.${MAJOR_VERSION}
	-ln -s ${LIB_STR_LIBNAME}.${MAJOR_VERSION} ${blddir}/${LIB_STR_LIBNAME}

${LIB_BYTE_TARGET}: ${SOURCE_FILES_BYTE} ${HEADERS_BYTE}
	${CC} ${CCFLAGS_SO_BYTE} -o $@ ${SOURCE_FILES_BYTE} ${LDFLAGS_BYTE}
	-ln -s ${LIB_BYTE_LIBNAME}.${VERSION}  ${blddir}/${LIB_BYTE_LIBNAME}.${MAJOR_VERSION}
	-ln -s ${LIB_BYTE_LIBNAME}.${MAJOR_VERSION} ${blddir}/${LIB_BYTE_LIBNAME}

${LIB_UINT_TARGET}: ${SOURCE_FILES_UINT} ${HEADERS_UINT}
	${CC} ${CCFLAGS_SO_UINT} -o $@ ${SOURCE_FILES_UINT} ${LDFLAGS_UINT}
	-ln -s ${LIB_UINT_LIBNAME}.${VERSION}  ${blddir}/${LIB_UINT_LIBNAME}.${MAJOR_VERSION}
	-ln -s ${LIB_UINT_LIBNAME}.${MAJOR_VERSION} ${blddir}/${LIB_UINT_LIBNAME}

${LIB_FMT_TARGET}: ${SOURCE_FILES_FMT} ${HEADERS_FMT}
	${CC} ${CCFLAGS_SO_FMT} -o $@ ${SOURCE_FILES_FMT} ${LDFLAGS_FMT}
	-ln -s ${LIB_FMT_LIBNAME}.${VERSION}  ${blddir}/${LIB_FMT_LIBNAME}.${MAJOR_VERSION}
	-ln -s ${LIB_FMT_LIBNAME}.${MAJOR_VERSION} ${blddir}/${LIB_FMT_LIBNAME}

${LIB_STRALLOC_TARGET}: ${SOURCE_FILES_STRALLOC} ${HEADERS_STRALLOC}
	${CC} ${CCFLAGS_SO_STRALLOC} -o $@ ${SOURCE_FILES_STRALLOC} ${LDFLAGS_STRALLOC}
	-ln -s ${LIB_STRALLOC_LIBNAME}.${VERSION}  ${blddir}/${LIB_STRALLOC_LIBNAME}.${MAJOR_VERSION}
	-ln -s ${LIB_STRALLOC_LIBNAME}.${MAJOR_VERSION} ${blddir}/${LIB_STRALLOC_LIBNAME}

${LIB_TAI_TARGET}: ${SOURCE_FILES_TAI} ${HEADERS_TAI}
	${CC} ${CCFLAGS_SO_TAI} -o $@ ${SOURCE_FILES_TAI} ${LDFLAGS_TAI}
	-ln -s ${LIB_TAI_LIBNAME}.${VERSION}  ${blddir}/${LIB_TAI_LIBNAME}.${MAJOR_VERSION}
	-ln -s ${LIB_TAI_LIBNAME}.${MAJOR_VERSION} ${blddir}/${LIB_TAI_LIBNAME}

${LIB_TAIA_TARGET}: ${SOURCE_FILES_TAIA} ${HEADERS_TAIA}
	${CC} ${CCFLAGS_SO_TAIA} -o $@ ${SOURCE_FILES_TAIA} ${LDFLAGS_TAIA}
	-ln -s ${LIB_TAIA_LIBNAME}.${VERSION}  ${blddir}/${LIB_TAIA_LIBNAME}.${MAJOR_VERSION}
	-ln -s ${LIB_TAIA_LIBNAME}.${MAJOR_VERSION} ${blddir}/${LIB_TAIA_LIBNAME}

strip_options:
	$(eval INSTALL_OPTS := -s)

install-strip: build strip_options install

install: build
	$(INSTALL_PROGRAM) -d $(DESTDIR)${libdir}
	$(INSTALL_PROGRAM) -d $(DESTDIR)${includedir}
	$(INSTALL_DATA) ${INSTALL_OPTS} ${LIB_STR_TARGET} $(DESTDIR)${libdir}
	$(INSTALL_DATA) ${INSTALL_OPTS} ${LIB_BYTE_TARGET} $(DESTDIR)${libdir}
	$(INSTALL_DATA) ${INSTALL_OPTS} ${LIB_UINT_TARGET} $(DESTDIR)${libdir}
	$(INSTALL_DATA) ${INSTALL_OPTS} ${LIB_FMT_TARGET} $(DESTDIR)${libdir}
	$(INSTALL_DATA) ${INSTALL_OPTS} ${LIB_STRALLOC_TARGET} $(DESTDIR)${libdir}
	$(INSTALL_DATA) ${INSTALL_OPTS} ${LIB_TAI_TARGET} $(DESTDIR)${libdir}
	$(INSTALL_DATA) ${INSTALL_OPTS} ${LIB_TAIA_TARGET} $(DESTDIR)${libdir}
ifeq ($(OSTYPE),CYGWIN_NT)
	ln -fs ${LIB_STR_LIBNAME}.${VERSION}  $(DESTDIR)${libdir}/${LIB_STR_LIBNAME}.${MAJOR_VERSION}
	ln -fs ${LIB_BYTE_LIBNAME}.${VERSION}  $(DESTDIR)${libdir}/${LIB_BYTE_LIBNAME}.${MAJOR_VERSION}
	ln -fs ${LIB_UINT_LIBNAME}.${VERSION}  $(DESTDIR)${libdir}/${LIB_UINT_LIBNAME}.${MAJOR_VERSION}
	ln -fs ${LIB_FMT_LIBNAME}.${VERSION}  $(DESTDIR)${libdir}/${LIB_FMT_LIBNAME}.${MAJOR_VERSION}
	ln -fs ${LIB_STRALLOC_LIBNAME}.${VERSION}  $(DESTDIR)${libdir}/${LIB_STRALLOC_LIBNAME}.${MAJOR_VERSION}
	ln -fs ${LIB_TAI_LIBNAME}.${VERSION}  $(DESTDIR)${libdir}/${LIB_TAI_LIBNAME}.${MAJOR_VERSION}
	ln -fs ${LIB_TAIA_LIBNAME}.${VERSION}  $(DESTDIR)${libdir}/${LIB_TAIA_LIBNAME}.${MAJOR_VERSION}
	$(INSTALL_DATA) ${blddir}/lib*.dll.a $(DESTDIR)${libdir}
else
	/sbin/ldconfig $(DESTDIR)${libdir}
endif
	ln -fs ${LIB_STR_LIBNAME}.${MAJOR_VERSION} $(DESTDIR)${libdir}/${LIB_STR_LIBNAME}
	ln -fs ${LIB_BYTE_LIBNAME}.${MAJOR_VERSION} $(DESTDIR)${libdir}/${LIB_BYTE_LIBNAME}
	ln -fs ${LIB_UINT_LIBNAME}.${MAJOR_VERSION} $(DESTDIR)${libdir}/${LIB_UINT_LIBNAME}
	ln -fs ${LIB_FMT_LIBNAME}.${MAJOR_VERSION} $(DESTDIR)${libdir}/${LIB_FMT_LIBNAME}
	ln -fs ${LIB_STRALLOC_LIBNAME}.${MAJOR_VERSION} $(DESTDIR)${libdir}/${LIB_STRALLOC_LIBNAME}
	ln -fs ${LIB_TAI_LIBNAME}.${MAJOR_VERSION} $(DESTDIR)${libdir}/${LIB_TAI_LIBNAME}
	ln -fs ${LIB_TAIA_LIBNAME}.${MAJOR_VERSION} $(DESTDIR)${libdir}/${LIB_TAIA_LIBNAME}
	$(INSTALL_DATA) ${HEADERS_STR} $(DESTDIR)${includedir}
	$(INSTALL_DATA) ${HEADERS_BYTE} $(DESTDIR)${includedir}
	$(INSTALL_DATA) ${HEADERS_UINT} $(DESTDIR)${includedir}
	$(INSTALL_DATA) ${HEADERS_FMT} $(DESTDIR)${includedir}
	$(INSTALL_DATA) ${HEADERS_STRALLOC} $(DESTDIR)${includedir}
	$(INSTALL_DATA) ${HEADERS_TAI} $(DESTDIR)${includedir}
	$(INSTALL_DATA) ${HEADERS_TAIA} $(DESTDIR)${includedir}

uninstall:
	rm -f $(DESTDIR)${libdir}/${LIB_STR_LIBNAME}.*
	rm -f $(DESTDIR)${libdir}/${LIB_BYTE_LIBNAME}.*
	rm -f $(DESTDIR)${libdir}/${LIB_UINT_LIBNAME}.*
	rm -f $(DESTDIR)${libdir}/${LIB_FMT_LIBNAME}.*
	rm -f $(DESTDIR)${libdir}/${LIB_STRALLOC_LIBNAME}.*
	rm -f $(DESTDIR)${libdir}/${LIB_TAI_LIBNAME}.*
	rm -f $(DESTDIR)${libdir}/${LIB_TAIA_LIBNAME}.*
ifeq ($(OSTYPE),CYGWIN_NT)
	rm -f $(DESTDIR)${libdir}/*${LIB_STR}*.dll.a
	rm -f $(DESTDIR)${libdir}/*${LIB_BYTE}*.dll.a
	rm -f $(DESTDIR)${libdir}/*${LIB_UINT}*.dll.a
	rm -f $(DESTDIR)${libdir}/*${LIB_FMT}*.dll.a
	rm -f $(DESTDIR)${libdir}/*${LIB_STRALLOC}*.dll.a
	rm -f $(DESTDIR)${libdir}/*${LIB_TAI}*.dll.a
	rm -f $(DESTDIR)${libdir}/*${LIB_TAIA}*.dll.a
else
	/sbin/ldconfig $(DESTDIR)${libdir}
endif
	rm -f $(DESTDIR)${libdir}/${LIB_STR_LIBNAME}
	rm -f $(DESTDIR)${libdir}/${LIB_BYTE_LIBNAME}
	rm -f $(DESTDIR)${libdir}/${LIB_UINT_LIBNAME}
	rm -f $(DESTDIR)${libdir}/${LIB_FMT_LIBNAME}
	rm -f $(DESTDIR)${libdir}/${LIB_STRALLOC_LIBNAME}
	rm -f $(DESTDIR)${libdir}/${LIB_TAI_LIBNAME}
	rm -f $(DESTDIR)${libdir}/${LIB_TAIA_LIBNAME}
	rm -f $(DESTDIR)${includedir}/${HEADERS_STR}
	rm -f $(DESTDIR)${includedir}/${HEADERS_BYTE}
	rm -f $(DESTDIR)${includedir}/${HEADERS_UINT}
	rm -f $(DESTDIR)${includedir}/${HEADERS_FMT}
	rm -f $(DESTDIR)${includedir}/${HEADERS_STRALLOC}
	rm -f $(DESTDIR)${includedir}/${HEADERS_TAI}
	rm -f $(DESTDIR)${includedir}/${HEADERS_TAIA}

html:
	-mkdir -p ${blddir}/doc
