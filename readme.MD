### Requirements

I am using [illuaminate](https://github.com/SquidDev/illuaminate),
[teal](https://github.com/teal-language/tl) and teal's build system
[cyan](https://github.com/teal-language/cyan).

Teal never runs in-game: `make build` compiles `src/**/*.tl` down to plain Lua
(`gen_target = "5.1"`) in `build/`, and `build/` is what gets deployed to a
computer. Files in `src/` that are still `.lua` are copied across unchanged, so
`build/` is always the complete tree.

Useful commands:

```bash
make check   # cyan check on every src/**/*.tl
make build   # cyan build -> build/, mirroring the src/ layout
make lint    # illuaminate lint src
make fix     # illuaminate fix src (rewrites files in place)
make clean   # rm -rf build
make         # check, build and lint
```

The same three steps run in CI on every pull request.

Note that `tl build` does not exist in the released `tl` (0.24.8) — building a
whole project is what cyan is for; bare `tl gen` also ignores `tlconfig.lua`'s
`build_dir`.
