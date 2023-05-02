#!/bin/bash

declare uids=$(cut -d: -f3 passwd)
echo "$uids" | tr " " "/n" | sort -n | awk 'BEGIN { prev=0 } { if (prev == 0) { prev=$1 } else { if ($1-prev > 1) { for (i=prev+1;i<$1;i++) { print i } } prev=$1 } }' > test.txt


