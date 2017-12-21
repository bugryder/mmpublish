#!/bin/bash
#
# npm 安装
#

if [ $# -lt 4 ]; then
    echo "Usage: $0 projectSrcDir repoBranch beginVer endVer"
	exit 1
fi

projectSrcDir=$1
repoBranch=$2
beginVer=$3
endVer=$4

cd $projectSrcDir || exit $?
git fetch --prune --tags >/dev/null 2>&1
git checkout $endVer || exit $?

#开始执行fis编译
[ -f "package.json" ] || exit 0

echo
echo "执行 npm 安装依赖库，分支：$repoBranch 配置文件，版本号：$endVer"
time npm install --registry="http://10.16.4.113:4873" || exit 1

exit 0

