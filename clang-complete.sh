#!/bin/sh
set -e

cd "$(dirname $0)"

echo "-I$HOME/.rvm/rubies/ruby-2.6.5/include/ruby-2.6.0" > ".clang_complete"
