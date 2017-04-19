# Figure out which compiler to use (prefer gdc, fall back to dmd).
ifeq (,$(DC))
	DC:=$(shell which gdc 2>/dev/null)
ifeq (,$(DC))
	DC:=$(shell which ldc2 2>/dev/null)
ifeq (,$(DC))
	DC:=dmd
endif
endif
endif

ifeq (gdc,$(notdir $(DC)))
	DFLAGS=-O4 -frelease -fno-bounds-check -fbuiltin
	OFSYNTAX=-o
else
ifeq (ldc2,$(notdir $(DC)))
	DFLAGS=-O4 -boundscheck=off -release
	OFSYNTAX=-of=
else
ifeq (dmd,$(notdir $(DC)))
	DFLAGS=-O -inline -release
	OFSYNTAX=-of
else
    $(error Unsupported compiler: $(DC))
endif
endif
endif

CC=cc
CXX=c++
CFLAGS=
CXXFLAGS=
WARPDRIVE=warpdrive.exe
GENERATED_DEFINES=generated_defines.d

# warp sources
SRCS=cmdline.d constexpr.d context.d directive.d expanded.d file.d \
id.d lexer.d loc.d macros.d main.d number.d outdeps.d ranges.d skip.d \
sources.d stringlit.d textbuf.d charclass.d util.d

# Binaries generated
BIN:=warp.exe $(WARPDRIVE)

# Rules

all : $(BIN)

clean :
	rm -rf $(BIN) $(addsuffix .o, $(BIN)) $(GENERATED_DEFINES)

warp.exe : $(SRCS)
	$(DC) $(DFLAGS) $(OFSYNTAX)$@ $(SRCS)

$(WARPDRIVE) : warpdrive.d $(GENERATED_DEFINES)
	$(DC) $(DFLAGS) $(OFSYNTAX)$@ $^

$(GENERATED_DEFINES) :
	./builtin_defines.sh '$(CC) $(CFLAGS)' '$(CXX) $(CXXFLAGS)' >$@.tmp
	mv $@.tmp $@
