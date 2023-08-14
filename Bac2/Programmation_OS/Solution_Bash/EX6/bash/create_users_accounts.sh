#!/bin/bash

# This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

# You should have received a copy of the GNU General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.

function print_help() {
    echo """
NAME
    ${0##*/} - creates user account based on formatted file.

SYNOPSIS
    ${0##*/} [-h] [-s sep] file

DESCRIPTION
    Creates user account based on information given in <file>. File should be formatted so that
    first field is the name of the new account and second field is the password to use. In other
    words, each line looks like:

    username<separator>password

    Username must follow linux username pattern. Coming from manpage of useradd:

        It is usually recommended to only use usernames that begin with a lower case letter or an
        underscore, followed by lower case letters, digits, underscores, or dashes. [...]

        Usernames may only be up to 32 characters long.

    Account is created only if the user does not alread exists.

    If a line do not contains separator, invalid account file is returned.

    -h
        print help and exits
    -s sep
        change the separator, ';' by default

RETURN VALUE
    0:  success
    1:  wrong option error
    2:  no account file given
    3:  invalid account file
    """
}

separator=";"

while getopts ":hs:" args; do
    case ${args} in
        h)
            print_help
            exit 0
            ;;
        s)
            separator="${OPTARG}"
            ;;
        ?)
            echo "Unknown option: -${OPTARG}" >&2
            exit 1
            ;;
    esac
done

shift $(( OPTIND - 1 ))

# Ensure that exactly one argument is given to the script 
[ "$#" -ne "1" ] && echo "Script takes file name as argument" >&2 && print_help && exit 2

# Check if the file is valid
[ ! -e "$1" ] && echo "${1} does not exists." >&2 && exit 3
[ ! -f "$1" ] && echo "${1} is not a file." >&2 && exit 3
[ ! -r "$1" ] && echo "${1} cannot be read, please correct the permissions." >&2 && exit 3

# Use of regex to ensure that the usernames are valid. According to useradd man page a username must
# follow the following pattern:
# * begin with a lowercase letter or an underscore
# * can contain up to 32 characters, each of these are lowercase letters, numbers or underscore
# * can contain a $ sign as last character

# Here we use:
# * -E to use extended regex
# * -v to exclude lines that follow the pattern
# * -x to match the whole line instead of a part of it

# The variable non_matching_lines contains all the lines that do not match the pattern. And thus all
# the lines containing an invalid username OR a password containing a space or the separator.

# Note also that the dollar needs to be escaped for grep (otherwise it would be interpreted as end
# of line marker). We thus need to prefix it with a \. However, during substitution phase (remember
# that before being executed a line is subject to substitution of variables and special characters),
# \$ is expended as $. Thus we need to use \\\$: \\ is substituted by \, and \$ by $. This gives use
# after substitution the line (considering that $separator is equal to ':' and $1 is equal to
# filename) :

# non_matching_lines=$(grep -vEx "[a-z_]([a-z0-9_-]{0,31}|[a-z0-9_-]{0,30}\$):[^ :]+" "filename")

non_matching_lines=$(grep -vEx "[a-z_]([a-z0-9_-]{0,31}|[a-z0-9_-]{0,30}\\\$)${separator}[^ ${separator}]+" "${1}")

if [ -n "${non_matching_lines}" ]; then
    echo "The following lines do not respect the expected pattern:" >&2
    echo "${non_matching_lines}" >&2

    print_help
    exit 3
fi

# Read the file
while read -r line; do
    # Split the line according to the given separator
    user=${line%"${separator}"*}
    pass=${line#*"${separator}"}

    # Test if a user exist as id return a zero status code when user is found.
    if id "${user}" &> /dev/null; then
        echo "User ${user} already exists. Skipping..."
    else
        # Create the user
        # We use echo here instead of the real command for test purpose. Once in production, echo and double quotes
        # should be removed
        echo "sudo useradd $user"
        echo "echo \"$user:$pass\" | sudo chpasswd"
    fi
done < "${1}"
