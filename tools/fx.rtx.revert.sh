#!/bin/bash
#
# 发送 RTX 提醒
#

if [ $# -lt 6 ] ; then
	echo "Usage: $0 lastVer endVer project projectName projectUrl receivers";
	exit 1
fi

self=$(readlink -f $0)
rtx_sh=$(dirname $self)/rtx.sh

lastVer="$1"
endVer="$2"
project="$3"
projectName="$4"
projectUrl="$5"
echo "$projectUrl" |grep -q '^http://' || projectUrl="http://$projectUrl"
shift;shift;shift;shift;shift
receivers=$@

#
date=$(date +"%Y-%m-%d %T")
title='繁星代码回退'
content="
$projectName
域名：$projectUrl
时间：$date
版本：$lastVer -> $endVer
如有疑问，请联系网站测试组"

/bin/bash $rtx_sh "$title" "$content" $receivers

exit 0
