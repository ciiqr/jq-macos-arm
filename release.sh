#!/usr/bin/env bash

set -e

declare commit
commit="$(git rev-parse --short HEAD)"

# TODO: debug only
find . -type f

gh release create \
    --title "$commit" \
    --notes '' \
    "v-${commit}" \
    ./jq-*/jq
