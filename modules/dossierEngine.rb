require 'json'
require 'fileutils'
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

  #
  def formatLocation(location)
    return location.gsub("\\","/")
  end

  #
  def getDossierCount(location)
    dossierFiles = Dir[location+"*"]
  end

  #
  def generateCSVFilename(location)
    return location + "dossierSummary.csv"
  end

  #
  def unpackMultipleDossierJson(location)
    dossierCount = getDossierCount(location).length
    counter = 1
    multipleJsonArray = []
    dossierFiles = Dir[location+"*"]
    puts "[Status] - There are #{dossierCount} files that will be unpacked:"
    dossierFiles.each do |dossier|
      puts "[Status] - Unpacking dossier file #{counter}"


      %x[unzip #{dossier} -d temp1x2y3z4]

      filenames = Dir["temp1x2y3z4/*"]
      filenames.each do |filename|
        if filename.include? ".bz2"
          Dir.mkdir 'temp2a3b4c5'
          %x[tar -xvf #{filename} -C temp2a3b4c5]
        end
        if filename.include? ".tar.gz"
          Dir.mkdir 'temp2a3b4c5'
          %x[tar -xvf #{filename} -C temp2a3b4c5]
        end
      end
      json = JSON.parse(File.read('temp2a3b4c5/small/xms/xmcli/show_all.json'))
      multipleJsonArray.push(json)
      FileUtils.rm_rf 'temp1x2y3z4'
      FileUtils.rm_rf 'temp2a3b4c5'
      counter += 1
      sleep(2)
    end
    return multipleJsonArray
  end

  #
  def getDossierTimestamp(location,pstn)
    timestamp = nil
    dossierFiles = Dir[location+"*"]
    dossierFiles.each do |dossier|
      if dossier.include? pstn
        filenameArray = dossier.split("/")
        filenameArray.each do |part|
          if part.include? "FNM00"
            filenameComponents = part.split("_")
            timestamp = filenameComponents[3]
          end
        end
      end
    end
    return timestamp
  end

  #
  def getClusterData(counter,jsonHash,allVolumes,allSnapshotGroups,location)
    clusterData = nil
    clusterCode = jsonHash["SystemsInfo"][counter]["sys_sw_version"]
    clusterSerial = jsonHash["SystemsInfo"][counter]["psnt"]

    #check the cluster code level
    if clusterCode.include? '3.0.'
      clusterData = {:pstn => clusterSerial, :code => '3.x'}
    else
      clusterName = jsonHash["Systems"][counter]["name"]
      clusterType = jsonHash["Systems"][counter]["size_and_capacity"]
      clusterState = jsonHash["AllSystems"][counter]["sys_health_state"]
      clusterPhysConsumed = (((jsonHash["Systems"][counter]["ud_ssd_space_in_use"]).to_f)/1024.0/1024.0/1024.0).round(2)
      clusterPhysFree = (((jsonHash["AllSystems"][counter]["free_ud_ssd_space"]).to_f)/1024.0/1024.0/1024.0).round(2)
      clusterPhysUsable = (((jsonHash["Systems"][counter]["ud_ssd_space"]).to_f)/1024.0/1024.0/1024.0).round(2)
      clusterPercFull = ((clusterPhysConsumed / clusterPhysUsable ) * 100).round(2)
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

          else
            clusterSnapVolCount += 1
            clusterSnapVolLogicalConsumed += ((vol["logical_space_in_use"].to_f)/1024.0/1024.0/1024.0).round(2)
            clusterSnapVolTotalLogical += ((vol["vol_size"].to_f)/1024.0/1024.0/1024.0).round(2)
          end
        end
      end

      #get the dossier file age
      dossierTimestamp = getDossierTimestamp(location,clusterSerial)

      #verbose
      combinedLogicalConsumed = (clusterSourceVolLogicalConsumed + clusterSnapVolLogicalConsumed).round(2)
      sourceDRR = (clusterSourceVolLogicalConsumed / clusterPhysConsumed).round(2)
      snapDRR = (clusterSnapVolLogicalConsumed / clusterPhysConsumed).round(2)
      combinedDRR = ((clusterSourceVolLogicalConsumed+clusterSnapVolLogicalConsumed) / clusterPhysConsumed).round(2)

      clusterData = {:pstn => clusterSerial, :name => clusterName, :timestamp => dossierTimestamp, :code => clusterCode, :type => clusterType, :state => clusterState,
                     :physUsable => clusterPhysUsable, :physConsumed => clusterPhysConsumed, :physFree => clusterPhysFree, :percFull => clusterPercFull,
                     :logicalConsumed => clusterSvgConsumed, :totalLogical => clusterSvgTotalLogical, :sourceVolCount => clusterSourceVolCount, :snapVolCount => clusterSnapVolCount,
                     :dedupe => clusterDedupe, :compression => clusterCompression, :drr => clusterDRR, :thinRatio => clusterThinRatio, :overallEff => clusterOverallEff,
                     :sourceLogicalConsumed => clusterSourceVolLogicalConsumed, :snapLogicalConsumed => clusterSnapVolLogicalConsumed, :combinedLogicalConsumed => combinedLogicalConsumed,
                     :sourceDRR => sourceDRR, :snapDRR => snapDRR, :combinedDRR => combinedDRR}
    end #end code check loop

    return clusterData
  end

  #
  def generateTotals(clustersArray)
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
    #get data from each cluster
    clustersArray.each do |clusterData|
      totalPhysUsable += clusterData[:physUsable]
      totalPhysConsumed += clusterData[:physConsumed]
      totalPhysFree += clusterData[:physFree]
      totalSvgConsumed += clusterData[:logicalConsumed]
      totalSvgTotalLogical += clusterData[:totalLogical]
      totalSourceVolCount += clusterData[:sourceVolCount]
      totalSnapVolCount += clusterData[:snapVolCount]
      totalSourceLogicalConsumed += clusterData[:sourceLogicalConsumed]
      totalSnapLogicalConsumed += clusterData[:snapLogicalConsumed]
    end
    totalDRR = (totalSvgConsumed / totalPhysConsumed).round(2)
    totalCombinedLogicalConsumed = (totalSourceLogicalConsumed + totalSnapLogicalConsumed).round(2)
    totalSourceDRR = (totalSourceLogicalConsumed / totalPhysConsumed).round(2)
    totalSnapDRR = (totalSnapLogicalConsumed / totalPhysConsumed).round(2)
    totalCombinedDRR = (totalCombinedLogicalConsumed / totalPhysConsumed).round(2)

    return {:totalPhysUsable => totalPhysUsable, :totalPhysConsumed => totalPhysConsumed, :totalPhysFree => totalPhysFree, :totalSvgConsumed => totalSvgConsumed,
            :totalSvgTotalLogical => totalSvgTotalLogical, :totalSourceVolCount => totalSourceVolCount, :totalSnapVolCount => totalSnapVolCount,
            :totalDRR => totalDRR, :totalSourceLogicalConsumed => totalSourceLogicalConsumed, :totalSnapLogicalConsumed => totalSnapLogicalConsumed,
            :totalCombinedLogicalConsumed => totalCombinedLogicalConsumed, :totalSourceDRR => totalSourceDRR, :totalSnapDRR => totalSnapDRR,
            :totalCombinedDRR => totalCombinedDRR}
  end

  #
  def generateSummaryCSV(clustersArray,totalsHash,location)
    CSV.open(DossierEngine.generateCSVFilename(location), "w") do |csv|
      csv <<["XtremIO Summary Report:", Time.now.strftime('%m/%d/%Y - %H:%M:%S')]
      csv <<[" "]
      csv <<[" "]
      csv <<["Basic Cluster Information"]
      csv <<["Serial Number", "Cluster Name", "Dossier Date","Cluster Code", "Cluster Type", "Cluster State", "Physical Usable (TB)", "Physical Consumed (TB)", "Physical Free (TB)", "% Full",
             "Logical Consumed (TB)", "Total Logical (TB)", "Source Vol Count", "Snap Vol Count",
             "Dedupe", "Compression", "DRR", "Thin Ratio", "Overall Efficiency"]
      clustersArray.each do |clusterData|
        csv << [clusterData[:pstn], clusterData[:name], clusterData[:timestamp], clusterData[:code], clusterData[:type], clusterData[:state], clusterData[:physUsable], clusterData[:physConsumed],
                clusterData[:physFree], clusterData[:percFull], clusterData[:logicalConsumed], clusterData[:totalLogical], clusterData[:sourceVolCount], clusterData[:snapVolCount],
                clusterData[:dedupe], clusterData[:compression], clusterData[:drr], clusterData[:thinRatio], clusterData[:overallEff]]
      end
      csv <<["Totals","-","-","-","-","-",totalsHash[:totalPhysUsable],totalsHash[:totalPhysConsumed],totalsHash[:totalPhysFree],"-",totalsHash[:totalSvgConsumed],totalsHash[:totalSvgTotalLogical],totalsHash[:totalSourceVolCount],totalsHash[:totalSnapVolCount],
             "-", "-", totalsHash[:totalDRR],"-","-"]

      #if verbose flag is set
      if DossierEngine.getFlags == true
        csv <<[" "]
        csv <<["Verbose Cluster Information"]
        csv <<["Serial Number", "Cluster Name", "Physical Consumed (TB)", "Source Logical Consumed (TB)", "Snapshot Logical Consumed (TB)", "Combined Logical Consumed (TB)", "DRR - Source", "DRR - Snap", "DRR - Combined"]
        clustersArray.each do |clusterData|
          csv << [clusterData[:pstn], clusterData[:name], clusterData[:physConsumed], clusterData[:sourceLogicalConsumed], clusterData[:snapLogicalConsumed], clusterData[:combinedLogicalConsumed],
                  clusterData[:sourceDRR], clusterData[:snapDRR], clusterData[:combinedDRR]]
        end
        csv <<["Totals","-",totalsHash[:totalPhysConsumed],totalsHash[:totalSourceLogicalConsumed],totalsHash[:totalSnapLogicalConsumed],totalsHash[:totalCombinedLogicalConsumed],totalsHash[:totalSourceDRR],totalsHash[:totalSnapDRR],totalsHash[:totalCombinedDRR]]
      end
    end
  end

  #Opens dossier file and pulls out the json data
  def unpackDossieJson(location)
    %x[unzip #{location} -d temp1x2y3z4]
    filenames = Dir["temp1x2y3z4/*"]
    filenames.each do |filename|
      if filename.include? ".bz2"
        %x[mkdir temp2a3b4c5]
        %x[tar -xvf #{filename} -C temp2a3b4c5]
      end
    end
    json = JSON.parse(File.read('temp2a3b4c5/small/xms/xmcli/show_all.json'))
    %x[rm -rf temp1x2y3z4]
    %x[rm -rf temp2a3b4c5]
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
    return jsonHash["AllSystems"].length.to_i
  end

  #Returns all volumes assoicated with the XMS servers clusters
  def getAllVolumes(jsonHash)
    return jsonHash["AllVolumes"]
  end

  #Returns all volume snapshot groups associated with the XMS servers clusters
  def getAllSnapshotGroups(jsonHash)
    return jsonHash["AllSnapshotGroups"]
  end





end
