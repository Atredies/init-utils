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

# check paramater to see which number to increment
if [[ "$1" == "feature" ]]; then
  minor=$(echo $minor + 1 | bc)
elif [[ "$1" == "build" ]]; then
  build=$(echo $build + 1 | bc)
elif [[ "$1" == "major" ]]; then
  major=$(echo $major+1 | bc)
  minor=0
else
  echo "usage: ./version.sh [major/feature/build]"
  exit -1
fi

export VERSION="${major}.${minor}.${build}"

cat <<EOF > ./VERSION
VERSION="${major}.${minor}.${build}"
EOF