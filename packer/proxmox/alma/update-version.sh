#!/bin/bash

source ./VERSION
major=0
minor=0
build=0

# break down the version number into it's components
regex="([0-9]+).([0-9]+).([0-9]+)"
if [[ $VERSION =~ $regex ]]; then
  major="${BASH_REMATCH[1]}"
  minor="${BASH_REMATCH[2]}"
  build="${BASH_REMATCH[3]}"
fi

build=$(echo $build + 1 | bc)

cat <<EOF > ./VERSION
VERSION="${major}.${minor}.${build}"
EOF