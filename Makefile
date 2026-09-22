TL_SOURCES := $(shell find src -name '*.tl')
# Not converted yet; copied into build/ as-is so build/ is the whole deployable
# tree rather than half of it.
LUA_SOURCES := $(shell find src -name '*.lua')
LUA_COPIES := $(patsubst src/%.lua,build/%.lua,$(LUA_SOURCES))

.PHONY: all check build lint fix clean

all: check build lint

# Type-check without emitting anything.
check:
	cyan check $(TL_SOURCES)

build: $(LUA_COPIES)
	cyan build

build/%.lua: src/%.lua
	@mkdir -p $(dir $@)
	cp $< $@

lint:
	illuaminate lint src

fix:
	illuaminate fix src

clean:
	rm -rf build
