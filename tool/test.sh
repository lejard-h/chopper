#!/bin/bash
pushd $PKG
function pkg_coverage {
  if [ "$CODECOV_TOKEN"] ; then
    pub run test_coverage
    bash <(curl -s https://codecov.io/bash)
  fi
}

pub run build_runner build --delete-conflicting-outputs
pub run test -p chrome -p vm --reporter expanded 
pkg_coverage