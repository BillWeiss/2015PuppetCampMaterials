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

TEMP_FILE=/tmp/puppet-lint.out

function setup() {
  rm -f $TEMP_FILE
  touch $TEMP_FILE
}

function loop() {
  for file in $(git diff --diff-filter=ACMRTUXB --name-only --cached --relative | grep "\.pp$");
  do
    bundle exec puppet-lint \
    --scope-variables=serverenv,serverrole,servertype,is_dr_server,in_dr_mode,monitor,mailer,notification_period \
    --file-server-conf=site-modules/puppet/files/fileserver.conf \
    --no-documentation-check \
    --no-80chars-check \
        --log-format "%{KIND}: %{path}:%{line} %{message}" "$file" >> $TEMP_FILE
  done
}

function warnings() {
  cat < $TEMP_FILE | GREP_COLOR='1;33' grep "WARNING"
}

function errors() {
  cat < $TEMP_FILE | GREP_COLOR='1;31' grep "ERROR"
}

function main() {
  loop
  if [ 0 -lt "$(warnings | wc -l)" ];
  then
    warnings
    STATUS=0
  fi
  if [ 0 -lt "$(errors | wc -l)" ];
  then
    errors
    STATUS=1
  fi
  exit $STATUS
}

setup
main
