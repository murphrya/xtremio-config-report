#!/usr/bin/env ruby
require 'json'
require 'colorize'
require 'terminal-table'

#Get the location of the json file from the user
def getFileLocation
  return ARGV[0]
end

#Pulls in the JSON from the user file and maps it to a Ruby Hash
def getJsonHash(location)
  return JSON.parse(File.read(location))
end

#Return the number of XtremIO clusters connected to the XMS server
def getClusterCount(jsonHash)
  return jsonHash["AllXms"][0]["num_of_systems"].to_i
end

#Return the XMS server IP address
def getXmsIp(jsonHash)
  return jsonHash["AllXms"][0]["xms_ip"]
end

#Return the XMS code level
def getXmsCode(jsonHash)
  return jsonHash["AllXms"][0]["sw_version"]
end

#
def printHeader
  puts " "
  puts "+---------------------- XtremIO Configuration Report v0.0 ---------------------+".colorize(:yellow)
  puts " "
end


#
def generateTable(title,headings,rows,style)
  table = Terminal::Table.new :title => title,
                              :headings => headings,
                              :rows => rows,
                              :style => style
 return table
end

#
def printTable(table)
  puts table
  puts ""
end


#testing commands
#puts json["AllVolumes"][0]["logical_space_in_use"]


##### Generate Variables Used by multiple clusters #####
Process.setproctitle("XtremIO Configuration Report")
location = getFileLocation
jsonHash = getJsonHash(location)
clusterCount = getClusterCount(jsonHash)
xmsIp = getXmsIp(jsonHash)
xmsCode = getXmsCode(jsonHash)
allVolumes =jsonHash["AllVolumes"]
allSnapshotGroups = jsonHash["AllSnapshotGroups"]


##### Generate the XMS table #####
printHeader

xmsTable = generateTable("1 - XMS Server Configuration",
                         ['XMS IP', 'XMS Code','Attached Clusters'],
                         [[xmsIp, xmsCode, clusterCount.to_s]],
                         {:width => 80})

printTable(xmsTable)


##### Generate the clusters configuration table rows#####
counter = 0
clusterRows = []
clusterCount.times do
  #Generate cluster specific variables
  clusterSerial = jsonHash["SystemsInfo"][counter]["psnt"]
  clusterName = jsonHash["Systems"][counter]["name"]
  clusterCode = jsonHash["SystemsInfo"][counter]["sys_sw_version"]
  clusterType = jsonHash["Systems"][counter]["size_and_capacity"]
  clusterRows << [(counter+1).to_s, clusterSerial, clusterName, clusterCode, clusterType]
end

clustersTable = generateTable("2 - XtremIO Cluster Configuration",
                         ['Cluster', 'PSTN','Name','Code','Type'],
                         clusterRows,
                         {:width => 80})

printTable(clustersTable)
