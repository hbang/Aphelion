#!/bin/bash
if [[ "`whoami`" == "kirb" || "`hostname`" == "kirbpad" ]]; then
	user="Adam D"
else
	user="`whoami`"
fi

write_shit() {
	(
		echo //
		echo //'  '"$1"
		echo //'  'Aphelion
		echo //
		echo //'  'Created by "$user" on `date +%d/%m/%y`.
		echo //'  'Copyright \(c\) `date +%Y` HASHBANG Productions. All rights reserved.
		echo //
		echo
	) >> "`dirname "$0"`/Aphelion/$1"
}

if [[ "$1" == "" ]]; then
	echo "Usage: `basename "$0"` classname"
	exit 1
fi

write_shit "$1".h
write_shit "$1".m
