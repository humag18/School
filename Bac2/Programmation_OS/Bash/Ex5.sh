#!/bin/bash

# Vérification de la présence de paramètre
if [[ "$#" -ne 0 ]]; then
    exit 1
fi 

declare file_name="./passwd.txt"
# Vérification de l'existance du fichier en question
if ! [[ -f "$file_name" ]]; then
    echo "$file_name doesn't exist !"
    exit 1
fi 
# recherche grace au grep du prochain UID disponible
for ((i = 0; i < 65535; i++)); do 
    if ! grep -qE "x:${i}:" "$file_name"; then
        echo "Next UID ${i}"
        exit 0
    fi
done
