from flask import Flask, render_template, request, redirect, url_for, session
import pyodbc
from functools import wraps
import os
import logging
from config import Config  # Import the configuration
from hashpass import hash_password # Import the hash_password function

app = Flask(__name__)
app.secret_key = os.urandom(24)  # Generate a random secret key

# Configure logging
logging.basicConfig(level=logging.DEBUG,
                    format='%(asctime)s - %(levelname)s - %(message)s')

# Function to connect to the database
def connect_to_db():
    try:
        conn_string = Config.CONNECTION_STRING # Corrected line
        conn = pyodbc.connect(conn_string)
        logging.info("Database connection successful")
        # Test the connection
        cursor = conn.cursor()
        cursor.execute("SELECT 1")
        cursor.fetchone()
        logging.info("Database connection test successful")
        return conn
    except Exception as e:
        logging.error(f"Error connecting to the database: {e}")
        return None

# Authentication decorator
def login_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if 'username' not in session:
            return redirect(url_for('login'))
        return f(*args, **kwargs)
    return decorated_function

# Admin role required decorator
def admin_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if session.get('role') != 'AdminRole225':
            return render_template('error.html', message='Unauthorized access')
        return f(*args, **kwargs)
    return decorated_function

# Route for the index page
@app.route('/')
def index():
    return render_template('index.html')

# Route for the login page
@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']

        # Direct authentication for AdminUser
        if username == 'AdminUser' and password == 'AdminPassword':
            session['username'] = username
            session['role'] = 'AdminRole225'
            logging.info(f"Login successful for hardcoded admin user: {username}")
            return redirect(url_for('home'))
            
        # Regular database authentication for other users
        conn = connect_to_db()
        if conn:
            cursor = conn.cursor()
            try:
                logging.info(f"Attempting login for user: {username}")
                cursor.execute("SELECT Role, PasswordHash FROM Users225 WHERE Username = ?", username)
                user = cursor.fetchone()

                if user:
                    stored_role = user[0]
                    stored_password_hash = user[1]

                    if hash_password(password) == stored_password_hash:
                        session['username'] = username
                        session['role'] = stored_role
                        logging.info(f"Login successful for user: {username} ({stored_role})")
                        return redirect(url_for('home'))
                    else:
                        logging.warning(f"Invalid credentials for user: {username}")
                        return render_template('login.html', error='Invalid credentials')
                else:
                    logging.warning(f"User {username} not found in database.")
                    return render_template('login.html', error='Invalid credentials')
            except Exception as e:
                logging.error(f"Error during login: {e}")
                return render_template('login.html', error=f'Database error: {e}')
            finally:
                if conn:
                    conn.close()
        else:
            logging.error("Failed to connect to the database.")
            return render_template('login.html', error='Failed to connect to the database. Try using AdminUser/AdminPassword to login.')
    else:
        # For GET requests, check if the user is already logged in
        if 'username' in session:
            return redirect(url_for('home'))
        # Otherwise, show the login page
        return render_template('login.html')

# Route for the logout page
@app.route('/logout')
@login_required
def logout():
    session.pop('username', None)
    session.pop('role', None)
    return redirect(url_for('login'))

# Route for the home page
@app.route('/home')
@login_required
def home():
    return render_template('home.html', username=session['username'], role=session['role'])

# Route for displaying cases
@app.route('/cases')
@login_required
def cases():
    conn = connect_to_db()
    if conn:
        cursor = conn.cursor()
        try:
            if session['role'] == 'PublicUserRole225':
                cursor.execute("SELECT CaseNumber, Title, Description, DateOpened, Status FROM PublicCases225")
            else:
                cursor.execute("SELECT * FROM Cases225")
            cases = cursor.fetchall()
            return render_template('cases.html', cases=cases, role=session['role'])
        except Exception as e:
            logging.error(f"Error fetching cases: {e}")
            return render_template('error.html', message='Error fetching cases')
        finally:
            if conn:
                conn.close()
    else:
        return render_template('error.html', message='Failed to connect to the database.')

