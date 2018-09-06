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
    # Gather coverage and upload to Coveralls.
if [ "$COVERALLS_TOKEN" ] ; then
  OBS_PORT=9292
  echo "Collecting coverage on port $OBS_PORT..."

  # Start tests in one VM.
  dart \
    --enable-vm-service=$OBS_PORT \
    --pause-isolates-on-exit \
    test/*_test.dart &

  # Run the coverage collector to generate the JSON coverage report.
  pub run coverage:collect_coverage \
    --port=$OBS_PORT \
    --out=var/coverage.json \
    --wait-paused \
    --resume-isolates

  echo "Generating LCOV report..."
  pub run coverage:format_coverage \
    --lcov \
    --in=var/coverage.json \
    --out=var/lcov.info \
    --packages=.packages \
    --report-on=lib

  coveralls-lcov var/lcov.info
fi
}

while (( "$#" )); do
  TASK=$1
  case $TASK in
  command) echo
    echo -e '\033[1mTASK: command\033[22m'
    echo -e 'pub run build_runner test -- -p chrome'
    pub run build_runner test -- -p chrome || EXIT_CODE=$?
    pkg_coverage
    ;;
  dartanalyzer) echo
    echo -e '\033[1mTASK: dartanalyzer\033[22m'
    echo -e 'dartanalyzer --fatal-infos --fatal-warnings .'
    dartanalyzer --fatal-infos --fatal-warnings . || EXIT_CODE=$?
    ;;
  dartfmt) echo
    echo -e '\033[1mTASK: dartfmt\033[22m'
    echo -e 'dartfmt -n --set-exit-if-changed .'
    dartfmt -n --set-exit-if-changed . || EXIT_CODE=$?
    ;;
  *) echo -e "\033[31mNot expecting TASK '${TASK}'. Error!\033[0m"
    EXIT_CODE=1
    ;;
  esac

  shift
done

exit $EXIT_CODE