USE master;
GO

-- Faire un backup complet
BACKUP DATABASE CybersecurityIncidentManagementDB
TO DISK = 'C:\Users\Mathieu\Desktop\Projets\Projet BBD Cybersécurité\db\CybersecurityIncidentManagementDB.bak'
WITH FORMAT,       -- créer un nouveau fichier de backup, écrase les anciens
     INIT,         -- initialise le média
     NAME = 'BackupCIMDB',  -- nom du backup
     STATS = 10;   -- affiche la progression
GO

-- Restaure la BDD actuelle avec le backup
USE master;
GO

RESTORE DATABASE CybersecurityIncidentManagementDB
FROM DISK = 'C:\Users\Mathieu\Desktop\Projets\Projet BBD Cybersécurité\db\CybersecurityIncidentManagementDB.bak'
WITH REPLACE;  -- remplace la base existante
GO

-- Mettre la base en single user
ALTER DATABASE CybersecurityIncidentManagementDB
SET SINGLE_USER
WITH ROLLBACK IMMEDIATE;

-- Remettre la base en multi user
ALTER DATABASE CybersecurityIncidentManagementDB
SET MULTI_USER;



