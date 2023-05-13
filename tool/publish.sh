#!/usr/bin/env bash

set -e

PKG=$1
echo -e "\033[1mPKG: ${PKG}\033[22m"
pushd "${PKG}"

sed '/Comment before publish$/,+2 d' pubspec.yaml > pubspec.temp.yaml
rm pubspec.yaml
mv pubspec.temp.yaml pubspec.yaml

if [ "$2" == "--dry-run" ]; then
  dart pub publish --dry-run
else
  dart pub publish --force
fi

popd