#!/bin/bash
for a in {1..9}
do
    d=${a}**3
	for b in {0..9}
	do
    e=${b}**3
		for c in {0..9}
		do
        f=${c}**3
        sum=$[$d+$e+$f]
        if
        [ $a$b$c -eq $sum ];then
        echo "shuixianhua: $sum"
        fi
done
	done
		done
