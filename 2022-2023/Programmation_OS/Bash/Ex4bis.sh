#!/bin/bash

declare uids=$(cut -d: -f3 passwd)

for ((i = 0; i < 1000; i++)); do
    
    if echo "$uids" | grep -q "$i"; then
        echo "$i"
        
    fi
done


