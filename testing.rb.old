#!/usr/bin/env ruby
require 'json'
require 'colorize'

#pull in the json file
filename = ARGV[0]
json = JSON.parse(File.read(filename))

#testing commands
#puts json["AllVolumes"][0]["logical_space_in_use"]


##### Script #####
puts " "
puts "#############################################".colorize(:yellow)
puts "##### XtremIO Configuration Report v0.0 #####".colorize(:yellow)
puts "#############################################".colorize(:yellow)
puts " "
#display XMS information
puts "---- XMS Configuration ---- ".colorize(:light_blue)
puts " XMS IP: " + json["AllXms"][0]["xms_ip"].colorize(:light_white)
puts " XMS Code: " + json["AllXms"][0]["sw_version"].colorize(:light_white)
puts " XIO Clusters:  " + json["AllXms"][0]["num_of_systems"].to_s.colorize(:light_white)

#Print out data for each connected XtremIO cluster
clusters = json["AllXms"][0]["num_of_systems"].to_i
counter = 0
clusters.times do
  clusterID = json["Systems"][counter]["name"]
  allVolumes =json["AllVolumes"]
  allSnapshotGroups = json["AllSnapshotGroups"]

  puts ""

  puts "---- Cluster #{(counter+1).to_s} Configuration ---- ".colorize(:light_blue)
  #System Name
  puts " Cluster Name: " + json["Systems"][counter]["name"].colorize(:light_white)

  #System Serial Number
  puts " Cluster S/N: " + json["SystemsInfo"][counter]["psnt"].colorize(:light_white)

  #Cluster Code Level
  puts " Cluster Code: " + json["SystemsInfo"][counter]["sys_sw_version"].colorize(:light_white)

  #System Name
  puts " Cluster Type: " + json["Systems"][counter]["size_and_capacity"].colorize(:light_white)

  #sys_health_state sys_state
  puts " System State: " + (json["AllSystems"][counter]["sys_health_state"] + " & " + json["AllSystems"][counter]["sys_state"]).colorize(:light_white)

  #sys_health_state
  puts " Major Alerts: " + json["AllSystems"][counter]["num_of_major_alerts"].to_s.colorize(:light_white)



  puts ""

  puts "---- Cluster #{(counter+1).to_s} Capacity ---- ".colorize(:light_blue)

  #Consumed SSD Space
  puts " Consumed Physical Space: " + (((json["Systems"][counter]["ud_ssd_space_in_use"]).to_f)/1024.0/1024.0/1024.0).round(1).to_s.colorize(:light_white) + " TB".colorize(:light_white)

  #Free SSD Space
  puts " Free Physical Space: " + (((json["AllSystems"][counter]["free_ud_ssd_space"]).to_f)/1024.0/1024.0/1024.0).round(1).to_s.colorize(:light_white) + " TB".colorize(:light_white)

  #Total SSD Space
  puts " Total Physical Space: " + (((json["Systems"][counter]["ud_ssd_space"]).to_f)/1024.0/1024.0/1024.0).round(1).to_s.colorize(:light_white) + " TB".colorize(:light_white)

  #logical_space_in_use
  puts " Consumed Logical Space: " + (((json["AllSystems"][counter]["logical_space_in_use"]).to_f)/1024.0/1024.0/1024.0).round(1).to_s.colorize(:light_white) + " TB".colorize(:light_white)

  #free_logical_space
  puts " Free Logical Space: " + (((json["AllSystems"][counter]["free_logical_space"]).to_f)/1024.0/1024.0/1024.0).round(1).to_s.colorize(:light_white) + " TB".colorize(:light_white)


  puts ""
  puts "---- Cluster #{(counter+1).to_s} Efficiency ---- ".colorize(:light_blue)

  #Dedup Ratio
  puts " Dedup Ratio: " + json["AllSystems"][counter]["dedup_ratio"].round(1).to_s.colorize(:light_white)

  #Compression Ratio
  puts " Compression Ratio: " + json["AllSystems"][counter]["compression_factor"].round(1).to_s.colorize(:light_white)

  #Compression Ratio
  puts " DRR: " + json["AllSystems"][counter]["data_reduction_ratio"].round(1).to_s.colorize(:light_white)

  #Thin Provisioning Ratio
  puts " Thin Provisioning Ratio: " + json["AllSystems"][counter]["thin_provisioning_ratio"].round(1).to_s.colorize(:light_white)

  #overall_efficiency_ratio
  puts " Overall Efficiency Ratio: " + json["AllSystems"][counter]["overall_efficiency_ratio"].round(1).to_s.colorize(:light_white)


  puts ""
  puts "---- Cluster #{(counter+1).to_s} Volumes ---- ".colorize(:light_blue)
  sourceCount = 0
  sourceLogicalConsumed = 0.0
  sourceTotalLogical = 0.0
  snapCount = 0
  snapLogicalConsumed = 0.0
  snapTotalLogical = 0.0
  combinedLogicalConsumed = 0.0
  combinedLogical = 0.0

  allVolumes.each do |vol|
    if vol["sys_id"][1] == clusterID
      if vol["created_from_volume"] == ""
        sourceCount += 1
        sourceLogicalConsumed += (vol["logical_space_in_use"].to_f)/1024.0/1024.0/1024.0
        sourceTotalLogical += (vol["vol_size"].to_f)/1024.0/1024.0/1024.0
        combinedLogical += (vol["vol_size"].to_f)/1024.0/1024.0/1024.0
        combinedLogicalConsumed += (vol["logical_space_in_use"].to_f)/1024.0/1024.0/1024.0
      else
        snapCount += 1
        snapLogicalConsumed += (vol["logical_space_in_use"].to_f)/1024.0/1024.0/1024.0
        snapTotalLogical += (vol["vol_size"].to_f)/1024.0/1024.0/1024.0
        combinedLogical += (vol["vol_size"].to_f)/1024.0/1024.0/1024.0
        combinedLogicalConsumed += (vol["logical_space_in_use"].to_f)/1024.0/1024.0/1024.0
      end
    end
  end
  puts " Source Volume Count = " + sourceCount.to_s.colorize(:light_white)
  puts " Snapshot Volume Count = " + snapCount.to_s.colorize(:light_white)
  #puts " Source Logical Consumed = " + (volLogicalConsumed.round(1).to_s + " TB").colorize(:light_white)
  #puts " Snapshot Logical Consumed = " + (sourceLogicalConsumed.round(1).to_s + " TB").colorize(:light_white)
  #puts " Combined Logical Consumed = " + (combinedLogicalConsumed.round(1).to_s + " TB").colorize(:light_white)
  #puts " Source Total Logical  = " + (sourceTotalLogical.round(1).to_s + " TB").colorize(:light_white)
  #puts " Snapshot Total Logical = " + (snapTotalLogical.round(1).to_s + " TB").colorize(:light_white)
  #puts " Combined Total Logical = " + (combinedLogical.round(1).to_s + " TB").colorize(:light_white)

  sgCount = 0
  sgConsumed = 0.0
  sgTotal = 0.0
  allSnapshotGroups.each do |sg|
    if sg["sys_id"][1] == clusterID
      #puts "Group " + sg["snapgrp_id"][2].to_s + " | Vols " + sg["num_of_vols"].to_s  +
      #" | Logical Consumed " + ((sg["logical_space_in_use"].to_f)/1024.0/1024.0/1024.0).round(1).to_s +
      #" | Total Logical " + ((sg["vol_size"].to_f)/1024.0/1024.0/1024.0).round(1).to_s
      sgCount += 1
      sgConsumed += (sg["logical_space_in_use"].to_f)/1024.0/1024.0/1024.0
      sgTotal += (sg["vol_size"].to_f)/1024.0/1024.0/1024.0
    end
  end
 puts ""
 puts " Snapshot Group Count = " + sgCount.to_s.colorize(:light_white)
 puts " Snapshot Group Logical Consumed = " + (sgConsumed.round(1).to_s + " TB").colorize(:light_white)
 puts " Snapshot Group Total Logical = " + (sgTotal.round(1).to_s + " TB").colorize(:light_white)
  #increment the counter
  counter+=1
end
