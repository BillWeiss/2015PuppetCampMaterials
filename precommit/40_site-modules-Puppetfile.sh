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
# this horrific thing checks to make sure that Puppetfile and site-modules
# are in sync

ERROR=0

# find modules that are imported via Puppetfile but not on disk
while read sitemodule
do
    if [ ! -d "site-modules/${sitemodule}" ]
    then
        echo "Yo, ${sitemodule} is still in Puppetfile, but not on disk" >&2
        ERROR=1
    fi
done < <( grep site_module Puppetfile | awk -F\' '{print $2}' )

while read diskmodule
do
    realname=$( echo "${diskmodule}" | sed 's/^site-modules\///g' ) 
    egrep -q "site_module\s+'${realname}'" Puppetfile
    if [[ $? -gt 0 ]] ; then
        echo "Yo, ${diskmodule} is on disk but not in Puppetfile"
        ERROR=1
    fi
done < <( find site-modules -mindepth 1 -maxdepth 1 -type d )

exit $ERROR
