from faker import Faker
import csv
import random
from datetime import datetime
import os

# chemin du dossier 'data' par rapport au script
script_dir = os.path.dirname(os.path.abspath(__file__))  # dossier contenant le script
data_folder = os.path.join(script_dir, '../data')  # remonte d'un niveau 

fake = Faker()

# Nombre de lignes à générer pour chaque table
n_analysts = 50
n_systems = 50
n_threats = 50
n_incidents = 50
n_vulnerabilities = 50
n_incidentthreats = 50

# Valeur fixe pour la colonne student_fullname
student_fullname = "Roland Laval Mathieu Baba"  

# ----------------- Analysts -----------------

# Ouvre/ Crée un fichier csv 
with open(os.path.join(data_folder, 'Analysts.csv'), 'w', newline='', encoding='utf-8') as f:
    writer = csv.writer(f) # Permission d'écrire dans le fichier
    writer.writerow(['analyst_id','name','email','role','expertise','student_fullname']) # en-tête des colonnes

    # Boucles pour générer de fausses données
    for i in range(1, n_analysts+1):
        writer.writerow([
            i,
            random.choice("!@#") + fake.name() + random.choice("!@#"), # données non nettoyées
            fake.email(),
            random.choice(['Junior Analyst', 'Senior Analyst', 'Manager']),
            random.choice(['Cybersecurity', 'Network', 'Application', 'Database']),
            student_fullname 
        ])

# ----------------- Systems -----------------
with open(os.path.join(data_folder, 'Systems.csv'), 'w', newline='', encoding='utf-8') as f:
    writer = csv.writer(f)
    writer.writerow(['system_id','name','owner','os','ip_adress','student_fullname'])
    for i in range(1, n_systems+1):
        writer.writerow([
            i,
            f"System {i}",
            fake.company() + random.choice("</>"), # données non nettoyées
            random.choice(['Windows Server', 'Linux', 'macOS']),
            fake.ipv4(),
            student_fullname
        ])

# ----------------- Threats -----------------
with open(os.path.join(data_folder, 'Threats.csv'), 'w', newline='', encoding='utf-8') as f:
    writer = csv.writer(f)
    writer.writerow(['threat_id','name','description','category','risk_level','student_fullname'])
    for i in range(1, n_threats+1):
        writer.writerow([
            i,
            f"Threat {i}",
            fake.sentence(nb_words=8),
            random.choice(['Application', 'Network', 'Hardware', 'Social Engineering']),
            random.choice("$*@") + random.choice(['Low','Medium','High']) + random.choice("$*@"), # données non nettoyées
            student_fullname
        ])

# ----------------- Incidents -----------------
with open(os.path.join(data_folder, 'Incidents.csv'), 'w', newline='', encoding='utf-8') as f:
    writer = csv.writer(f)
    writer.writerow(['incident_id','title','severity','status','reported_date','analyst_id','student_fullname'])
    for i in range(1, n_incidents+1):
        writer.writerow([
            i,
            f"Incident {i}",
            random.choice(['Low','Medium','High']),
            random.choice(['Open','Closed','In Progress']),
            fake.date_time_this_year().strftime("%Y-%m-%d %H:%M:%S"),
            random.randint(1, n_analysts),
            student_fullname
        ])

# ----------------- Vulnerabilities -----------------
with open(os.path.join(data_folder, 'Vulnerabilities.csv'), 'w', newline='', encoding='utf-8') as f:
    writer = csv.writer(f)
    writer.writerow(['vuln_id','system_id','cve_code','description','patch_status','student_fullname'])
    for i in range(1, n_vulnerabilities+1):
        writer.writerow([
            i,
            random.randint(1, n_systems),
            f"CVE-{fake.random_number(digits=4)}-{fake.random_number(digits=4)}",
            fake.sentence(nb_words=10),
            random.choice(['Patched','Unpatched']),
            student_fullname
        ])

# ----------------- IncidentThreats -----------------
with open(os.path.join(data_folder, 'IncidentThreats.csv'), 'w', newline='', encoding='utf-8') as f:
    writer = csv.writer(f)
    writer.writerow(['incident_id','threat_id'])
    for _ in range(n_incidentthreats):
        writer.writerow([
            random.randint(1, n_incidents),
            random.randint(1, n_threats)
        ])

print("CSV générés")
