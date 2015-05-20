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
# borrowed from https://github.com/drwahl/puppet-git-hooks/blob/master/commit_hooks/yaml_syntax_check.sh
# with some modifications to make it look like our other checks

ERROR=0
DIR=$( dirname "$0" )

for file in $( "$DIR/find_files" '\.yaml$' )
do
    ruby -e "require 'yaml'; YAML.parse(File.open('${file}'))" > /dev/null
    ret=$?
    if [ $ret -gt 0 ]
    then
        echo "^^^ is in ${file}"
    fi
    ERROR=$(( ERROR + ret ))
done

exit $ERROR
