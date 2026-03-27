-- Créer un schéma dédié pour la staging
CREATE SCHEMA IF NOT EXISTS staging;

-- Miroir du fichier mobilier.csv
CREATE TABLE staging.inventaire_mobiliers (
    id_inventaire TEXT,
    type_inventaire TEXT,
    materiau TEXT,
    lieu TEXT,
    latitude TEXT,
    longitude TEXT,
    date_installation TEXT,
    etat TEXT,
    remarques TEXT
);

-- Miroir du fichier interventions.csv
CREATE TABLE staging.interventions (
    date_intervention TEXT,
    objet_intervention TEXT,
    type_intervention TEXT,
    technicien TEXT,
    duree TEXT,
    cout_materiau TEXT,
    remarques TEXT
);

-- Miroir du fichier signalements.csv
CREATE TABLE staging.signalements (
    date_signalement TEXT,
    signale_par TEXT,
    id_inventaire_mobilier TEXT,
    description_probleme TEXT,
    urgence TEXT,
    statut TEXT
);

-- Miroir du fichier fournisseurs.csv
CREATE TABLE staging.fournisseurs (
    entreprise TEXT,
    nom_contact TEXT,
    telephone TEXT,
    email TEXT,
    type_materiel TEXT,
    remarques TEXT
);

-- Importer les données d'Excel
COPY staging.signalements
FROM '/csv/signalements.csv'
WITH (
        FORMAT csv,
        HEADER true,
        DELIMITER ',',
        ENCODING 'UTF8'
    );

COPY staging.inventaire_mobiliers
FROM '/csv/inventaire_mobilier.csv'
WITH (
        FORMAT csv,
        HEADER true,
        DELIMITER ',',
        ENCODING 'UTF8'
    );

COPY staging.fournisseurs
FROM '/csv/fournisseurs_contacts.csv'
WITH (
        FORMAT csv,
        HEADER true,
        DELIMITER ',',
        ENCODING 'UTF8'
    );

COPY staging.interventions
FROM '/csv/interventions.csv'
WITH (
        FORMAT csv,
        HEADER true,
        DELIMITER ',',
        ENCODING 'UTF8'
    );