#!/bin/bash
#
# 处理fis相关
#

if [ $# -lt 7 ]; then
    echo "Usage: $0 projectSrcDir projectSrcDirForFis devExportDir repoBranch beginVer endVer fisDir fisConf pubType"
	exit 1
fi

projectSrcDir=$1
projectSrcDirForFis=$2
devExportDir=$3
repoBranch=$4
beginVer=$5
endVer=$6
fisDir=$7
fisConf=$8
pubType=$9

#是否安装fis
fisbin=''
which fis3 >/dev/null 2>&1 && fisbin=$(which fis3)
[ -e '/usr/local/node/bin/fis3' ] && fisbin='/usr/local/node/bin/fis3'
if [ "x$fisbin" = 'x' ]; then
	echo "出错了！没有安装 fis3"
	exit 1
fi

retCode=0

#从源码目录创建fis编译需要的目录
if [ ! -d "$projectSrcDirForFis" ]; then
	cd $projectSrcDir || exit $?
	git fetch --prune --tags >/dev/null 2>&1
	git checkout $endVer || exit $?
	rsync -aq $projectSrcDir/ $projectSrcDirForFis/ --exclude=$fisDir/ --exclude=.git/
fi

#同步导出文件
rsync -aq $devExportDir/ $projectSrcDirForFis/

cd $projectSrcDirForFis || exit $?

#开始执行fis编译
[ -f "$fisConf" ] || exit $retCode

#搜集url
echo '__RESOURCE_MAP__' >map.json

echo
echo "执行 Fis3 编译，分支：$repoBranch 配置文件：$fisConf"
#time $fisbin release -f $fisConf -ompDd ./ >/dev/null || exit $?
if [ "$(echo $endVer |tr '[a-z]' '[A-Z]')" = 'HEAD' ]; then
	endVer='head'.$(date +"%Y%m%d%H%M")
fi
time $fisbin release -d ./ ${pubType}_$endVer || exit $?

#单独处理 static/html/404.html
html404='static/html/404.html'
if [ -f "$html404" ]; then
	cd $projectSrcDir || exit $?
	git fetch --prune --tags >/dev/null 2>&1
	git checkout $repoBranch || exit $?
	git pull || exit $?
	cp $projectSrcDirForFis/$html404 $html404
	if git status -s "$html404" |grep -q -P "M\s{1}"; then
		git commit -m "发布系统：Fis编译新的404页面" "$html404" || exit $?
		git push || exit $?
	fi
fi

exit $retCode

