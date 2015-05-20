#!/bin/sh
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
# Script mostly written by Brian Riehman at Backstop Solutions Group (https://github.com/briehman)
#
# Backstoppers run this after they clone our Puppet repo to get things in
# working order. It sets an upstream to fetch from, installs our
# pre-commit hook, and adds some useful aliases

readonly UPSTREAM_URL=git@github.com:backstop/Puppet.git

if ! git ls-remote --exit-code upstream >/dev/null 2>&1; then
  echo "Adding upstream remote"
  git remote add upstream $UPSTREAM_URL
  git fetch upstream
  echo
fi

for branch in master office; do
  if ! git show-ref --verify --quiet refs/heads/$branch; then
    git checkout --track upstream/$branch
    echo
  else
    git branch $branch --set-upstream-to upstream/$branch
  fi
done

echo "\nInstalling pre-commit hooks"
cp pre-commit.sh .git/hooks/pre-commit

echo "Setting up workflow aliases"
git config alias.fetch-upstream '!bash -c "git stash; git fetch --all; git checkout master; git merge upstream/master; git checkout office; git merge upstream/office; git push origin master; git push origin office; git checkout \$0" $(git status -bs | cut -f2 -d\  | cut -f1 -d.); git stash pop'
git config alias.new-work '!bash -c "git fetch-upstream; git checkout master -b ${1:-new-work-branch}"'
git config alias.decapitate '!bash -c "git checkout master; git branch --contains \$0 | grep ^\\* > /dev/null && (git branch -d \$0; git push origin :\$0; git fetch origin)"'
