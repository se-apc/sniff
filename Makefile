# Variables to override
#
# CC            C compiler
# CROSSCOMPILE  crosscompiler prefix, if any
# CFLAGS    compiler flags for compiling all C files
# ERL_CFLAGS    additional compiler flags for files using Erlang header files
# ERL_EI_INCLUDE_DIR include path to ei.h (Required for crosscompile)
# ERL_EI_LIBDIR path to libei.a (Required for crosscompile)
# LDFLAGS   linker flags for linking all binaries
# ERL_LDFLAGS   additional linker flags for projects referencing Erlang libraries

# Check that we're on a supported build platform
ifeq ($(CROSSCOMPILE),)
    # Not crosscompiling, so check that we're on Linux.
    ifneq ($(shell uname -s),Linux)
        $(warning Elixir ALE only works on Linux, but crosscompilation)
        $(warning is supported by defining $$CROSSCOMPILE, $$ERL_EI_INCLUDE_DIR,)
        $(warning and $$ERL_EI_LIBDIR. See Makefile for details. If using Nerves,)
        $(warning this should be done automatically.)
        $(warning .)
        $(warning Skipping C compilation unless targets explicitly passed to make.)
    DEFAULT_TARGETS = priv
    endif
endif
DEFAULT_TARGETS ?= priv/libsniff.so

# Look for the EI library and header files
# For crosscompiled builds, ERL_EI_INCLUDE_DIR and ERL_EI_LIBDIR must be
# passed into the Makefile.
ifeq ($(ERL_EI_INCLUDE_DIR),)
ERL_ROOT_DIR = $(shell erl -eval "io:format(\"~s~n\", [code:root_dir()])" -s init stop -noshell)
ifeq ($(ERL_ROOT_DIR),)
   $(error Could not find the Erlang installation. Check to see that 'erl' is in your PATH)
endif
ERL_EI_INCLUDE_DIR = "$(ERL_ROOT_DIR)/usr/include"
ERL_EI_LIBDIR = "$(ERL_ROOT_DIR)/usr/lib"
endif

# Set Erlang-specific compile and linker flags
ERL_CFLAGS ?= -I$(ERL_EI_INCLUDE_DIR)
ERL_LDFLAGS ?= -L$(ERL_EI_LIBDIR) -lei

include env.tmp
CFLAGS ?= -fPIC -std=c99 -D_GNU_SOURCE -pedantic-errors -Wall -Wextra -I$(ERTS_HOME)/include
LDFLAGS ?= -shared -dynamiclib -undefined,dynamic_lookup
CC = $(CROSSCOMPILE)-gcc
UNAME := $(shell uname)
SRCDIR   = src
OBJDIR   = obj
PRVDIR	 = priv

SOURCES = $(SRCDIR)/sniff_posix.c $(SRCDIR)/sniff.c

OBJECTS := $(SOURCES:$(SRCDIR)/%.c=$(OBJDIR)/%.o)

.PHONY: all clean

all: $(DEFAULT_TARGETS)

$(OBJECTS): $(OBJDIR)/%.o : $(SRCDIR)/%.c
	mkdir -p $(OBJDIR)
	@echo CFLAGS=$(CFLAGS)
	@echo ERL_CC=$(ERL_CFLAGS)
	@echo CC=$(CC) 
	$(CC) -c $(ERL_CFLAGS) $(CFLAGS) -o $@ $<

priv/libsniff.so: $(OBJECTS)
	mkdir -p $(PRVDIR)
	$(CC) $^ $(ERL_LDFLAGS) $(LDFLAGS) -o $@

clean:
	rm -f obj/*
	rm -f priv/*

