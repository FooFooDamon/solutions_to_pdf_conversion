#!/bin/bash

if [ ! -f "$1" ]; then
	echo "${1}: Not a file, or does not exist" >&2
	exit 1
elif [ $(file -b "$1" | grep -c "\<text\>") -eq 0 ]; then
	echo "${1}: Not a text file" >&2
	exit 1
else
	unoconv -f pdf "$1" && echo "${1}: Converted to PDF."
fi

