-- Create the Employee table first
CREATE TABLE Employee (
    PersonNumber VARCHAR(50) PRIMARY KEY,
    Name VARCHAR(100),
    Employee_Rank VARCHAR(50),
    Qualification VARCHAR(100),
    Designation ENUM('ATO', 'Assistant ATO', 'Supervisor', 'Tool Controller', 'Tradesmen'),
    Image BLOB,
    Biometric BLOB,
    Active_Status INT CHECK (Active_Status IN (0, 1)),
    TeamID VARCHAR(50)
);

-- Create the users table
CREATE TABLE User (
    PersonNumber VARCHAR(50) PRIMARY KEY, 
    Password VARCHAR(1000),
    FOREIGN KEY (PersonNumber) REFERENCES Employee(PersonNumber)
);


-- Create the Team table next as it is referenced by other tables
CREATE TABLE Team (
    SupervisorPersonNumber VARCHAR(50) PRIMARY KEY,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    HelicopterFrameNumber VARCHAR(50) UNIQUE,
    TradesMen1PersonNumber VARCHAR(50) UNIQUE,
    TradesMen2PersonNumber VARCHAR(50) UNIQUE,
    TradesMen3PersonNumber VARCHAR(50) UNIQUE
);

-- Create the Helicopter table as it is referenced by Team
CREATE TABLE Helicopter (
    FrameNumber VARCHAR(50) PRIMARY KEY,
    Name VARCHAR(100),
    Image BLOB,
    Active_Status INT CHECK (Active_Status IN (0, 1)),
    TeamID VARCHAR(50)
);

-- Create the ToolKits table
CREATE TABLE ToolKits (
    ToolkitID INT PRIMARY KEY,
    ToolkitName VARCHAR(100),
    Color1 VARCHAR(50),
    Color2 VARCHAR(50),
    Active_Status INT CHECK (Active_Status IN (0, 1))
);

-- Create the Tools table as it references ToolKits
CREATE TABLE Tools (
    ToolID INT AUTO_INCREMENT PRIMARY KEY,
    ToolkitID INT,
    Name VARCHAR(100),
    Size VARCHAR(50),
    PartNo VARCHAR(100),
    TotalQuantity INT,
    NetQuantity INT,
    Active_Status INT CHECK (Active_Status IN (0, 1))
);



-- Create the Services table
CREATE TABLE Services (
    ServiceID INT PRIMARY KEY,
    Name VARCHAR(100),
    HoursTaken INT,
    Active_Status INT CHECK (Active_Status IN (0, 1))
);

-- Create the Tokens table as it references Tools, Team, and Employee
CREATE TABLE Tokens (
    TokenID INT PRIMARY KEY AUTO_INCREMENT,
    ToolID INT,
    TeamID VARCHAR(50),
    EmployeeID VARCHAR(50),
    ServiceID INT,
    Status ENUM('Issued', 'Returned') DEFAULT 'Issued',
    IssuedBy VARCHAR(50),
    IssuedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ReturnedAt TIMESTAMP NULL,
    DueDate TIMESTAMP AS (IssuedAt + INTERVAL 12 HOUR)
);

-- Create the TeamService table as it references Team and Services
CREATE TABLE TeamService (
    SupervisorPersonNumber VARCHAR(50),
    ServiceID INT,
    AssignedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CompletedAt TIMESTAMP NULL,
    PRIMARY KEY (SupervisorPersonNumber, ServiceID,AssignedAt)
);

-- Create the HistoryOfTeams table
CREATE TABLE HistoryOfTeams (
    SupervisorPersonNumber VARCHAR(50),
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ClosedAt TIMESTAMP,
    HelicopterFrameNumber VARCHAR(50),
    TradesMen1PersonNumber VARCHAR(50),
    TradesMen2PersonNumber VARCHAR(50),
    TradesMen3PersonNumber VARCHAR(50),
    PRIMARY KEY (SupervisorPersonNumber, CreatedAt)
);

-- Create the TeamServiceHistory table as it references HistoryOfTeams and Services
CREATE TABLE TeamServiceHistory (
    SupervisorPersonNumber VARCHAR(50),
    ServiceID INT,
    PerformedAt TIMESTAMP,
    CompletedAt TIMESTAMP NULL,
    PRIMARY KEY (SupervisorPersonNumber, ServiceID, PerformedAt)
);



