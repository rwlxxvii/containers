#!/usr/bin/python
import requests, json, time, urllib3
 
# Variables
nessusBaseURL="https://127.0.0.1:8834"
access_key="    "
secret_key="    "
upToThisManyDaysAgo=5
folderID = 3
sleepPeriod = 5
# Turn off TLS warnings
urllib3.disable_warnings()
 
# Show all folders
URL=nessusBaseURL+"/folders"
headers = {'Content-type': 'application/json', "X-ApiKeys": "accessKey={}; secretKey={}".format(access_key, secret_key)}
t = requests.get(url = URL, headers=headers, verify = False)
jsonFolder = t.json()
print(jsonFolder)
 
# Look for scans from upToThisManyDaysAgo from GET /scans request
epochTime = time.time()
lastDay = str(epochTime - ( 60 * 60 * 24 * upToThisManyDaysAgo))
splitDay = lastDay.split('.',-1)
URL = nessusBaseURL+"/scans?folder_id="+str(folderID)+"&last_modification_date="+splitDay[0]
t = requests.get(url = URL, headers=headers, verify = False)
data = t.json()
 
# Cycle through the scans from upToThisManyDaysAgo looking for ones that have been completed and add them to a list
scanIDs = []
for line in data['scans']:
    if line['status'] == 'completed':
        scanIDs.append([line['id'],line['name']])
 
# Main loop for the program
for listID in scanIDs:
    ID = listID[0]
    NAME = str(listID[1])
 
    # Call the POST /export function to collect details for each scan
    URL = nessusBaseURL+"/scans/"+str(ID)+"/export"
 
    # In this case, we're asking for a:
    #   - CSV export
    #   - Only requesting certain fields
    #   - Severity = 4 (aka Critical) only
    payload = {
        "format": "csv",
        "reportContents": {
            "csvColumns": {
                "id": True,
                "cve": True,
                "cvss": True,
                "risk": True,
                "hostname": True,
                "protocol": True,
                "port": True,
                "plugin_name": True,
                "synopsis": False,
                "description": True,
                "solution": True,
                "see_also": False,
                "plugin_output": True,
                "stig_severity": False,
                "cvss3_base_score": True,
                "cvss_temporal_score": False,
                "cvss3_temporal_score": False,
                "risk_factor": False,
                "references": True,
                "plugin_information": True,
                "exploitable_with": True
            }
        },
        "extraFilters": {
            "host_ids": [],
            "plugin_ids": []
        },
        "filter.0.quality": "eq",
        "filter.0.filter": "severity",
        "filter.0.value": "Critical",
        "filter.1.quality": "eq",
        "filter.1.filter": "severity",
        "filter.1.value": "High",
        "filter.2.quality": "eq",
        "filter.2.filter": "severity",
        "filter.2.value": "Medium",
        "filter.3.quality": "eq",
        "filter.3.filter": "severity",
        "filter.3.value": "Low"
    }
 
    # Pass the POST request in json format. Two items are returned, file and token
    jsonPayload = json.dumps(payload)
    r = requests.post(url = URL, headers=headers, data = jsonPayload, verify = False)
    jsonData = r.json()
    scanFile = str(jsonData['file'])
 
    # Use the file just received and check to see if it's 'ready', otherwise sleep for sleepPeriod seconds and try again
    status = "loading"
    while status != 'ready':
        URL = nessusBaseURL+"/scans/"+str(ID)+"/export/"+scanFile+"/status"
        t = requests.get(url = URL, headers=headers, verify = False)
        data = t.json()
        if data['status'] == 'ready':
            status = 'ready'
        else:
            time.sleep(sleepPeriod)
 
    # Now that the report is ready, download
    URL = nessusBaseURL+"/scans/"+str(ID)+"/export/"+scanFile+"/download"
    d = requests.get(url = URL, headers=headers, verify = False)
    dataBack = d.text
 
    # Clean up the CSV data
    csvData = dataBack.split('\r\n',-1)
    NAMECLEAN=NAME.replace('/','-',-1)
    print("-----------------------------------------------")
    print("Starting  "+NAMECLEAN)
    for line in csvData:
        print(line)
    print("Completed "+NAMECLEAN)
