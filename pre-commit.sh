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
# This is a driver to run a number of pre-commit checks in a git repo.
# Since the pre-commit.sh file has to be installed each time it's changed,
# the goal is to move those changes into the precommit directory

ERROR=0
RED='\033[0;31m'
ORANGE='\033[0;33m'
NC='\033[0m'
FAILED_CHECKS=""

# You may need to change these if you don't use all of our checks, or if
# you add additional checks with their own binary requirements
REQDBINS="git ruby erb openssl puppet puppet-lint shellcheck"

hasbinaries () {
    READY=0

    for thing in $REQDBINS ; do
        type "$thing" > /dev/null
        READY=$(( READY + $? ))
    done

    return $READY
}

on_dangerous_branch () {
  [[ $(gitbranch) == office ]] || [[ $(gitbranch) == master ]]
}

gitbranch () {
   git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/\* //'
}

# Reattach to stdin
exec < /dev/tty

if on_dangerous_branch ; then
    read -r -p "Whoa, there, cowboy. You're on $(gitbranch). You sure you don't want to PR that? [y/n] "
    if [[ $REPLY =~ ^[Yy]$ ]] ; then
        echo "Okay, here I go."
    else
        echo "Good call."
        exit 1
    fi
fi

hasbinaries

if [[ $? -ne 0 ]] ; then
    if [[ -e ~/.rvm/scripts/rvm ]] ; then
        source ~/.rvm/scripts/rvm
    fi

    hasbinaries

    if [[ $? -ne 0 ]] ; then
        echo "Hey, you're missing some binaries that this needs to run" >&2
        echo "Take care of this and come back, please" >&2
        echo "Those binaries are: ${REQDBINS}" >&2
        exit 1
    fi
fi

for script in precommit/*.sh ; do
    $script
    LOCAL_ERROR=$?
    if [ 0 -lt "$LOCAL_ERROR" ];
    then
      FAILED_CHECKS+="$(echo "$script" | sed 's/precommit\///') "
    fi
    ERROR=$((ERROR + LOCAL_ERROR))
done

if [ 0 -lt "$ERROR" ];
then
  echo -e "The following precommit checks ${RED}failed${NC}:"
  echo -e "${ORANGE}$FAILED_CHECKS${NC}"
  echo -e "Your commit has ${RED}NOT${NC} happened!"
  exit 1
else
  exit 0
fi
