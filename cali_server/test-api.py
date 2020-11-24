import requests
from requests.auth import HTTPBasicAuth
import json
import datetime

user_to_invite = 'sih28@cornell.edu'
user_to_invite_alt = 'acctholdersaleh@gmail.com'
http_addr = "http://127.0.0.1"
http_port = "5000"
http_root_link = "%s:%s" % (http_addr, http_port)

def create_event_test():
  create_event_json_str = '{ "summary":"test event (serve acct)", "description":"created event via service acct", "start": {"dateTime": "2020-09-22T01:22:40.410446Z"}, "end": {"dateTime": "2020-09-22T02:22:40.410446Z"}}'
  response = requests.post('%s/create-event' % http_root_link, json=create_event_json_str, verify=False)
  return response

def edit_event_test():
  # edit_event_json_str = '{"summary":"Some edited event"}'
  edit_event_id = "oo7pc5vbrac64umn0210494t08"
  start_datetime = datetime.datetime.utcnow()
  start_dt_str = start_datetime.isoformat() + 'Z' # 'Z' indicates UTC time
  end_dt_str = (start_datetime + datetime.timedelta(minutes=60)).isoformat() + 'Z'
  edit_event_json_str = '{"summary":"test event,edit (serve acct)", "description":"created event via service acct", "start": {"dateTime": "%s"}, "end": {"dateTime": "%s"}, "attendees": [{ "email": "sih28@cornell.edu" }] }' % (start_dt_str, end_dt_str)
  response = requests.put('%s/edit-event?id=%s' % (http_root_link, edit_event_id), json=edit_event_json_str, verify=False)
  return response

def add_attendee_test():
  start_datetime = datetime.datetime.utcnow()
  start_dt_str = start_datetime.isoformat() + 'Z' # 'Z' indicates UTC time
  end_dt_str = (start_datetime + datetime.timedelta(minutes=60)).isoformat() + 'Z'
  create_event_json_str = '{ "summary":"test event, add attendee (serve acct)", "description":"plz work", "start": {"dateTime": "%s"}, "end": {"dateTime": "%s"} }' % (start_dt_str, end_dt_str)
  response = requests.post('%s/create-event' % http_root_link, json=create_event_json_str, verify=False)
  created_event_id = response.json().get('id')
  assert isinstance(created_event_id, str)
  assert len(created_event_id) > 0
  response = requests.put('%s/add-attendee?event-id=%s&attendee=%s' % (http_root_link,created_event_id,user_to_invite) )
  return response

def remove_attendee_test():
  start_datetime = datetime.datetime.utcnow()
  start_dt_str = start_datetime.isoformat() + 'Z' # 'Z' indicates UTC time
  end_dt_str = (start_datetime + datetime.timedelta(minutes=60)).isoformat() + 'Z'
  create_event_json_str = '{ "summary":"test event, remove attendee (serve acct)", "description":"plz work", "start": {"dateTime": "%s"}, "end": {"dateTime": "%s"}, "attendees": [{ "email": "sih28@cornell.edu"}, {"email":"acctholdersaleh@gmail.com"}] }' % (start_dt_str, end_dt_str)
  response = requests.post('%s/create-event' % http_root_link, json=create_event_json_str, verify=False)
  created_event_id = response.json['id']
  response = requests.put('%s/add-attendee?event-id=%s&attendee=%s' % (http_root_link,created_event_id,user_to_invite) )
  return response

if __name__ == '__main__':
  # test_fns = [create_event_test, edit_event_test]
  # test_fns = [create_event_test]
  test_fns = [add_attendee_test]
  expected_error_code = [201, 201, 201]
  for test in test_fns:
    result = test()
    print(result)


