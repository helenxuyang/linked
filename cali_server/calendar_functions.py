"""


"""
import os
import pickle
import json
import datetime
import logging
from googleapiclient.discovery import build
from google_auth_oauthlib.flow import InstalledAppFlow
from google.auth.transport.requests import Request

# If modifying these scopes, delete the file token.pickle.
SCOPES = ['https://www.googleapis.com/auth/calendar']

def get_calendar_service():
    creds = None
    # The file token.pickle stores the user's access and refresh tokens, and is
    # created automatically when the authorization flow completes for the first
    # time.
    if os.path.exists('token.pickle'):
        with open('token.pickle', 'rb') as token:
            creds = pickle.load(token)
    # If there are no (valid) credentials available, let the user log in.
    # Intended only for debugging / fixing loss of credentials, should 
    #   hopefully never need to do this
    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            flow = InstalledAppFlow.from_client_secrets_file(
                'credentials.json', SCOPES)
            creds = flow.run_local_server(port=0)
        # Save the credentials for the next run
        with open('token.pickle', 'wb') as token:
            pickle.dump(creds, token)

    return build('calendar', 'v3', credentials=creds, cache_discovery=False)

def create_event(json_string):
    """
    Creates a calendar event with the provided json
    """
    logging.info("create event request: %s" % json_string)
    service = get_calendar_service()
    event = service.events().insert(calendarId = 'primary',
                                    body=json.loads(json_string)).execute()
    return event

def edit_event(edit_event_id, json_string):
    """
    Edits a calendar event with the provided json
    """
    # adding for debugging
    start_dt_str = start_datetime.isoformat() + 'Z' # 'Z' indicates UTC time
    end_dt_str = (start_datetime + datetime.timedelta(minutes=60)).isoformat() + 'Z'
    json_dict = {
        "summary": "this event was edited",
        "description": "woah!",
        "start": {'dateTime': start_dt_str},
        "end": {'dateTime': end_dt_str},
    }

    logging.info("edit event request: %s" % json_string)
    service = get_calendar_service()
    
    #json_dict = json.loads(json_string)
    
    print(json_string)
    event = service.events().update(calendarId = 'primary', eventId=edit_event_id, body=json_dict).execute()


if __name__ == '__main__':
    import datetime
    start_datetime = datetime.datetime.utcnow()
    start_dt_str = start_datetime.isoformat() + 'Z' # 'Z' indicates UTC time
    end_dt_str = (start_datetime + datetime.timedelta(minutes=60)).isoformat() + 'Z'
    create_event_json = '{ "summary":"test event (serve acct)", "description":"created event via service acct", "start": {"dateTime": "%s"}, "end": {"dateTime": "%s"}, "attendees": [{ "email": "sih28@cornell.edu" }] }' % (start_dt_str, end_dt_str)
    # resp = create_event(create_event_json)
    edit_event_id = "azl0bDIzanAwOXUxcjRuZzc1MzRpYWRmcmcgbm8ucHJvYmxsYW1hLmxpbmtlZEBt"
    edit_event_json = '{"summary":"test event,edit (serve acct)", "description":"created event via service acct", "start": {"dateTime": "%s"}, "end": {"dateTime": "%s"}, "attendees": [{ "email": "sih28@cornell.edu" }] }' % (start_dt_str, end_dt_str)
    resp = edit_event(edit_event_id, edit_event_json)
    print(resp)
    print(resp.data)
