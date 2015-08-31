#Licensed under the Apache License, Version 2.0 (the "License");
#you may not use this file except in compliance with the License.
#You may obtain a copy of the License at
#
#http://www.apache.org/licenses/LICENSE-2.0
#
#Unless required by applicable law or agreed to in writing, software
#distributed under the License is distributed on an "AS IS" BASIS,
#WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#See the License for the specific language governing permissions and
#  limitations under the License.
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