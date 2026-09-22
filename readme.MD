### Requirements

I am using [illuaminate](https://github.com/SquidDev/illuaminate) and [teal](https://github.com/teal-language/tl).

Useful commands:

```bash
make check   # tl check on every src/**/*.tl
make build   # tl gen -> build/, mirroring the src/ layout
make lint    # illuaminate lint src
make fix     # illuaminate fix src (rewrites files in place)
make clean   # rm -rf build
make         # check, build and lint
```

The same three steps run in CI on every pull request.

Note that `tl build` does not exist in the released `tl` (0.24.8) — it is
`tl check` and `tl gen`, and `tl gen` ignores `tlconfig.lua`'s `build_dir`,
so the Makefile passes `-o` per file.
