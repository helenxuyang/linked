import requests
from requests.auth import HTTPBasicAuth
import json
import datetime


create_event_json_str = '{ "summary":"test event (serve acct)", "description":"created event via service acct", "start": {"dateTime": "2020-09-22T01:22:40.410446Z"}, "end": {"dateTime": "2020-09-22T02:22:40.410446Z"}, "attendees": [{ "email": "sih28@cornell.edu" }] }'
edit_event_json_str = '{"summary":"Some edited event"}'

# response = requests.post('https://127.0.0.1:5000/create-event', json=json_str, auth=HTTPBasicAuth(user, pwd))
# response = requests.post('http://127.0.0.1:5000/create-event', json=create_event_json_str, verify=False)
# print(response)
response = requests.put('http://127.0.0.1:5000/edit-event?id=oo7pc5vbrac64umn0210494t08', json=edit_event_json_str, verify=False)
print(response)

