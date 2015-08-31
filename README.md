# Movtivation
Sometimes we have to test some production environment hive sql on test environment. So we need to do by follow steps:

1. Get table name from the sql, and then get the DDL from the table name
2. Get the paths from the sql which we need to copy to the test environment
3. Discp the paths to the test environment
4. Setup the table by the DDL and add the partition by the command `MSCK REPAIR TABLE src` with the already copied datas

It's  annoying when we do the above steps manually. Hence, we need a tool to help us doing this.

# Usage
## Compile

```shell
sh mkdist.sh
```
we can get the `tableInfoGetter-bin.tar.gz` after we runned the shell. We can decompress it on the production environment and run the shell in `bin` directory and configs the variables from `con` directory

##Configuration
All the configurations are in the `con/conf.sh` file. 
I will figure out the main configurations:

### Common
`PATH_WRITE_FILE`:The path need to be copied to the test environment

###For the `tableinfoGetter.sh`
`SQL_FILE`: The sql file which used to get informations

`OUT_PUTFILE`:Save the data after we running the jar. It contains the table name and the paths separated by comma

`CREATE_TABLE_SQL`: The DDL got by 

`OLD_NS`: Namespace of the production environment 

`NEW_NS`: Namespace of the test environment

`SPARK_HOME`: We need spark to help us to get the informations, so we need to install on the client node of the production environment

### For the `cpdata.sh`

`DEST_IP`: The ip of test environment active namenode

`HADOOP_HOME`: We need to run `distcp` to copy datas, hence we need a hadoop client by config this environment variable.


##Run
We can running the shell in the `bin` directory.
* `tableinfoGetter.sh`: Get the path and dll from sql file
* `cpdata.sh`: copy the path from the production environment to the test environment.

#TODO
* Clean the code
* Make the code more easier to use
* Add more test
* Bug fixs