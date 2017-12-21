#!/bin/bash
#
# GIT 收集 commit log 日志
#

if [ ! $# -eq 5 ] ; then
	echo "Usage: $0 gitSrcDir repoBranch beginVer endVer reportFile"
	exit 1
fi

gitSrcDir="$1"
repoBranch="$2"
beginVer="$3"
endVer="$4"
reportFile="$5"

if [ ! -d "$gitSrcDir" ]; then
    echo "源码目录 $gitSrcDir 不存在"
    exit 2
fi

echo >$reportFile
echo "版本区间 $beginVer ~ $endVer" >>$reportFile
echo "更新日志如下：" >>$reportFile
echo >>$reportFile

cd $gitSrcDir
git fetch --prune --tags >/dev/null 2>&1
git checkout $repoBranch || exit $?
git pull || exit $?

if [ "x$beginVer" == "x0" ]; then
    git log --pretty=oneline --abbrev-commit $endVer >>$reportFile || exit $?
else
    git log --pretty=oneline --abbrev-commit $beginVer...$endVer >>$reportFile || exit $?
fi

exit 0
