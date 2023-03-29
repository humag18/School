#!/bin/bash

echo "Le nombre de variable passé en paramètres est : $#"

declare i = 1

while [[ $i -le $# ]]; do
    echo "paramètre n°$i : $"
    
done
