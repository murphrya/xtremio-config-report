#!/usr/bin/env ruby
require 'json'
require 'colorize'
require 'terminal-table'
require 'csv'
load 'modules\dossierEngine.rb'
load 'modules\reportEngine.rb'
include DossierEngine
include ReportEngine

#Generate Variables Used by multiple clusters
Process.setproctitle("XtremIO Summary Report")
location = DossierEngine.getFileLocation
dossierCount = getDossierCount(location)
multipleJsonArray = unpackMultipleDossierJson(location)

#Main Program Loop
clustersArray = []
totalPhysUsable = 0.0
totalPhysConsumed = 0.0
totalPhysFree = 0.0
totalSvgConsumed = 0.0
totalSvgTotalLogical = 0.0
totalSourceVolCount = 0
totalSnapVolCount = 0
totalDRR = 0
totalSourceLogicalConsumed = 0.0
totalSnapLogicalConsumed = 0.0
totalCombinedLogicalConsumed = 0.0
totalSourceDRR = 0.0
totalSnapDRR = 0.0
totalCombinedDRR = 0.0
dossierCount = 1

#for each dossier file
multipleJsonArray.each do |jsonHash|
  clusterCount = DossierEngine.getClusterCount(jsonHash)
  counter = 0
  allVolumes = DossierEngine.getAllVolumes(jsonHash)
  allSnapshotGroups = DossierEngine.getAllSnapshotGroups(jsonHash)

  puts "[Status] - Generating XtremIO Summary from dossier #{dossierCount}"
  #for each cluster in the dossier file
  clusterCount.times do
    clusterSerial = jsonHash["SystemsInfo"][counter]["psnt"]
    clusterName = jsonHash["Systems"][counter]["name"]
    clusterCode = jsonHash["SystemsInfo"][counter]["sys_sw_version"]
    clusterType = jsonHash["Systems"][counter]["size_and_capacity"]
    clusterState = jsonHash["AllSystems"][counter]["sys_health_state"]
    clusterPhysConsumed = (((jsonHash["Systems"][counter]["ud_ssd_space_in_use"]).to_f)/1024.0/1024.0/1024.0).round(2)
    clusterPhysFree = (((jsonHash["AllSystems"][counter]["free_ud_ssd_space"]).to_f)/1024.0/1024.0/1024.0).round(2)
    clusterPhysUsable = (((jsonHash["Systems"][counter]["ud_ssd_space"]).to_f)/1024.0/1024.0/1024.0).round(2)
    clusterSvgCount = 0
    clusterSvgConsumed = 0.0
    clusterSvgTotalLogical = 0.0
    clusterSourceVolCount = 0
    clusterSnapVolCount = 0
    clusterDedupe = jsonHash["AllSystems"][counter]["dedup_ratio"].round(2)
    clusterCompression = jsonHash["AllSystems"][counter]["compression_factor"].round(2)
    clusterDRR = jsonHash["AllSystems"][counter]["data_reduction_ratio"].round(2)
    clusterThinRatio = jsonHash["AllSystems"][counter]["thin_provisioning_ratio"].round(2)
    clusterOverallEff = jsonHash["AllSystems"][counter]["overall_efficiency_ratio"].round(2)
    clusterSourceVolLogicalConsumed = 0.0
    clusterSourceVolTotalLogical = 0.0
    clusterSnapVolLogicalConsumed = 0.0
    clusterSnapVolTotalLogical = 0.0

    #generate logical consumed and total logical
    allSnapshotGroups.each do |sg|
      if sg["sys_id"][1] == jsonHash["Systems"][counter]["name"]
        clusterSvgCount += 1
        clusterSvgConsumed += ((sg["logical_space_in_use"].to_f)/1024.0/1024.0/1024.0).round(2)
        clusterSvgTotalLogical += ((sg["vol_size"].to_f)/1024.0/1024.0/1024.0).round(2)
      end
    end

    #generate source and snap count
    allVolumes.each do |vol|
      if vol["sys_id"][1] == jsonHash["Systems"][counter]["name"]
        if vol["created_from_volume"] == ""
          clusterSourceVolCount += 1
          clusterSourceVolLogicalConsumed += ((vol["logical_space_in_use"].to_f)/1024.0/1024.0/1024.0).round(2)
          clusterSourceVolTotalLogical += ((vol["vol_size"].to_f)/1024.0/1024.0/1024.0).round(2)
          totalSourceLogicalConsumed += ((vol["logical_space_in_use"].to_f)/1024.0/1024.0/1024.0).round(2)

        else
          clusterSnapVolCount += 1
          clusterSnapVolLogicalConsumed += ((vol["logical_space_in_use"].to_f)/1024.0/1024.0/1024.0).round(2)
          clusterSnapVolTotalLogical += ((vol["vol_size"].to_f)/1024.0/1024.0/1024.0).round(2)
          totalSnapLogicalConsumed += ((vol["logical_space_in_use"].to_f)/1024.0/1024.0/1024.0).round(2)
        end
      end
    end

    #add to totals
    totalPhysUsable += clusterPhysUsable
    totalPhysConsumed += clusterPhysConsumed
    totalPhysFree += clusterPhysFree
    totalSvgConsumed += clusterSvgConsumed
    totalSvgTotalLogical += clusterSvgTotalLogical
    totalSourceVolCount += clusterSourceVolCount
    totalSnapVolCount += clusterSnapVolCount


    #verbose
    combinedLogicalConsumed = (clusterSourceVolLogicalConsumed + clusterSnapVolLogicalConsumed).round(2)
    sourceDRR = (clusterSourceVolLogicalConsumed / clusterPhysConsumed).round(2)
    snapDRR = (clusterSnapVolLogicalConsumed / clusterPhysConsumed).round(2)
    combinedDRR = ((clusterSourceVolLogicalConsumed+clusterSnapVolLogicalConsumed) / clusterPhysConsumed).round(2)

    clusterData = {:pstn => clusterSerial, :name => clusterName, :code => clusterCode, :type => clusterType, :state => clusterState,
                   :physUsable => clusterPhysUsable, :physConsumed => clusterPhysConsumed, :physFree => clusterPhysFree,
                   :logicalConsumed => clusterSvgConsumed, :totalLogical => clusterSvgTotalLogical, :sourceVolCount => clusterSourceVolCount, :snapVolCount => clusterSnapVolCount,
                   :dedupe => clusterDedupe, :compression => clusterCompression, :drr => clusterDRR, :thinRatio => clusterThinRatio, :overallEff => clusterOverallEff,
                   :sourceLogicalConsumed => clusterSourceVolLogicalConsumed, :snapLogicalConsumed => clusterSnapVolLogicalConsumed, :combinedLogicalConsumed => combinedLogicalConsumed,
                   :sourceDRR => sourceDRR, :snapDRR => snapDRR, :combinedDRR => combinedDRR}
    clustersArray.push(clusterData)
    counter += 1
  end
  dossierCount += 1