-- Alter Team table to add foreign key constraints
ALTER TABLE Team
ADD CONSTRAINT FK_SupervisorPersonNumber
FOREIGN KEY (SupervisorPersonNumber) REFERENCES Employee(PersonNumber),
ADD CONSTRAINT FK_HelicopterFrameNumber
FOREIGN KEY (HelicopterFrameNumber) REFERENCES Helicopter(FrameNumber),
ADD CONSTRAINT FK_TradesMen1PersonNumber
FOREIGN KEY (TradesMen1PersonNumber) REFERENCES Employee(PersonNumber),
ADD CONSTRAINT FK_TradesMen2PersonNumber
FOREIGN KEY (TradesMen2PersonNumber) REFERENCES Employee(PersonNumber),
ADD CONSTRAINT FK_TradesMen3PersonNumber
FOREIGN KEY (TradesMen3PersonNumber) REFERENCES Employee(PersonNumber);


Alter Tools table to add foreign key constraint
ALTER TABLE Tools
ADD CONSTRAINT FK_ToolKit
FOREIGN KEY (ToolkitID) REFERENCES ToolKits(ToolkitID);

-- Alter Tokens table to add foreign key constraints
ALTER TABLE Tokens
ADD CONSTRAINT FK_Tool
FOREIGN KEY (ToolID) REFERENCES Tools(ToolID),
ADD CONSTRAINT FK_Team
FOREIGN KEY (TeamID) REFERENCES Team(SupervisorPersonNumber),
ADD CONSTRAINT FK_Employee
FOREIGN KEY (EmployeeID) REFERENCES Employee(PersonNumber),
ADD CONSTRAINT FK_Service
FOREIGN KEY(ServiceID) REFERENCES Services(ServiceID);

-- Alter TeamService table to add foreign key constraints
ALTER TABLE TeamService
ADD CONSTRAINT FK_TeamService_Supervisor
FOREIGN KEY (SupervisorPersonNumber) REFERENCES Team(SupervisorPersonNumber),
ADD CONSTRAINT FK_TeamService_Service
FOREIGN KEY (ServiceID) REFERENCES Services(ServiceID);

-- Alter HistoryOfTeams table to add foreign key constraints
ALTER TABLE HistoryOfTeams
ADD CONSTRAINT FK_HistoryOfTeams_Supervisor
FOREIGN KEY (SupervisorPersonNumber) REFERENCES Employee(PersonNumber),
ADD CONSTRAINT FK_HistoryOfTeams_Helicopter
FOREIGN KEY (HelicopterFrameNumber) REFERENCES Helicopter(FrameNumber),
ADD CONSTRAINT FK_HistoryOfTeams_TradesMen1
FOREIGN KEY (TradesMen1PersonNumber) REFERENCES Employee(PersonNumber),
ADD CONSTRAINT FK_HistoryOfTeams_TradesMen2
FOREIGN KEY (TradesMen2PersonNumber) REFERENCES Employee(PersonNumber),
ADD CONSTRAINT FK_HistoryOfTeams_TradesMen3
FOREIGN KEY (TradesMen3PersonNumber) REFERENCES Employee(PersonNumber);

-- Alter TeamServiceHistory table to add foreign key constraints
ALTER TABLE TeamServiceHistory
ADD CONSTRAINT FK_TeamServiceHistory_Supervisor
FOREIGN KEY (SupervisorPersonNumber) REFERENCES HistoryOfTeams(SupervisorPersonNumber),
ADD CONSTRAINT FK_TeamServiceHistory_Service
FOREIGN KEY (ServiceID) REFERENCES Services(ServiceID);



************************************************DUMMY DATA FOR USERS AND EMPLOYEE****************************************************************


INSERT INTO Employee (PersonNumber, Name, Employee_Rank, Qualification, Designation, Image, Biometric, Active_Status, TeamID) VALUES
-- Officers
('42342-Z', 'Alice Johnson', 'Chief Engineer', 'Mechanical Engineering', 'ATO', NULL, NULL, 1, NULL),
('42343-Z', 'Bob Smith', 'Senior Engineer', 'Electrical Engineering', 'Assistant ATO', NULL, NULL, 1, NULL),

-- Sailors
('543267-S', 'Charlie Brown', 'Technician', 'Diploma in Engineering', 'Tradesmen', NULL, NULL, 1, NULL),
('543268-S', 'David Wilson', 'Technician', 'Diploma in Engineering', 'Tradesmen', NULL, NULL, 1, NULL),
('543269-S', 'Eva Davis', 'Technician', 'Diploma in Engineering', 'Tradesmen', NULL, NULL, 1, NULL),

