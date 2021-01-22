#!/bin/bash
set -e

DIR=$(dirname "${BASH_SOURCE[0]}")
cd "$DIR"

CPU_COUNT=$(grep -c "^processor" "/proc/cpuinfo" || sysctl -n "hw.ncpu")

TMP_PATH="$(pwd)/../tmp"
TMP_SIZE="64"

./temp/mount.sh "$TMP_PATH" "$TMP_SIZE"

cd ".."

bash -cl "\
  gem install bundler && \
  bundle install \
"

# Using standard default prefix.
prefix=${1:-"/usr/local"}

# Fix path environment params.
export PATH="${PATH}:${prefix}/bin"
export C_INCLUDE_PATH="${C_INCLUDE_PATH}:${prefix}/include"
export LIBRARY_PATH="${C_INCLUDE_PATH}:${prefix}/lib"
export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${prefix}/lib"

# Compiling library from source.
LZWS_BRANCH="v1.4.1"

cd "tmp"

# Remove orphaned directory.
rm -rf "lzws"

git clone "https://github.com/andrew-aladev/lzws.git" \
  --single-branch \
  --branch "$LZWS_BRANCH" \
  --depth 1 \
  "lzws"
cd "lzws/build"

# "sudo" may be required for prefix.
if command -v "sudo" > /dev/null 2>&1; then
  is_sudo_required=true
else
  is_sudo_required=false
fi

for dictionary in "linked-list" "sparse-array"; do
  echo "dictionary: ${dictionary}"

  find . -depth \( \
    -name "CMake*" \
    -o -name "*.cmake" \
  \) -exec rm -rf {} +

  cmake ".." \
    -DCMAKE_INSTALL_PREFIX="$prefix" \
    -DCMAKE_BUILD_TYPE="RELEASE" \
    -DLZWS_COMPRESSOR_DICTIONARY="$dictionary" \
    -DLZWS_CLI=OFF \
    -DLZWS_TESTS=OFF \
    -DLZWS_EXAMPLES=OFF \
    -DLZWS_MAN=OFF

  make clean
  make -j${CPU_COUNT}

  if $is_sudo_required; then
    sudo make install
  else
    make install
  fi

  bash -cl "\
    cd ../../.. && \
    bundle exec rake clean && \
    bundle exec rake \
  "

  if $is_sudo_required; then
    sudo xargs rm < "install_manifest.txt"
  else
    xargs rm < "install_manifest.txt"
  fi
done
