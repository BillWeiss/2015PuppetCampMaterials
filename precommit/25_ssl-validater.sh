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

compareKeyCert () {
  keyfile="${1}.key"
  certfile="${1}.crt"

    # this grabs the modulus from the key and cert and compares them
    # if they don't match, the key/cert don't match and things will go
    # wrong here
    diff <( openssl rsa -in "${keyfile}" -noout -modulus ) \
         <( openssl x509 -in "${certfile}" -noout -modulus ) > /dev/null

    return $?
}

# find all the changed .crt and .key files
for changedfile in $( "$DIR/find_files" '\.(crt|key)$' )
do
    # keys and certs have to have the same name except for suffix here.
    # That's just the way we do it to make things like this easier
    BASE=$( echo "${changedfile}" | sed 's/\.crt$//g' )

    # I'm sure there's some clever way to DRY this up, but I don't know
    # what it is
    if [[ ! -f "${BASE}.key" ]] ; then
        echo "Can't find a matching key for ${changedfile}" >&2
        ERROR=$(( ERROR + 1 ))
        continue
    fi

    if [[ ! -f "${BASE}.crt" ]] ; then
        echo "Can't find a matching cert for ${changedfile}" >&2
        ERROR=$(( ERROR + 1 ))
        continue
    fi

    compareKeyCert "${BASE}"

    if [ $? -ne 0 ] ; then
        echo "${BASE}.key and ${BASE}.crt modulus differ\!" >&2
        ERROR=$(( ERROR + 1 ))
    fi
done

if [ ${ERROR} -gt 0 ] ; then
    echo "YoYoYoYoYoYoYoYoYoYoYoYoYoYoYoYoYoYoYoYoYoYoYoYoYoYoYoYoYoYoYoYoYoYoYoYoYoYoYoYoYoYoYoYo" >&2
    echo "IF THIS FAILED, IT MEANS THESE CERTS WILL BRING DOWN A SITE" >&2
    echo "DO NOT BYPASS THIS CHECK WITHOUT BEING SUPER SURE YOU KNOW WHAT TO DO" >&2
    echo " AND GET A FRIEND TO LOOK OVER YOUR CHANGE.  A FRIEND WHO CAN" >&2
    echo " RECITE HOW RSA WORKS OFF THE TOP OF THEIR HEAD OR WHO CAN" >&2
    echo " DESCRIBE HOW ELLIPTIC CURVE CRYPTO WORKS" >&2
    echo "YoYoYoYoYoYoYoYoYoYoYoYoYoYoYoYoYoYoYoYoYoYoYoYoYoYoYoYoYoYoYoYoYoYoYoYoYoYoYoYoYoYoYoYo" >&2
fi

exit ${ERROR}
