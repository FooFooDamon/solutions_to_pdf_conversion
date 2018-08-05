#!/bin/bash

INDEX_URL=http://www.67shu.com/63/63663

mkdir -p zhenxiebiji zhenxiebiji_utf8

[ -f zhenxiebiji_index.html ] || curl $INDEX_URL/ > zhenxiebiji_index.html

[ `ls zhenxiebiji/ | wc -l` -gt 0 ] || iconv -c -f gbk -t utf8 zhenxiebiji_index.html \
	| sed "/<dd>/s//\n<dd>/g" \
	| grep "<dd>" \
	| grep -v "<dd><\/dd>" \
	| awk -F \" '{ print $2 }' \
	| while read i
	do
		[ `echo $i | grep -c "http"` -gt 0 ] || i="$INDEX_URL/$i"
		echo "Downloading $i ..."
		curl $i > zhenxiebiji/$(basename $i)
	done

[ `ls zhenxiebiji_utf8/ | wc -l` -gt 0 ] || for i in zhenxiebiji/*
do
	iconv -c -f gbk -t utf8 $i \
		| sed "/charset=gbk/s//charset=utf-8/g" \
		> zhenxiebiji_utf8/$(basename $i)
done

for i in zhenxiebiji/*
do
	wkhtmltopdf --no-images --disable-javascript --disable-local-file-access --disable-plugins --minimum-font-size 40 "$i" "$i".pdf
	echo "$i pdf conversion finished"
done

pdftk zhenxiebiji/*.pdf output zhenxiebiji.pdf

