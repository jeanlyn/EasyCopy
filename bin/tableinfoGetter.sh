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

checkConfig $SPARK_HOME SPARK_HOME
checkConfig $SQL_FILE SQL_FILE
checkConfig $OUT_PUTFILE OUT_PUTFILE
checkConfig $PATH_WRITE_FILE $PATH_WRITE_FILE
checkConfig $CREATE_TABLE_SQL CREATE_TABLE_SQL

if [ ! -f ${SQL_FILE#file:/} ];then
	echo "There no sql file in $SQL_FILE"
	exit
fi

$SPARK_HOME/bin/spark-submit \
--master local \
--class org.apache.spark.sql.hive.execution.TableInforGetter \
$FWDIR/bin/TableInfoGetter-1.0-SNAPSHOT.jar $SQL_FILE 1>$OUT_PUTFILE 

if [ $? != 0 ];then
	echo "Something wrong in getting table info from sql!"
fi

cat $OUT_PUTFILE|awk -F, '{print "show create table "$1";"}' |sort -u > $SHOW_CREATE_SQL

cat $OUT_PUTFILE|awk -F, '{print $2}'|sed '/^$/d' > $PATH_WRITE_FILE

$SPARK_HOME/bin/spark-sql \
--master local \
-f $SHOW_CREATE_SQL 1> $CREATE_TABLE_SQL

OLD_NS=$(echo $OLD_NS|sed 's/\//\\\//g')
NEW_NS=$(echo $NEW_NS|sed 's/\//\\\//g')

sed -i -e 's/CREATE/;\nCREATE/' -e "s/$OLD_NS/$NEW_NS/g" $CREATE_TABLE_SQL


