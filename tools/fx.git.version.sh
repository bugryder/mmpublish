#!/bin/bash
#
# GIT 查找最大版本号（tag）
#

if [ $# -lt 3 ] ; then
	echo "Usage: $0 gitSrcDir repoHost repoBranch resultFile versionOrderFile"
	exit 1
fi

self=$(readlink -f $0)
orderTool=$(dirname $self)/version_order.py

gitSrcDir=$1
repoHost=$2
repoBranch=$3
resultFile=$4
versionOrderFile=$5

if [ ! -d "$gitSrcDir" ]; then
	echo "项目源码目录不存在, 拉取 $repoHost"
	git clone $repoHost $gitSrcDir || exit $?
fi

cd $gitSrcDir
echo "更新代码.."

#先删掉所有tag
git tag -d $(git tag) >/dev/null 2>&1
git fetch --prune --tags >/dev/null 2>&1
git checkout $repoBranch >/dev/null || exit $?
git pull >/dev/null || exit $?

#
#各种情况下的 tag 列表
project=$(basename $gitSrcDir)
case "$project" in
	*forrel*)
		tags=$(git tag -l |grep 'rel_' |xargs) ;;
	*-gray1*)
		tags=$(git tag -l |grep 'gray1_' |xargs) ;;
	*-gray*)
		tags=$(git tag -l |grep 'gray_' |xargs) ;;
	*)
		tags=$(git tag -l |grep -v [a-zA-Z] |xargs)
esac

echo "疯狂计算中.."
$orderTool 'asc' $tags >$versionOrderFile
tail -n1 $versionOrderFile >$resultFile

exit 0
