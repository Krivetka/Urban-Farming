CREATE TABLE Plants (
    PlantName VARCHAR(100) PRIMARY KEY,
    OptimalPH NUMERIC(4, 2),
    OptimalHumidity NUMERIC(5, 2)
);

CREATE TABLE Farms (
    FarmName VARCHAR(100) PRIMARY KEY,
    Location VARCHAR(255),
    UserID INT NOT NULL
);

CREATE TABLE Users (
    UserID SERIAL PRIMARY KEY,
    UserName VARCHAR(100) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    PasswordHash VARCHAR(255) NOT NULL
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
    FOREIGN KEY (SystemID) REFERENCES HydroponicSystems(SystemID)
);
