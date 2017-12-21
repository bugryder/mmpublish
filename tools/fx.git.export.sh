#!/bin/bash
#
# GIT 导出文件
#

if [ $# -lt 6 ]; then
    echo "Usage: $0 gitSrcDir repoHost repoBranch beginVer endVer toPath subDir"
	exit 1
fi

gitSrcDir=$1
repoHost=$2
repoBranch=$3
beginVer=$4
endVer=$5
toPath=$6
[ -d "$toPath" ] || mkdir -p $toPath
subDir=$7

if [ ! -d "$gitSrcDir" ]; then
	echo "项目源码目录不存在, 拉取 $repoHost"
	git clone $repoHost $gitSrcDir || exit $?
fi

cd $gitSrcDir
git fetch --prune --tags >/dev/null 2>&1
git checkout $repoBranch || exit $?
git pull || exit $?

tmpFile=$(mktemp)

#不对中文进行quote 
git config core.quotepath false

if [ "x$beginVer" == "x0" ]; then
    echo "全量导出 $endVer，请等待"
    git archive --format=tar.gz $endVer -o $tmpFile
else
    echo "差异导出 $beginVer ~ $endVer，请等待"
    #git archive $endVer $(git diff --name-only -b $beginVer $endVer) |gzip >$tmpFile
    lines=$(git diff --name-status -b $beginVer $endVer |grep -v ^D |grep -v Upgrade/ |grep -v TestCase/ |wc -l) 
    if [ $lines -eq 0 ]; then
        echo "出错了，版本区间 $beginVer $endVer 没有任何差异文件！打错标签了？"
        exit 1
    fi    
    git archive --format=tar.gz $endVer $(git diff --name-status -b $beginVer $endVer |grep -v ^D |grep -v Upgrade/ |grep -v TestCase/ |awk '{print $2}') -o $tmpFile
fi

tar -xzf $tmpFile -C $toPath $subDir >/dev/null 2>&1

if ! ls $toPath/* >/dev/null 2>&1; then
	echo '出错了，没导出任何文件，请检查导出命令！'
	exit 1
fi

if [ "$(echo $endVer |tr '[a-z]' '[A-Z]')" = 'HEAD' ]; then
	endVer='head'.$(date +"%Y%m%d%H%M")
fi

echo $endVer >$toPath/$subDir/version.txt
rm $tmpFile

exit 0
