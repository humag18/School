#!/bin/bash

if [[ "$#" -ne 1 ]]; then
    exit 1
fi
for i in {0..65535}; do 
    if ! grep -qE "x:${i}:" "$1"; then
        echo "Next uid ${i}"
        exit 0
    fi
done

