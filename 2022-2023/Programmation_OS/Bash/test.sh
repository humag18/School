#!/bin/bash

# Récupération de la liste des UID de la machine
uids=($(cut -d: -f3 /etc/passwd))

# Boucle pour parcourir la liste des UID
i=1
echo $#
while [[ $i -le $# ]]; do
    for uid in ${uids[@]}
    do
    # Vérification si l'UID correspond au paramètre
        if [[ $uid -eq $1 ]]; then
            echo "L'UID ${!i} est présent sur la machine"
        else
            echo "L'UID ${!i} n'est pas présent sur la machine"
        fi
    done

    i=$((i+1))
done
