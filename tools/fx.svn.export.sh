#!/bin/bash
if [ $# -lt 6 ] ; then
	echo " e.g.: $0 \$project \$svnHost \$svnPath \$beginVer \$endVer \$toPath \$svnUser \$svnPass";
	exit 1;
fi
pwd=`pwd`;
project="$1";
svnHost="$2;
svnPath="$3";
beginVer="$4";
endVer="$5";
toPath="$6";
svnUser="$7";
svnPass="$8";

svnHost1="$svnHost$svnPath";
svnHost2=$(echo $svnHost1 | sed "s#/#\\\/#g");
svnPath2=$(echo $svnPath | sed "s#/#\\\/#g");
fileListPath="$toPath";

if [ ! -d "$toPath" ]; then
	mkdir $toPath -p -m 777;
	chmod 777 $toPath -R;
fi

fileList="$toPath/$beginVer.$endVer.txt";


echo '*****************开始导出svn********************';
if [ "$beginVer" -eq "0" ]; then
	echo "完整打包 $svnHost";
	# echo "svn export -q --username=$svnUser --password=$svnPass $svnHost1 -r $endVer $fileListPath --no-auth-cache --force;";
	svn export -q --username=$svnUser --password=$svnPass $svnHost1 -r $endVer $fileListPath --no-auth-cache --force;
else
	svn diff --new=$svnHost1@$endVer --old=$svnHost1@$beginVer --username=$svnUser --password=$svnPass --summarize | awk '{print $2}' | sed "s/${svnHost2}//g" | awk '{print $1}' > $fileList;
	cat $fileList;
	#忽略文件处理
	cat $fileList | grep -v 'Thumbs.db' | grep -v 'ConfigFiles/' | grep -v 'tools/' | grep -v 'TestCase/' | grep -v 'Config/Instances' | grep -v 'Init/fanxing.txt' | grep -v 'test.php' > tmp1;
	cat tmp1 | grep "[^\/]*\.[^\/]*$" > $fileList;
#	cat tmp1 > $fileList;
	rm tmp1;
	if [ ! -s $fileList ]; then
		echo '没文件产生，可能导出语句有错';
		exit 0;
	fi

	for line in $(cat $fileList); do
		pfName=$fileListPath$line;
		path=${pfName%/*};
		if [ ! -d "$path" ]; then
			mkdir $path -p -m 777;
			chmod 777 $path -R;
		fi
		cd $pwd;
#echo "svn export  --username=$svnUser --password=$svnPass $svnHost1$line@$endVer $fileListPath$line --no-auth-cache; ";
		svn export -q --username=$svnUser --password=$svnPass $svnHost1$line@$endVer $fileListPath$line --no-auth-cache; 
	done
	rm $fileList;
fi
echo '*****************结束导出svn********************';
touch $fileListPath/version.txt;
echo $endVer > $fileListPath/version.txt; 

echo '*****************导出报告********************';
echo "导出文件目录:$fileListPath";
echo '*****************导出报告********************';
