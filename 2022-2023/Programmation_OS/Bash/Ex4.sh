#!/bin/bash

declare uid_list=$(cut -d: -f3 /etc/passwd)

for id in "${uid_list[@]}"
do  
    if [[ $1==$id ]]; 
    then
        echo "Votre paramètre $1 est présent dans dans la liste des UID"
    fi
done
