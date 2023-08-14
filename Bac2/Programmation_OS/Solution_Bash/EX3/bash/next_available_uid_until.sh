#!/bin/bash

# This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

# You should have received a copy of the GNU General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.

# Note that a while/until loop would be a little bit more clean since:
# * we do not need to specify a limit on the UID
# * we do not need the use of exit or break to avoid extra process

# However the latter require a counter...

case "$#" in
    0)
        default_file="./passwd"
        start=0
        ;;
    1)
        default_file="$1"
        start=0
        ;;
    2)
        default_file="$1"
        start="$2"
        ;;
    *)
        echo "Too many arguments"
        echo "$0 [passwd_file [start_index]]"
        exit 2
        ;;
esac

if [ ! -e "${default_file}" ]; then
    echo "Unexisting file: ${default_file}"
    exit 3
fi

if [ ! -r "${default_file}" ]; then
    echo "You do not have read acccess to file: ${default_file}"
    exit 4
fi

if [ "${start}" -lt "0" ]; then
    echo "Start index must be a positive integer"
    exit 5
fi

cur_uid=1
free_uid=""

until [ "$free_uid" ]; do
    if ! grep -qE "x:${cur_uid}:" "${default_file}"; then
        free_uid=$cur_uid
    fi
    (( cur_uid++ ))
done

echo "Next uid: ${free_uid}"
