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
# This is the inverse of 00_stash-things.sh
#
# There is a known issue here!  If you do the following steps, you'll get
# a warning about a merge conflict in your own file.  Sorry, not sure what
# do to there.  Please avoid doing this.
#
# * Change foo
# * `git add foo`
# * Change foo again
# * `git commit`

if [ -e .git/MERGE_HEAD ]; then
    echo "Not unstashing during a merge"
    exit 0
fi

UNSTAGED_CHANGES=$(git diff --name-only | wc -l)

if [ "$UNSTAGED_CHANGES" -ne 0 ] ; then
  echo "Unstaged changes, you should do something about that. Not unstashing now."
  exit 0
fi

ERROR=0

STASHCOUNT=$(git stash list -q | wc -l)

if [ "$STASHCOUNT" -ne 0 ] ; then
    git stash pop -q
    ret=$?

    if [ $ret != 0 ] ; then
        echo "Stash pop failed.  No idea what to do here.  Return: ${ret}"
        ERROR=$ret
    fi
fi

exit $ERROR
