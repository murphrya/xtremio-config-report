require 'json'

#pull in the json file
json = JSON.parse(File.read("show_all.json"))

#testing commands
#puts json["SystemsInfo"][0]
#puts json["AllXms"][0]["xms_ip"]


##### Script #####

puts " "
#display XMS information
puts "---- XMS Information ---- "
puts " XMS IP: " + json["AllXms"][0]["xms_ip"]
puts " XMS Code: " + json["AllXms"][0]["sw_version"]
puts " Attached Clusters:  " + json["AllXms"][0]["num_of_systems"].to_s

puts ""
puts "---- Cluster 1 Configuration ---- "
#System Name
puts " Cluster Name: " + json["Systems"][0]["name"]

#System Serial Number
puts " Cluster S/N: " + json["SystemsInfo"][0]["psnt"]

#Cluster Code Level
puts " Cluster Code: " + json["SystemsInfo"][0]["sys_sw_version"]

#System Name
puts " Cluster Type: " + json["Systems"][0]["size_and_capacity"]

puts ""
puts "---- Cluster 1 Capacity ---- "
#Total SSD Space
puts " Total SSD Space: " + (((json["Systems"][0]["ud_ssd_space"]).to_f)/1024.0/1024.0/1024.0).round(1).to_s + "TB"

#Consumed SSD Space
puts " Consumed SSD Space: " + (((json["Systems"][0]["ud_ssd_space_in_use"]).to_f)/1024.0/1024.0/1024.0).round(1).to_s + "TB"

#Dedup Ratio
puts " Dedup Ratio: " + json["ClustersSavings"][0]["dedup_ratio_text"]

#Compression Ratio
puts " Compression Ratio: " + json["ClustersSavings"][0]["compression_factor_text"]

#Thin Provisioning Savings
puts " Thin Provisioning Savings: " + json["ClustersSavings"][0]["thin_provisioning_savings"].round(1).to_s
