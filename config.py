# filepath: c:\Users\donko\Music\POLICE\config.py
import os

class Config:
    SERVER = os.environ.get('DB_SERVER', 'DESKTOP-170MKOG')  # Replace with your server name
    DATABASE = os.environ.get('DB_DATABASE', 'PoliceManagementSystem225')
    # Windows Authentication - Trusted Connection
    CONNECTION_STRING = f'DRIVER={{ODBC Driver 17 for SQL Server}};SERVER={SERVER};DATABASE={DATABASE};Trusted_Connection=yes;'