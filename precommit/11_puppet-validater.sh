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

ERROR=0
DIR=$( dirname "$0" )

for file in $( "$DIR/find_files" '\.pp$' )
do
    puppet parser validate \
        --render-as s \
        --modulepath=site-modules \
        --color=false "${file}" 2>&1 | \
            egrep -v 'Warning: You cannot collect [a-z ]*without storeconfigs being set' | \
            egrep -v "Warning: Deprecation notice: Node inheritance is not supported in Puppet >= 4.0.0" | \
            egrep -v ".*at.*nodes\.pp"
    # feel free to be pretty impressed at the below.  PIPESTATUS contains
    # the exit codes of everything in the previous pipeline, and thus this
    # pulls out the exit of just the puppet parser line
    ERROR=$(( ERROR + PIPESTATUS[0] ))
done

exit $ERROR
