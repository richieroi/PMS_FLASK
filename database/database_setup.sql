-- Create the database
CREATE DATABASE PoliceManagementSystem225;
GO

USE PoliceManagementSystem225;
GO

-- Create the PoliceOfficers table
CREATE TABLE PoliceOfficers225 (
    OfficerID INT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    BadgeNumber VARCHAR(20) UNIQUE NOT NULL,
    Rank VARCHAR(50),
    Precinct VARCHAR(50),
    DateOfBirth DATE,
    HireDate DATE,
    Gender VARCHAR(10),
    ContactNumber VARCHAR(20),
    Email VARCHAR(100)
);

-- Create the Cases table
CREATE TABLE Cases225 (
    CaseID INT PRIMARY KEY,
    CaseNumber VARCHAR(20) UNIQUE NOT NULL,
    Title VARCHAR(255) NOT NULL,
    Description TEXT,
    DateOpened DATETIME DEFAULT GETDATE(),
    DateClosed DATETIME,
    Status VARCHAR(50) DEFAULT 'Open',
    LeadOfficerID INT FOREIGN KEY REFERENCES PoliceOfficers225(OfficerID)
);

-- Create the Evidence table
CREATE TABLE Evidence225 (
    EvidenceID INT PRIMARY KEY,
    CaseID INT FOREIGN KEY REFERENCES Cases225(CaseID),
    Description TEXT,
    DateCollected DATETIME DEFAULT GETDATE(),
    LocationCollected VARCHAR(255),
    CustodianOfficerID INT FOREIGN KEY REFERENCES PoliceOfficers225(OfficerID)
);

-- Create the Suspects table
CREATE TABLE Suspects225 (
    SuspectID INT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    DateOfBirth DATE,
    Address VARCHAR(255),
    ContactNumber VARCHAR(20),
    CaseID INT FOREIGN KEY REFERENCES Cases225(CaseID)
);

-- Create the Vehicles table
CREATE TABLE Vehicles225 (
    VehicleID INT PRIMARY KEY,
    LicensePlate VARCHAR(20) UNIQUE NOT NULL,
    Make VARCHAR(50),
    Model VARCHAR(50),
    Color VARCHAR(50),
    OwnerName VARCHAR(100),
    CaseID INT FOREIGN KEY REFERENCES Cases225(CaseID)
);

-- ...existing code...

-- Create the Arrests table
CREATE TABLE Arrests225 (
    ArrestID INT PRIMARY KEY,
    SuspectID INT FOREIGN KEY REFERENCES Suspects225(SuspectID),
    OfficerID INT FOREIGN KEY REFERENCES PoliceOfficers225(OfficerID),
    CaseID INT FOREIGN KEY REFERENCES Cases225(CaseID),
    ArrestDate DATETIME DEFAULT GETDATE(),
    Location VARCHAR(255),
    Reason TEXT
);

-- Create the Warrants table
CREATE TABLE Warrants225 (
    WarrantID INT PRIMARY KEY,
    SuspectID INT FOREIGN KEY REFERENCES Suspects225(SuspectID),
    CaseID INT FOREIGN KEY REFERENCES Cases225(CaseID),
    IssueDate DATETIME DEFAULT GETDATE(),
    ExpiryDate DATETIME,
    IssuingJudge VARCHAR(255),
    ExecutingOfficerID INT FOREIGN KEY REFERENCES PoliceOfficers225(OfficerID)
);

-- Create the Victims table
CREATE TABLE Victims225 (
    VictimID INT PRIMARY KEY,
    CaseID INT FOREIGN KEY REFERENCES Cases225(CaseID),
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    DateOfBirth DATE,
    Address VARCHAR(255),
    ContactNumber VARCHAR(20),
    InjuryDescription TEXT
);

-- Insert sample data into Arrests
INSERT INTO Arrests225 (ArrestID, SuspectID, OfficerID, CaseID, ArrestDate, Location, Reason) VALUES
(1, 1, 1, 1, '2023-01-16', '123 Main Street', 'Suspected of theft'),
(2, 2, 2, 2, '2023-02-21', '456 Graffiti Lane', 'Vandalism');

-- Insert sample data into Warrants
INSERT INTO Warrants225 (WarrantID, SuspectID, CaseID, IssueDate, ExpiryDate, IssuingJudge, ExecutingOfficerID) VALUES
(1, 1, 1, '2023-01-15', '2023-02-15', 'Judge Judy', 1),
(2, 2, 2, '2023-02-20', '2023-03-20', 'Judge Joe Brown', 2);