-- Tool Controllers
('543270-S', 'Frank Green', 'Mechanic', 'Diploma in Engineering', 'Tool Controller', NULL, NULL, 1, NULL),
('543271-S', 'Grace Lee', 'Supervisor', 'Management Degree', 'Supervisor', NULL, NULL, 1, NULL),

-- Additional Supervisors
('543272-S', 'Hannah Moore', 'Senior Supervisor', 'Management Degree', 'Supervisor', NULL, NULL, 1, NULL),
('543273-S', 'Ian Clark', 'Lead Supervisor', 'Business Administration', 'Supervisor', NULL, NULL, 1, NULL),
('543274-S', 'Jack Thompson', 'Project Supervisor', 'Engineering Management', 'Supervisor', NULL, NULL, 1, NULL),
('543275-S', 'Kelly Adams', 'Operational Supervisor', 'Operations Management', 'Supervisor', NULL, NULL, 1, NULL),
('543276-S', 'Laura White', 'Technical Supervisor', 'Technical Management', 'Supervisor', NULL, NULL, 1, NULL),

-- Additional Tradesmen
('543277-S', 'Mike Roberts', 'Machinist', 'Diploma in Engineering', 'Tradesmen', NULL, NULL, 1, NULL),
('543278-S', 'Nina Harris', 'Electrician', 'Diploma in Electrical Engineering', 'Tradesmen', NULL, NULL, 1, NULL),
('543279-S', 'Oliver King', 'Mechanic', 'Diploma in Mechanical Engineering', 'Tradesmen', NULL, NULL, 1, NULL),
('543280-S', 'Paul Young', 'Welder', 'Diploma in Welding Technology', 'Tradesmen', NULL, NULL, 1, NULL),
('543281-S', 'Quinn Scott', 'Technician', 'Diploma in Engineering', 'Tradesmen', NULL, NULL, 1, NULL),
('543282-S', 'Rita Nelson', 'Plumber', 'Diploma in Plumbing', 'Tradesmen', NULL, NULL, 1, NULL),
('543283-S', 'Sam Green', 'Carpenter', 'Diploma in Carpentry', 'Tradesmen', NULL, NULL, 1, NULL),
('543284-S', 'Tina Carter', 'Painter', 'Diploma in Painting', 'Tradesmen', NULL, NULL, 1, NULL),
('543285-S', 'Ursula Adams', 'Assembler', 'Diploma in Assembly Technology', 'Tradesmen', NULL, NULL, 1, NULL),
('543286-S', 'Victor Baker', 'Inspector', 'Diploma in Inspection Technology', 'Tradesmen', NULL, NULL, 1, NULL),

-- Additional Tool Controllers
('543287-S', 'Will Harris', 'Tool Controller', 'Diploma in Engineering', 'Tool Controller', NULL, NULL, 1, NULL),
('543288-S', 'Xena Miller', 'Tool Controller', 'Diploma in Engineering', 'Tool Controller', NULL, NULL, 1, NULL);


INSERT INTO User (PersonNumber, Password) VALUES
-- Officers
('42342-Z', '1234'),
('42343-Z', '1234');


**********************************************DUMMY DATA FOR HELICOPTER******************************************************************

INSERT INTO Helicopter (FrameNumber, Name, Image, Active_Status, TeamID) VALUES
('CH001', 'Chetak', NULL, 1, NULL),
('CH002', 'Chetak', NULL, 1, NULL),
('CH003', 'Chetak', NULL, 1, NULL),
('CH004', 'Chetak', NULL, 1, NULL),
('CH005', 'Chetak', NULL, 1, NULL),
('CH006', 'Chetak', NULL, 1, NULL),
('CH007', 'Chetak', NULL, 1, NULL),
('CH008', 'Chetak', NULL, 1, NULL),
('CH009', 'Chetak', NULL, 1, NULL),
('CH010', 'Chetak', NULL, 1, NULL);


****************************************** DUMMY DATA FOR TOOLS AND TOOL KITS*******************************************************************


INSERT INTO ToolKits (ToolkitID, ToolkitName, Color1, Color2, Active_Status)
VALUES 
    (1, 'Basic Toolkit', 'Red', 'Black', 1),
    (2, 'Advanced Toolkit', 'Blue', 'White', 1),
    (3, 'Pro Toolkit', 'Green', 'Yellow', 1),
    (4, 'Standard Toolkit', 'Grey', 'Orange', 1);
    
