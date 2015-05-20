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
#
# This stashes local unstaged changes so the later checks don't look at
# uncommitted code

if [ -e .git/MERGE_HEAD ]; then
    echo "Not stashing during a merge"
    exit 0
fi


RED='\033[0;31m'
ORANGE='\033[0;33m'
NC='\033[0m'

GIT_UNSTAGED_FILES=$(git diff --name-only)
GIT_STAGED_FILES=$(git diff --cached --name-only)

ERROR=0

# if there are staged files and unstaged files, check if each unstaged file is the staged file
if [ -n "$GIT_STAGED_FILES" ] && [ -n "$GIT_UNSTAGED_FILES" ];
then
  for staged_file in $GIT_STAGED_FILES
  do
    for unstaged_file in $GIT_UNSTAGED_FILES
    do
      if [ "$staged_file" = "$unstaged_file" ];
      then
        echo -e "${RED}You should probably add ${ORANGE}${staged_file}${NC}${RED}, you have staged and unstaged changes.${NC}"
        ERROR=1
      fi
    done
  done
  if [ $ERROR -eq 1 ]; # short_circuit
  then
    exit 1
  fi
fi


GIT_DIFF_COUNT=$(git diff --cached --name-only | wc -l)

if [ "$GIT_DIFF_COUNT" -eq 0 ] ; then
  echo "No changes, not stashing."
  exit 0
fi

git stash -q --keep-index
ret=$?
if [ $ret != 0 ] ; then
    echo "Stash failed... Uh oh.  Returned ${ret}"
    ERROR=$ret
fi

exit $ERROR
