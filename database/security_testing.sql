-- Simulating Unauthorized Access:
-- Attempt to update a case status as a PublicUser (should fail)
-- This will fail because the PublicUserRole225 only has SELECT permissions on the PublicCases225 view.

-- Audit and Logging:
-- (Already implemented with the CasesUpdateTrigger225 and CasesAudit225 table)
-- Query to retrieve logs of user activities
SELECT * FROM CasesAudit225;
GO

-- Backup and Recovery:
-- Backup the database
BACKUP DATABASE PoliceManagementSystem225
TO DISK = 'C:\Users\donko\Music\POLICE\PoliceManagementSystem225_backup.bak';
GO

-- Restore the database
-- First, set the database to single-user mode
ALTER DATABASE PoliceManagementSystem225 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO

-- Restore the database
RESTORE DATABASE PoliceManagementSystem225
FROM DISK = 'C:\Users\donko\Music\POLICE\PoliceManagementSystem225_backup.bak'
WITH REPLACE;
GO

-- Set the database back to multi-user mode
ALTER DATABASE PoliceManagementSystem225 SET MULTI_USER;
GO

-- Importance of Regular Backups:
-- Regular backups are crucial for maintaining data integrity and ensuring that the database can be restored in case of data loss or corruption.
-- In the context of access control, backups ensure that the security measures and permissions are preserved and can be restored if needed.