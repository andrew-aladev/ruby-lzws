#!/bin/bash
set -e

cd "$(dirname $0)"

# Fix path environment params.
export PATH="$PATH:/usr/local/bin"
export C_INCLUDE_PATH="$C_INCLUDE_PATH:/usr/local/include"
export LIBRARY_PATH="$C_INCLUDE_PATH:/usr/local/lib"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/local/lib"

LZWS_BRANCH="v1.2.0"

tmp="../tmp"
build="$tmp/lzws-build"

mkdir -p "$build"
cd "$build"

rm -rf "lzws"
git clone --depth 1 --branch "$LZWS_BRANCH" "https://github.com/andrew-aladev/lzws.git" "lzws"
cd "lzws/build"

for dictionary in "linked-list" "sparse-array"; do
  echo "dictionary: $dictionary"

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
  sudo make install

  bash -c '\
    source ~/.rvm/scripts/rvm && \
    cd ../../../.. && \
    gem install bundler &&
    bundle install && \
    bundle exec rake clean && \
    bundle exec rake \
  '
done
