#!/bin/bash
#
# 发送 RTX 提醒
#

if [ $# -lt 3 ] ; then
	echo "Usage: $0 title content receivers"
	exit 1
fi

title="$1"
content="$2"
shift;shift
receivers=$@

for receiver in $receivers; do
    echo "发送RTX提醒到：$receiver"
    if echo $receiver |egrep -q -i "[a-zA-Z]"; then
        #新接口，发送给群组或者个人，必须是英文名
        curl -A "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.0)" -d "appKey=10001&userName=$receiver&rtxType=sendRtxTip&title=$title&content=$content" \
        http://u2.kugou.net:11770/sendRtxByPost >/dev/null 2>&1
    else
        #旧接口，发送给个人，支持中文名字
        curl -A "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.0)" -d "appKey=10001&receivers=$receiver&rtxType=sendRtxTip&title=$title&content=$content" \
        http://u2.kugou.net:11610/sendRtx >/dev/null 2>&1
    fi
done

exit 0
