require 'json'

module DossierEngine
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

  #Returns all volumes assoicated with the XMS servers clusters
  def getAllVolumes(jsonHash)
    return jsonHash["AllVolumes"]
  end

  #Returns all volume snapshot groups associated with the XMS servers clusters
  def getAllSnapshotGroups(jsonHash)
    return jsonHash["AllSnapshotGroups"]
  end
end
