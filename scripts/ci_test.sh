#!/bin/bash
set -e

cd "$(dirname $0)"

# This script is for CI machines only, it provides junk and changes some config files.
# Please do not use it on your machine.

# CI may not want to provide target ruby version.
# We can just use the latest available ruby based on target major version.
cd ".."
ruby_version=$(< ".ruby-version")
ruby_major_version=$(echo "${ruby_version%.*}" | sed "s/\./\\\./g") # escaping for regex
ruby_version=$(rvm list | grep -o -e "$ruby_major_version\.[0-9]\+" | sort | tail -n 1)
echo "$ruby_version" > ".ruby-version"

bash -cl "rvm use '.' && gem install bundler && bundle install"

# Fix path environment params.
export PATH="$PATH:/usr/local/bin"
export C_INCLUDE_PATH="$C_INCLUDE_PATH:/usr/local/include"
export LIBRARY_PATH="$C_INCLUDE_PATH:/usr/local/lib"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/local/lib"

# Compiling library from source.
LZWS_BRANCH="v1.3.0"

build="tmp/lzws-build"
mkdir -p "$build"
cd "$build"

# Remove orphaned directory.
rm -rf "lzws"
git clone --depth 1 --branch "$LZWS_BRANCH" "https://github.com/andrew-aladev/lzws.git" "lzws"
cd "lzws/build"

for dictionary in "linked-list" "sparse-array"; do
  echo "dictionary: $dictionary"

  # Remove previous cmake files.
  find . \( -name "CMake*" -o -name "*.cmake" \) -exec rm -rf {} +

  cmake ".." \
    -DLZWS_COMPRESSOR_DICTIONARY="$dictionary" \
    -DLZWS_CLI=OFF \
    -DLZWS_TESTS=OFF \
    -DLZWS_EXAMPLES=OFF \
    -DLZWS_MAN=OFF \
    -DCMAKE_BUILD_TYPE="RELEASE" \
    -DCMAKE_C_FLAGS_RELEASE="-O2 -march=native"
  make clean
  make -j2

  # "sudo" may be required for "/usr/local".
  sudo make install

  bash -cl "bundle exec rake clean && bundle exec rake"
done