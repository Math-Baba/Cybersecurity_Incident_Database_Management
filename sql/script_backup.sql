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
FROM DISK = 'C:\Backups\CybersecurityIncidentManagementDB.bak'
WITH REPLACE;  -- remplace la base existante
GO

