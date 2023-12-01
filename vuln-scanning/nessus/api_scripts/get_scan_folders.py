#!/usr/bin/python
import requests, json, time, urllib3

# Variables
nessusBaseURL="https://127.0.0.1:8834"
access_key="enter aKey"
secret_key="enter sKey"

# Show all folders
URL=nessusBaseURL+"/folders"
headers = {'Content-type': 'application/json', "X-ApiKeys": "accessKey={}; secretKey={}".format(access_key, secret_key)}
t = requests.get(url = URL, headers=headers, verify = False)
jsonFolder = t.json()
print(json.dumps(jsonFolder, indent=4, sort_keys=True))

# Show all scans
URL=nessusBaseURL+"/scans"
headers = {'Content-type': 'application/json', "X-ApiKeys": "accessKey={}; secretKey={}".format(access_key, secret_key)}
t = requests.get(url = URL, headers=headers, verify = False) 
jsonScans = t.json()
print(json.dumps(jsonScans, indent=4, sort_keys=True))
