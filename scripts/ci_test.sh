#!/usr/bin/env bash
set -e

DIR=$(dirname "${BASH_SOURCE[0]}")
cd "$DIR"

CPU_COUNT=$(grep -c "^processor" "/proc/cpuinfo" || sysctl -n "hw.ncpu")

TMP_PATH="$(pwd)/../tmp"
TMP_SIZE="64"

./temp/mount.sh "$TMP_PATH" "$TMP_SIZE"

cd ".."

ROOT_DIR=$(pwd)

# We need to send coverage for extension.
curl -s "https://codecov.io/bash" > "build/codecov.sh"
chmod +x "build/codecov.sh"

/usr/bin/env bash -cl "\
  cd \"$ROOT_DIR\" && \
  gem install bundler --force && \
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
LZWS_BRANCH="v1.5.4"

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
  sudo_prefix="sudo"
else
  sudo_prefix=""
fi

# "dos2unix" may be required for text file handling.
if command -v "dos2unix" > /dev/null 2>&1; then
  dos2unix_prefix="${sudo_prefix} dos2unix"
else
  dos2unix_prefix=":"
fi

DICTIONARIES=("linked-list" "sparse-array")
BIGNUM_LIBRARIES=("gmp" "tommath")

some_test_passed=false

for dictionary in "${DICTIONARIES[@]}"; do
  for bignum_library in "${BIGNUM_LIBRARIES[@]}"; do
    echo "dictionary: ${dictionary}, bignum library: ${bignum_library}"

    find . -depth \( \
      -name "CMake*" \
      -o -name "*.cmake" \
    \) -exec rm -rf {} +

    # It may not work on target platform.
    cmake ".." \
      -DCMAKE_INSTALL_PREFIX="$prefix" \
      -DLZWS_COMPRESSOR_DICTIONARY="$dictionary" \
      -DLZWS_BIGNUM_LIBRARY="$bignum_library" \
      -DLZWS_SHARED=ON \
      -DLZWS_STATIC=OFF \
      -DLZWS_CLI=OFF \
      -DLZWS_TESTS=OFF \
      -DLZWS_EXAMPLES=OFF \
      -DLZWS_MAN=OFF \
      -DLZWS_COVERAGE=OFF \
      -DCMAKE_BUILD_TYPE="Release" \
      || continue

    cmake --build "." --target "clean"
    cmake --build "." -j${CPU_COUNT} --config "Release"
    $sudo_prefix cmake --build "." --target "install" --config "Release"

    /usr/bin/env bash -cl "\
      cd \"$ROOT_DIR\" && \
      bundle exec rake clean && \
      bundle exec rake && \
      ./build/codecov.sh \
    "

    $dos2unix_prefix "install_manifest.txt"
    cat "install_manifest.txt" | $sudo_prefix xargs rm -f

    some_test_passed=true
  done
done

if [ "$some_test_passed" = false ]; then
  >&2 echo "At least one test should pass"
  exit 1
fi
