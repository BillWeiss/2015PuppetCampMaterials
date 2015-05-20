#!/bin/bash
# Copyright 2015 Backstop Solutions Group, LLC.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# =======================================================================

TEMP_FILE=/tmp/shellcheck.out

function setup() {
  rm -f $TEMP_FILE
  touch $TEMP_FILE
}

function loop() {
  for file in $(git diff --diff-filter=ACMRTUXB --name-only --cached --relative | grep '\.sh$');
  do
    shellcheck --format=gcc "$file" >> $TEMP_FILE
  done
}

function notices() {
  cat < $TEMP_FILE | grep_color 'note' '1;32'
}

function warnings() {
  cat < $TEMP_FILE | grep_color 'warning' '1;33'
}

function errors() {
  cat < $TEMP_FILE | grep_color 'error' '1;31'
}

function awk_strip() {
  awk '{print $2}' | tr -d ':' | tr -d "^\d:"
}

function grep_color() {
  local type=$1
  local color=$2
  GREP_COLOR="$color" grep -in "$type"
}

function main() {
  loop
  if [ 0 -lt "$(notices | awk_strip | wc -l)" ];
  then
    notices
    STATUS=0
  fi
  if [ 0 -lt "$(warnings | awk_strip | wc -l)" ];
  then
    warnings
    STATUS=0
  fi
  if [ 0 -lt "$(errors | awk_strip | wc -l)" ];
  then
    errors
    STATUS=1
  fi
  exit $STATUS
}

setup
main
