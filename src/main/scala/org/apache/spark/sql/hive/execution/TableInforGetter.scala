package org.apache.spark.sql.hive.execution

import java.net.URL

import org.apache.spark._
import org.apache.spark.sql.SQLContext
import org.apache.spark.sql.execution.{ExplainCommand, ExecutedCommand, SparkPlan}
import org.apache.spark.sql.hive.{HiveShim, HiveContext}

import scala.io.Source

object TableInforGetter {
  def main(args: Array[String]) {
    if (args.length < 1) {
      System.err.println("参数必须大于1!")
      System.exit(1)
    }
    val sqlFile = new URL(args(0))
    val conf = new SparkConf().setAppName("Pathgetter").setMaster("local")
    val spark = new SparkContext(conf)
    val sqlContext = new HiveContext(spark)
    try {
      val sqls = mkSqlFromFile(sqlFile)
      for (sql <- sqls) {
        val plan = sqlContext.sql(sql).queryExecution.executedPlan
        plan.collect {
          case ExecutedCommand(ExplainCommand(loggical, _, _)) =>
            val execuPlan = sqlContext.executePlan(loggical).executedPlan
            printInfoFromPlan(execuPlan)
        }
      }
    } catch {
      case e: Throwable =>
        System.err.println(e.getMessage)
        spark.stop()
        System.exit(1)
    } finally {
      spark.stop()
    }
  }


  def mkSqlFromFile(filename :URL) :Array[String] = {
    val sb = StringBuilder.newBuilder
    Source.fromURL(filename).getLines.foreach {
      line =>
        if (!line.stripPrefix(" ").startsWith("--")) {
          if (sb.length > 0) {
            sb.append('\n')
          }
          sb.append(line.split("--")(0))
        }
    }
    sb.toString().split(";")
  }

  def runSqlGetPlan(sql :String, context: SQLContext): SparkPlan = {
    context.sql(sql).queryExecution.executedPlan
  }


  def printInfoFromPlan(plan :SparkPlan): Unit = {
    plan.collect {
      case hiveScan @ HiveTableScan(requestAtribut, metaRelation, partion) =>
        // handle difference from patition table and none patition table
        if (metaRelation.hiveQlTable.isPartitioned) {
          hiveScan.prunePartitions(metaRelation.hiveQlPartitions).map {
            case partition =>
              System.out.println(
                s"${metaRelation.databaseName}.${metaRelation.tableName}" +
                  s",${HiveShim.getDataLocationPath(partition).toString}")
          }
        } else {
          System.out.println(
            s"${metaRelation.databaseName}.${metaRelation.tableName}" +
              s",${metaRelation.hiveQlTable.getPath.toString}"
          )
        }
      case InsertIntoHiveTable(table, partition, child, overwrite) =>
        System.out.println(s"${table.databaseName}.${table.tableName}")
    }
  }
}

