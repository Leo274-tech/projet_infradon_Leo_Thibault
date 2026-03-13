-- Active: 1772186463800@@127.0.0.1@5432@infradon
-- Active: 1772794232287@@127.0.0.1@5432@infradon-- Active: 1772794232287@@127.0.0.1@5432@infradon-- Active: 1772794232287@@127.0.0.1@5432@postgres-- Active: 1772794232287@@127.0.0.1@5432@infradon@public-- Active: 1772794232287@@127.0.0.1@5432@infradon-- Active: 1772794232287@@127.0.0.1@5432@infradon-- Active: 1772794232287@@127.0.0.1@5432@infradon-- Active: 1766063369847@@127.0.0.1@5438-- Active: 1766063369847@@127.0.0.1@5438-- Active: 1766063369847@@127.0.0.1@5438-- Active: 1764341819867@@127.0.0.1@5437
CREATE TABLE IF NOT EXISTS signalements (
    id SERIAL PRIMARY KEY,
    date_signalement DATE,
    signale_par VARCHAR(50),
    id_inventaire INTEGER REFERENCES inventaires(id),
    description_probleme TEXT NOT NULL, 
    urgence VARCHAR(20),
    statut VARCHAR(20)

);

CREATE TABLE IF NOT EXISTS interventions (
    id SERIAL PRIMARY KEY,
    date_intervention DATE,
    type_intervention INTEGER REFERENCES types_interventions(id),
    technicien VARCHAR(30),
    duree_heure REAL,
    cout_matériau DECIMAL(10, 2),
    remarques TEXT,
    id_signalement INTEGER REFERENCES NOT NULL signalement(id)

);

CREATE TABLE IF NOT EXISTS signalement_inventaire (
    id SERIAL PRIMARY KEY,
    id_signalement INTEGER REFERENCES NOT NULL signalement(id),
    id_inventaire INTEGER REFERENCES NOT NULL inventaire(id)

);

CREATE TABLE IF NOT EXISTS inventaire (
    id SERIAL PRIMARY KEY,
    id_inventaire VARCHAR(10) NOT NULL,
    type_inventaire INTEGER REFERENCES types_inventaire(id),
    materiau VARCHAR(50),
    lieu GEOMETRY(POINT, 2056),
    date_installation DATE,
    etat INTEGER REFERENCES etat_inventaire(id),
    remarques VARCHAR(120),
    id_fournisseur INTEGER REFERENCES fournisseurs(id)
);


CREATE TABLE IF NOT EXISTS fournisseurs (
    id SERIAL PRIMARY KEY,
    entreprise VARCHAR(30),
    nom_contact VARCHAR(30) NOT NULL,
    telephone INTEGER,
    email VARCHAR(50),
    remarque(120)
);

CREATE TABLE IF NOT EXISTS types_inventaires(
    id SERIAL PRIMARY KEY,
    libelle VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS etats_inventaires(
    id SERIAL PRIMARY KEY,
    libelle VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS types_materiel(
    id SERIAL PRIMARY KEY,
    libelle VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS types_interventions(
    id SERIAL PRIMARY KEY,
    libelle VARCHAR(50)
);



