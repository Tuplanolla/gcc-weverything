# Warnings for GCC

Clang has a handy option called `-Weverything`, which
 enables every warning built into the compiler.
GCC does not.
This project provides `-Weverything` for
 compiling C files with GCC.

Both compilers of course have `-Wall` and `-Wextra`, but
 their names are misleading:
 they only offer a few of the most commonly used warnings.

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

The rest of the files inside the `tags` directory contain
 the warning options for
 each of the tagged versions of GCC.
For example `gcc-4_8_0-release` contains
 124 warnings of which 23 are undocumented.

## Installation

The closest thing to an installation is downloading the option listings.

    [user@computer ~]$ wget https://github.com/Tuplanolla/gcc-weverything/blob/master/tags/gcc-4_8_0-release

## Usage

It is easy to integrate `-Weverything` with `make` by fixing the version

    CFLAGS=`cat gcc-4_8_0-release`

or detecting it automatically.

    CFLAGS=gcc-`gcc --version | grep -o "[0-9]\+\(\.[0-9]\)*" | head -n 1 | tr . _`-release

## Bugs and Limitations

Throughout history GCC has used
 three kinds of option specification systems, so
 there can be small variations in the extracted output.
For example `-Wformat` was changed to `-Wformat=` when
 version 3.4.0 was released.
Such options have to be
 tweaked by hand or
 removed.

Since everything really means everything here, `-Werror` and
 warnings like, say, `-Wtraditional` are also included.
Therefore it is almost impossible to
 compile files without disabling some of them with `-Wno-`.

    CFLAGS=`cat gcc-4_8_0-release` -Wno-error
