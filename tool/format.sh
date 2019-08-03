#!/bin/bash
pushd $PKG
dartanalyzer --fatal-infos --fatal-warnings . 