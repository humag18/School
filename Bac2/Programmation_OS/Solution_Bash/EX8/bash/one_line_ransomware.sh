#!/bin/bash

# This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

# You should have received a copy of the GNU General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.


# This is an extra solution that supports cyphering and decyphering with a minimal number of lines (the cyphering and
# decyphering core code is one line, the rest is option management and file removing command). It does not support the
# file or directory mode but accept a ix of both of them.
#
# This is given as an example and should not be taken as a clean solution (for example a cyphered then decyphred file
# has name previous_name.cyphered.decyphered). Use of functions (cf cleaner solution given) could allow us to solve that
# problem but would imply more code. This script has for only purpose to give an idea of the versatility of bash.

key=$(openssl rand -hex 100)
out_ext=".cyphered"
safe=false

while getopts "ds" args; do
    case ${args} in
        d)
            # Option -d
            read -rp "Enter key: " key
            openssl_opt="-d"
            in_ext=""
            out_ext=".decypher"
            ;;
        s)
            safe=true
            ;;
        *)
            exit 1
            ;;
    esac
done

echo "$key"

find "$@" -type f -exec openssl enc ${openssl_opt} -aes-256-cbc -k "$key" -in {}${in_ext} -out {}${out_ext} \;
( ! $safe ) && find "$@" -type f ! -name "${in_ext}" -exec rm {} \;
