# Police Management System

A comprehensive web application designed for law enforcement agencies to securely manage cases, evidence, personnel data, and prisoner releases.

## Overview

The Police Management System (PMS) is a Flask-based application that provides a secure platform for police departments to manage and track all aspects of their operations. It features role-based access control, comprehensive case tracking, evidence management, and analytical tools for data-driven decision making.

## Features

- **User Authentication**: Secure login system with role-based access (Admin, Investigator, Public)
- **Dashboard**: Overview of cases, officer assignments, and recent activities
- **Case Management**: Create, view, and manage cases with detailed tracking
- **Evidence Tracking**: Register and monitor evidence with chain of custody details
- **Officer Management**: Maintain officer records and assignments
- **Suspect Database**: Record and search suspect information
- **Prisoner Release Tracking**: Monitor upcoming and past prisoner releases
- **Statistics & Analytics**: Visualize data for better insights and decision-making
- **Settings Management**: User preferences and security settings

## Technology Stack

- **Backend**: Python, Flask
- **Database**: Microsoft SQL Server
- **Frontend**: HTML, CSS, JavaScript, Bootstrap 4
- **Authentication**: Session-based authentication with role-based permissions
- **Data Visualization**: Chart.js

## Setup Instructions

### Prerequisites
- Python 3.7 or later
- Microsoft SQL Server
- ODBC Driver 17 for SQL Server

### Installation

1. Clone the repository:
   ```
   git clone https://github.com/yourusername/police-management-system.git
   cd police-management-system
   ```

2. Create a virtual environment and activate it:
   ```
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. Install dependencies:
   ```
   pip install -r requirements.txt
   ```

4. Configure your database connection in `config.py`:
   ```python
   SERVER = 'your-server-name'
   DATABASE = 'PoliceManagementSystem225'
   ```

5. Run the application:
   ```
   python app.py
   ```

6. Access the application at: http://localhost:5000

### Default Admin Login
- Username: AdminUser
- Password: AdminPassword

## Project Structure

- `/templates` - HTML templates for the application
- `/static` - Static files (CSS, JavaScript, images)
- `app.py` - Main application file
- `config.py` - Configuration settings
- `hashpass.py` - Password hashing utilities
- `requirements.txt` - Required Python packages

## Database Schema

The application uses the following key tables:
- `Users225` - User authentication information
- `Cases225` - Case details and status
- `Evidence225` - Evidence records linked to cases
- `PoliceOfficers225` - Officer information
- `Suspects225` - Suspect records
- `PrisonerReleases225` - Prisoner release information

## Security Features

- Password hashing using SHA-256
- Role-based access control
- Session management
- Input validation

## User Roles

1. **AdminRole225**
   - Full access to all system features
   - Can add/edit/delete all records
   - Access to system settings and user management

2. **InvestigatorRole225**
   - Access to cases, evidence, suspects, and prisoner releases
   - Can add new records and edit existing ones
   - Limited access to officer management

3. **PublicUserRole225**
   - Read-only access to public case information
   - No access to sensitive data or system functions

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature-name`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin feature-name`
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgements

- Bootstrap 4 for the UI components
- Chart.js for data visualization
- Font Awesome for icons
