# Show commands that make uses
VERBOSE = TRUE

# Directory layout.
PROJDIR := $(realpath $(CURDIR)/)
SOURCEDIR := $(PROJDIR)/src/lib
BINDIR := $(PROJDIR)/src/bin
DOCDIR := $(PROJDIR)/doc

RELEASEDIR := $(PROJDIR)/release
DEBUGDIR := $(PROJDIR)/debug

CFLAGS = -Wall -Werror -std=c11 -I$(SOURCEDIR)
LDLIBS = -lm
ifeq ($(DEBUG),1)
	CFLAGS += -g 
	LDLIBS +=
	BUILDDIR := $(DEBUGDIR)
else
	CFLAGS += -fPIC -O3 -DNDEBUG
	LDLIBS += -fPIC
	BUILDDIR := $(RELEASEDIR)
endif

# Compiler and compiler options
CC = cc

# Add this list to the VPATH, the place make will look for the source files.
VPATH = $(SOURCEDIR):$(BINDIR)

# Create lists of source and header files for common modules.
SOURCES = $(wildcard $(SOURCEDIR)/*.c)
HEADERS = $(wildcard $(SOURCEDIR)/*.h)

# Define object files for all common modules
OBJS:=$(subst $(SOURCEDIR), $(BUILDDIR), $(SOURCES:.c=.o))

# Create a list of programs.
BIN_SOURCES = $(wildcard $(BINDIR)/*.c)
BIN_OBJS = $(subst $(BINDIR), $(BUILDDIR), $(BIN_SOURCES:.c=.o))
BINS = $(subst $(BINDIR), $(BUILDDIR), $(BIN_SOURCES:.c=))

DEPS := $(BIN_OBJS:.o=.d) $(OBJS:.o=.d)

# Print a bunch of info to help debugging make.
ifeq ($(VERBOSE),TRUE)
    $(info ----------------- variables ----------------- )
    $(info                                               )
    $(info $$(CC) $(CC)                                  )
    $(info                                               )
    $(info $$(CFLAGS) $(CFLAGS)                          )
    $(info                                               )
    $(info $$(LDLIBS) $(LDLIBS)                          )
    $(info                                               )
    $(info $$(VPATH)                                     )
    $(foreach DIR, $(subst :, , $(VPATH)), $(info $(DIR)))
    $(info                                               )
    $(info $$(SOURCES)                                   )
    $(foreach SRC, $(SOURCES), $(info $(SRC))            )
    $(info                                               )
    $(info $$(HEADERS)                                   )
    $(foreach SRC, $(HEADERS), $(info $(SRC))            )
    $(info                                               )
    $(info $$(OBJS)                                      )
    $(foreach OBJ, $(OBJS), $(info $(OBJ))               )
    $(info                                               )
    $(info $$(BIN_SOURCES)                               )
    $(foreach SRC, $(BIN_SOURCES), $(info $(SRC))        )
    $(info                                               )
    $(info $$(BIN_OBJS)                                  )
    $(foreach OBJ, $(BIN_OBJS), $(info $(OBJ))           )
    $(info                                               )
    $(info $$(BINS)                                      )
    $(foreach BIN, $(BINS), $(info $(BIN))               )
    $(info                                               )
    $(info $$(DEPS)                                      )
    $(foreach DEP, $(DEPS), $(info $(DEP))               )
    $(info                                               )
    $(info --------------------------------------------- )
endif

# Hide or not the calls depending on VERBOSE
ifeq ($(VERBOSE),TRUE)
	HIDE = 
else
	HIDE = @
endif

.PHONY: all clean directories doc

all: makefile directories $(BINS)

$(BINS): directories makefile  $(BIN_OBJS) $(OBJS)
	@echo
	@echo Linking $@
	$(HIDE)$(CC) $@.o $(OBJS) $(LDLIBS) -o $@

-include $(DEPS)

# Generate rules
$(BUILDDIR)/%.o: %.c makefile
	@echo
	@echo Building $@
	$(HIDE)$(CC) -c $(CFLAGS) -o $@ $< -MMD

directories:
	@echo
	@echo "Creating directory $(BUILDDIR)"
	$(HIDE)mkdir -p $(BUILDDIR) 2>/dev/null

doc: Doxyfile makefile $(SOURCES) $(HEADERS)
	@echo
	@echo Building documentation.
	$(HIDE) doxygen 2>/dev/null

clean:
	-$(HIDE)rm -rf $(DEBUGDIR) $(RELEASEDIR) $(DOCDIR) 2>/dev/null
	@echo
	@echo Cleaning done!