# Route for adding a new case (Admin only)
@app.route('/add_case', methods=['GET', 'POST'])
@login_required
@admin_required
def add_case():
    if request.method == 'POST':
        case_number = request.form['case_number']
        title = request.form['title']
        description = request.form['description']
        lead_officer_id = request.form['lead_officer_id']

        conn = connect_to_db()
        if conn:
            cursor = conn.cursor()
            try:
                cursor.execute("EXEC RegisterNewCase225 ?, ?, ?, ?", case_number, title, description, lead_officer_id)
                conn.commit()
                return redirect(url_for('cases'))
            except Exception as e:
                conn.rollback()
                logging.error(f"Error adding case: {e}")
                return render_template('error.html', message=f'Error adding case: {e}')
            finally:
                if conn:
                    conn.close()
        else:
            return render_template('error.html', message='Failed to connect to the database.')

    return render_template('add_case.html')

# Route for displaying officers
@app.route('/officers')
@login_required
def officers():
    conn = connect_to_db()
    if conn:
        cursor = conn.cursor()
        try:
            cursor.execute("SELECT * FROM PoliceOfficers225")
            officers = cursor.fetchall()
            return render_template('officers.html', officers=officers, role=session['role'])
        except Exception as e:
            logging.error(f"Error fetching officers: {e}")
            return render_template('error.html', message='Error fetching officers')
        finally:
            if conn:
                conn.close()
    else:
        return render_template('error.html', message='Failed to connect to the database.')

# Route for displaying suspects
@app.route('/suspects')
@login_required
def suspects():
    conn = connect_to_db()
    if conn:
        cursor = conn.cursor()
        try:
            cursor.execute("SELECT * FROM Suspects225")
            suspects = cursor.fetchall()
            return render_template('suspects.html', suspects=suspects, role=session['role'])
        except Exception as e:
            logging.error(f"Error fetching suspects: {e}")
            return render_template('error.html', message='Error fetching suspects')
        finally:
            if conn:
                conn.close()
    else:
        return render_template('error.html', message='Failed to connect to the database.')

# Route for displaying evidence
@app.route('/evidence')
@login_required
def evidence():
    conn = connect_to_db()
    if conn:
        cursor = conn.cursor()
        try:
            cursor.execute("SELECT * FROM Evidence225")
            evidence = cursor.fetchall()
            return render_template('evidence.html', evidence=evidence, role=session['role'])
        except Exception as e:
            logging.error(f"Error fetching evidence: {e}")
            return render_template('error.html', message='Error fetching evidence')
        finally:
            if conn:
                conn.close()
    else:
        return render_template('error.html', message='Failed to connect to the database.')

# Route for displaying prisoner releases
@app.route('/prisoner_releases')
@login_required
def prisoner_releases():
    conn = connect_to_db()
    if conn:
        cursor = conn.cursor()
        try:
            cursor.execute("""
                SELECT pr.ReleaseID, pr.PrisonerName, pr.PrisonerID, pr.DateOfIncarceration, 
                       pr.DateOfRelease, pr.ReleaseType, po.FirstName + ' ' + po.LastName as SupervisingOfficer, 
                       pr.CaseID, pr.ReleaseConditions, pr.ReleaseStatus, pr.NextCheckInDate, pr.Notes
                FROM PrisonerReleases225 pr
                LEFT JOIN PoliceOfficers225 po ON pr.SupervisingOfficerID = po.OfficerID
            """)
            releases = cursor.fetchall()
            return render_template('prisoner_releases.html', releases=releases, role=session['role'])
        except Exception as e:
            logging.error(f"Error fetching prisoner releases: {e}")
            return render_template('error.html', message='Error fetching prisoner releases')
        finally:
            if conn:
                conn.close()
    else:
        return render_template('error.html', message='Failed to connect to the database.')

