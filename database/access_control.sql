-- Define different user roles
-- Admin: Full access to all tables and operations.
-- Investigator: Access to view and modify cases, evidence, and suspects.
-- Officer: Access to view cases and add evidence.
-- PublicUser: Limited access to view case information.

-- Create logins and users (replace with your actual logins)
CREATE LOGIN AdminUser WITH PASSWORD = 'AdminPassword';
CREATE USER AdminUser FOR LOGIN AdminUser;

CREATE LOGIN InvestigatorUser WITH PASSWORD = 'InvestigatorPassword';
CREATE USER InvestigatorUser FOR LOGIN InvestigatorUser;

CREATE LOGIN OfficerUser WITH PASSWORD = 'OfficerPassword';
CREATE USER OfficerUser FOR LOGIN OfficerUser;

CREATE LOGIN PublicUser WITH PASSWORD = 'PublicPassword';
CREATE USER PublicUser FOR LOGIN PublicUser;

-- Create roles
CREATE ROLE AdminRole225;
CREATE ROLE InvestigatorRole225;
CREATE ROLE OfficerRole225;
CREATE ROLE PublicUserRole225;

-- Add users to roles
ALTER ROLE AdminRole225 ADD MEMBER AdminUser;
ALTER ROLE InvestigatorRole225 ADD MEMBER InvestigatorUser;
ALTER ROLE OfficerRole225 ADD MEMBER OfficerUser;
ALTER ROLE PublicUserRole225 ADD MEMBER PublicUser;

-- Grant permissions to roles
-- Admin role: Full control
GRANT CONTROL ON DATABASE::PoliceManagementSystem225 TO AdminRole225;

-- Investigator role: SELECT, INSERT, UPDATE on Cases, Evidence, and Suspects
GRANT SELECT, INSERT, UPDATE ON Cases225 TO InvestigatorRole225;
GRANT SELECT, INSERT, UPDATE ON Evidence225 TO InvestigatorRole225;
GRANT SELECT, INSERT, UPDATE ON Suspects225 TO InvestigatorRole225;
GRANT SELECT ON PoliceOfficers225 TO InvestigatorRole225; -- Read access to officer info
GRANT SELECT ON Vehicles225 TO InvestigatorRole225;

-- Officer role: SELECT on Cases, INSERT on Evidence
GRANT SELECT ON Cases225 TO OfficerRole225;
GRANT INSERT ON Evidence225 TO OfficerRole225;
GRANT SELECT ON PoliceOfficers225 TO OfficerRole225;
GRANT SELECT ON Vehicles225 TO OfficerRole225;

-- PublicUser role: SELECT on Cases (limited columns)
GRANT SELECT ON Cases225 TO PublicUserRole225;

-- Create a view for public users to limit the columns they can see
CREATE VIEW PublicCases225 AS
SELECT CaseNumber, Title, Description, DateOpened, Status
FROM Cases225;

GRANT SELECT ON PublicCases225 TO PublicUserRole225;
--Revoke permissions
REVOKE SELECT ON Cases225 FROM PublicUserRole225;


-- ...existing code...

-- Investigator role: SELECT, INSERT, UPDATE on Arrests, Warrants, and Victims
GRANT SELECT, INSERT, UPDATE ON Arrests225 TO InvestigatorRole225;
GRANT SELECT, INSERT, UPDATE ON Warrants225 TO InvestigatorRole225;
GRANT SELECT, INSERT, UPDATE ON Victims225 TO InvestigatorRole225;

-- Officer role: SELECT on Arrests, Warrants, and Victims
GRANT SELECT ON Arrests225 TO OfficerRole225;
GRANT SELECT ON Warrants225 TO OfficerRole225;
GRANT SELECT ON Victims225 TO OfficerRole225;

-- Justification for Permissions:
-- AdminRole225: Full control is necessary for database administration tasks.
-- InvestigatorRole225: SELECT, INSERT, UPDATE on Cases, Evidence, and Suspects are needed for case management.
-- OfficerRole225: SELECT on Cases and INSERT on Evidence are needed for basic case involvement.
-- PublicUserRole225: SELECT on PublicCases225 is granted to allow public access to limited case information.
-- Revoking SELECT on Cases225 from PublicUserRole225 restricts public access to case information.