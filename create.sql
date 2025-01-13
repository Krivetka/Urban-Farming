CREATE TABLE Users (
    UserID SERIAL PRIMARY KEY,
    UserName VARCHAR(100) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    PasswordHash VARCHAR(255) NOT NULL,
    Owner BOOLEAN DEFAULT FALSE
);

CREATE TABLE Plants (
    PlantName VARCHAR(100) PRIMARY KEY,
    OptimalPH NUMERIC(4, 2),
    OptimalHumidity NUMERIC(5, 2)
);

CREATE TABLE Farms (
    FarmID SERIAL PRIMARY KEY,
    FarmName VARCHAR(100) UNIQUE NOT NULL,
    Location VARCHAR(255) NOT NULL
);

CREATE TABLE FarmUsers (
    FarmUserID SERIAL PRIMARY KEY,
    FarmID INT NOT NULL,
    UserID INT NOT NULL,
    Role VARCHAR(50),
    FOREIGN KEY (FarmID) REFERENCES Farms(FarmID),
    FOREIGN KEY (UserID) REFERENCES Users(UserID),
    UNIQUE (FarmID, UserID)
);


CREATE TABLE Harvest (
    HarvestID SERIAL PRIMARY KEY,
    FarmName VARCHAR(100) NOT NULL,
    PlantName VARCHAR(100) NOT NULL,
    HarvestDate DATE NOT NULL,
    Quantity NUMERIC(10, 2) NOT NULL,
    FOREIGN KEY (FarmName) REFERENCES Farms(FarmName),
    FOREIGN KEY (PlantName) REFERENCES Plants(PlantName)
);

CREATE TABLE HydroponicSystems (
    SystemID SERIAL PRIMARY KEY,
    SystemName VARCHAR(100) NOT NULL,
    FarmName VARCHAR(100) NOT NULL,
    FOREIGN KEY (FarmName) REFERENCES Farms(FarmName)
);

CREATE TABLE Sensors (
    SensorID SERIAL PRIMARY KEY,
    SensorType VARCHAR(100) NOT NULL,
    SystemID INT NOT NULL,
    FOREIGN KEY (SystemID) REFERENCES HydroponicSystems(SystemID)
);

CREATE TABLE EnvironmentalConditions (
    ConditionID SERIAL PRIMARY KEY,
    SensorID INT NOT NULL,
    MeasurementType VARCHAR(100) NOT NULL,
    MeasurementValue NUMERIC(10, 2) NOT NULL,
    MeasurementDateTime TIMESTAMP NOT NULL,
    FOREIGN KEY (SensorID) REFERENCES Sensors(SensorID)
);

CREATE TABLE MaintenanceLogs (
    LogID SERIAL PRIMARY KEY,
    SystemID INT NOT NULL,
    MaintenanceDate DATE NOT NULL,
    Description TEXT,
    Type VARCHAR(10) NOT NULL CHECK (Type IN ('OK', 'Warning', 'Error', 'Info', 'Critical')),
    FOREIGN KEY (SystemID) REFERENCES HydroponicSystems(SystemID)
);









DROP TABLE IF EXISTS Temp_Farms;

CREATE TEMP TABLE Temp_Farms (
    Email VARCHAR(100),
    UserName VARCHAR(100),
    PasswordHash VARCHAR(255),
    Owner TEXT,
    FarmName VARCHAR(100),
    Location VARCHAR(255)
);

COPY Temp_Farms(Email, UserName, PasswordHash, Owner, FarmName, Location)
FROM 'C:\TEMP\Farms_and_Users.csv'
DELIMITER ','
CSV HEADER;

UPDATE Temp_Farms
SET Owner = 
    CASE 
        WHEN LOWER(Owner) IN ('true', '1', 'yes') THEN 'TRUE'
        WHEN LOWER(Owner) IN ('false', '0', 'no') THEN 'FALSE'
        ELSE NULL
    END;

DELETE FROM Temp_Farms WHERE Owner IS NULL;

INSERT INTO Farms (FarmName, Location)
SELECT DISTINCT FarmName, Location
FROM Temp_Farms
ON CONFLICT (FarmName) DO NOTHING;

INSERT INTO Users (UserName, Email, PasswordHash, Owner)
SELECT DISTINCT UserName, Email, PasswordHash, CAST(Owner AS BOOLEAN)
FROM Temp_Farms
ON CONFLICT (Email) DO NOTHING;

INSERT INTO FarmUsers (FarmID, UserID, Role)
SELECT DISTINCT f.FarmID, u.UserID,
       CASE WHEN CAST(tf.Owner AS BOOLEAN) THEN 'Owner' ELSE 'Worker' END AS Role
FROM Temp_Farms tf
JOIN Farms f ON tf.FarmName = f.FarmName
JOIN Users u ON tf.Email = u.Email
ON CONFLICT (FarmID, UserID) DO NOTHING;

