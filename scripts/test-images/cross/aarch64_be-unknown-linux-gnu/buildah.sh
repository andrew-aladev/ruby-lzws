#!/bin/bash
set -e

DIR=$(dirname "${BASH_SOURCE[0]}")
cd "$DIR"

source "../../utils.sh"
source "./env.sh"

pull "$FROM_IMAGE_NAME"
check_up_to_date

CONTAINER=$(from "$FROM_IMAGE_NAME")
config --arch="arm64" --entrypoint "/home/entrypoint.sh"

# Add pic for gmp https://bugs.gentoo.org/707332.
run find "/usr/portage/dev-libs/gmp" -maxdepth 1 -name gmp-*.ebuild \
  -exec sed -i "s/econf /econf --with-pic /g" "{}" \; \
  -exec ebuild "{}" manifest \;

run mkdir -p /home
copy ../../entrypoint.sh /home/

copy root/ /
build emerge -v \
  dev-vcs/git dev-util/cmake \
  dev-libs/gmp app-arch/ncompress \
  dev-lang/ruby:2.7 virtual/rubygems

commit
