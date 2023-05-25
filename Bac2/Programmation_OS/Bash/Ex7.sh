#!/bin/bash
while getopts "hs:" option; do
    case "$option" in
        h) echo "-s <specialchar>: change le séparateur par défaut"
            exit 0
        ;;
        s) IFS=${OPTARG}
        ;;
        *) echo default
        ;;
    esac
    
done
data=`sed -n "1p" ./usrad.txt`

if [[ -z "$IFS" ]]; then
    IFS=";"    
fi 

read -a strarr <<< "$data"

declare username=${strarr[0]}
declare passwd=${strarr[1]}
useradd -m -p "$passwd" "$username"