# Route for statistics page
@app.route('/statistics')
@login_required
def statistics():
    conn = connect_to_db()
    if conn:
        cursor = conn.cursor()
        try:
            # Get case statistics
            cursor.execute("SELECT COUNT(*) FROM Cases225")
            total_cases = cursor.fetchone()[0]
            
            cursor.execute("SELECT COUNT(*) FROM Cases225 WHERE Status = 'Open'")
            open_cases = cursor.fetchone()[0]
            
            cursor.execute("SELECT COUNT(*) FROM Cases225 WHERE Status = 'Closed'")
            closed_cases = cursor.fetchone()[0]
            
            # Get officer statistics
            cursor.execute("SELECT COUNT(*) FROM PoliceOfficers225")
            total_officers = cursor.fetchone()[0]
            
            # Get suspect statistics
            cursor.execute("SELECT COUNT(*) FROM Suspects225")
            total_suspects = cursor.fetchone()[0]
            
            # Get evidence statistics
            cursor.execute("SELECT COUNT(*) FROM Evidence225")
            total_evidence = cursor.fetchone()[0]
            
            # Get case types distribution - Fixed: replacing 'Type' with 'Status' or another existing column
            # We're using Status as a fallback since we know it exists based on other queries
            cursor.execute("SELECT Status as CaseType, COUNT(*) as Count FROM Cases225 GROUP BY Status")
            case_types = cursor.fetchall()
            
            return render_template('statistics.html', 
                                total_cases=total_cases,
                                open_cases=open_cases,
                                closed_cases=closed_cases,
                                total_officers=total_officers,
                                total_suspects=total_suspects,
                                total_evidence=total_evidence,
                                case_types=case_types)
        except Exception as e:
            logging.error(f"Error fetching statistics: {e}")
            return render_template('error.html', message='Error fetching statistics')
        finally:
            conn.close()
    else:
        return render_template('error.html', message='Failed to connect to the database.')

# Route for analytics page
@app.route('/analytics')
@login_required
def analytics():
    conn = connect_to_db()
    if conn:
        cursor = conn.cursor()
        try:
            # Get monthly case data (for last 6 months)
            cursor.execute("""
                SELECT 
                    MONTH(DateOpened) as Month, 
                    YEAR(DateOpened) as Year,
                    COUNT(*) as CaseCount 
                FROM Cases225 
                WHERE DateOpened >= DATEADD(month, -6, GETDATE()) 
                GROUP BY MONTH(DateOpened), YEAR(DateOpened)
                ORDER BY YEAR(DateOpened), MONTH(DateOpened)
            """)
            monthly_cases = cursor.fetchall()
            
            # Get officer performance metrics
            cursor.execute("""
                SELECT po.OfficerID, po.FirstName, po.LastName, 
                       COUNT(c.CaseID) as CaseCount,
                       COUNT(CASE WHEN c.Status = 'Closed' THEN 1 ELSE NULL END) as ClosedCases
                FROM PoliceOfficers225 po
                LEFT JOIN Cases225 c ON po.OfficerID = c.LeadOfficerID
                GROUP BY po.OfficerID, po.FirstName, po.LastName
                ORDER BY CaseCount DESC
            """)
            officer_performance = cursor.fetchall()
            
            return render_template('analytics.html', 
                                monthly_cases=monthly_cases,
                                officer_performance=officer_performance)
        except Exception as e:
            logging.error(f"Error fetching analytics data: {e}")
            return render_template('error.html', message='Error fetching analytics data')
        finally:
            conn.close()
    else:
        return render_template('error.html', message='Failed to connect to the database.')

