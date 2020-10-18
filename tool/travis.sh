#!/bin/bash
# Created with https://github.com/dart-lang/mono_repo

set -e

if [ -z "$PKG" ]; then
  echo -e '\033[31mPKG environment variable must be set!\033[0m'
  exit 1
fi

if [ "$#" == "0" ]; then
  echo -e '\033[31mAt least one task argument must be provided!\033[0m'
  exit 1
fi

echo -e "\033[1mPKG: ${PKG}\033[22m"
pushd "${PKG}"
dart pub get

## TODO use builtin coverage report from package:test
function pkg_coverage {
  if [ "$CODECOV_TOKEN" ] ; then
    dart pub run test_coverage
    bash <(curl -s https://codecov.io/bash)
  fi
}

function run_analyze {
  echo -e '\033[1mTASK: dartanalyzer\033[22m'
  dart analyze --fatal-warnings --fatal-infos .
}

function run_format {
  echo -e '\033[1mTASK: format\033[22m'
  dart format -o none --set-exit-if-changed .
}

function run_build {
  echo -e '\033[1mTASK: build\033[22m'
  dart pub run build_runner build --delete-conflicting-outputs
}

function run_test {
  echo -e '\033[1mTASK: test\033[22m'
  dart pub run test -p chrome -p vm --reporter expanded
  pkg_coverage    
}

for TASK in "$@"; do
  case $TASK in
  build) echo
    run_build
    ;;
  test) echo
    run_test
    ;;
  dartanalyzer) echo
    run_analyze
    ;;
  dartfmt) echo
    run_format
    ;;
  *) echo -e "\033[31mNot expecting TASK '${TASK}'. Error!\033[0m"
    exit 1
    ;;
  esac

done
