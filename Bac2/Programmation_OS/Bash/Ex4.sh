#!/bin/bash

if [[ $# -lt 1 ]]; then
    echo "Entrez des paramètres" 1>&2
    exit 1
fi
for ((i = 1; i < $#+1; i++)); do
    if [[ ${!i} -le 1000 ]]; then
        echo "${!i} est un UID valable"
    else
        echo "${!i} n'est pas un UID valable"
    fi 
        
done 