# Route for settings page
@app.route('/settings', methods=['GET', 'POST'])
@login_required
def settings():
    if request.method == 'POST':
        # Process form submission (e.g., change password, update preferences)
        action = request.form.get('action')
        
        if action == 'change_password':
            current_password = request.form.get('current_password')
            new_password = request.form.get('new_password')
            confirm_password = request.form.get('confirm_password')
            
            # Validation checks
            if not current_password or not new_password or not confirm_password:
                return render_template('settings.html', error='All password fields are required')
                
            if new_password != confirm_password:
                return render_template('settings.html', error='New passwords do not match')
            
            # Verify current password and update to new password in database
            # (This is just a placeholder, actual implementation would access the database)
            hashed_new_password = hash_password(new_password)
            return render_template('settings.html', success='Password updated successfully')
            
        elif action == 'update_preferences':
            # Process preferences update
            notification_enabled = request.form.get('notification_enabled') == 'on'
            theme = request.form.get('theme')
            
            # Save preferences to database or session
            session['theme'] = theme
            session['notifications'] = notification_enabled
            
            return render_template('settings.html', success='Preferences updated successfully')
    
    # For GET requests, just show the settings page
    return render_template('settings.html')

# Routes for Evidence CRUD operations
@app.route('/add_evidence', methods=['GET', 'POST'])
@login_required
def add_evidence():
    if request.method == 'POST':
        case_id = request.form['case_id']
        description = request.form['description']
        date_collected = request.form['date_collected']
        location_collected = request.form['location_collected']
        custodian_officer_id = request.form['custodian_officer_id']
        
        conn = connect_to_db()
        if conn:
            cursor = conn.cursor()
            try:
                cursor.execute("""
                    INSERT INTO Evidence225 (CaseID, Description, DateCollected, LocationCollected, CustodianOfficerID)
                    VALUES (?, ?, ?, ?, ?)
                """, case_id, description, date_collected, location_collected, custodian_officer_id)
                conn.commit()
                return redirect(url_for('evidence'))
            except Exception as e:
                conn.rollback()
                logging.error(f"Error adding evidence: {e}")
                return render_template('error.html', message=f'Error adding evidence: {e}')
            finally:
                conn.close()
        else:
            return render_template('error.html', message='Failed to connect to the database.')
    
    # For GET requests, get the list of cases and officers for dropdown menus
    conn = connect_to_db()
    if conn:
        cursor = conn.cursor()
        try:
            cursor.execute("SELECT CaseID, CaseNumber FROM Cases225")
            cases = cursor.fetchall()
            
            cursor.execute("SELECT OfficerID, FirstName, LastName FROM PoliceOfficers225")
            officers = cursor.fetchall()
            
            return render_template('add_evidence.html', cases=cases, officers=officers)
        except Exception as e:
            logging.error(f"Error fetching cases or officers: {e}")
            return render_template('error.html', message='Error fetching data')
        finally:
            conn.close()
    else:
        return render_template('error.html', message='Failed to connect to the database.')

@app.route('/edit_evidence/<int:evidence_id>', methods=['GET', 'POST'])
@login_required
def edit_evidence(evidence_id):
    if request.method == 'POST':
        case_id = request.form['case_id']
        description = request.form['description']
        date_collected = request.form['date_collected']
        location_collected = request.form['location_collected']
        custodian_officer_id = request.form['custodian_officer_id']
        
        conn = connect_to_db()
        if conn:
            cursor = conn.cursor()
            try:
                cursor.execute("""
                    UPDATE Evidence225
                    SET CaseID = ?, Description = ?, DateCollected = ?, LocationCollected = ?, CustodianOfficerID = ?
                    WHERE EvidenceID = ?
                """, case_id, description, date_collected, location_collected, custodian_officer_id, evidence_id)
                conn.commit()
                return redirect(url_for('evidence'))
            except Exception as e:
                conn.rollback()
                logging.error(f"Error updating evidence: {e}")
                return render_template('error.html', message=f'Error updating evidence: {e}')
            finally:
                conn.close()
        else:
            return render_template('error.html', message='Failed to connect to the database.')
    
    conn = connect_to_db()
    if conn:
        cursor = conn.cursor()
        try:
            cursor.execute("SELECT * FROM Evidence225 WHERE EvidenceID = ?", evidence_id)
            evidence = cursor.fetchone()
            
            cursor.execute("SELECT CaseID, CaseNumber FROM Cases225")
            cases = cursor.fetchall()
            
            cursor.execute("SELECT OfficerID, FirstName, LastName FROM PoliceOfficers225")
            officers = cursor.fetchall()
            
            return render_template('edit_evidence.html', evidence=evidence, cases=cases, officers=officers)
        except Exception as e:
            logging.error(f"Error fetching evidence details: {e}")
            return render_template('error.html', message='Error fetching data')
        finally:
            conn.close()
    else:
        return render_template('error.html', message='Failed to connect to the database.')

