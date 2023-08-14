#!/bin/bash

# This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

# You should have received a copy of the GNU General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.

interne="Programmation des systèmes"

# Test if environment variable is set
[ -z "${publique+x}" ] && echo "La variable publique n'est pas affectée. Exiting." >&2 && exit 1
# ${pub+x} is a use case of parameter expansion:
# https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html#tag_18_06_02
# ${pub+x} is equal to "x" if variable is set (and even if contains an empty string) and equal to "" otherwise.

if [ -n "$publique" ]; then
    echo "${interne}${publique}"
else
    echo "La variable publique est vide" >&2
    exit 2
fi

exit 0
