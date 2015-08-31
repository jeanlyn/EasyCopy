/**
 * Created by jeanlyn on 15/7/9.
 */

import org.apache.spark.sql.hive.execution.TableInforGetter
import org.scalatest.BeforeAndAfter
import org.scalatest.BeforeAndAfterAll
import org.scalatest.FunSuite
import org.scalatest.{BeforeAndAfter, BeforeAndAfterAll, FunSuite}

class mkSqlFromFileSuite extends FunSuite {
  test("mkSqlFromFile"){
    val pathget = TableInforGetter
    val filename = Thread.currentThread().getContextClassLoader.getResource("sqltest.txt")
    println(filename)
    val result = pathget.mkSqlFromFile(filename)
    result.foreach(println)
    assert(result.length == 2)
  }
}
