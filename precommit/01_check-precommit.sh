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

getmd5 () {
    filetocheck=$1

    if type md5sum > /dev/null 2>&1 ; then
        md5sum "${filetocheck}" | awk '{print $1}'
    elif type md5 > /dev/null 2>&1 ; then
        md5 "${filetocheck}" | awk '{print $NF}'
    else
        echo "No md5 program found :(" >&2
        exit 1
    fi
}


CURRENT=$( getmd5 .git/hooks/pre-commit )
NEW=$( getmd5 ./pre-commit.sh )

if [[ "${CURRENT}" != "${NEW}" ]] ; then
    echo "Yo, you need to install a new version of the pre-commit hook. Rerun init.sh." >&2
    echo "The MD5 of .git/hooks/pre-commit (${CURRENT})" >&2 
    echo "             and ./pre-commit.sh (${NEW}) differ" >&2
    exit 1
fi
