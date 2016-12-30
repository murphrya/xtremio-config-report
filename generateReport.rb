#!/usr/bin/env ruby
require 'json'
require 'colorize'
require 'terminal-table'
load 'modules\dossierEngine.rb'
load 'modules\reportEngine.rb'
include DossierEngine
include ReportEngine

##### Generate Variables Used by multiple clusters #####
Process.setproctitle("XtremIO Configuration Report")
jsonHash = DossierEngine.generateJsonHash(getFileLocation)
clusterCount = DossierEngine.getClusterCount(jsonHash)
xmsIp = DossierEngine.getXmsIp(jsonHash).colorize(:light_white)
xmsCode = DossierEngine.getXmsCode(jsonHash).colorize(:light_white)
allVolumes = DossierEngine.getAllVolumes(jsonHash)
allSnapshotGroups = DossierEngine.getAllSnapshotGroups(jsonHash)


##### Generate the XMS table #####
printHeader

xmsTable = ReportEngine.generateTable("XMS Server Configuration".colorize(:light_blue),
                         ['XMS IP'.colorize(:cyan), 'XMS Code'.colorize(:cyan),'Attached Clusters'.colorize(:cyan)],
                         [[xmsIp, xmsCode, clusterCount.to_s.colorize(:light_white)]],
                         {:width => 100})
ReportEngine.printTable(xmsTable)

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

  #generate cluster volume information
  sourceVolCount = 0
  snapVolCount = 0
  allVolumes.each do |vol|
    if vol["sys_id"][1] == jsonHash["Systems"][counter]["name"]
      if vol["created_from_volume"] == ""
        sourceVolCount += 1
      else
        snapVolCount += 1
      end
    end
  end
  sourceVolTotal = sourceVolCount.to_s.colorize(:light_white)
  snapVolTotal = snapVolCount.to_s.colorize(:light_white)

  logicalCapacityRows << [clusterSerial,clusterSvgTotal,clusterLogicalConsumed,clusterTotalLogical,sourceVolTotal,snapVolTotal]


  #generate cluster efficiency information
  clusterDedupe = jsonHash["AllSystems"][counter]["dedup_ratio"].round(1).to_s.colorize(:light_white)
  clusterCompression = jsonHash["AllSystems"][counter]["compression_factor"].round(1).to_s.colorize(:light_white)
  clusterDRR = jsonHash["AllSystems"][counter]["data_reduction_ratio"].round(1).to_s.colorize(:light_white)
  clusterThinRatio = jsonHash["AllSystems"][counter]["thin_provisioning_ratio"].round(1).to_s.colorize(:light_white)
  clusterOverallEff = jsonHash["AllSystems"][counter]["overall_efficiency_ratio"].round(1).to_s.colorize(:light_white)
  efficiencyRows << [clusterSerial,clusterDedupe,clusterCompression,clusterDRR,clusterThinRatio,clusterOverallEff]

end

configurationTable = ReportEngine.generateTable("Current Configuration - All Clusters".colorize(:light_blue),
                         ['PSTN'.colorize(:cyan),'Name'.colorize(:cyan),'Code'.colorize(:cyan),'Type'.colorize(:cyan),'State'.colorize(:cyan),'Major Alerts'.colorize(:cyan)],
                         configurationRows,
                         {:width => 100})

physCapacityTable = ReportEngine.generateTable("Physical Capacity - All Clusters".colorize(:light_blue),
                              ['PSTN'.colorize(:cyan), 'SSD Usable (TB)'.colorize(:cyan),'SSD Consumed (TB)'.colorize(:cyan),'SSD Free (TB)'.colorize(:cyan)],
                              physCapacityRows,
                              {:width => 100})

logicalCapacityTable = ReportEngine.generateTable("Logical Capacity - All Clusters".colorize(:light_blue),
                                  ['PSTN'.colorize(:cyan), 'SVGs'.colorize(:cyan),'Logical Consumed (TB)'.colorize(:cyan),'Total Logical (TB)'.colorize(:cyan),'Source Vols'.colorize(:cyan),'Snap Vols'.colorize(:cyan)],
                                  logicalCapacityRows,
                                  {:width => 100})

efficiencyTable = ReportEngine.generateTable("Efficiency - All Clusters".colorize(:light_blue),
                              ['PSTN'.colorize(:cyan), 'Dedupe'.colorize(:cyan),'Compression'.colorize(:cyan),'DRR'.colorize(:cyan),'Thin Ratio'.colorize(:cyan),'Total Efficiency'.colorize(:cyan)],
                              efficiencyRows,
                              {:width => 100})

ReportEngine.printTable(configurationTable)
ReportEngine.printTable(physCapacityTable)
ReportEngine.printTable(logicalCapacityTable)
ReportEngine.printTable(efficiencyTable)
ReportEngine.printFooter
