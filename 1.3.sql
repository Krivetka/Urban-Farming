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





DROP TABLE IF EXISTS Temp_Plants;

CREATE TEMP TABLE Temp_Plants (
    PlantName VARCHAR(100),
    OptimalPH NUMERIC(4, 2),
    OptimalHumidity NUMERIC(5, 2),
    OptimalLightIntensity INT
);

COPY Temp_Plants(PlantName, OptimalPH, OptimalHumidity, OptimalLightIntensity)
FROM 'C:\TEMP\Plants.csv'
DELIMITER ','
CSV HEADER;

INSERT INTO Plants (PlantName, OptimalPH, OptimalHumidity, OptimalLightIntensity)
SELECT DISTINCT PlantName, OptimalPH, OptimalHumidity, OptimalLightIntensity
FROM Temp_Plants
ON CONFLICT (PlantName) DO NOTHING;

DROP TABLE IF EXISTS Temp_HydroponicSensors;

CREATE TEMP TABLE Temp_HydroponicSensors (
    SystemName VARCHAR(100),
    FarmName VARCHAR(100),
	SensorType VARCHAR(100)
);

COPY Temp_HydroponicSensors(SystemName, FarmName, SensorType)
FROM 'C:\TEMP\Hydroponic_Systems_and_Sensors.csv'
DELIMITER ','
CSV HEADER;

INSERT INTO HydroponicSystems (SystemName, FarmName)
SELECT DISTINCT SystemName, FarmName
FROM Temp_HydroponicSensors
ON CONFLICT (SystemName) DO NOTHING;

INSERT INTO Sensors (SensorType, SystemID)
SELECT DISTINCT ths.SensorType, hs.SystemID
FROM Temp_HydroponicSensors ths
JOIN HydroponicSystems hs ON ths.SystemName = hs.SystemName
ON CONFLICT DO NOTHING;



DROP TABLE IF EXISTS Temp_HarvestConditions;

CREATE TEMP TABLE Temp_HarvestConditions (
    FarmName VARCHAR(100),
    PlantName VARCHAR(100),
    HarvestDate DATE,
    Quantity NUMERIC(10, 2),
    MeasurementType VARCHAR(100),
    MeasurementValue NUMERIC(10, 2),
    MeasurementDateTime TIMESTAMP
);

COPY Temp_HarvestConditions(FarmName, PlantName, HarvestDate, Quantity, MeasurementType, MeasurementValue, MeasurementDateTime)
FROM 'C:\\TEMP\\Harvest_and_Conditions.csv'
DELIMITER ','
CSV HEADER;

DELETE FROM Harvest
WHERE ctid NOT IN (
    SELECT MIN(ctid)
    FROM Harvest
    GROUP BY FarmName, PlantName, HarvestDate
);

CREATE UNIQUE INDEX IF NOT EXISTS harvest_unique_idx
ON Harvest (FarmName, PlantName, HarvestDate);

INSERT INTO Harvest (FarmName, PlantName, HarvestDate, Quantity)
SELECT DISTINCT FarmName, PlantName, HarvestDate, Quantity
FROM Temp_HarvestConditions
ON CONFLICT (FarmName, PlantName, HarvestDate) DO NOTHING;


INSERT INTO EnvironmentalConditions (HarvestID, SensorID, MeasurementType, MeasurementValue, MeasurementDateTime)
SELECT DISTINCT h.HarvestID, 
       COALESCE(s.SensorID, 1) AS SensorID, 
       th.MeasurementType, 
       th.MeasurementValue, 
       th.MeasurementDateTime
FROM Temp_HarvestConditions th
JOIN Harvest h ON th.FarmName = h.FarmName
               AND th.PlantName = h.PlantName
               AND th.HarvestDate = h.HarvestDate
JOIN Farms f ON th.FarmName = f.FarmName
LEFT JOIN HydroponicSystems hs ON f.FarmName = hs.FarmName
LEFT JOIN Sensors s ON hs.SystemID = s.SystemID;


