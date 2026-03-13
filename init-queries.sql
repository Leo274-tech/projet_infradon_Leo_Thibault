-- Active: 1772186463800@@127.0.0.1@5432@infradon
-- Active: 1772794232287@@127.0.0.1@5432@infradon-- Active: 1772794232287@@127.0.0.1@5432@infradon-- Active: 1772794232287@@127.0.0.1@5432@postgres-- Active: 1772794232287@@127.0.0.1@5432@infradon@public-- Active: 1772794232287@@127.0.0.1@5432@infradon-- Active: 1772794232287@@127.0.0.1@5432@infradon-- Active: 1772794232287@@127.0.0.1@5432@infradon-- Active: 1766063369847@@127.0.0.1@5438-- Active: 1766063369847@@127.0.0.1@5438-- Active: 1766063369847@@127.0.0.1@5438-- Active: 1764341819867@@127.0.0.1@5437
CREATE TABLE IF NOT EXISTS signalements (
    id SERIAL PRIMARY KEY,
    date_signalement DATE,
    signale_par VARCHAR(50),
    objet VARCHAR(50),
    description VARCHAR(120) NOT NULL, 
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
    remarques VARCHAR(120),
    INTERGER REFERENCES NOT NULL signalement(id)

);

CREATE TABLE IF NOT EXISTS signalement_inventaire (
    id SERIAL PRIMARY KEY,
    INTERGER REFERENCES NOT NULL signalement(id),
    INTERGER REFERENCES NOT NULL inventaire(id)

);

CREATE TABLE IF NOT EXISTS inventaire (
    id SERIAL PRIMARY KEY,
    id_inventaire INTEGER NOT NULL,
    type_inventaire INTEGER REFERENCES types_inventaire(id),
    materiau VARCHAR(50),
    lieu VARCHAR(30),
    date_installation DATE,
    etat INTEGER REFERENCES etat(id),
    remarques VARCHAR(120)
);


CREATE TABLE IF NOT EXISTS fournisseurs (
    id SERIAL PRIMARY KEY,
    entreprise VARCHAR(30),
    nom_contact VARCHAR(30) NOT NULL,
    telephone INTEGER,
    email VARCHAR(50),
    type_materiel VARCHAR(50) REFERENCES types_inventaire(id),
    remarque(120)

);
