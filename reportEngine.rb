#!/usr/bin/env ruby
require 'json'
require 'colorize'

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


#testing commands
#puts json["AllVolumes"][0]["logical_space_in_use"]


##### Generate Variables #####
location = getFileLocation
jsonHash = getJsonHash(location)
clusterCount = getClusterCount(jsonHash)
xmsIp = getXmsIp(jsonHash)
xmsCode = getXmsCode(jsonHash)


puts " "
puts "#############################################".colorize(:yellow)
puts "##### XtremIO Configuration Report v0.0 #####".colorize(:yellow)
puts "#############################################".colorize(:yellow)
puts " "
#display XMS information
puts "---- XMS Configuration ---- ".colorize(:light_blue)
puts " XMS IP: " + xmsIp.colorize(:light_white)
puts " XMS Code: " + xmsCode.colorize(:light_white)
puts " XtremIO Clusters:  " + clusterCount.to_s.colorize(:light_white)