-- Insert sample data into Victims
INSERT INTO Victims225 (VictimID, CaseID, FirstName, LastName, DateOfBirth, Address, ContactNumber, InjuryDescription) VALUES
(1, 3, 'Victim', 'One', '1970-01-01', '789 Victim Lane', '555-123-4567', 'Minor injuries'),
(2, 3, 'Victim', 'Two', '1980-02-02', '101 Victim Street', '555-789-0123', 'Severe injuries');
-- Insert sample data into PoliceOfficers
INSERT INTO PoliceOfficers225 (OfficerID, FirstName, LastName, BadgeNumber, Rank, Precinct, DateOfBirth, HireDate, Gender, ContactNumber, Email) VALUES
(1, 'John', 'Doe', 'PD123', 'Detective', '1st Precinct', '1980-05-15', '2010-08-20', 'Male', '123-456-7890', 'john.doe@police.gov'),
(2, 'Jane', 'Smith', 'PD456', 'Sergeant', '2nd Precinct', '1975-11-22', '2005-03-10', 'Female', '987-654-3210', 'jane.smith@police.gov'),
(3, 'Robert', 'Jones', 'PD789', 'Officer', '1st Precinct', '1985-02-01', '2015-09-01', 'Male', '555-123-4567', 'robert.jones@police.gov'),
(4, 'Emily', 'Brown', 'PD012', 'Officer', '3rd Precinct', '1990-07-10', '2020-01-15', 'Female', '777-888-9999', 'emily.brown@police.gov'),
(5, 'Michael', 'Davis', 'PD345', 'Detective', '2nd Precinct', '1978-09-18', '2008-06-01', 'Male', '333-444-5555', 'michael.davis@police.gov');

-- Create the PrisonerReleases table
CREATE TABLE PrisonerReleases225 (
    ReleaseID INT PRIMARY KEY,
    PrisonerName VARCHAR(100) NOT NULL,
    PrisonerID VARCHAR(20) NOT NULL,
    DateOfIncarceration DATE NOT NULL,
    DateOfRelease DATE NOT NULL,
    ReleaseType VARCHAR(50) NOT NULL, -- e.g., Completed Sentence, Parole, Bail
    SupervisingOfficerID INT FOREIGN KEY REFERENCES PoliceOfficers225(OfficerID),
    CaseID INT FOREIGN KEY REFERENCES Cases225(CaseID),
    ReleaseConditions TEXT,
    ReleaseStatus VARCHAR(50) DEFAULT 'Scheduled', -- e.g., Scheduled, Completed, Canceled
    NextCheckInDate DATE,
    Notes TEXT
);

-- Insert sample data into PrisonerReleases
INSERT INTO PrisonerReleases225 (ReleaseID, PrisonerName, PrisonerID, DateOfIncarceration, DateOfRelease, ReleaseType, SupervisingOfficerID, CaseID, ReleaseConditions, ReleaseStatus, NextCheckInDate, Notes) VALUES
(1, 'James Wilson', 'P10045', '2022-06-15', '2023-06-15', 'Completed Sentence', 2, 2, 'None', 'Completed', NULL, 'Released after completing full sentence.'),
(2, 'Maria Rodriguez', 'P10289', '2022-10-03', '2023-07-01', 'Parole', 1, 1, 'Weekly check-in, No contact with victims, Cannot leave state', 'Scheduled', '2023-07-08', 'First-time offender, good behavior during incarceration.'),
(3, 'Thomas Lee', 'P11056', '2022-08-22', '2023-06-30', 'Bail', 5, 5, 'Electronic monitoring, Surrender passport', 'Scheduled', '2023-07-07', 'Awaiting trial, granted conditional release.'),
(4, 'Sarah Johnson', 'P10567', '2022-05-10', '2023-06-20', 'Parole', 3, 3, 'Monthly check-in, Rehabilitation program', 'Completed', '2023-07-20', 'Successfully reintegrating.'),
(5, 'Robert Davis', 'P10892', '2022-11-15', '2023-07-10', 'Bail', 4, 4, 'House arrest, Electronic ankle monitor', 'Scheduled', '2023-07-17', 'High flight risk, strict conditions applied.');

