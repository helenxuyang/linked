import requests
from requests.auth import HTTPBasicAuth
import json
import datetime

user_to_invite = 'sih28@cornell.edu'

def create_event_test():
  create_event_json_str = '{ "summary":"test event (serve acct)", "description":"created event via service acct", "start": {"dateTime": "2020-09-22T01:22:40.410446Z"}, "end": {"dateTime": "2020-09-22T02:22:40.410446Z"}, "attendees": [{ "email": "sih28@cornell.edu" }] }'
  response = requests.post('http://127.0.0.1:5000/create-event', json=create_event_json_str, verify=False)
  return response

def edit_event_test():
  # edit_event_json_str = '{"summary":"Some edited event"}'
  start_datetime = datetime.datetime.utcnow()
  start_dt_str = start_datetime.isoformat() + 'Z' # 'Z' indicates UTC time
  end_dt_str = (start_datetime + datetime.timedelta(minutes=60)).isoformat() + 'Z'
  edit_event_json_str = '{"summary":"test event,edit (serve acct)", "description":"created event via service acct", "start": {"dateTime": "%s"}, "end": {"dateTime": "%s"}, "attendees": [{ "email": "sih28@cornell.edu" }] }' % (start_dt_str, end_dt_str)
  response = requests.put('http://127.0.0.1:5000/edit-event?id=oo7pc5vbrac64umn0210494t08', json=edit_event_json_str, verify=False)
  return response

if __name__ == '__main__':
  # test_fns = [create_event_test, edit_event_test]
  # expected_error_code = [201, 201]
  test_fns = [edit_event_test]
  for test in test_fns:
    result = test()
    print(result)