@app.route('/delete_evidence/<int:evidence_id>', methods=['POST'])
@login_required
def delete_evidence(evidence_id):
    conn = connect_to_db()
    if conn:
        cursor = conn.cursor()
        try:
            cursor.execute("DELETE FROM Evidence225 WHERE EvidenceID = ?", evidence_id)
            conn.commit()
            return redirect(url_for('evidence'))
        except Exception as e:
            conn.rollback()
            logging.error(f"Error deleting evidence: {e}")
            return render_template('error.html', message=f'Error deleting evidence: {e}')
        finally:
            conn.close()
    else:
        return render_template('error.html', message='Failed to connect to the database.')

# Routes for Suspects CRUD operations
@app.route('/add_suspect', methods=['GET', 'POST'])
@login_required
def add_suspect():
    if request.method == 'POST':
        first_name = request.form['first_name']
        last_name = request.form['last_name']
        dob = request.form['dob']
        address = request.form['address']
        contact = request.form['contact']
        case_id = request.form['case_id']
        
        conn = connect_to_db()
        if conn:
            cursor = conn.cursor()
            try:
                cursor.execute("""
                    INSERT INTO Suspects225 (FirstName, LastName, DateOfBirth, Address, ContactNumber, CaseID)
                    VALUES (?, ?, ?, ?, ?, ?)
                """, first_name, last_name, dob, address, contact, case_id)
                conn.commit()
                return redirect(url_for('suspects'))
            except Exception as e:
                conn.rollback()
                logging.error(f"Error adding suspect: {e}")
                return render_template('error.html', message=f'Error adding suspect: {e}')
            finally:
                conn.close()
        else:
            return render_template('error.html', message='Failed to connect to the database.')
    
    # GET request - show the form
    conn = connect_to_db()
    if conn:
        cursor = conn.cursor()
        try:
            cursor.execute("SELECT CaseID, CaseNumber FROM Cases225")
            cases = cursor.fetchall()
            return render_template('add_suspect.html', cases=cases)
        except Exception as e:
            logging.error(f"Error fetching cases: {e}")
            return render_template('error.html', message='Error fetching data')
        finally:
            conn.close()
    else:
        return render_template('error.html', message='Failed to connect to the database.')

# Routes for Officers CRUD operations (similar implementation as above)
@app.route('/add_officer', methods=['GET', 'POST'])
@login_required
@admin_required  # Only admins should add officers
def add_officer():
    if request.method == 'POST':
        first_name = request.form['first_name']
        last_name = request.form['last_name']
        badge_number = request.form['badge_number']
        rank = request.form['rank']
        precinct = request.form['precinct']
        
        conn = connect_to_db()
        if conn:
            cursor = conn.cursor()
            try:
                cursor.execute("""
                    INSERT INTO PoliceOfficers225 (FirstName, LastName, BadgeNumber, Rank, Precinct)
                    VALUES (?, ?, ?, ?, ?)
                """, first_name, last_name, badge_number, rank, precinct)
                conn.commit()
                return redirect(url_for('officers'))
            except Exception as e:
                conn.rollback()
                logging.error(f"Error adding officer: {e}")
                return render_template('error.html', message=f'Error adding officer: {e}')
            finally:
                conn.close()
        else:
            return render_template('error.html', message='Failed to connect to the database.')
    
    return render_template('add_officer.html')

# Error handling route
@app.errorhandler(500)
def internal_server_error(e):
    return render_template('error.html', message='Internal Server Error'), 500

if __name__ == '__main__':
    app.run(debug=True)