# filepath: hash_passwords.py
import hashlib

def hash_password(password):
    return hashlib.sha256(password.encode()).hexdigest()