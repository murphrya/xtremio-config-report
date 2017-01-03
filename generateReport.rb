#!/usr/bin/env ruby
require 'json'
require 'colorize'
require 'terminal-table'
load 'modules\dossierEngine.rb'
load 'modules\reportEngine.rb'
include DossierEngine
include ReportEngine

#Generate Variables Used by multiple clusters
Process.setproctitle("XtremIO Configuration Report")
jsonHash = DossierEngine.generateJsonHash(getFileLocation)
clusterCount = DossierEngine.getClusterCount(jsonHash)
flag =  DossierEngine.getFlags
tableWidth = {:width => 100}
tableWidth2 = {:width => 120}

#Generate the XMS table
xmsIp = DossierEngine.getXmsIp(jsonHash).colorize(:light_white)
xmsCode = DossierEngine.getXmsCode(jsonHash).colorize(:light_white)
xmsTitle = "XMS Server Configuration".colorize(:light_blue)
xmsHeader = ['XMS IP'.colorize(:cyan), 'XMS Code'.colorize(:cyan),'Attached Clusters'.colorize(:cyan)]
xmsRows = [[xmsIp, xmsCode, clusterCount.to_s.colorize(:light_white)]]
xmsTable = ReportEngine.generateTable(xmsTitle,xmsHeader,xmsRows,tableWidth)


#Generate the cluster tables
counter = 0
allVolumes = DossierEngine.getAllVolumes(jsonHash)
allSnapshotGroups = DossierEngine.getAllSnapshotGroups(jsonHash)

configurationTitle = "Current Configuration - All Clusters".colorize(:light_blue)
configurationHeader = ['PSTN'.colorize(:cyan),'Name'.colorize(:cyan),'Code'.colorize(:cyan),'Type'.colorize(:cyan),'State'.colorize(:cyan),'Major Alerts'.colorize(:cyan)]
configurationRows = DossierEngine.generateConfigurationRows(jsonHash,clusterCount)

physCapacityTitle = "Physical Capacity - All Clusters".colorize(:light_blue)
physCapacityHeader = ['PSTN'.colorize(:cyan), 'SSD Usable (TB)'.colorize(:cyan),'SSD Consumed (TB)'.colorize(:cyan),'SSD Free (TB)'.colorize(:cyan)]
physCapacityRows = DossierEngine.generatePhysCapRows(jsonHash,clusterCount)

logicalCapacityTitle = "Logical Capacity - All Clusters".colorize(:light_blue)
logicalCapacityHeader = ['PSTN'.colorize(:cyan), 'SVGs'.colorize(:cyan),'Logical Consumed (TB)'.colorize(:cyan),'Total Logical (TB)'.colorize(:cyan),'Source Vols'.colorize(:cyan),'Snap Vols'.colorize(:cyan)]
logicalCapacityRows = DossierEngine.generateLogiCapRows(jsonHash,clusterCount,allVolumes,allSnapshotGroups)

efficiencyTitle = "Efficiency - All Clusters".colorize(:light_blue)
efficiencyHeader = ['PSTN'.colorize(:cyan), 'Dedupe'.colorize(:cyan),'Compression'.colorize(:cyan),'DRR'.colorize(:cyan),'Thin Ratio'.colorize(:cyan),'Total Efficiency'.colorize(:cyan)]
efficiencyRows = DossierEngine.generateEffRows(jsonHash,clusterCount)

sourceVerboseTitle = "Verbose - Source Volumes".colorize(:light_blue)
sourceVerboseHeader = ['PSTN'.colorize(:cyan), 'Count'.colorize(:cyan), 'Logical Consumed (TB)'.colorize(:cyan), "Mapped Logical Consumed (TB)".colorize(:cyan), "Total Logical (TB)".colorize(:cyan)]
sourceVerboseRows = ReportEngine.generateSourceVerboseRows(jsonHash,clusterCount,allVolumes,allSnapshotGroups)

snapVerboseTitle = "Verbose - Non-RP Snap Volumes".colorize(:light_blue)
snapVerboseHeader = ['PSTN'.colorize(:cyan), 'Count'.colorize(:cyan), 'Logical Consumed (TB)'.colorize(:cyan), "Mapped Logical Consumed (TB)".colorize(:cyan), "Total Logical (TB)".colorize(:cyan)]
snapVerboseRows = ReportEngine.generateSnapVerboseRows(jsonHash,clusterCount,allVolumes,allSnapshotGroups)

rpVerboseTitle = "Verbose - RP Snap Volumes".colorize(:light_blue)
rpVerboseHeader = ['PSTN'.colorize(:cyan), 'Count'.colorize(:cyan), 'Logical Consumed (TB)'.colorize(:cyan), "Mapped Logical Consumed (TB)".colorize(:cyan), "Total Logical (TB)".colorize(:cyan)]
rpVerboseRows = ReportEngine.generateRpVerboseRows(jsonHash,clusterCount,allVolumes,allSnapshotGroups)

drrVerboseTitle = "Verbose - DRR".colorize(:light_blue)
drrVerboseHeader = ['PSTN'.colorize(:cyan), 'Vols'.colorize(:cyan), 'Total Logical (TB)'.colorize(:cyan), "Logical Consumed (TB)".colorize(:cyan), "DRR - Source".colorize(:cyan), "DRR - Snap".colorize(:cyan), "DRR - All".colorize(:cyan)]
drrVerboseRows = ReportEngine.generateDrrVerboseRows(jsonHash,clusterCount,allVolumes,allSnapshotGroups)


configurationTable = ReportEngine.generateTable(configurationTitle,configurationHeader,configurationRows,tableWidth)
physCapacityTable = ReportEngine.generateTable(physCapacityTitle,physCapacityHeader,physCapacityRows,tableWidth)
logicalCapacityTable = ReportEngine.generateTable(logicalCapacityTitle,logicalCapacityHeader,logicalCapacityRows,tableWidth)
efficiencyTable = ReportEngine.generateTable(efficiencyTitle,efficiencyHeader,efficiencyRows,tableWidth)
sourceVerboseTable =  ReportEngine.generateTable(sourceVerboseTitle,sourceVerboseHeader,sourceVerboseRows,tableWidth2)
snapVerboseTable =  ReportEngine.generateTable(snapVerboseTitle,snapVerboseHeader,snapVerboseRows,tableWidth2)
rpVerboseTable =  ReportEngine.generateTable(rpVerboseTitle,rpVerboseHeader,rpVerboseRows,tableWidth2)
drrVerboseTable =  ReportEngine.generateTable(drrVerboseTitle,drrVerboseHeader,drrVerboseRows,tableWidth2)

#Print all tables to terminal
ReportEngine.printHeader
ReportEngine.printTable(xmsTable)
ReportEngine.printTable(configurationTable)
ReportEngine.printTable(physCapacityTable)
ReportEngine.printTable(logicalCapacityTable)
ReportEngine.printTable(efficiencyTable)
if flag == true
  ReportEngine.printTable(sourceVerboseTable)
  ReportEngine.printTable(snapVerboseTable)
  ReportEngine.printTable(rpVerboseTable)
  ReportEngine.printTable(drrVerboseTable)
end
ReportEngine.printFooter
