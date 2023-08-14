#!/bin/bash

# This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

# You should have received a copy of the GNU General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.

# Default values for parameters
min_uid=0
max_uid=65535
nb_id=1
consecutive=0
passwd_file="./passwd"

help_message="SYNOPSIS

${0##*/} [-h] [-c] [-f passwd_file] [-m min_id] [-M max_id] [-u] [-n nb]

DESCRIPTION

Look for available ids.

-h: print this help and exit
-c: if used with -n, force consecutive ids
-f password_file: define passwd_file to use. Default to ./passwd
-m min_id: set the minimum id that can be returned. Default to 0
-M max_id: set the maximum id that can be returned. Default to 65535
-u: force regular user id (same as -m 1000). If both -u and -m are given, keeps the highest value
-n nb_id: the number of ids to return"



while getopts "chf:m:M:n:u" args; do
    case ${args} in
        c)
            # Option -c
            consecutive=1
            ;;
        h)
            # Option -h
            echo "$help_message"
            exit 0
            ;;
        f)
            # Option -f
            if [ "${OPTARG}" != "${OPTARG#-}" ]; then
                echo "Option f requires a valid argument, got ${OPTARG}" >&2
                exit 10
            fi
            passwd_file="$OPTARG"
            ;;
        m)
            # Option -m
            if [ "${OPTARG}" != "${OPTARG#-}" ]; then
                echo "Option m requires a valid argument, got ${OPTARG}" >&2
                exit 10
            fi

            # Ensure that given parameter is a number
            if ! [ "$OPTARG" -eq "$OPTARG" ] 2> /dev/null; then
                echo "$OPTARG is not a number" >&2
                return 1
            fi

            [ "$OPTARG" -gt "$min_uid" ] && min_uid="$OPTARG"
            ;;
        M)
            # Option -M
            if [ "${OPTARG}" != "${OPTARG#-}" ]; then
                echo "Option M requires a valid argument, got ${OPTARG}" >&2
                exit 10
            fi

            # Ensure that given parameter is a number
            if ! [ "$OPTARG" -eq "$OPTARG" ] 2> /dev/null; then
                echo "$OPTARG is not a number" >&2
                return 1
            fi

            [ "$OPTARG" -le "$min_uid" ] && echo "max_uid should be larger than min_uid" >&2 && exit 5
            [ "$OPTARG" -lt "$max_uid" ] && max_uid="$OPTARG"
            ;;
        n)
            # Option -n
            if [ "${OPTARG}" != "${OPTARG#-}" ]; then
                echo "Option n requires a valid argument, got ${OPTARG}" >&2
                exit 10
            fi

            # Ensure that given parameter is a number
            if ! [ "$OPTARG" -eq "$OPTARG" ] 2> /dev/null; then
                echo "$OPTARG is not a number" >&2
                return 1
            fi

            nb_id="$OPTARG"
            ;;
        u)
            # Option -u
            [ "$min_uid" -lt "1000" ] && min_uid=1000
            ;;
        *)
            echo "Unknown option given" >&2
            exit 3
    esac
done

if [ ! -e "${passwd_file}" ]; then
    echo "Unexisting file: ${passwd_file}"
    exit 3
fi

if [ ! -r "${passwd_file}" ]; then
    echo "You do not have read acccess to file: ${passwd_file}"
    exit 4
fi

if [ "$min_uid" -ge "$max_uid" ]; then
    echo "min_uid should be smaller than max_uid" >&2 
    exit 5
fi

counter=$min_uid

# No need to go to max_uid when the number of different ids is greater than 1
loop_stop=$(( max_uid - nb_id + 1 ))

# At each iteration, the counter increases and if a new uid is found, the nb_id remaining is decreasing. If all uids
# have been found (or if the counter reached the max) we can stop.
while [ "$counter" -lt "$loop_stop" ] && [ "$nb_id" -gt "0" ]; do 
    # Test if the uid is available
    if ! grep -qE "x:${counter}:" "${passwd_file}"; then
        # A free slot has been found. If user asked for a consecutive set of uid we need to explore further before
        # printing.
        if [ "$consecutive" -eq "1" ]; then
            # Look for consecutive id
            
            # We create a new counter that will keep track of number of free consecutive uids
            look_id=1

            # Test if uid is available and if we still have to find free slots (look_id < nb_id)
            while ! grep -qE "x:$(( counter + look_id )):" "${passwd_file}" && [ $look_id -lt "$nb_id" ]; do
                # Add a free slot to the counter of free slot
                (( look_id++ ))
            done

            # If we have enough free slot...
            if [ "$look_id" -eq "$nb_id" ]; then
                # ... we print all of them ...
                for i in $(seq "$counter" $(( counter + nb_id - 1 ))); do
                    echo "Next uid: $i"
                done
                # ... and set the remaining uid to find to 0 to terminate the first loop
                nb_id=0
            else
                # If not, we know that the current slots of free uids is not sufficient. No need to parse them. We
                # jump to the uid following the one which is not free.
                (( counter += look_id ))
            fi
        else
            # If we do not need consecutive ids, we can print the one we found and decrease the remaining uid to find
            echo "Next uid: ${counter}"
            (( nb_id-- ))
        fi
    fi
    (( counter++ ))
done

if [ "$nb_id" -gt "0" ]; then
    echo "Not enough uid available... Please increase the search rate" >&2
    exit 4
fi
