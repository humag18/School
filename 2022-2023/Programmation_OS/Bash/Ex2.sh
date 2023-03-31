#! /usr/bin/env bash

declare interne="Programmation"
echo $interne

if[[ -n "$publique" ]]; then
    if [[ -z "$publique" ]];then
        echo "empty variable" >&2
    else
        echo $publique
    
    fi
        echo $interne$publique

        interne="Programmation des systèmes" 
        publique="1000\$ de bash svp"
        echo $interne$publique
else
    echo "La variable n'existe pas!" >&2
fi

