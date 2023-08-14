#!/bin/bash

# This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

# You should have received a copy of the GNU General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.

print_help() {
    echo """
NAME
    ${0##*/} - creates user account based on formatted file.

SYNOPSIS
    ${0##*/} [-h] [-s sep] [-l logfile] [-L error_logfile] file

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
    -l logfile
        All the executed commands are added at the end of the file logfile
    -L error_logfile
        All the errors are added at the end of the file error_logfile
    -s sep
        change the separator, ';' by default

RETURN VALUE
    0:  success
    1:  wrong option error
    2:  no account file given
    3:  invalid account file
    """
}

errecho() {
    local return_status=""

    while getopts "q:" args; do
        case ${args} in
            q)
                # Option -q
                if [ "${OPTARG}" != "${OPTARG#-}" ]; then
                    echo "Option q requires a valid argument, got ${OPTARG}" >&2
                    exit 10
                fi
                return_status="$OPTARG"
                ;;
            *)
                return 1
                ;;
        esac
    done
    # The first parameter is the return status of the script

    shift $(( OPTIND - 1 ))

    # All other arguments are error message
    echo "${@}" | tee -a "${error_file}" >&2

    [ "${return_status}" ] && exit "${return_status}"
}

separator=";"

# /dev/null is a "sink" file: every stream redirected to the latter is just destroyed. Using this allows us to redirect
# all the stream to these variables and just change the variable values when corresponding options are given.
error_file="/dev/null"
log_file="/dev/null"

while getopts ":hl:L:s:" args; do
    case ${args} in
        h)
            print_help
            exit 0
            ;;
        l)
            if [ "${OPTARG}" != "${OPTARG#-}" ]; then
                errecho -q 1 "Option l requires a valid argument, got ${OPTARG}"
            fi
            log_file="${OPTARG}"
            ;;
        L)
            if [ "${OPTARG}" != "${OPTARG#-}" ]; then
                errecho -q 1 "Option L requires a valid argument, got ${OPTARG}"
            fi
            error_file="$OPTARG"
            ;;
        s)
            if [ "${OPTARG}" != "${OPTARG#-}" ]; then
                errecho -q 1 "Option s requires a valid argument, got ${OPTARG}"
            fi
            separator="${OPTARG}"
            ;;
        ?)
            errecho -q 1 "Unknown option: -${OPTARG}"
            ;;
    esac
done

shift $(( OPTIND - 1 ))

header="
==============================================
Execution at $(date)
=============================================="

# Tee duplicates the standard input and redirects it on standard input and to all the files given as
# parameter
echo "$header" | tee -a "${log_file}" "${error_file}"

[ "$#" -ne "1" ] && errecho "Script takes file name as argument" && print_help && exit 2

[ ! -e "$1" ] && errecho -q 3 "${1} does not exists."
[ ! -f "$1" ] && errecho -q 3 "${1} is not a file."
[ ! -r "$1" ] && errecho -q 3 "${1} cannot be read, please correct the permissions."

non_matching_lines=$(grep -vEx "[a-z_]([a-z0-9_-]{0,31}|[a-z0-9_-]{0,30}\\\$)${separator}[^ ${separator}]+" "${1}")

if [ -n "${non_matching_lines}" ]; then
    errecho "The following lines do not respect the expected pattern:"
    errecho "${non_matching_lines}"

    print_help
    exit 3
fi

tmp_file=$(mktemp)
return_status=0

while read -r line; do
    user=${line%"${separator}"*}
    pass=${line#*"${separator}"}

    if id "${user}" &> /dev/null; then
        echo "User ${user} already exists. Skipping..."
    else
        echo "sudo useradd $user" >> "${log_file}" && \
        sudo useradd "$user" 2> "$tmp_file" && \
        echo "echo \"$user:$pass\" | sudo chpasswd" >> "${log_file}" && \
        echo "$user:$pass" | sudo chpasswd 2>> "$tmp_file"

        # if file is not empty then an error occured in the user creation
        if ! (wc -c "$tmp_file" | grep -qE "^0 "); then
            tee -a "${error_file}" < "${tmp_file}" >&2 

            # sudo or useradd error
            return_status=4
        fi

    fi
done < "${1}"

exit $return_status
