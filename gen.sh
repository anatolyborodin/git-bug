#!/bin/sh

L=`seq 101 120`

for x in ${L}; do
	for y in ${L}; do
		echo $x $y
		for z in ${L}; do
			mkdir -p bb/$x/$y && dd if=/dev/urandom of=bb/${x}/${y}/${z}.dat bs=1K count=5 2> /dev/null
		done
	done
done
