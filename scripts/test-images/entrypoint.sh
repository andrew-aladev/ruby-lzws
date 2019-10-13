#!/bin/bash
set -e

cd "$(dirname $0)"

env-update
source /etc/profile

git clone "https://github.com/andrew-aladev/ruby-lzws.git" --single-branch --branch "master" --depth 1 "ruby-lzws"
cd "ruby-lzws"

./scripts/ci_test.sh
