#!/bin/bash

INDEX_URL=http://www.67shu.com/63/63663
RESULT_DIR=$(dirname $0)/$(basename $0 .sh)

mkdir -p $RESULT_DIR/zhenxiebiji $RESULT_DIR/zhenxiebiji_utf8

[ -f $RESULT_DIR/zhenxiebiji_index.html ] || curl $INDEX_URL/ > $RESULT_DIR/zhenxiebiji_index.html

[ `ls $RESULT_DIR/zhenxiebiji/ | wc -l` -gt 0 ] || iconv -c -f gbk -t utf8 $RESULT_DIR/zhenxiebiji_index.html \
	| sed "/<dd>/s//\n<dd>/g" \
	| grep "<dd>" \
	| grep -v "<dd><\/dd>" \
	| awk -F \" '{ print $2 }' \
	| while read i
	do
		[ `echo $i | grep -c "http"` -gt 0 ] || i="$INDEX_URL/$i"
		echo "Downloading $i ..."
		curl $i > $RESULT_DIR/zhenxiebiji/$(basename $i)
	done

[ `ls $RESULT_DIR/zhenxiebiji_utf8/ | wc -l` -gt 0 ] || for i in $RESULT_DIR/zhenxiebiji/*
do
	iconv -c -f gbk -t utf8 $i \
		| sed "/charset=gbk/s//charset=utf-8/g" \
		> $RESULT_DIR/zhenxiebiji_utf8/$(basename $i)
done

for i in $RESULT_DIR/zhenxiebiji/*
do
	wkhtmltopdf --no-images --disable-javascript --disable-local-file-access --disable-plugins --minimum-font-size 30 --lowquality "$i" "$i".pdf
	echo "$i pdf conversion finished"
done

pdftk $RESULT_DIR/zhenxiebiji/*.pdf output $RESULT_DIR/zhenxiebiji.pdf

