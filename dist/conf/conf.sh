#!/usr/bin/env bash
FWDIR="$(cd "`dirname $0`"/..; pwd)"

#For copy data
#export DEST_IP=""
#export DEST_NANESPACE=""
#export HADOOP_HOME=""


#For run TableInfoGetter.jar to get ddl sql and copy path
#export SPARK_HOME
export SQL_FILE="file:/${FWDIR}/data/sql"
export OUT_PUTFILE="${FWDIR}/data/outputfile.txt"
export CREATE_TABLE_SQL="${FWDIR}/data/create_table.sql"
#use for replace the LOCATION on ddl sql
export OLD_NS="hdfs://ns1"
export NEW_NS="hdfs://ns2"




#For Common
export PATH_WRITE_FILE="${FWDIR}/data/path.txt"



