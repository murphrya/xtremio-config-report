require 'json'
module DossierEngine
  #Get the location of the json file from the user
  def getFileLocation
    return ARGV[0]
  end

  #Get the location of the json file from the user
  def getFlags
    if ARGV[1] == "verbose"
      return true
    else
      return false
    end
  end

  #Opens dossier file and pulls out the json data
  def unpackDossieJson(location)
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

  #Returns all volumes assoicated with the XMS servers clusters
  def getAllVolumes(jsonHash)
    return jsonHash["AllVolumes"]
  end

  #Returns all volume snapshot groups associated with the XMS servers clusters
  def getAllSnapshotGroups(jsonHash)
    return jsonHash["AllSnapshotGroups"]
  end

  #generate config rows
  def generateConfigurationRows(jsonHash,clusterCount)
    counter = 0
    configurationRows = []
    clusterCount.times do
      clusterSerial = jsonHash["SystemsInfo"][counter]["psnt"].colorize(:light_white)
      clusterName = jsonHash["Systems"][counter]["name"].colorize(:light_white)
      clusterCode = jsonHash["SystemsInfo"][counter]["sys_sw_version"].colorize(:light_white)
      clusterType = jsonHash["Systems"][counter]["size_and_capacity"].colorize(:light_white)
      clusterState = jsonHash["AllSystems"][counter]["sys_health_state"].colorize(:light_white)
      clusterMajorAlerts = jsonHash["AllSystems"][counter]["num_of_major_alerts"].to_s.colorize(:light_white)
      configurationRows << [clusterSerial, clusterName, clusterCode, clusterType, clusterState,clusterMajorAlerts]
    end
    return configurationRows
  end

  #generate phys capacity rows
  def generatePhysCapRows(jsonHash,clusterCount)
    ##### Generate the clusters configuration table rows#####
    counter = 0
    physCapacityRows = []
    clusterCount.times do
      #Generate cluster configuration information
      clusterSerial = jsonHash["SystemsInfo"][counter]["psnt"].colorize(:light_white)
      clusterPhysConsumed = (((jsonHash["Systems"][counter]["ud_ssd_space_in_use"]).to_f)/1024.0/1024.0/1024.0).round(1).to_s.colorize(:light_white)
      clusterPhysFree = (((jsonHash["AllSystems"][counter]["free_ud_ssd_space"]).to_f)/1024.0/1024.0/1024.0).round(1).to_s.colorize(:light_white)
      clusterPhysUsable = (((jsonHash["Systems"][counter]["ud_ssd_space"]).to_f)/1024.0/1024.0/1024.0).round(1).to_s.colorize(:light_white)
      physCapacityRows << [clusterSerial,clusterPhysUsable,clusterPhysConsumed,clusterPhysFree]
    end
    return physCapacityRows
  end

  #generate logical capacity rows
  def generateLogiCapRows(jsonHash,clusterCount,allVolumes,allSnapshotGroups)
    counter = 0
    logicalCapacityRows = []
    sourceVolCount = 0
    snapVolCount = 0
    clusterCount.times do
      clusterSerial = jsonHash["SystemsInfo"][counter]["psnt"].colorize(:light_white)
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
      allVolumes.each do |vol|
        if vol["sys_id"][1] == jsonHash["Systems"][counter]["name"]
          if vol["created_from_volume"] == ""
            sourceVolCount += 1
          else
            snapVolCount += 1
          end
        end
      end
      clusterSvgTotal = clusterSvgCount.to_s.colorize(:light_white)
      clusterLogicalConsumed= clusterSvgConsumed.round(1).to_s.colorize(:light_white)
      clusterTotalLogical = clusterSvgTotalLogical.round(1).to_s.colorize(:light_white)
      sourceVolTotal = sourceVolCount.to_s.colorize(:light_white)
      snapVolTotal = snapVolCount.to_s.colorize(:light_white)
      logicalCapacityRows << [clusterSerial,clusterSvgTotal,clusterLogicalConsumed,clusterTotalLogical,sourceVolTotal,snapVolTotal]
    end
    return logicalCapacityRows
  end

  #generate eff rows
  def generateEffRows(jsonHash,clusterCount)
    counter = 0
    efficiencyRows = []
    clusterCount.times do
      #Generate cluster configuration information
      clusterSerial = jsonHash["SystemsInfo"][counter]["psnt"].colorize(:light_white)
      clusterDedupe = jsonHash["AllSystems"][counter]["dedup_ratio"].round(1).to_s.colorize(:light_white)
      clusterCompression = jsonHash["AllSystems"][counter]["compression_factor"].round(1).to_s.colorize(:light_white)
      clusterDRR = jsonHash["AllSystems"][counter]["data_reduction_ratio"].round(1).to_s.colorize(:light_white)
      clusterThinRatio = jsonHash["AllSystems"][counter]["thin_provisioning_ratio"].round(1).to_s.colorize(:light_white)
      clusterOverallEff = jsonHash["AllSystems"][counter]["overall_efficiency_ratio"].round(1).to_s.colorize(:light_white)
      efficiencyRows << [clusterSerial,clusterDedupe,clusterCompression,clusterDRR,clusterThinRatio,clusterOverallEff]
    end
    return efficiencyRows
  end


  def generateVerboseRows(jsonHash,clusterCount,allVolumes,allSnapshotGroups)
    counter = 0
    sourceVolCount = 0
    sourceVolConsumed = 0.0
    sourceVolTotalLogi = 0.0
    snapVolCount = 0
    snapVolConsumed = 0.0
    snapVolTotalLogi = 0.0
    rpVolCount = 0
    rpVolConsumed = 0.0
    rpVolTotalLogi = 0.0
    verboseRows = []
    clusterCount.times do
      #Generate cluster configuration information
      clusterSerial = jsonHash["SystemsInfo"][counter]["psnt"].colorize(:light_white)
      #totals for each volume type
      allVolumes.each do |vol|
        if vol["sys_id"][1] == jsonHash["Systems"][counter]["name"]
          if vol["created_from_volume"] == ""
            sourceVolCount += 1
            sourceVolConsumed += (vol["logical_space_in_use"].to_f)/1024.0/1024.0/1024.0
            sourceVolTotalLogi += (vol["vol_size"].to_f)/1024.0/1024.0/1024.0
          else
            if vol["created_by_app"] == ""
              snapVolCount += 1
              snapVolConsumed += (vol["logical_space_in_use"].to_f)/1024.0/1024.0/1024.0
              snapVolTotalLogi += (vol["vol_size"].to_f)/1024.0/1024.0/1024.0
            else
              rpVolCount += 1
              rpVolConsumed += (vol["logical_space_in_use"].to_f)/1024.0/1024.0/1024.0
              rpVolTotalLogi += (vol["vol_size"].to_f)/1024.0/1024.0/1024.0
            end
          end
        end
      end

      totalSourceVols = sourceVolCount.to_s.colorize(:light_white)
      totalSourceConsumed = sourceVolConsumed.round(1).to_s.colorize(:light_white)
      totalSnapVols = snapVolCount.to_s.colorize(:light_white)
      totalSnapConsumed = snapVolConsumed.round(1).to_s.colorize(:light_white)
      totalRpVols = rpVolCount.to_s.colorize(:light_white)
      totalRpConsumed = rpVolConsumed.round(1).to_s.colorize(:light_white)
      verboseRows << [clusterSerial,totalSourceVols,totalSourceConsumed,totalSnapVols,totalSnapConsumed,totalRpVols,totalRpConsumed]
    end
    return verboseRows
  end
end
