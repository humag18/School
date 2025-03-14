#!/bin/bash

# This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

# You should have received a copy of the GNU General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.

if [ "$#" -lt 1 ]; then
    echo "${0} uid1 [[uid2] [uid3 [...]]]"
    exit 1
fi

for i in "$@"; do
    if [ "$i" -ge "1000" ]; then
        echo "UID $i is a valid regular UID"
        exit 0
    fi
    echo "UID $i is not a valid regular UID"
    exit 2
done
