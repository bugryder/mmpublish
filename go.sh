#!/bin/bash
#
# 繁星网站发版工具
#
# Copyright © 2016 kugou.com
#
# Authors: 
# mmfei <wenglingfei@kugou.net>
#

# 工作目录
# workDir=$(dirname $0)
# workDir=$(readlink -f $workDir)
workDir=`pwd`;

# ini 文件处理脚本
iniTool="${toolsDir}/ini.sh"
# IP 地址
ip=${SSH_CLIENT%% *}
echo $workDir;
#公共函数
source $workDir/common.sh


# 项目目录
projectsDir=$workDir/projectConfig
mkdir -p $toolsDir $projectsDir

#
echo
msg_green '#### 欢迎使用繁星网站发布系统 ####'
echo    

#
# 项目编号
#
msg_white '#### 选择发布项目 ####'
project=''
declare -a allProjects
sed -i 's/^[ \t]*//g' $projectsDir/*.config.ini #删除行首空格
iniFiles=$(ls $projectsDir/*.config.ini 2>/dev/null)
i=0
for iniFile in $iniFiles; do
    project=$(basename ${iniFile%%.config.ini})
    name=$($iniTool $iniFile base name)
	name=$(echo $name |tr -d ' ')
    allProjects[$i]="${name}__$project"
	let i++
done
allProjects[$i]="取消本次发布！"


echo
PS3=$(echo -e "\n请输入将要发布的项目编号：")
select project in ${allProjects[@]}; do
	break
done


#项目名
echo $project |grep -q '取消' && error_exit


project=$(echo $project |awk -F'__' '{print $2}')
iniFile=$projectsDir/${project}.config.ini
[ -f "$iniFile" ] || error_exit
projectName=$($iniTool $iniFile base name)

##项目仓库
repoType=$($iniTool $iniFile repository 'type') #类型
repoHost=$($iniTool $iniFile repository host) #源码地址
repoName=$(basename $repoHost)
repoBranch=$($iniTool $iniFile repository branch) #发布分支
repoBranchGray=$($iniTool $iniFile repository grayBranch) #灰度分支
isMerge=$($iniTool $iniFile repository merge) #是否回源
mergeBack=$($iniTool $iniFile repository mergeBack) #回源到哪个分支
[ "x$repoType" = 'x' ] && repoType='git'
[ "x$repoBranch" = 'x' ] && repoBranch='master'
[ "x$isMerge" = 'x' ] && isMerge='0'
[ "x$mergeBack" = 'x' ] && mergeBack='develop'


