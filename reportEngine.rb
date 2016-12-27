#!/usr/bin/env ruby
require 'json'
require 'colorize'
require 'terminal-table'

#Get the location of the json file from the user
def getFileLocation
  return ARGV[0]
end

#Opens dossier file and pulls out the json data
def unpackDossieJson(location)
  #myjsonfile = 'small/xms/xmcli/show_all.json'
  #input = %x[unzip -p #{location} | bzip2 -q -dc - | tar -xvf - #{myjsonfile} -O]
  #puts input

  %x[unzip #{location} -d tempdir]
  filenames = Dir["tempdir/*"]
  filenames.each do |filename|
    if filename.include? ".bz2"
      %x[mkdir tempdir2]
      %x[tar -xvf #{filename} -C tempdir2]
    end
  end
  json = JSON.parse(File.read('tempdir2/small/xms/xmcli/show_all.json'))
  %x[rm -rf tempdir]
  %x[rm -rf tempdir2]
  return json
end

#Pulls in the JSON from the user file and maps it to a Ruby Hash
def getJson(location)
  return JSON.parse(File.read(location))
end

#Handles the file type passed to the tool
def generateJsonHash(location)
  if ARGV[0].include? ".json"
    return getJson(location)
  end
  if ARGV[0].include? ".zip"
    return unpackDossieJson(location)
  end
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

#Prints the program header to the command line
def printHeader
  puts " "
  puts "+---------------------- XtremIO Configuration Report v0.0 ---------------------+".colorize(:light_yellow)
  puts " "
  puts "This report is used to spot check an XtremIO cluster by using the dossier file.\nIt will report on cluster configuration, capacity, and efficiency.".colorize(:yellow)
  puts ""
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


#testing commands
#puts json["AllVolumes"][0]["logical_space_in_use"]


##### Generate Variables Used by multiple clusters #####
Process.setproctitle("XtremIO Configuration Report")
jsonHash = generateJsonHash(getFileLocation)
clusterCount = getClusterCount(jsonHash)
xmsIp = getXmsIp(jsonHash).colorize(:light_white)
xmsCode = getXmsCode(jsonHash).colorize(:light_white)
allVolumes =jsonHash["AllVolumes"]
allSnapshotGroups = jsonHash["AllSnapshotGroups"]


##### Generate the XMS table #####
printHeader

xmsTable = generateTable("XMS Server Configuration".colorize(:light_blue),
                         ['XMS IP'.colorize(:cyan), 'XMS Code'.colorize(:cyan),'Attached Clusters'.colorize(:cyan)],
                         [[xmsIp, xmsCode, clusterCount.to_s.colorize(:light_white)]],
                         {:width => 80})
printTable(xmsTable)

##### Generate the clusters configuration table rows#####
counter = 0
configurationRows = []
physCapacityRows = []
logicalCapacityRows = []
efficiencyRows = []
clusterCount.times do
  #Generate cluster configuration information
  clusterSerial = jsonHash["SystemsInfo"][counter]["psnt"].colorize(:light_white)
  clusterName = jsonHash["Systems"][counter]["name"].colorize(:light_white)
  clusterCode = jsonHash["SystemsInfo"][counter]["sys_sw_version"].colorize(:light_white)
  clusterType = jsonHash["Systems"][counter]["size_and_capacity"].colorize(:light_white)
  clusterState = jsonHash["AllSystems"][counter]["sys_health_state"].colorize(:light_white)
  clusterMajorAlerts = jsonHash["AllSystems"][counter]["num_of_major_alerts"].to_s.colorize(:light_white)
  configurationRows << [clusterSerial, clusterName, clusterCode, clusterType, clusterState,clusterMajorAlerts]

  #generate cluster physical capacity information
  clusterPhysConsumed = (((jsonHash["Systems"][counter]["ud_ssd_space_in_use"]).to_f)/1024.0/1024.0/1024.0).round(1).to_s.colorize(:light_white)
  clusterPhysFree = (((jsonHash["AllSystems"][counter]["free_ud_ssd_space"]).to_f)/1024.0/1024.0/1024.0).round(1).to_s.colorize(:light_white)
  clusterPhysUsable = (((jsonHash["Systems"][counter]["ud_ssd_space"]).to_f)/1024.0/1024.0/1024.0).round(1).to_s.colorize(:light_white)
  physCapacityRows << [clusterSerial,clusterPhysUsable,clusterPhysConsumed,clusterPhysFree]

  #generate cluster logical capacity information
  clusterSvgCount = 0
  clusterSvgConsumed = 0.0
  clusterSvgTotalLogical = 0.0
  allSnapshotGroups.each do |sg|
    if sg["sys_id"][1] == jsonHash["Systems"][counter]["name"]
      clusterSvgCount += 1
      clusterSvgConsumed += (sg["logical_space_in_use"].to_f)/1024.0/1024.0/1024.0
      clusterSvgTotalLogical += (sg["vol_size"].to_f)/1024.0/1024.0/1024.0
    end
  end
  clusterSvgTotal = clusterSvgCount.to_s.colorize(:light_white)
  clusterLogicalConsumed= clusterSvgConsumed.round(1).to_s.colorize(:light_white)
  clusterTotalLogical = clusterSvgTotalLogical.round(1).to_s.colorize(:light_white)
  logicalCapacityRows << [clusterSerial,clusterSvgTotal,clusterLogicalConsumed,clusterTotalLogical]

  #generate cluster efficiency information
  clusterDedupe = jsonHash["AllSystems"][counter]["dedup_ratio"].round(1).to_s.colorize(:light_white)
  clusterCompression = jsonHash["AllSystems"][counter]["compression_factor"].round(1).to_s.colorize(:light_white)
  clusterDRR = jsonHash["AllSystems"][counter]["data_reduction_ratio"].round(1).to_s.colorize(:light_white)
  clusterThinRatio = jsonHash["AllSystems"][counter]["thin_provisioning_ratio"].round(1).to_s.colorize(:light_white)
  clusterOverallEff = jsonHash["AllSystems"][counter]["overall_efficiency_ratio"].round(1).to_s.colorize(:light_white)
  efficiencyRows << [clusterSerial,clusterDedupe,clusterCompression,clusterDRR,clusterThinRatio,clusterOverallEff]

end

configurationTable = generateTable("Current Configuration - All Clusters".colorize(:light_blue),
                         ['PSTN'.colorize(:cyan),'Name'.colorize(:cyan),'Code'.colorize(:cyan),'Type'.colorize(:cyan),'State'.colorize(:cyan),'Major Alerts'.colorize(:cyan)],
                         configurationRows,
                         {:width => 80})

physCapacityTable = generateTable("Physical Capacity - All Clusters".colorize(:light_blue),
                              ['PSTN'.colorize(:cyan), 'SSD Usable (TB)'.colorize(:cyan),'SSD Consumed (TB)'.colorize(:cyan),'SSD Free (TB)'.colorize(:cyan)],
                              physCapacityRows,
                              {:width => 80})

logicalCapacityTable = generateTable("Logical Capacity - All Clusters".colorize(:light_blue),
                                  ['PSTN'.colorize(:cyan), 'SVG Count'.colorize(:cyan),'Logical Consumed (TB)'.colorize(:cyan),'Total Logical (TB)'.colorize(:cyan)],
                                  logicalCapacityRows,
                                  {:width => 80})

efficiencyTable = generateTable("Efficiency - All Clusters".colorize(:light_blue),
                              ['PSTN'.colorize(:cyan), 'Dedupe'.colorize(:cyan),'Compression'.colorize(:cyan),'DRR'.colorize(:cyan),'Thin Ratio'.colorize(:cyan),'Total Efficiency'.colorize(:cyan)],
                              efficiencyRows,
                              {:width => 80})

printTable(configurationTable)
printTable(physCapacityTable)
printTable(logicalCapacityTable)
printTable(efficiencyTable)
