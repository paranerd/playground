#!/bin/bash

path="${PWD#.}";
level=0;

function print {
	local level=$2
	#printf "%s\n" "level: $level"

	while [ $level -gt 0 ]; do
		printf "%s" '    '
		let level=level-1
	done

	if [ $2 -ne -1 ]; then
		printf "|-- ";
	fi

	printf "%s\n" "$1"
}

function subdir {
	#printf "%s\n" "subdir called for $1 with level $2"
	all=($(ls $1))

	for i in "${all[@]}"
	do
		if [[ -d "$1/$i" ]]; then
			print $i $2

			newLevel=$(($2 + 1))
			subdir "$1/$i" $newLevel;
		else
			print $i $2
		fi
	done
}

print "${PWD##*/}" "-1"
subdir $path $level