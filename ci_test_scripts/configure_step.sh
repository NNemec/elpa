#!/bin/bash
source /etc/profile.d/modules.sh
set -ex
pwd

source ./ci_test_scripts/.ci-env-vars
echo $1
eval  ./configure $1
