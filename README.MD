#Setup Pre-Req's
Below are the steps required to run the summary script on Windows:

###Step 1 - Install and configure Ruby for Windows
1. Download Ruby 2.2.6 32bit: https://dl.bintray.com/oneclick/rubyinstaller/rubyinstaller-2.2.6.exe
2. Install Ruby 2.2.6.
3. Download the Ruby Development Kit: https://dl.bintray.com/oneclick/rubyinstaller/DevKit-mingw64-32-4.7.2-20130224-1151-sfx.exe
4. Extract the Development Kit to C:\Devkit
5. Open up a Windows Command Prompt as an administrator and navigate to C:\Devkit
6. Initialize the Devkit with the following command: ``` bash dk.rb init```
7. Install the Devkit with the following command: ```dk.rb install```

###Step 2 - Install and configure Git for Windows


###Run Report
1. Place dossier files into a folder. In this example they will be placed in C:/Users/Administrator/Desktop/DossierFiles
2. Navigate to the xtremio-config-report folder
3. Make sure you are on the latest version: ```git pull```
4. Make sure you have all the required ruby gems intalled: ```bundle install```
5. From the xtremio-config-report folder run the generate summary command. Provide the full path to the dossier folder, including the trailing / at the end.
6. Example of running the report to generate csv output: ```ruby generateSummary.rb "C:/Users/Administrator/Desktop/DossierFiles/" "csv"```
7. Example of running the report to generate cli output: ```ruby generateSummary.rb "C:/Users/Administrator/Desktop/DossierFiles/" "cli"```
