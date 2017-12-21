#!/bin/bash
#
# fifo 管道方式执行命令
# 放到跳板机执行 
#

if [ ! $# -eq 1 ] ; then
	echo "Usage: $0 cmdFile";
	exit 1
fi

cmdFile=$1
if [ ! -f "$cmdFile" ]; then
	echo "文件不存在 $cmdFile"
	exit 1
fi

cmdFile=$(readlink -f $cmdFile)
logFile=${cmdFile}.log
retFile=${cmdFile}.ret #记录执行脚本的退出码
fifoFile=${cmdFile}.fifo

#初始化
[ -f "$retFile" ] && echo 0 >"$retFile"

#写入
[ -e "$fifoFile" ] && rm -f "$fifoFile"
mkfifo $fifoFile
if [ ! -p "$fifoFile" ]; then
	echo "创建管道失败 $fifoFile"
	exit 1
fi

/bin/bash $cmdFile >$fifoFile 2>&1 &

#读出
echo -e "\n$(date +'%Y-%m-%d %H:%M:%S')\n" >$logFile
while read line; do
	echo "$line"
	echo "$line" >>$logFile
done <$fifoFile
echo -e "\n$(date +'%Y-%m-%d %H:%M:%S')\n" >>$logFile

[ -e "$fifoFile" ] && rm -f "$fifoFile"
[ -f "$retFile" ] && exit $(cat $retFile 2>/dev/null)

exit 0
