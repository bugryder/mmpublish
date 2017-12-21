#!/bin/bash
if [ $# -lt 7 ] ; then
	echo " e.g.: $0 \$project \$svnHost \$svnPath \$beginVer \$endVer \$svnUser \$svnPass \$reportFile";
	exit 1;
fi
project="$1";
svnHost="$2";
svnPath="$3";
beginVer="$4";
endVer="$5";
svnUser="$6";
svnPass="$7";
reportFile="$8";

svnLogFile='./tmp.svn.log'; #svnlog
tmpFile1='./tmp.text.txt'; #需要关注的内容 - 临时
tmpFile2='./tmp.uni.text.txt'; #无需关注 - 临时
needNodifyFile='./text.txt'; #需要关注的内容 - 最终
commentFile='./uni.text.txt'; #无需关注 - 最终
lastTextFile='./tmp.author.txt';
t='./t';

#生成log日志
svn log $svnHost$svnPath -r $beginVer:$endVer --username=$svnUser --password=$svnPass > $svnLogFile;

if [ ! -f $lastTextFile ]; then
	touch $lastTextFile;
fi
if [ ! -f $needNodifyFile ]; then
	touch $needNodifyFile
fi
if [ ! -f $commentFile ]; then
	touch $commentFile
fi

echo '' > $tmpFile1;
echo '' > $tmpFile2;
echo '' > $needNodifyFile;
echo '' > $commentFile;
echo '' > $lastTextFile;

#写入数据
function writeData()
{
	echo '' > $t;
	#需要关注处理
	
	s=`cat $tmpFile1 | sed '/^$/d' | awk '{printf "%s | ",$0}'`;
	if [[ ! -z $s ]]; then
		cat $lastTextFile >> $tmpFile1;
		cat $tmpFile1 | sed '/^$/d' > $t;
		cat $t | awk '{printf "%s | ",$0}' > $tmpFile1;
		s1=`cat $lastTextFile`;
		echo $s''$s1 >> $needNodifyFile
	fi

	
	#无需关注处理
	s=`cat $tmpFile2 | sed '/^$/d' | awk '{printf "%s | ",$0}'`;
	if [[ ! -z $s ]]; then
		cat $lastTextFile >> $tmpFile2;
		cat $tmpFile2 | sed '/^$/d' > $t;
		cat $t | awk '{printf "%s | ",$0}' > $tmpFile2;
		s2=`cat $lastTextFile`;
		echo $s''$s2 >> $commentFile
	fi

	echo '' > $tmpFile1;
	echo '' > $tmpFile2;
	rm $t;
}

cat $svnLogFile | sed '/^$/d' | awk '{if(/^$/){}else{print $0;}}' | while read i;do 
	if [[ $i =~ ^r ]]; then 
		version=`echo $i | sed 's/^r//g' | sed 's/ .*$//g'`
		if [ "$version" = "$beginVer" ]; then
			continue; # 去掉第一个版本的日志 , 多出来的
		fi
		author=`echo $i | sed 's/^r[0-9]* | //g' | sed 's/ .*$//g'`
		time=`echo $i | sed 's/^r[0-9]* | [^|]* | //g' | sed 's/ +.*$//g'`
		
		writeData;

		echo "$author ($time) [$version]" > $lastTextFile;
		
	elif [[ ! $i =~ ^-+$ ]]; then 
		if [[ $i =~ ^# ]]; then
			echo $i >> $tmpFile2;
		else
			echo $i >> $tmpFile1;
		fi
	fi
done;
writeData;

rm $tmpFile1;
rm $tmpFile2;
rm $lastTextFile;
rm $svnLogFile;

if [[ -f $reportFile ]]; then
	rm $reportFile;
fi

touch $reportFile;
report='繁星网程序更新,更新内容如下:';
if [[ -s $needNodifyFile ]]; then
	report="$report`cat $needNodifyFile`";
	echo '测试需要关注的内容' >> $reportFile;
	cat $needNodifyFile >> $reportFile;
	rm $needNodifyFile;
	echo '' >> $reportFile;
	echo '' >> $reportFile;
fi

if [[ -s $commentFile ]]; then
	report="$report`cat $commentFile`";
	echo '其他修改信息' >> $reportFile;
	cat $commentFile >> $reportFile;
	echo '' >> $reportFile;
	echo '' >> $reportFile;
	rm $commentFile;
fi

echo '*****************结束生成报告************************';