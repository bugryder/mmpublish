#!/bin/bash
#
# 检查 crontab 配置文件
#

if [ $# -lt 1 ] ; then
	echo " e.g.: $0 timerFile"
    exit 1
fi

#
check_timer()
{
    ret=0
    timerFile=$1
    
    #是否带bom
    if grep -q -rl $'\xEF\xBB\xBF' $timerFile; then
        echo "错误！带有 BOM 标志"
        #sed -i '1s/^\xEF\xBB\xBF//'
        ret=1
    fi
    
    #删除＃开头的行
    tmpFile=$(mktemp)
    sed -e 's/^[ ]*//' -e '/^#/d' -e '/^$/d' $timerFile >$tmpFile

    #检查格式
	tmpFileLoop=$(mktemp)
    while read line; do
        #时间段包含字母
        if echo "$line" |awk '{print $1,$2,$3,$4,$5}' |grep -q [a-zA-Z]; then
            echo "错误！时间段包含无效字符："
            echo "$line"
			echo
            ret=1
        fi

		#bash语法错误
        echo "echo $(echo "$line" |sed 's#2>&1##g' |awk -F'>>|>' '{print $2}') >/dev/null 2>&1" >$tmpFileLoop
	    if ! /bin/bash $tmpFileLoop; then
	    	echo "错误！重定向语句语法错误："
	    	echo "$line"
	    	echo
	    	ret=1
        fi

        ##输出无重定向
        if ! echo "$line" |grep -q '>'; then
            echo "警告！输出没有重定向："
            echo "$line"
	    	echo
	    	ret=1
        fi
    done < $tmpFile
    rm $tmpFile $tmpFileLoop

    return $ret
}

file=$1
if [ -f $file ]; then
	#删除行首空格
	sed -i 's/^[ \t]*//g' $file 
    check_timer $file
    exit $?
fi

exit 0
