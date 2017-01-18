##Placeholder README - Detailed Instructions are a work in progress

##Run Report
1. Place dossier files into a folder. In this example they will be placed in C:/Users/Administrator/Desktop/DossierFiles
2. Navigate to the xtremio-config-report folder
3. Make sure you are on the latest version: ```git pull```
4. Make sure you have all the required ruby gems intalled: ```bundle install```
5. From the xtremio-config-report folder run the generate summary command. Provide the full path to the dossier folder, including the trailing / at the end.
6. Example of running the report: ```ruby generateSummary.rb "C:/Users/Administrator/Desktop/DossierFiles/"```
