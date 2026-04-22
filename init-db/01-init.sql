-- Active: 1776325076709@@127.0.0.1@5432@infradon
-- Active: 1772794232287@@127.0.0.1@5432@infradon-- Active: 1772794232287@@127.0.0.1@5432@infradon-- Active: 1772794232287@@127.0.0.1@5432@postgres-- Active: 1772794232287@@127.0.0.1@5432@infradon@public-- Active: 1772794232287@@127.0.0.1@5432@infradon-- Active: 1772794232287@@127.0.0.1@5432@infradon-- Active: 1772794232287@@127.0.0.1@5432@infradon-- Active: 1766063369847@@127.0.0.1@5438-- Active: 1766063369847@@127.0.0.1@5438-- Active: 1766063369847@@127.0.0.1@5438-- Active: 1764341819867@@127.0.0.1@5437

-- TABLES DE NORMALISATION

CREATE TABLE IF NOT EXISTS types_inventaire (
    id SERIAL PRIMARY KEY,
    libelle VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS etats_inventaire (
    id SERIAL PRIMARY KEY,
    libelle VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS types_materiau (
    id SERIAL PRIMARY KEY,
    libelle VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS types_intervention (
    id SERIAL PRIMARY KEY,
    libelle VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS statuts_signalement (
    id SERIAL PRIMARY KEY,
    libelle VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS urgences_signalement (
    id SERIAL PRIMARY KEY,
    libelle VARCHAR(50) UNIQUE NOT NULL
);



-- TABLES D'ENTITÉS

CREATE TABLE IF NOT EXISTS fournisseurs (
    id SERIAL PRIMARY KEY,
    entreprise VARCHAR(30) NOT NULL,
    nom_contact VARCHAR(30),
    telephone VARCHAR(15),
    email VARCHAR(50),
    remarques VARCHAR(120)
);

CREATE TABLE IF NOT EXISTS inventaire_mobiliers (
    id SERIAL PRIMARY KEY,
    id_inventaire VARCHAR(10) NOT NULL,
    id_type_inventaire INTEGER REFERENCES types_inventaire(id),
    id_type_materiau INTEGER REFERENCES types_materiau(id),
    lieu VARCHAR(50) NOT NULL,
    geom GEOMETRY(POINT, 2056),
    date_installation DATE,
    id_etat INTEGER REFERENCES etats_inventaire(id),
    remarques VARCHAR(120)
);

CREATE TABLE IF NOT EXISTS signalements (
    id SERIAL PRIMARY KEY,
    date_signalement DATE,
    signale_par VARCHAR(50),
    inventaire_mobilier TEXT NOT NULL, -- colonne temporaire pour permettre une jointure
    description_probleme TEXT NOT NULL, 
    id_urgence INTEGER REFERENCES urgences_signalement(id),
    id_statut INTEGER REFERENCES statuts_signalement(id)

);

CREATE TABLE IF NOT EXISTS interventions (
    id SERIAL PRIMARY KEY,
    date_intervention DATE,
    inventaire_mobilier TEXT NOT NULL, -- colonne temporaire pour permettre une jointure
    type_intervention INTEGER REFERENCES types_intervention(id),
    technicien VARCHAR(30),
    duree_heure REAL,
    cout_materiau FLOAT,
    remarques TEXT,
    id_signalement INTEGER REFERENCES signalements(id)

);

CREATE TABLE IF NOT EXISTS signalements_inventaires (
    id SERIAL PRIMARY KEY,
    id_signalement INTEGER REFERENCES signalements(id) NOT NULL,
    id_inventaire INTEGER REFERENCES inventaire_mobiliers(id) NOT NULL

);

CREATE TABLE IF NOT EXISTS interventions_inventaires (
    id SERIAL PRIMARY KEY,
    id_intervention INTEGER REFERENCES signalements(id) NOT NULL,
    id_inventaire INTEGER REFERENCES inventaire_mobiliers(id) NOT NULL

);

CREATE TABLE IF NOT EXISTS fournisseurs_typesinventaire (
    id SERIAL PRIMARY KEY,
    id_fournisseur INTEGER REFERENCES fournisseurs(id) NOT NULL,
    id_type_inventaire INTEGER REFERENCES types_inventaire(id) NOT NULL
)



