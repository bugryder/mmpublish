# !/bin/bash
#

INIFILE=$1
SECTION=$2
ITEM=$3
NEWVAL=$4

#读
ReadINIfile() { 
    ReadINI=$(cat $INIFILE |grep -v "^\s*;" |awk -F '=' '/\['$SECTION'\]/{a=1}a==1 && $1~/^'$ITEM'$/{print $2;exit}')
    echo $ReadINI
}

#写
WriteINIfile() {
    WriteINI=$(cat $INIFILE |grep -v "^\s*;" |sed -i "/^\[$SECTION\]/,/^\[/ {/^\[$SECTION\]/b;/^\[/b;s/^$ITEM*=.*/$ITEM=$NEWVAL/g;}")
    echo $WriteINI
}

if [[ "x$4" == "x" ]]; then
    ReadINIfile $1 $2 $3
else
    WriteINIfile $1 $2 $3 $4
fi
