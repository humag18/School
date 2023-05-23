#!/bin/bash


while getopts "m:M:uhn:c" option ; do
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
        c)
            declare seq=true 
        ;;
        *) 
            echo "Option invalide" >&2
            exit 1
        ;;
    esac
    
done
if [[ -z "$seq" ]]; then
    declare seq=false
fi
if [[ -z "$uid_min" ]]; then
    declare uid_min=0
fi
if [[ -z "$uid_max" ]]; then
    declare uid_max=65535
fi
if [[ -z "$nb_id" ]]; then
    declare nb_id=1
    declare seq=false
fi

declare file_name="./passwd.txt"
if ! [[ -f "$file_name" ]]; then
    echo "$file_name not find" >&2
    exit 1
fi
declare used_uids
declare previous_uid=0
for ((i = "$uid_min"; i < "$uid_max"; i++)); do
    if ! grep -qE "x:${i}:" "$file_name"; then
        if [[ $seq ]]; then            
            if [[ "$used_uids" -ne 0 ]]; then
                declare second=true
            fi
            if [[ $second ]]; then
                if [[ "$i" -ne "$previous_uid" ]]; then
                    exit 0
                fi
                
            fi
        fi 
        echo "Next UID $i"
        used_uids=$((used_uids+1))
        previous_uid=$((i+1))
        if [[ "$used_uids" -ge "$nb_id" ]]; then
            exit 0
        fi     

    fi 
done
