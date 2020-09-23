import os
import logging
from flask import Flask, request, jsonify
from flask_httpauth import HTTPBasicAuth
from werkzeug.security import generate_password_hash, check_password_hash
from googleapiclient.discovery import build
from google_auth_oauthlib.flow import InstalledAppFlow
from google.auth.transport.requests import Request
import calendar_functions 

flask_api = Flask('Cali API')
auth = HTTPBasicAuth()

_username = os.environ.get('cali_username', "").strip()
_password_hashed = os.environ.get('cali_pwd_hashed',"").strip()

def try_request(request_name, gcal_fn, args):
    logger.info(args)
    request_json = args[0]
    if(request_json == None):
        response = "expected a json payload, but not present"
        return jsonify(response), 400
    else:
        result = None
        try:
            result = gcal_fn(*args)
            logging.info(result)
            return jsonify(result), 201
        except Exception as e:
            response = "\n Error occurred in GCal request, %s \n" % str(e)
            logger.info(response)
            return jsonify(response), 500

@auth.verify_password
def verify_password(username, password):
    if(username.strip() == _username) and check_password_hash(_password_hashed, password):
        return True
    else:
        logger.warning("Sign in failed, %s:%s" % (username, password))
        return False

# @auth.login_required
@flask_api.route("/status-check")
def status_check():
    return 'Successfully signed on\n'

@flask_api.route("/create-event", methods=['POST'])
def create_event():
    return try_request("create-event", calendar_functions.create_event, (request.json,) )
    # logging.info("create Event rest api request")
    # if(request.json == None):
    #     response = "Json request not present, received %s" % str(request.data)
    #     return jsonify(response), 400
    # else:
    #     result = None
    #     try:
    #         result = calendar_functions.create_event(request.json)
    #         logging.info(result)
    #         return jsonify(result), 201
    #     except Exception as e:
    #         response = "\n Error occurred in GCal request, %s \n" % str(e)
    #         logging.info(response)
    #         return jsonify(response), 500

@flask_api.route("/edit-event", methods=['PUT'])
def edit_event():
    edit_event_id = request.args.get('id')
    logger.info("editing event %s" % edit_event_id)
    if edit_event_id == None:
        return jsonify("event id needed for edit-event request"), 400
    return try_request("edit-event", calendar_functions.edit_event, (edit_event_id, request.json))
    # logging.info("edit Event rest api request")
    # if(request.json == None):
    #     response = "Json request not present, received %s" % str(request.data)
    #     return jsonify(response), 400
    # else:
    #     edit_event_id = request.args.get('id')
    #     result = None
    #     try:
    #         result = calendar_functions.edit_event(edit_event_id, request.json)
    #         logging.info(result)
    #         return jsonify(result), 201
    #     except Exception as e:
    #         response = "\n Error occurred in GCal request, %s \n" % str(e)
    #         logging.info(response)
    #         return jsonify(response), 500
        
@flask_api.route("/add-attendee", methods=['PUT'])
def add_attendee():
    logger.info("add attendee rest api request")



if __name__ == '__main__':
    logging.basicConfig(level=logging.DEBUG)
    logger = logging.getLogger(__name__)
    #flask_api.run(debug=True, ssl_context=('cert.pem','key.pem'))
    flask_api.run(debug=True)