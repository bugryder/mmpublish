#!/bin/bash
#
# GIT 分支间合并
#

if [ ! $# -eq 8 ] ; then
	echo "Usage: $0 gitSrcDir branch preVersion version branchto project projectName repo"
	exit 1
fi

self=$(readlink -f $0)
rtx_sh=$(dirname $self)/rtx.sh

gitSrcDir="$1"
branch="$2"
preVersion="$3"
version="$4"
branchto="$5"
project="$6"
projectName="$7"
repo="$8"

if [ ! -d "$gitSrcDir" ]; then
    echo "源码目录 $gitSrcDir 不存在"
    exit 2
fi

cd $gitSrcDir
git fetch --prune --tags >/dev/null 2>&1

#发版过程中, master 分支可能会有新的提交
#所以基于结束版本号创建一个临时分支
branchTemp=${branch}_$version
#创建前先删除
git branch -D $branchTemp 2>/dev/null 
git branch $branchTemp $version || exit $?

git checkout $branchto || exit $?
git pull || exit $?

tmpFile=$(mktemp)
git merge --no-ff $branchTemp -m "发布系统：Merge branch '$branch' into '$branchto'" >$tmpFile 2>&1

if [ $? -eq 0 ]; then
    isOk=1
    git push
else
    isOk=0
    git merge --abort

	#强制切会主分支
	git checkout -f master

	#合并失败则发RTX通知
	receivers='黄忠信 孙潇'
	merge_log_url='http://mgr.fxwork.kugou.net/merge/merge_log_read'
	date=$(date +"%Y-%m-%d %T")
	title='繁星分支合并通知'
	content="
$projectName
版本：$preVersion - $version
分支：$branch -> $branchto 合并失败
时间：$date
$merge_log_url
如有疑问，请联系网站研发组"
	/bin/bash $rtx_sh "$title" "$content" $receivers
fi

#删除临时分支
git branch -D $branchTemp

content="$(cat $tmpFile 2>/dev/null |sed 's#$#\r#g')"
rm $tmpFile

mgr_url="http://mgr.fxwork.kugou.net"
addtime=$(date +%s)
curl -d "ct=open&ac=merge_log&project=$project&name=$projectName&preVersion=$preVersion&version=$version&repo=$repo&branch=$branch&addTime=$addtime&branchto=$branchto&isOk=$isOk&content=$content" $mgr_url >/dev/null 2>&1

[ $isOk -eq 1 ] && exit 0 

exit 1

