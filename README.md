# Warnings for GCC

Clang has a handy option called `-Weverything`, which
 enables every warning built into the compiler.
GCC has `-Wall` and `-Wextra`, but
 they only offer a few (despite their names).
This project provides `-Weverything` for GCC.

## Files

The file `extract.scm` contains sloppy code for
 extracting all of the `-W` options from
 the source code of any version of GCC.
That includes undocumented options, which
 are actually quite common.
Those willing to try it need CHICKEN and some eggs,
 a Scheme implementation and a bunch of libraries, to
 run it.
It is safe to use in the sense that
 it does not do any destructive operations like
 writing files.

The file `checkout.sh` contains equally sloppy code for
 checking out various GCC versions from a local Git repository, which
 has to be downloaded separately.
It exists to automate using `extract.scm` and
 contains all of the potentially harmful operations, so
 one should proceed with caution.

The rest of the files contain the warning options for
 each of the tagged versions of GCC.
For example `gcc-4_8_0-release` contains
 124 warnings of which 23 are undocumented.

## Usage

It is easy to integrate `-Weverything` with `make` by fixing the version

    CFLAGS=`cat gcc-4_8_0-release`

or detecting automatically.

    CFLAGS=gcc-`gcc --version | grep -o "[0-9]\+\(\.[0-9]\)*" | head -n 1 | sed y/./_/`-release
