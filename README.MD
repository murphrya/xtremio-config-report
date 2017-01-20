#Installation
Below are the steps required to run the summary script on Windows:

###Step 1 - Install and configure Ruby for Windows
1. Download Ruby 2.2.6 32bit: https://dl.bintray.com/oneclick/rubyinstaller/rubyinstaller-2.2.6.exe
2. Install Ruby 2.2.6.
3. Download the Ruby Development Kit: https://dl.bintray.com/oneclick/rubyinstaller/DevKit-mingw64-32-4.7.2-20130224-1151-sfx.exe
4. Extract the Development Kit to C:\Devkit
5. Open up a Windows Command Prompt as an administrator and navigate to C:\Devkit
6. Initialize the Devkit with the following command: ```dk.rb init```
7. Install the Devkit with the following command: ```dk.rb install```
8. Install the Ruby bundler: ```gem install bundle```

###Step 2 - Install and configure Git for Windows
1. Download Git for Windows: https://github.com/git-for-windows/git/releases/download/v2.11.0.windows.3/Git-2.11.0.3-64-bit.exe
2. Install Git for Windows, this will also install Git Bash (MINGWIN64) which we will use to run the script.

###Step 3 - Setup the report script
1. Open up a MINGWIN64 window by launching the Git Bash application.
2. Run the git clone command to copy down the script to your computer: ```git clone https://github.com/murphrya/xtremio-config-report.git```
3. CD into the report directory: ```cd xtremio-config-report```
4. Install the Ruby dependencies: ```bundle install```

#Use
1. Place your dossier file(s) into a folder. In this example they will be placed in C:/Users/Administrator/Desktop/DossierFiles
2. Navigate to the xtremio-config-report folder using Git Bash
3. Make sure you are on the latest version of the script: ```git pull```
4. From the xtremio-config-report folder run the generate summary command. Provide the full path to the dossier folder, including the trailing / at the end
5. Example of running the report to generate csv output: ```ruby generateSummary.rb "C:/Users/Administrator/Desktop/DossierFiles/" "csv"```
6. Example of running the report to generate cli output: ```ruby generateSummary.rb "C:/Users/Administrator/Desktop/DossierFiles/" "cli"```
