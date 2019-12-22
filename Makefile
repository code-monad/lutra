prefix ?= /usr
destdir ?= ${prefix}
arch ?=
static ?= false
linker ?=
PONYC ?= ponyc

BUILD_DIR ?= bin
SRC_DIR ?= lutra
binary := $(BUILD_DIR)/lutra

ifneq ($(arch),)
  arch_arg := --cpu $(arch)
endif

ifdef static
  ifeq (,$(filter $(static),true false))
	$(error "static must be true or false)"
  endif
endif

ifeq ($(static),true)
  LINKER += --static 
endif

$(binary):
	${PONYC} $(SRC_DIR) -o ${BUILD_DIR}

$(BUILD_DIR):
	-mkdir -p $(BUILD_DIR)

install: $(binary)
	@echo "install $(binary) to "
	@mkdir -p $(DESTDIR)$(prefix)/bin
	@cp $^ $(DESTDIR)$(prefix)/bin

clean:
	rm -rf $(BUILD_DIR)

all: $(binary) install


.PHONY: all
