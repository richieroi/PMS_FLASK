from flask import Flask
from flask_session import Session 
import os

app = Flask(__name__)

# Configure strong secret key for session
app.secret_key = os.environ.get('SECRET_KEY', 'dev_key_change_in_production')

# Configure session type to be filesystem-based rather than cookie-based
app.config['SESSION_TYPE'] = 'filesystem'
app.config['SESSION_PERMANENT'] = False
app.config['PERMANENT_SESSION_LIFETIME'] = 1800  # 30 minutes
Session(app)

# This file can be empty or minimal since we're not using it for route definitions anymore.
# You can remove the import for routes to avoid conflicts.

# If needed in the future for actual modular app structure:
# from flask import Flask
# app = Flask(__name__)
# app.config.from_object('config')
