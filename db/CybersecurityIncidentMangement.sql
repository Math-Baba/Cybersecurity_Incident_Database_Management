-- Création de la base de données
CREATE DATABASE CybersecurityIncidentManagementDB

-- Utilisation de la base de données
USE CybersecurityIncidentManagementDB;

-- Création des différentes tables
CREATE TABLE Analysts (
    analyst_id INT PRIMARY KEY IDENTITY(1,1),
    name VARCHAR(100),
    email VARCHAR(100),
    role VARCHAR(50),
    expertise VARCHAR(100), 
	student_fullname VARCHAR(100)
);

CREATE TABLE Systems (
    system_id INT PRIMARY KEY IDENTITY(1,1),
    name VARCHAR(100),
    owner VARCHAR(100),
    os VARCHAR(50),
    ip_adress VARCHAR(50),
	student_fullname VARCHAR(100)
);

CREATE TABLE Threats (
    threat_id INT PRIMARY KEY IDENTITY(1,1),
    name VARCHAR(100),
    description NVARCHAR(MAX),
    category VARCHAR(50),
    risk_level VARCHAR(20),
	student_fullname VARCHAR(100)
);

CREATE TABLE Incidents (
    incident_iD INT PRIMARY KEY IDENTITY(1,1),
    title VARCHAR(100),
    severity VARCHAR(20),
    status VARCHAR(20),
    reported_date DATETIME,
    analyst_id INT FOREIGN KEY REFERENCES Analysts(analyst_id),
	student_fullname VARCHAR(100)
);

CREATE TABLE IncidentThreats (
    incident_id INT FOREIGN KEY REFERENCES Incidents(incident_id),
    threat_id INT FOREIGN KEY REFERENCES Threats(threat_id),
    PRIMARY KEY (incident_id, threat_id)
);

CREATE TABLE Vulnerabilities (
    vuln_id INT PRIMARY KEY IDENTITY(1,1),
    system_id INT FOREIGN KEY REFERENCES Systems(system_id),
    cve_code VARCHAR(50),
    description NVARCHAR(MAX),
    patch_status VARCHAR(20),
	student_fullname VARCHAR(100)
);


DELETE FROM Analysts

SELECT * FROM Analysts
 
-- Mettre à jour analyst_id avec des valeurs aléatoires entre 101 et 150
UPDATE Vulnerabilities
SET system_id = CAST(101 + (ABS(CHECKSUM(NEWID())) % 50) AS INT);

-- Insérer 50 lignes aléatoires pour les id
DECLARE @i INT = 1;

WHILE @i <= 50
BEGIN
    INSERT INTO IncidentThreats (incident_id, threat_id)
    VALUES (
        CAST(101 + (ABS(CHECKSUM(NEWID())) % 50) AS INT),  -- incident_id entre 101 et 150
        CAST(1 + (ABS(CHECKSUM(NEWID())) % 50) AS INT)   -- threat_id entre 1 et 50
    );

    SET @i = @i + 1;
END;

-- Duplique 10 lignes au hasard de la table Analysts
INSERT INTO Analysts (name, email, role, expertise,student_fullname)
SELECT TOP 10 name, email, role, expertise, student_fullname FROM Analysts ORDER BY NEWID();  


