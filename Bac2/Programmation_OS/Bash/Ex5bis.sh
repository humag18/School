#!/bin/bash


while getopts "m:M:u" option ; do
    case "${option}" in
        m) 
            declare uid_min=${OPTARG}
        ;;
        M)
            declare uid_max=${OPTARG}
        ;;
        u)
            declare uid_max=1000
        ;;
        *) 
            echo "Option invalide" >&2
            exit 1
        ;;
    esac
    
done

if [[ -z "$uid_min" ]]; then
    uid_min=0
fi
if [[ -z "$uid_max" ]]; then
    uid_max=65535
fi

declare file_name="./passwd.txt"
if ! [[ -f "$file_name" ]]; then
    echo "$file_name not find" >&2
    exit 1
fi

for ((i = "$uid_min"; i < "$uid_max"; i++)); do
   if ! grep -qE "x:${i}:" "$file_name"; then
       echo "Next UID $i"
       exit 0
   fi 
done
