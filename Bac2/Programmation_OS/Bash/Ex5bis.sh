#!/bin/bash


while getopts "m:M:uhn:" option ; do
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
        h)
            echo "Voici les différentes options possible lors de l'exécution de ce programme: 
            -m <nbr>: établit un uid minimum 
            -M <nbr>: établit un uid maximum 
            -u: ne peut afficher que les uid pour utilisateur normaux
            -n <nb_id>: permet d'afficher <nb_id> de uids"
            exit 0
        ;;
        n)
            declare nb_id=${OPTARG}
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
if [[ -z "$nb_id" ]]; then
    nb_id=1
fi

declare file_name="./passwd.txt"
if ! [[ -f "$file_name" ]]; then
    echo "$file_name not find" >&2
    exit 1
fi

for ((i = "$uid_min"; i < "$uid_max"; i++)); do
   for ((i = 0; i < "$nb_id"; i++)); do 
        if ! grep -qE "x:${i}:" "$file_name"; then
            echo "Next UID $i"
        fi 
    done
done
