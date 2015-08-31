#!/usr/bin/env bash
FWDIR="$(cd "`dirname $0`"/..; pwd)"

. $FWDIR/conf/conf.sh

checkConfig () {
    if [ $# == 1 ];then
        echo "$1 does not config! Please config in conf/conf.sh"
        exit 1
    fi
} 
#check for the config

checkConfig $PATH_WRITE_FILE PATH_WRITE_FILE

checkConfig $DEST_IP DEST_IP

checkConfig $HADOOP_HOME HADOOP_HOME


file="${PATH_WRITE_FILE}"

#Control the concurrent distcp nums
THEAD_NUM=8
mkfifo tmpcp
exec 9<>tmpcp
                                                                                                                                                                               
for ((i=0;i<$THEAD_NUM;i++))
do
    echo -ne "\n" 1>&9
done
                                                                                                                                                                               
                                                                                                                                                                               
#destsrc=" hdfs://172.22.167.77:8020"
destsrc=" ${DEST_IP}"
cmd="$HADOOP_HOME/bin/hadoop distcp -update -skipcrccheck "
total=`wc -l $file|cut -d" " -f1 2>/dev/null`
i=1

for p in `cat $file`;do
    echo "[$((i++))/$total]"
    read -u 9
    {
        #echo "[$((i++))/$total]"
        strip_string=`echo "$p"|awk -F/ '{if($1=="hdfs:")printf $1"//"$3;else printf ""}'`
        path=${p#${strip_string}}
        run=${cmd}" "$p" "${destsrc}${path}
        $run
        echo "running: $run" 
        if [ $? != 0 ];then
            exit 1
        fi
        echo -ne "\n" 1>&9
                                                                                                                                                                               
    }&
    if [[ $? != 0 ]];then
        exit 1
    fi
done

wait
/bin/rm tmpcp