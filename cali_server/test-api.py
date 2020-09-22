import requests
from requests.auth import HTTPBasicAuth
import json
import datetime


json_str = '{ "summary":"test event (serve acct)", "description":"created event via service acct", "start": {"dateTime": "2020-09-22T01:22:40.410446Z"}, "end": {"dateTime": "2020-09-22T02:22:40.410446Z"}, "attendees": [{ "email": "sih28@cornell.edu" }] }'

# response = requests.post('https://127.0.0.1:5000/create-event', json=json_str, auth=HTTPBasicAuth(user, pwd))
response = requests.post('http://127.0.0.1:5000/create-event', json=json_str, verify=False)
print(response)