-- Insert sample data into Cases
INSERT INTO Cases225 (CaseID, CaseNumber, Title, Description, DateOpened, Status, LeadOfficerID) VALUES
(1, 'C-2023-001', 'Theft at First Bank', 'A robbery occurred at First Bank on Main Street.', '2023-01-15', 'Open', 1),
(2, 'C-2023-002', 'Vandalism at City Hall', 'City Hall was vandalized with graffiti.', '2023-02-20', 'Closed', 2),
(3, 'C-2023-003', 'Assault on Elm Street', 'An assault occurred on Elm Street.', '2023-03-10', 'Open', 3),
(4, 'C-2023-004', 'Traffic Accident on Oak Avenue', 'A traffic accident occurred on Oak Avenue.', '2023-04-05', 'Closed', 4),
(5, 'C-2023-005', 'Burglary at Smith Residence', 'The Smith residence was burglarized.', '2023-05-01', 'Open', 5);

-- Insert sample data into Evidence
INSERT INTO Evidence225 (EvidenceID, CaseID, Description, DateCollected, LocationCollected, CustodianOfficerID) VALUES
(1, 1, 'Security camera footage', '2023-01-15', 'First Bank', 1),
(2, 2, 'Spray paint cans', '2023-02-20', 'City Hall', 2),
(3, 3, 'Witness statement', '2023-03-10', 'Elm Street', 3),
(4, 4, 'Vehicle fragments', '2023-04-05', 'Oak Avenue', 4),
(5, 5, 'Footprints near window', '2023-05-01', 'Smith Residence', 5);

-- Insert sample data into Suspects
INSERT INTO Suspects225 (SuspectID, FirstName, LastName, DateOfBirth, Address, ContactNumber, CaseID) VALUES
(1, 'Unknown', 'Suspect', '1990-01-01', 'Unknown', 'Unknown', 1),
(2, 'Jane', 'Vandal', '1985-05-10', '123 Graffiti Lane', '555-111-2222', 2),
(3, 'John', 'Doe', '1980-03-15', '456 Elm Street', '555-333-4444', 3),
(4, 'Driver', 'Unknown', '1995-11-20', 'Unknown', 'Unknown', 4),
(5, 'Burglar', 'Unknown', '1970-07-04', 'Unknown', 'Unknown', 5);

-- Insert sample data into Vehicles
INSERT INTO Vehicles225 (VehicleID, LicensePlate, Make, Model, Color, OwnerName, CaseID) VALUES
(1, 'ABC-123', 'Ford', 'Focus', 'Blue', 'John Smith', 4),
(2, 'XYZ-789', 'Toyota', 'Camry', 'Silver', 'Jane Doe', 4),
(3, 'DEF-456', 'Honda', 'Civic', 'Red', 'Robert Jones', 4),
(4, 'GHI-012', 'Nissan', 'Altima', 'Black', 'Emily Brown', 4),
(5, 'JKL-345', 'Chevrolet', 'Malibu', 'White', 'Michael Davis', 4);



-- Create the Users table
CREATE TABLE Users225 (
    UserID INT PRIMARY KEY IDENTITY(1,1),
    Username VARCHAR(50) UNIQUE NOT NULL,
    PasswordHash VARCHAR(255) NOT NULL,
    Role VARCHAR(50) NOT NULL
);

-- Insert sample data into Users
-- Note: Replace 'hashed_password' with the actual hashed password
INSERT INTO Users225 (Username, PasswordHash, Role) VALUES
('AdminUser', 'hashed_admin_password', 'AdminRole225'),
('InvestigatorUser', 'hashed_investigator_password', 'InvestigatorRole225'),
('OfficerUser', 'hashed_officer_password', 'OfficerRole225'),
('PublicUser', 'hashed_public_password', 'PublicUserRole225');


-- Explanation of Tables and Relationships:
-- PoliceOfficers225: Stores information about police officers.
-- Cases225: Stores information about cases, with a foreign key referencing PoliceOfficers for the lead officer.
-- Evidence225: Stores information about evidence related to cases, with foreign keys referencing Cases and PoliceOfficers.
-- Suspects225: Stores information about suspects involved in cases, with a foreign key referencing Cases.
-- Vehicles225: Stores information about vehicles involved in cases, with a foreign key referencing Cases.
-- The relationships are necessary to link officers to cases, evidence to cases, suspects to cases, and vehicles to cases,
-- allowing for efficient querying and management of police-related data.