#!/bin/bash

input=$1
output=$2

h=$(head -n 1 $input | cut -f 2-); h2=$(echo -e "#FID\tID"); echo -e $h2"\t"$h | tr ' ' '\t' > $output
tail -n +2 $input | sed 's/Yes/1/g' | sed 's/No/0/g' | sed 's/NA/-9/g' | awk -v OFS='\t' '{print $1,$0}' >> $output