end

puts "[Status] - Generating totals from all dossier reports"
totalDRR = (totalSvgConsumed / totalPhysConsumed).round(2)
totalCombinedLogicalConsumed = (totalSourceLogicalConsumed + totalSnapLogicalConsumed).round(2)
totalSourceDRR = (totalSourceLogicalConsumed / totalPhysConsumed).round(2)
totalSnapDRR = (totalSnapLogicalConsumed / totalPhysConsumed).round(2)
totalCombinedDRR = (totalCombinedLogicalConsumed / totalPhysConsumed).round(2)

CSV.open("dossierSummary.csv", "w") do |csv|
  csv <<["XtremIO Summary Report - " + Time.now.strftime('%m/%d/%Y - %H:%M:%S')]
  csv <<[" "]
  csv <<[" "]
  csv <<["Basic Cluster Information"]
  csv <<["Serial Number", "Cluster Name", "Cluster Code", "Cluster Type", "Cluster State", "Physical Usable (TB)", "Physical Consumed (TB)", "Physical Free (TB)",
         "Logical Consumed (TB)", "Total Logical (TB)", "Source Vol Count", "Snap Vol Count",
         "Dedupe", "Compression", "DRR", "Thin Ratio", "Overall Efficiency"]
  clustersArray.each do |clusterData|
    csv << [clusterData[:pstn], clusterData[:name], clusterData[:code], clusterData[:type], clusterData[:state], clusterData[:physUsable], clusterData[:physConsumed],
            clusterData[:physFree], clusterData[:logicalConsumed], clusterData[:totalLogical], clusterData[:sourceVolCount], clusterData[:snapVolCount],
            clusterData[:dedupe], clusterData[:compression], clusterData[:drr], clusterData[:thinRatio], clusterData[:overallEff]]
  end
  csv <<["Totals","-","-","-","-",totalPhysUsable,totalPhysConsumed,totalPhysFree,totalSvgConsumed,totalSvgTotalLogical,totalSourceVolCount,totalSnapVolCount,
         "-", "-", totalDRR,"-","-"]

  #if verbose flag is set
  if DossierEngine.getFlags == true
    csv <<[" "]
    csv <<["Verbose Cluster Information"]
    csv <<["Serial Number", "Cluster Name", "Physical Consumed (TB)", "Source Logical Consumed (TB)", "Snapshot Logical Consumed (TB)", "Combined Logical Consumed (TB)", "DRR - Source", "DRR - Snap", "DRR - Combined"]
    clustersArray.each do |clusterData|
      csv << [clusterData[:pstn], clusterData[:name], clusterData[:physConsumed], clusterData[:sourceLogicalConsumed], clusterData[:snapLogicalConsumed], clusterData[:combinedLogicalConsumed],
              clusterData[:sourceDRR], clusterData[:snapDRR], clusterData[:combinedDRR]]
    end
    csv <<["Totals","-",totalPhysConsumed,totalSourceLogicalConsumed,totalSnapLogicalConsumed,totalCombinedLogicalConsumed,totalSourceDRR,totalSnapDRR,totalCombinedDRR]
  end

end
