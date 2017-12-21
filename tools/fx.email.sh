#!/bin/bash
#
# 发送邮件
#

if [ $# -lt 6 ] ; then
	echo "Usage: $0 reportFile beginVer endVer project projectName projectUrl emailList";
	exit 1
fi

reportFile="$1"
beginVer="$2"
endVer="$3"
project="$4"
projectName="$5"
projectUrl="$6"
shift;shift;shift;shift;shift;shift;
emailList="$*"

#邮件内容
body="$(mktemp)"

echo >$body
echo "项目名：$projectName" >>$body
echo "域名：$projectUrl" >>$body
echo "发布版本：$beginVer ~ $endVer" >>$body
echo "发布时间：$(date +"%Y-%m-%d %R:%S")" >> $body
echo '*****************************************' >>$body
echo >>$body
cat $reportFile >>$body
echo >>$body
echo '本邮件由繁星网发布系统自动发出，请勿回复！任何建议请联系网站研发组，谢谢！^o^ ' >>$body
echo >>$body

#发邮件为HTML格式，这里加标签
tmpFile="$(mktemp)"
sed 's/$/<br \/>/' $body >$tmpFile

subject="繁星发布系统：$projectName"

for email in $emailList; do
	echo "发送邮件到：${email}" |tr -d '\n'
	mgr_url="http://mgr.fxwork.kugou.net"
	tmpPost=$(mktemp)
	curl -F "email=${email}" \
		 -F "subject=${subject}" \
		 -F "file=@${tmpFile}"  \
		 "$mgr_url/?ct=open&ac=send_email" -s -o $tmpPost
	back=$(cat $tmpPost)
	[ "$back" == 1 ] && echo ' 成功' || echo ' 失败'
	rm $tmpPost
done

rm $body $tmpFile

exit 0
