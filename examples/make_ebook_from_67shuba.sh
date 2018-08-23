#!/bin/bash

usage()
{
	echo "$(basename $0) - 从67书吧下载网页内容并制作成PDF文档" >&2
	echo "用法：$(basename $0) <电子书目录页地址>" >&2
	echo "示例：$(basename $0) http://www.67shu.com/19/19505/" >&2
}

if [ $# -lt 1 ]; then
	usage
	exit 1
elif [[ "$1" == "-h" || "" == "--help" ]]; then
	usage
	exit 0
else
	INDEX_URL="$1"
fi

RESULT_DIR=$(dirname $0)/$(basename "$INDEX_URL")

mkdir -p $RESULT_DIR/cache $RESULT_DIR/cache_utf8

[ -f $RESULT_DIR/index.html ] || curl $INDEX_URL/ > $RESULT_DIR/index.html

[ `ls $RESULT_DIR/cache/ | wc -l` -gt 0 ] || iconv -c -f gbk -t utf8 $RESULT_DIR/index.html \
	| sed "/<dd>/s//\n<dd>/g" \
	| grep "<dd>" \
	| grep -v "<dd><\/dd>" \
	| awk -F \" '{ print $2 }' \
	| while read i
	do
		[ `echo $i | grep -c "http"` -gt 0 ] || i="$INDEX_URL/$i"
		echo "正在下载 $i ..."
		curl $i > $RESULT_DIR/cache/$(basename $i)
		new_i=$(printf "%016d.html" $(echo "$(basename $i)" | sed "/\.html$/s///"))
		echo "重命名：$(basename $i) -> $new_i"
		mv "$RESULT_DIR/cache/$(basename $i)" "$RESULT_DIR/cache/$new_i"
	done

[ `ls $RESULT_DIR/cache_utf8/ | wc -l` -gt 0 ] || for i in $RESULT_DIR/cache/*
do
	echo "正在将网页的字符编码转成UTF-8格式以备后用：$i ..."
	iconv -c -f gbk -t utf8 $i \
		| sed "/charset=gbk/s//charset=utf-8/g" \
		> $RESULT_DIR/cache_utf8/$(basename $i)
done

for i in $RESULT_DIR/cache/*.html
do
	[ ! -f "${i}.pdf" ] || continue
	echo "正在将 $i 转换成PDF格式……"
	wkhtmltopdf --outline --no-images --disable-javascript --disable-local-file-access --disable-plugins --minimum-font-size 30 --lowquality "$i" "$i".pdf
done

book_name=$(iconv -c -f gbk -t utf8 $RESULT_DIR/index.html | grep -a book_name | sed "/.*content=\"\(.*\)\".*/s//\1/g")
[ -n "$book_name" ] || book_name=$(iconv -c -f gbk -t utf8 $RESULT_DIR/index.html | grep -a "<title>" | sed "/<\/\{0,1\}title>/s///g")
[ -n "$book_name" ] || book_name=$(basename "$INDEX_URL")
echo "准备生成的文档名：$book_name"

pdftk $RESULT_DIR/cache/*.pdf output "$RESULT_DIR/${book_name}.pdf" && echo "PDF文档生成完毕：$RESULT_DIR/${book_name}.pdf"

