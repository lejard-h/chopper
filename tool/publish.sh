#!/usr/bin/env bash

PKG=$1
echo -e "\033[1mPKG: ${PKG}\033[22m"
pushd "${PKG}"

mkdir -p .pub-cache

echo $CREDENTIAL_JSON > ~/.pub-cache/credentials.json

dart pub publish -f --dry-run
popd