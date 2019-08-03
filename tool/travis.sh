#!/bin/bash
# Created with https://github.com/dart-lang/mono_repo

if [ -z "$PKG" ]; then
  echo -e '\033[31mPKG environment variable must be set!\033[0m'
  exit 1
fi

if [ "$#" == "0" ]; then
  echo -e '\033[31mAt least one task argument must be provided!\033[0m'
  exit 1
fi

pushd $PKG
pub upgrade || exit $?

EXIT_CODE=0

function pkg_coverage {
  if [ "$CODECOV_TOKEN" ] ; then
    pub run test_coverage
    bash <(curl -s https://codecov.io/bash)
  fi
}

function run_analyze {
  echo -e '\033[1mTASK: dartanalyzer\033[22m'
  dartfmt -n --set-exit-if-changed .
}

function run_format {
  echo -e '\033[1mTASK: format\033[22m'
  dartfmt -n --set-exit-if-changed .
}

function run_test {
  echo -e '\033[1mTASK: test\033[22m'
  pub run build_runner build --delete-conflicting-outputs
  pub run test -p chrome -p vm --reporter expanded 
  pkg_coverage    
}

while (( "$#" )); do
  TASK=$1
  case $TASK in
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
    EXIT_CODE=1
    ;;
  esac

  shift
done

exit $EXIT_CODE