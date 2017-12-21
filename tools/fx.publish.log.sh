#!/bin/bash
#
# 发版纪录
#

if [ $# -lt 12 ] ; then
	echo "Usage: $0 project url name preVersion version repo branch contentFile servers isTimer timerServers fileListFile"  
	exit 1
fi

project=$1
url=$2
name=$3
preVersion=$4
version=$5
repo=$6
branch=$7
contentFile=$8
servers=$9
shift
isTimer=$9
shift
timerServers=$9
shift
fileListFile=$9

addTime=$(date +%s)
mgr_url="http://mgr.fxwork.kugou.net"

#发布内容
content=''
[ -f "$contentFile" ] && content="$(cat $contentFile 2>/dev/null |sed 's#$#\r#g')"

#文件列表
#行数过长的时候，curl 会提示参数过长
#所以采用表单上传文件方式
[ -f "$fileListFile" ] && sed -i 's#$#\r#g' "$fileListFile" || fileListFile=$(mktemp)

echo "发送发版日志到：${mgr_url}"
#curl -d "ct=open&ac=publish_log&project=$project&url=$url&name=$name&preVersion=$preVersion&version=$version&repo=$repo&branch=$branch&addTime=$addTime&content=$content&servers=$servers&isTimer=$isTimer&timerServers=$timerServers&filelist=$filelist" \
#$mgr_url >/dev/null 2>&1

curl -F "project=$project" \
     -F "url=$url" \
	 -F "name=$name" \
     -F "preVersion=$preVersion" \
	 -F "version=$version" \
     -F "repo=$repo" \
	 -F "branch=$branch"  \
     -F "addTime=$addTime" \
     -F "content=$content" \
     -F "servers=$servers" \
	 -F "isTimer=$isTimer" \
     -F "timerServers=$timerServers" \
	 -F "file=@$fileListFile"  \
	 "$mgr_url/?ct=open&ac=publish_log"

exit 0
