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

if [ ! -f $SQL_FILE ];then
	echo "There no sql file in $SQL_FILE"
	exit
fi

$SPARK_HOME/bin/spark-submit \
--master local \
--class org.apache.spark.sql.hive.execution.TableInforGetter \
TableInforGetter-1.0-SNAPSHOT.jar $SQL_FILE 1>$OUT_PUTFILE 

if [ $? != 0 ];then
	echo "Something wrong in getting table info from sql!"
fi

create_sql=`cat $OUT_PUTFILE OUT_PUTFILE|awk -F, '{print "show create table "$1";"}' |sort -u`

cat $OUT_PUTFILE OUT_PUTFILE|awk -F, '{print $2}'|sed '/^$/d' > $PATH_WRITE_FILE

$SPARK_HOME/bin/spark-submit \
--master local \
-e $create_sql 1> $CREATE_TABLE_SQL

sed -i -e s/CREATE/;CREATE/ -e s/$OLD_NS/$NEW_NS/g $CREATE_TABLE_SQL


