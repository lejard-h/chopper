#!/bin/bash
# install coverage tools
dart pub global activate coverage
dart pub global activate remove_from_coverage

## loop through all the packages
PKGS=("chopper" "chopper_generator" "chopper_build_value")

for PKG in "${PKGS[@]}"
do
  # move to package directory
  pushd "$PKG" || exit
  # install dependencies
  dart pub get
  # run tests with coverage
  dart pub global run coverage:test_with_coverage
  # remove generated files from coverage
  dart pub global run remove_from_coverage:remove_from_coverage -f coverage/lcov.info -r '\.g\.dart$'
  # if coverage/lcov.info exists, upload to codecov
  [ -f coverage/lcov.info ] && bash <(curl -s https://codecov.io/bash) -f coverage/lcov.info
  # move back to root directory
  popd || exit
done