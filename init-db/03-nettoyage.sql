-- Active: 1772186463800@@127.0.0.1@5432@infradon
-- Tables de normalisation
INSERT INTO
    public.types_inventaire (libelle)
VALUES ('lampadaire'),
    ('fontaine'),
    ('banc'),
    ('poubelle'),
    ('borne recharge'),
    ('panneau') ON CONFLICT (libelle) DO NOTHING;

INSERT INTO
    public.etats_inventaire (libelle)
VALUES ('à remplacer'),
    ('bon'),
    ('usé') ON CONFLICT (libelle) DO NOTHING;

INSERT INTO
    public.types_materiel (libelle)
VALUES ('bois'),
    ('métal'),
    ('sodium'),
    ('LED'),
    ('pierre'),
    ('béton') ON CONFLICT (libelle) DO NOTHING;

INSERT INTO
    public.types_intervention (libelle)
VALUES ('peinture'),
    ('remplacement'),
    ('réparation'),
    ('nettoyage'),
    ('hivernage'),
    ('redressage'),
    ('détartrage'),
    ('autre') ON CONFLICT (libelle) DO NOTHING;

-- Tables entités

INSERT INTO
    public.fournisseurs (
        entreprise,
        nom_contact,
        telephone,
        email,
        remarque
    )
SELECT
    entreprise,
    NULLIF(TRIM(nom_contact), ''),
    CASE
        WHEN telephone LIKE '0%' THEN telephone
        WHEN telephone LIKE '+41%' THEN regexp_replace(telephone, '^\+41', '0')
        ELSE NULL
    END AS telephone,
    CASE
        WHEN email LIKE '%@%' THEN email
        ELSE NULL
    END AS email,
    NULLIF(TRIM(remarque), '')
FROM staging.fournisseurs ON CONFLICT (id) DO NOTHING;

INSERT INTO 
    public.inventaire_mobilier (
        id_inventaire,
        type_inventaire,
        materiau,
        lieu,
        latitude,
        longitude,
        date_installation,
        etat,
        remarques
    );
SELECT id_inventaire, type_inventaire, materiau, lieu, latitude, longitude,
date_installation, etat, remarques
