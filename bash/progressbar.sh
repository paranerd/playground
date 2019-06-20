#!/bin/bash
n=0
m=100

while [ $n -le 100 ]
do
	echo -n "|"
	i=0
	while [ $i -le $n ]
	do
		if [ $i == $n ]
		then
			echo -n ">"
		else
		echo -n "="
		fi
		i=$(($i+1))
	done
	while [ $m -ge $n ]
	do
		echo -n "-"
		m=$(($m-1))
	done
	sleep 0.25s
	n=$(($n+1))
	echo -n "|"
	echo "$(tput cuu1)"
done

echo ""
