#!/bin/bash
set -e

DIR=$(dirname "${BASH_SOURCE[0]}")
source "${DIR}/../../env.sh"

FROM_IMAGE_NAME="test_x86_64-gentoo-linux-musl"
IMAGE_NAME="${IMAGE_PREFIX}_x86_64-gentoo-linux-musl"

REBUILD_DATE=$(< "${DIR}/.rebuild_date") || :