-- Toolkit 1
INSERT INTO Tools (ToolID, ToolkitID, Name, Size, PartNo, TotalQuantity, NetQuantity, Active_Status)
VALUES 
    (1, 1, 'Screwdriver', 'Medium', 'SD-001', 1, 1, 1),
    (2, 1, 'Wrench', 'Large', 'WN-002', 1, 1, 1),
    (3, 1, 'Hammer', 'Medium', 'HM-003', 1, 1, 1),
    (4, 1, 'Pliers', 'Small', 'PL-004', 1, 1, 1),
    (5, 1, 'Tape Measure', 'Large', 'TM-005', 1, 1, 1),
    (6, 1, 'Socket Set', 'Medium', 'SS-006', 1, 1, 1),
    (7, 1, 'Drill Bit Set', 'Small', 'DB-007', 1, 1, 1),
    (8, 1, 'Screwdriver Set', 'Medium', 'SDS-008', 1, 1, 1),
    (9, 1, 'Utility Knife', 'Small', 'UK-009', 1, 1, 1),
    (10, 1, 'Chisel Set', 'Medium', 'CS-010', 1, 1, 1),
    (11, 1, 'Level', 'Medium', 'LV-011', 1, 1, 1),
    (12, 1, 'Allen Wrenches', 'Small', 'AW-012', 1, 1, 1),
    (13, 1, 'Tape Measure', 'Small', 'TM-013', 1, 1, 1),
    (14, 1, 'Adjustable Wrench', 'Large', 'AW-014', 1, 1, 1),
    (15, 1, 'Claw Hammer', 'Medium', 'CH-015', 1, 1, 1),
    (16, 1, 'Pipe Wrench', 'Large', 'PW-016', 1, 1, 1),
    (17, 1, 'Bolt Cutter', 'Large', 'BC-017', 1, 1, 1),
    (18, 1, 'Pry Bar', 'Medium', 'PB-018', 1, 1, 1),
    (19, 1, 'Needle Nose Pliers', 'Small', 'NNP-019', 1, 1, 1),
    (20, 1, 'Saw', 'Large', 'SW-020', 1, 1, 1);

-- Toolkit 2
INSERT INTO Tools (ToolID, ToolkitID, Name, Size, PartNo, TotalQuantity, NetQuantity, Active_Status)
VALUES 
    (21, 2, 'Drill', 'Small', 'DR-021', 1, 1, 1),
    (22, 2, 'Hammer', 'Medium', 'HM-022', 1, 1, 1),
    (23, 2, 'Screwdriver', 'Medium', 'SD-023', 1, 1, 1),
    (24, 2, 'Pliers', 'Small', 'PL-024', 1, 1, 1),
    (25, 2, 'Tape Measure', 'Large', 'TM-025', 1, 1, 1),
    (26, 2, 'Socket Set', 'Medium', 'SS-026', 1, 1, 1),
    (27, 2, 'Chisel Set', 'Medium', 'CS-027', 1, 1, 1),
    (28, 2, 'Utility Knife', 'Small', 'UK-028', 1, 1, 1),
    (29, 2, 'Screwdriver Set', 'Medium', 'SDS-029', 1, 1, 1),
    (30, 2, 'Level', 'Medium', 'LV-030', 1, 1, 1),
    (31, 2, 'Allen Wrenches', 'Small', 'AW-031', 1, 1, 1),
    (32, 2, 'Adjustable Wrench', 'Large', 'AW-032', 1, 1, 1),
    (33, 2, 'Claw Hammer', 'Medium', 'CH-033', 1, 1, 1),
    (34, 2, 'Pipe Wrench', 'Large', 'PW-034', 1, 1, 1),
    (35, 2, 'Bolt Cutter', 'Large', 'BC-035', 1, 1, 1),
    (36, 2, 'Pry Bar', 'Medium', 'PB-036', 1, 1, 1),
    (37, 2, 'Needle Nose Pliers', 'Small', 'NNP-037', 1, 1, 1),
    (38, 2, 'Saw', 'Large', 'SW-038', 1, 1, 1),
    (39, 2, 'Drill Bit Set', 'Small', 'DB-039', 1, 1, 1),
    (40, 2, 'Hand Saw', 'Large', 'HS-040', 1, 1, 1);

