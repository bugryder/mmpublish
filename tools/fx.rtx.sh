#!/bin/bash
#
# 发送 RTX 提醒
#

if [ $# -lt 6 ] ; then
	echo "Usage: $0 beginVer endVer project projectName projectUrl receivers";
	exit 1
fi

self=$(readlink -f $0)
rtx_sh=$(dirname $self)/rtx.sh

beginVer="$1"
endVer="$2"
project="$3"
projectName="$4"
projectUrl="$5"
echo "$projectUrl" |grep -q '^http://' || projectUrl="http://$projectUrl"
echo $projectName |grep -q '发布' || projectName="$4 已发布"
shift;shift;shift;shift;shift
receivers=$@

# 获得发版记录ID
tmpFile=$(mktemp)
wget -q -O $tmpFile "http://mgr.fxwork.kugou.net/?ct=open&ac=publish_id&project=$project&preVersion=$beginVer&version=$endVer"
publish_id=$(cat $tmpFile 2>/dev/null)
if [ "x$publish_id" != 'x' ] && [ "$publish_id" != '-1' ]; then
    publish_url="详情：http://mgr.fxwork.kugou.net/publish/$publish_id"
fi

#
date=$(date +"%Y-%m-%d %T")
title='繁星发版通知'
content="
$projectName
域名：$projectUrl
版本：$beginVer - $endVer
时间：$date
$publish_url
如有疑问，请联系网站测试组"

/bin/bash $rtx_sh "$title" "$content" $receivers

exit 0
