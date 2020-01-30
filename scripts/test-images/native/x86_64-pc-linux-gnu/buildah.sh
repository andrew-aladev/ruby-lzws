#!/bin/bash
set -e

DIR=$(dirname "${BASH_SOURCE[0]}")
cd "$DIR"

source "../../utils.sh"
source "./env.sh"

docker_pull "$FROM_IMAGE_NAME"

CONTAINER=$(buildah from "$FROM_IMAGE_NAME")
buildah config --label maintainer="$MAINTAINER" --entrypoint "/home/entrypoint.sh" "$CONTAINER"

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
