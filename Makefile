TL_SOURCES := $(shell find src -name '*.tl')
LUA_OUTPUT := $(patsubst src/%.tl,build/%.lua,$(TL_SOURCES))

.PHONY: all check build lint fix clean

all: check build lint

# Type-check without emitting anything.
check:
	tl check $(TL_SOURCES)

build: $(LUA_OUTPUT)

# `tl gen` writes next to the current directory rather than honouring
# tlconfig's build_dir, so each file is emitted explicitly.
build/%.lua: src/%.tl
	@mkdir -p $(dir $@)
	tl gen -o $@ $<

lint:
	illuaminate lint src

fix:
	illuaminate fix src

clean:
	rm -rf build
