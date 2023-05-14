#!/bin/bash

# ensure codecov token exists
if [ -z "$CODECOV_TOKEN" ]; then
  echo "CODECOV_TOKEN is not set"
  exit 1
fi

# install coverage tools
dart pub global activate coverage
dart pub global activate remove_from_coverage

# install codecov uploader
curl -Os https://uploader.codecov.io/latest/linux/codecov
chmod +x codecov

# ensure codecov uploaded downloaded
if [ ! -f codecov ]; then
  echo "codecov uploader not found"
  exit 1
fi

## loop through all the packages
PKGS=("chopper" "chopper_generator" "chopper_build_value")

for PKG in "${PKGS[@]}"
do
  # move to package directory
  cd "$PKG" || exit
  # install dependencies
  dart pub get
  # run tests with coverage
  dart pub global run coverage:test_with_coverage
  # remove generated files from coverage
  dart pub global run remove_from_coverage:remove_from_coverage -f coverage/lcov.info -r '\.g\.dart$'
  # if coverage/lcov.info exists, upload to codecov
  [ -f coverage/lcov.info ] && ../codecov -t "$CODECOV_TOKEN" -f coverage/lcov.info
  # move back to root directory
  cd - || exit
done