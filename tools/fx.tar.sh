#!/bin/bash
#
# 压缩导出目录
#

if [ $# -lt 2 ] ; then
	echo " e.g.: $0 path toFile subDir otherParams"
	exit 1
fi

path=$1
toFile=$2
subDir=$3

cd $path
shift
shift

if [ "x$subDir" != 'x' ]; then
	cd $subDir
	shift
fi

tar -czf $toFile * $* >/dev/null 2>&1

if [ ! -f $toFile ]; then
    echo "$toFile 不存在，压缩出错"
    exit 1
fi

files=$(tar tf $toFile |grep -v 'version.txt' |grep -v '/'$)
if [ "x$files" == 'x' ]; then
    echo "$toFile 文件为空，导出文件全被忽略了？"
    exit 1
fi

exit 0

