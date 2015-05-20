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

if git diff --cached --name-only Gemfile | grep -q '^Gemfile$' && ! git diff --cached --name-only Gemfile.lock | grep -q '^Gemfile\.lock$'; then
  echo "Commit contains a change to Gemfile but no update of Gemfile.lock"
  echo "To fix this run:"
  echo -e "\tbundle install"
  echo -e "\tgit add Gemfile.lock"
  exit 1
fi

if git diff --cached --name-only Puppetfile | grep -q '^Puppetfile$' && ! git diff --cached --name-only Puppetfile.lock | grep -q '^Puppetfile\.lock$'; then
  echo "Commit contains a change to Puppetfile but no update of Puppetfile.lock"
  echo "To fix this run:"
  echo -e "\tlibrarian-puppet install"
  echo -e "\tgit add Puppetfile.lock"
  exit 1
fi
