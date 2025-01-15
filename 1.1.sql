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
    OptimalHumidity NUMERIC(5, 2),
    OptimalLightIntensity INT
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
    SystemName VARCHAR(100) NOT NULL UNIQUE,
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
    HarvestID INT NOT NULL,
    SensorID INT NOT NULL,
    MeasurementType VARCHAR(100) NOT NULL,
    MeasurementValue NUMERIC(10, 2) NOT NULL,
    MeasurementDateTime TIMESTAMP NOT NULL,
    FOREIGN KEY (HarvestID) REFERENCES Harvest(HarvestID),
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