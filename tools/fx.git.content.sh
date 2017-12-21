#!/bin/bash
#
# GIT 收集多版本内容
#

if [ ! $# -eq 5 ] ; then
	echo "Usage: $0 contentDir beginVer endVer versionOrderFile resultFile"
	exit 1
fi

contentDir="$1"
beginVer="$2"
endVer="$3"
versionOrderFile="$4"
resultFile="$5"
>$resultFile

#全量发布时不执行操作
if [ "$beginVer" = '0' ] && [ "$endVer" = 'HEAD' ]; then
	exit 0
fi

if [ ! -d "$contentDir" ]; then
    echo "发版内容目录 $contentDir 不存在"
    exit 2
fi

#tag 列表
#
tags=$(cat $versionOrderFile |xargs)

#endVer 是 HEAD 时, 判断为最大 tag
if [ "$endVer" = 'HEAD' ]; then
	tags="$tags $endVer"
fi
tags=($tags)


#
#数组长度 ${#a[@]}
#数组切片 ${a[@]:0:2}
#整个数组 ${a[@]}
#
if [ ${#tags[@]} -eq 1 ]; then
	beginKey=0
	endKey=0
else
	key=0
	for tag in ${tags[@]}; do
		[ "x$tag" == "x$beginVer" ] && beginKey=$key
		[ "x$tag" == "x$endVer" ] && endKey=$key
		let key=$key+1
	done
fi

if [ "x$beginKey" != 'x' ] && [ "x$endKey" != 'x' ]; then
	let offset=$endKey-$beginKey+1
    subTags=(${tags[@]:$beginKey:$offset})
    let start=${#subTags[@]}-1
    for ((i=$start; i>=0; i--)); do
        tag=${subTags[$i]}
        [ "x$tag" == "x$beginVer" ] && continue #不收集开始版本号日志
        contentFile="$contentDir/$tag/content.txt"
        if [ -f "$contentFile" ]; then
            if [ "x$(cat $contentFile)" != 'x' ]; then
                grep -q "${tag} --" $contentFile || echo "${tag} --" >>$resultFile
                cat $contentFile >>$resultFile
                echo -e "-------------------------------------------\n" >>$resultFile
            fi
        fi 
    done
fi

exit 0
