module ReportEngine
  #Prints the program header to the command line
  def printHeader
    puts " "
    puts " "
    puts "########################################### Start Report ###########################################".colorize(:green)
    puts " "
    puts "XtremIO Dossier Reporter v1.0: This report is used to get an overview of XtremIO clusters by using".colorize(:green)
    puts "the dossier file. It will report on cluster configuration, capacity, and efficiency.".colorize(:green)
    puts " "
  end

  #Creates a table with the user defined variables
  def generateTable(title,headings,rows,style)
    table = Terminal::Table.new :title => title, :headings => headings, :rows => rows, :style => style
    return table
  end

  #Prints the provided table to the command line
  def printTable(table)
    puts table
    puts ""
  end

  def printFooter
    puts " "
    puts "############################################ End Report ############################################".colorize(:green)
    puts " "
  end
end
