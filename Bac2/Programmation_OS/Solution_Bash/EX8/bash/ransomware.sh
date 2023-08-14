#!/bin/bash

# This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

# You should have received a copy of the GNU General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.

key=$(openssl rand -hex 100)

# Variable action contains the name of the function to be executed depending on the parameters so that lines like:
#
# $action my_file 
#
# Will be expanded to:
# cypher my_file (or decypher my_file)
# Forcing the execution of the right function
action="cypher"

# The same principles applies here since true and false are built-in commands. By setting this, we can use the syntax
# if $safe; then
#   statement
# fi
safe=false
file_mode=false
generated_key=true

while getopts "dfk:s" args; do
    case ${args} in
        d)
            # Option -d
            action="decypher"
            ;;
        f)
            # Option -f
            file_mode=true
            ;;
        k)
            # Option -k
            if [ "${OPTARG}" != "${OPTARG#-}" ]; then
                echo "Option k requires a valid argument, got ${OPTARG}" >&2
                exit 10
            fi
            key="$OPTARG"
            generated_key=false
            ;;
        # s
        s)
            # Option -s
            safe="1"
            ;;
        *)
            exit 1
            ;;
    esac
done

shift $(( OPTIND - 1 ))

# Since these functions will be called through xargs, the global variables are not accessible anymore. We need to give them to the function through paramters
cypher() {
    local file_name out_file_name safe key

    key="$1"
    safe="$2"

    shift 2

    for file_name in "$@"; do
        if [ "${file_name}" = "${file_name%.cyphered}" ]; then
            out_file_name="${file_name}.cyphered"
            # We only remove the file if encryption went fine and if safe mode is disabled
            openssl enc -aes-256-cbc -pbkdf2 -k "$key" -in "${file_name}" -out "${out_file_name}" && ! $safe && rm "${file_name}"
        else
            echo "${file_name} is already cyphered"
        fi
    done
}

decypher() {
    local file_name out_file_name safe key

    key="$1"
    safe="$2"

    shift 2

    for file_name in "$@"; do
        out_file_name="${file_name%.cyphered}"
        if [ "${file_name}" != "${out_file_name}" ]; then
            openssl enc -d -aes-256-cbc -pbkdf2 -k "$key" -in "${file_name}" -out "${out_file_name}" && ! $safe && rm "${file_name}"
        else
            echo "${file_name} is not encrypted"
        fi
    done
}

# Function cypher and decyphered are exported (made global) so that they can be call through find and exec
export -f cypher decypher

[ "$#" -lt "1" ] && echo "Script takes at least a positional argument" >&2 && exit 1

# If the key is set as generated (thus no -k options has been given)...
if $generated_key; then
    # ... and if the action is to cypher then we print the key (to have it to decypher)
    [ "$action" = "cypher" ] && echo "$key"
    # ... and if the action is to decypher then we ask the user for the key (it has no sense to use a random key to decypher...)
    [ "$action" = "decypher" ] && read -rp "Enter key: " key
fi

for file in "$@"; do
    [ ! -e "$file" ] && echo "File or directory: $file does not exists" >&2 && continue

    if [ -d "$file" ] && $file_mode; then
        echo "Given a directory ($file) while in file mode" >&2
        continue
    fi

    if [ -f "$file" ] && ! $file_mode; then
        echo "Given a file ($file) while in directory mode" >&2
        continue
    fi

    find "$file" -type f -print0 | xargs -0 -P10 -I args bash -c "$action '$key' '$safe' 'args'"
done
