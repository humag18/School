#!/bin/bash
declare file_name=./passwd.txt
if ! [[ -f "$file_name" ]]; then
    echo "$file_name doesn't exist !"
    exit 1
fi
# recherche grace au grep du prochain UID disponible
for ((i = 1000; i < 65535; i++)); do 
    if grep -qE "x:${i}:" "$file_name"; then
        echo "Next user acount ${i}"
    fi
done
exit 0

