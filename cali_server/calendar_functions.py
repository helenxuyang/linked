"""


"""
import datetime
import json
import logging
import os
import pickle
from googleapiclient.discovery import build
from google_auth_oauthlib.flow import InstalledAppFlow
from google.auth.transport.requests import Request

class APIRequestException(Exception):
    pass

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
    try:
        assert type(json_string) == str
    except:
        raise APIRequestException("arg should be a json string, not %s" % type(json_string))
    logging.info("create event request: %s" % json_string)
    service = get_calendar_service()
    event = service.events().insert(calendarId = 'primary',
                                    body=json.loads(json_string)).execute()
    return event

def edit_event(edit_event_id, json_string):
    """
    Fetches calendar event then edits it with the provided json
    """
    logging.info("edit event request: %s" % json_string)
    service = get_calendar_service()
    event = service.events().get(calendarId='primary', eventId=edit_event_id).execute()
    if event is None:
        raise APIRequestException("Cannot find cal event with id = %s" % edit_event_id)
    json_dict = json.loads(json_string)
    
    for field in json_dict:
        event[field] = json_dict[field]

    updated_event = service.events().update(calendarId = 'primary', eventId=edit_event_id, body=event).execute()
    return updated_event

def add_attendee(attendee, event_id):
    logging.info("add attendee request: %s,%s" % (attendee, event_id))
    service = get_calendar_service()
    event = service.events().get(calendarId='primary', eventId=event_id).execute()
    if event is None:
        raise APIRequestException("Cannot find cal event with id = %s" % event_id)
    attendees = event.get('attendees')
    if attendees is not None:
        attendees_emails = map(lambda guest: guest.email, attendees)
        if event.maxAttendee == len(attendees):
            raise APIRequestException("Event %s already has max attendees invited" % event_id)
        elif attendee in attendees_emails:
            raise APIRequestException("Attendee is already added to event")
        else:
            event[attendees].append(attendee)
    else:
        event[attendees] = [attendee]
    updated_event = service.events().update(calendarId = 'primary', eventId=event_id, body=event).execute()
    return updated_event

def remove_attendee(attendee, event_id):
    logging.info("remove attendee request: %s, %s" % (attendee, event_id))
    service = get_calendar_service()
    event = service.events().get(calendarId='primary', eventId=event_id).execute()
    if event is None:
        raise APIRequestException("Cannot find cal event with id = %s" % event_id)
    attendees = event.get('attendees')
    if attendees is not None:
        attendees_emails = map(lambda guest: guest.email, attendees)
        if len(attendees_emails) == 1:
            raise APIRequestException("Event %s cannot remove only attendee remaining (should be the host?), try deleting the event" % event_id)
        elif attendee not in attendees_emails:
            raise APIRequestException("Attendee is already not added to event")
        else:
            attendees_emails.remove(attendee)
            event[attendees] = attendees_emails
            updated_event = service.events().update(calendarId = 'primary', eventId=event_id, body=event).execute()
            return updated_event
    else:
        raise APIRequestException("No attendees for event %s" % event_id)

if __name__ == '__main__':
    get_calendar_service()
    # start_datetime = datetime.datetime.utcnow()
    # start_dt_str = start_datetime.isoformat() + 'Z' # 'Z' indicates UTC time
    # end_dt_str = (start_datetime + datetime.timedelta(minutes=60)).isoformat() + 'Z'
    # # create_event_json = '{ "summary":"test event (serve acct)", "description":"created event via service acct", "start": {"dateTime": "%s"}, "end": {"dateTime": "%s"}, "attendees": [{ "email": "sih28@cornell.edu" }] }' % (start_dt_str, end_dt_str)
    # # resp = create_event(create_event_json)
    # edit_event_id = "oo7pc5vbrac64umn0210494t08"
    # edit_event_json = '{"summary":"test event,edit (serve acct)", "description":"created event via service acct", "start": {"dateTime": "%s"}, "end": {"dateTime": "%s"}, "attendees": [{ "email": "sih28@cornell.edu" }] }' % (start_dt_str, end_dt_str)
    # resp = edit_event(edit_event_id, edit_event_json)
    # print(resp)
    
