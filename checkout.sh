#! /bin/sh

# This is a "write once, run away" kind of a utility for
# checking out tags from a Git repository and
# delegating work to another script.
# This script takes a single command line argument that
# should specify where the source code repository is.

test "$#" -eq 1 || {
	echo "Argument not found."
	exit 1
}

test -d "$1" -a -d "$1/.git" || {
	echo "Repository not found."
	exit 1
}

command -v csi > /dev/null && test -x extract.scm || {
	echo "Runtime not found."
	exit 1
}

mkdir -p tags || {
	echo "Directory not found."
	exit 1
}

for t in `git --git-dir "$1/.git" tag | tac`
do
	git --git-dir "$1/.git" --work-tree "$1" checkout "$t" \
			&& ./extract.scm "$1" > "tags/$t"
done
