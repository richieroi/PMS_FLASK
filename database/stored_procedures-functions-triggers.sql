-- Stored Procedure: Registering a new case
CREATE PROCEDURE RegisterNewCase225 (
    @CaseNumber VARCHAR(20),
    @Title VARCHAR(255),
    @Description TEXT,
    @LeadOfficerID INT
)
AS
BEGIN
    INSERT INTO Cases225 (CaseNumber, Title, Description, LeadOfficerID)
    VALUES (@CaseNumber, @Title, @Description, @LeadOfficerID);
END;
GO

-- Execute the stored procedure
EXEC RegisterNewCase225 'C-2024-001', 'New Case Title', 'New Case Description', 1;
GO
-- ...existing code...

-- Stored Procedure: Update Case Status
CREATE PROCEDURE UpdateCaseStatus225 (
    @CaseID INT,
    @NewStatus VARCHAR(50)
)
AS
BEGIN
    UPDATE Cases225 SET Status = @NewStatus WHERE CaseID = @CaseID;
END;
GO

-- Stored Procedure: Get Case Details
CREATE PROCEDURE GetCaseDetails225 (
    @CaseID INT
)
AS
BEGIN
    SELECT * FROM Cases225 WHERE CaseID = @CaseID;
    SELECT * FROM Evidence225 WHERE CaseID = @CaseID;
    SELECT * FROM Suspects225 WHERE CaseID = @CaseID;
END;
GO

-- Function: Get Suspect Count for a Case
CREATE FUNCTION GetSuspectCount225 (@CaseID INT)
RETURNS INT
AS
BEGIN
    DECLARE @SuspectCount INT;
    SELECT @SuspectCount = COUNT(*) FROM Suspects225 WHERE CaseID = @CaseID;
    RETURN @SuspectCount;
END;
GO

-- Function: Get Evidence Count for a Case
CREATE FUNCTION GetEvidenceCount225 (@CaseID INT)
RETURNS INT
AS
BEGIN
    DECLARE @EvidenceCount INT;
    SELECT @EvidenceCount = COUNT(*) FROM Evidence225 WHERE CaseID = @CaseID;
    RETURN @EvidenceCount;
END;
GO
-- Trigger: Logging updates to the Cases table
CREATE TABLE CasesAudit225 (
    AuditID INT PRIMARY KEY IDENTITY(1,1),
    CaseID INT,
    OldStatus VARCHAR(50),
    NewStatus VARCHAR(50),
    UpdateDate DATETIME DEFAULT GETDATE(),
    UpdatedBy VARCHAR(255)
);
GO

CREATE TRIGGER CasesUpdateTrigger225
ON Cases225
AFTER UPDATE
AS
BEGIN
    INSERT INTO CasesAudit225 (CaseID, OldStatus, NewStatus, UpdateDate, UpdatedBy)
    SELECT
        i.CaseID,
        d.Status,
        i.Status,
        GETDATE(),
        SUSER_NAME()
    FROM
        inserted i
    INNER JOIN
        deleted d ON i.CaseID = d.CaseID
    WHERE i.Status <> d.Status;
END;
GO

-- Example of updating a case to trigger the trigger
UPDATE Cases225 SET Status = 'Closed' WHERE CaseID = 1;
GO

-- Function: Calculate the number of open cases for an officer
CREATE FUNCTION GetOfficerOpenCases225 (@OfficerID INT)
RETURNS INT
AS
BEGIN
    DECLARE @OpenCases INT;
    SELECT @OpenCases = COUNT(*)
    FROM Cases225
    WHERE LeadOfficerID = @OfficerID AND Status = 'Open';
    RETURN @OpenCases;
END;
GO

-- Example of using the function
SELECT dbo.GetOfficerOpenCases225(1) AS OpenCases;
GO

-- IF-ELSE Statement: Determining case priority
DECLARE @CaseID INT = 3;
DECLARE @CaseStatus VARCHAR(50);

SELECT @CaseStatus = Status FROM Cases225 WHERE CaseID = @CaseID;

IF @CaseStatus = 'Open'
BEGIN
    PRINT 'Case is open and requires immediate attention.';
END
ELSE
BEGIN
    PRINT 'Case is closed or does not require immediate attention.';
END
GO