-- Toolkit 3
INSERT INTO Tools (ToolID, ToolkitID, Name, Size, PartNo, TotalQuantity, NetQuantity, Active_Status)
VALUES 
    (41, 3, 'Pliers', 'Small', 'PL-041', 1, 1, 1),
    (42, 3, 'Tape Measure', 'Large', 'TM-042', 1, 1, 1),
    (43, 3, 'Socket Set', 'Medium', 'SS-043', 1, 1, 1),
    (44, 3, 'Screwdriver Set', 'Medium', 'SDS-044', 1, 1, 1),
    (45, 3, 'Chisel Set', 'Medium', 'CS-045', 1, 1, 1),
    (46, 3, 'Utility Knife', 'Small', 'UK-046', 1, 1, 1),
    (47, 3, 'Hammer', 'Medium', 'HM-047', 1, 1, 1),
    (48, 3, 'Level', 'Medium', 'LV-048', 1, 1, 1),
    (49, 3, 'Drill Bit Set', 'Small', 'DB-049', 1, 1, 1),
    (50, 3, 'Allen Wrenches', 'Small', 'AW-050', 1, 1, 1),
    (51, 3, 'Adjustable Wrench', 'Large', 'AW-051', 1, 1, 1),
    (52, 3, 'Claw Hammer', 'Medium', 'CH-052', 1, 1, 1),
    (53, 3, 'Pipe Wrench', 'Large', 'PW-053', 1, 1, 1),
    (54, 3, 'Bolt Cutter', 'Large', 'BC-054', 1, 1, 1),
    (55, 3, 'Pry Bar', 'Medium', 'PB-055', 1, 1, 1),
    (56, 3, 'Needle Nose Pliers', 'Small', 'NNP-056', 1, 1, 1),
    (57, 3, 'Saw', 'Large', 'SW-057', 1, 1, 1),
    (58, 3, 'Hand Saw', 'Large', 'HS-058', 1, 1, 1),
    (59, 3, 'Pipe Cutter', 'Medium', 'PC-059', 1, 1, 1),
    (60, 3, 'Bolt Puller', 'Large', 'BP-060', 1, 1, 1);

-- Toolkit 4
INSERT INTO Tools (ToolID, ToolkitID, Name, Size, PartNo, TotalQuantity, NetQuantity, Active_Status)
VALUES 
    (61, 4, 'Saw', 'Large', 'SW-061', 1, 1, 1),
    (62, 4, 'Level', 'Medium', 'LV-062', 1, 1, 1),
    (63, 4, 'Drill', 'Small', 'DR-063', 1, 1, 1),
    (64, 4, 'Hammer', 'Medium', 'HM-064', 1, 1, 1),
    (65, 4, 'Pliers', 'Small', 'PL-065', 1, 1, 1),
    (66, 4, 'Tape Measure', 'Large', 'TM-066', 1, 1, 1),
    (67, 4, 'Socket Set', 'Medium', 'SS-067', 1, 1, 1),
    (68, 4, 'Chisel Set', 'Medium', 'CS-068', 1, 1, 1),
    (69, 4, 'Utility Knife', 'Small', 'UK-069', 1, 1, 1),
    (70, 4, 'Screwdriver Set', 'Medium', 'SDS-070', 1, 1, 1),
    (71, 4, 'Allen Wrenches', 'Small', 'AW-071', 1, 1, 1),
    (72, 4, 'Adjustable Wrench', 'Large', 'AW-072', 1, 1, 1),
    (73, 4, 'Claw Hammer', 'Medium', 'CH-073', 1, 1, 1),
    (74, 4, 'Pipe Wrench', 'Large', 'PW-074', 1, 1, 1),
    (75, 4, 'Bolt Cutter', 'Large', 'BC-075', 1, 1, 1),
    (76, 4, 'Pry Bar', 'Medium', 'PB-076', 1, 1, 1),
    (77, 4, 'Needle Nose Pliers', 'Small', 'NNP-077', 1, 1, 1),
    (78, 4, 'Hand Saw', 'Large', 'HS-078', 1, 1, 1),
    (79, 4, 'Pipe Cutter', 'Medium', 'PC-079', 1, 1, 1),
    (80, 4, 'Bolt Puller', 'Large', 'BP-080', 1, 1, 1);



****************************************** DUMMY DATA FOR SERVICES *****************************************************************************

INSERT INTO Services (ServiceID, Name, HoursTaken, Active_Status) VALUES
(1, 'Engine Overhaul', 10, 1),
(2, 'Hydraulic System Check', 8, 1),
(3, 'Rotor Blade Replacement', 12, 1),
(4, 'Fuel System Inspection', 6, 1),
(5, 'Electrical System Repair', 5, 1),
(6, 'Transmission Maintenance', 9, 1),
(7, 'Avionics Calibration', 7, 1),
(8, 'Landing Gear Inspection', 11, 1),
(9, 'Engine Performance Check', 10, 1),
(10, 'Structural Integrity Check', 8, 1);
