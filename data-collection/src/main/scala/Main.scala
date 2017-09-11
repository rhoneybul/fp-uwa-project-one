import org.jsoup.Jsoup
import org.jsoup.nodes.Document
import org.jsoup.nodes.Element
import org.jsoup.select.Elements
import scala.collection.JavaConversions._
import java.io._

object Main extends App {

  def getDataFromLink(
    link : String,
    filename : String,
    curr_index : Int,
    total_index : Int,
    fileWriter : PrintWriter
  ) = {

    println(s"Getting Data for: ${link}, Link: ${curr_index} of ${total_index}")
    doc = Jsoup.connect(link).get()
    var tables = doc.select("table.wikitable").zipWithIndex

    val yearSplit = filename.split(" ")
    var year = yearSplit(yearSplit.length-1)

    for ((table, i) <- tables) {
      println(s"Getting Table ${i}")

      var allHeaders = table.select("tr > th").map(
        header => header.text
      )

      var headers = allHeaders.zipWithIndex.filter(
        header => relevantHeaders.contains(header._1)
      )

      if (headers.length == relevantHeaders.length) {
        var headerIndices = headers.map(header => header._2)
        var headerVals = headers.map(header => header._1.replace("\n", ""))

        var rows = table.select("tbody > tr").zipWithIndex
        rows.remove(0)

        val allRows = rows.map(
          row => row._1.select("td").map(
            el => el.text
          ).zipWithIndex.filter(
            rowElem => headerIndices.contains(rowElem._2)
          )
        )

        val rowValues = allRows.map(row => row.map(el => el._1.replace("\n", "")))

        // Writer.write("Year".concat("\t"))
        // Writer.write(headerVals.mkString("\t").concat("\n"))
        rowValues.map(
          row => Writer.write(year.concat("\t").concat(row.mkString("\t").concat("\n")))
        )
        // Writer.write("\n")
      }

    }

    // var table = tables(0)

    // GET FOR ALL TABLES, NOT JUST THE FIRST

  }

  val wikiBaseUrl = "http://en.wikipedia.org"

  var doc = Jsoup.connect(
    "https://en.wikipedia.org/wiki/List_of_terrorist_incidents"
  ).get()

  val pageLinks = doc.select(".div-col > ul > li > a")
  val years = List.range(1970, 2018)
  val relevantHeaders : List[String] = List(
    "Type",
    "Dead",
    "Date",
    "Injured",
    "Location",
    "Details",
    "Perpetrator"
  )

  val yearsAsString = years.map(year => year.toString)

  val relevantLinks = for(
    link <- pageLinks;
    if yearsAsString.map(
      year => link.text.contains(year)
    ).contains(true)) yield (link.text, wikiBaseUrl.concat(link.attr("href")))

  val relevantLinksWithIndex = relevantLinks.zipWithIndex

  val Writer = new PrintWriter(new File("data/incidents.txt"))

  Writer.write(relevantHeaders.mkString(", ").concat("\n"))

  relevantLinksWithIndex.map(
    link => getDataFromLink(
      link._1._2,
      link._1._1,
      link._2,
      relevantLinksWithIndex.length,
      Writer
    )
  )

  Writer.close()

}
