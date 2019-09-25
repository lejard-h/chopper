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

echo -e "\033[1mPKG: ${PKG}\033[22m"
pushd "${PKG}" || exit $?
pub upgrade --no-precompile || exit $?

function pkg_coverage {
  if [ "$CODECOV_TOKEN" ] ; then
    pub run test_coverage
    bash <(curl -s https://codecov.io/bash)
  fi
}

function run_analyze {
  echo -e '\033[1mTASK: dartanalyzer\033[22m'
  dartanalyzer --fatal-warnings --fatal-infos .
}

function run_format {
  echo -e '\033[1mTASK: format\033[22m'
  dartfmt -n --set-exit-if-changed .
}

function run_test {
  echo -e '\033[1mTASK: test\033[22m'
  pub run build_runner test --delete-conflicting-outputs -- -p chrome -p vm --reporter expanded 
  pkg_coverage    
}

for TASK in "$@"; do
  case $TASK in
  test) echo
    run_test || EXIT_CODE=$?
    ;;
  dartanalyzer) echo
    run_analyze || EXIT_CODE=$?
    ;;
  dartfmt) echo
    run_format || EXIT_CODE=$?
    ;;
  *) echo -e "\033[31mNot expecting TASK '${TASK}'. Error!\033[0m"
    EXIT_CODE=1
    ;;
  esac

done

exit $EXIT_CODE