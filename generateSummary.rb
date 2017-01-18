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
rawLocation = DossierEngine.getFileLocation
location = DossierEngine.formatLocation(rawLocation)
dossierCount = DossierEngine.getDossierCount(location)
multipleJsonArray = DossierEngine.unpackMultipleDossierJson(location)

#Main Program Loop
clustersArray = []
dossierCount = 1

#for each dossier file
multipleJsonArray.each do |jsonHash|
  clusterCount = DossierEngine.getClusterCount(jsonHash)
  allVolumes = DossierEngine.getAllVolumes(jsonHash)
  allSnapshotGroups = DossierEngine.getAllSnapshotGroups(jsonHash)
  counter = 0

  puts "[Status] - Starting XtremIO analysis for dossier #{dossierCount}"
  puts "[Status] - Dossier #{dossierCount} has #{clusterCount} XtremIO cluster(s) attached"

  #for each cluster in the dossier file
  clusterCount.times do
    clusterData = DossierEngine.getClusterData(counter,jsonHash,allVolumes,allSnapshotGroups,location)
    puts "[Status] - Starting #{clusterData[:pstn]} analysis"
    if clusterData[:code] != '3.x'
      clustersArray.push(clusterData)
      puts "[Status] - Completed #{clusterData[:pstn]} analysis"
    else
      puts "[Warning] - Skipping #{clusterData[:pstn]} because it is a 3.x cluster"
    end
    counter += 1
  end #end cluster count loop
  puts "[Status] - Completed XtremIO analysis for dossier #{dossierCount}"
  dossierCount += 1
end # end dossier file multiple json loop

puts "[Status] - Generating totals from all XtremIO clusters"
totalsHash = DossierEngine.generateTotals(clustersArray)

puts "[Status] - Generating the csv summary file in #{location}"
DossierEngine.generateSummaryCSV(clustersArray,totalsHash,location)
