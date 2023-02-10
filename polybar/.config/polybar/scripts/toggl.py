#!/usr/bin/env python3

import os
import time
import json

import requests
from dotenv import dotenv_values

config = dotenv_values(os.path.expanduser('~/.env'))
API_TOKEN = config.get("TOGGL_API_KEY")

if not API_TOKEN:
    print("API token empty")
    exit()
    
try:
    response = requests.get(
        url="https://api.track.toggl.com/api/v8/time_entries/current",
        auth=(API_TOKEN, "api_token")
    )
except:
    print("Network error")
    exit()

if response.status_code != 200:
    print(f"Toggl API: code {response.status_code}")
    exit()

response = response.json()

if not response['data'] or not ("pid" in response["data"] or "description" in response["data"]):
    print("  No project")
    exit()

seconds = time.time() - abs(response['data']['duration'])
m, s = divmod(seconds, 60)
h, m = divmod(m, 60)

if not "pid" in response["data"]:
    name = response['data']['description']
else:
    link = 'https://api.track.toggl.com/api/v8/projects/' + str(response['data']['pid'])
    name = json.loads(requests.get(link, auth=(API_TOKEN, "api_token")).content)["data"]["name"]

m = int(m)
h = int(h)
if m < 10: m = '0' + str(m)
m = str(m)
h = str(h)
out = "  " + name + " " + '(' + h + ':' + m + ')'
print(out)
