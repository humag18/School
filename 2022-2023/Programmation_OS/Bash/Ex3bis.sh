#!/bin/bash

echo "Le nombre de variable passé en paramètres est : $#"

declare i=1
declare k=1
declare parametres=()
while [[ $i -le $# ]]; do
    parametres+=(${!i})
    echo "paramètre n°$i : ${!i} "
    ((i++))
done
i=1
declare rec=0

#while [[ $parametre ]]; do
    
#done
for parametre in "${parametres[@]}"
do
    echo $parametre
    rec=0
    for recurence in "${parametres[@]}"
    do 
        if [[ $recurence == $parametre ]]; then
            ((rec++))
            echo $parametre $recurence $rec
        fi
    done
    echo "Le parametre $parametre a une récurence de $rec"
done

