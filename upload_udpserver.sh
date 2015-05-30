#!/bin/bash

LUATOOL='python ../../programmer/luatool.py --port /dev/ttyUSB0'
$LUATOOL -w

cd source/udp_server
for i in $( ls *.lua -I init.lua ); do
	$LUATOOL --src $i -c

	if [ $? -ne 0 ]
	then
		break
	fi
done

if [ $? = 0 ]
then
	$LUATOOL --src init.lua
fi

if [ $? = 0 ]
then
	for i in $( ls *.html ); do
		$LUATOOL --src $i

		if [ $? -ne 0 ]
		then
			break
		fi
	done
fi

if [ $? = 0 ]
then
	echo "uploaded everything successful"
fi