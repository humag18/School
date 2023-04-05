#!/bin/bash

declare uid_list=$(cut -d: -f3 /etc/passwd)
echo $uid_list
declare i=1
while [[ $i -le $# ]]; 
do
    for id in "${uid_list[@]}"
    do  
        if [[ ${!i}==$id ]]; 
        then

            echo "Votre paramètre ${!i} est présent dans dans la liste des UID"
        else
            echo "Votre paramètre ${!i} n'est pas présent dans la liste des UID"
        fi
    done
    i=$((i+1))
done
