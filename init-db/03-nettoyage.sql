-- Active: 1772794232287@@127.0.0.1@5432

-- Tables de normalisation
INSERT INTO
    public.types_inventaire (libelle)
VALUES ('lampadaire'),
    ('fontaine'),
    ('banc'),
    ('poubelle'),
    ('borne recharge'),
    ('panneau')
ON CONFLICT (libelle) DO NOTHING;

INSERT INTO
    public.etats_inventaire (libelle)
VALUES ('à remplacer'),
    ('bon'),
    ('usé')
ON CONFLICT (libelle) DO NOTHING;

INSERT INTO
    public.types_materiel (libelle)
VALUES ('bois'),
    ('métal'),
    ('sodium'),
    ('LED'),
    ('pierre'),
    ('béton')
ON CONFLICT (libelle) DO NOTHING;

INSERT INTO
    public.types_intervention (libelle)
VALUES ('peinture'),
    ('remplacement'),
    ('réparation'),
    ('nettoyage'),
    ('hivernage'),
    ('redressage'),
    ('détartrage'),
    ('autre')
ON CONFLICT (libelle) DO NOTHING;

-- Tables entités
INSERT INTO
    public.fournisseurs (
        entreprise,
        nom_contact,
        telephone,
        email,
        remarques
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
    NULLIF(TRIM(remarques), '')
FROM staging.fournisseurs
ON CONFLICT (id) DO NOTHING;

INSERT INTO
    public.inventaire_mobilier (
        type_inventaire, --id
        materiau,
        lieu,
        latitude,
        longitude,
        date_installation,
        etat,
        remarques
    );

SELECT
    CASE
        WHEN LOWER(TRIM(type_inventaire)) LIKE '%lampadaire%' THEN 1
        WHEN LOWER(TRIM(type_inventaire)) LIKE '%fontaine%' THEN 2
        WHEN LOWER(TRIM(type_inventaire)) LIKE '%banc%' THEN 3
        WHEN LOWER(TRIM(type_inventaire)) LIKE '%poubelle%' THEN 4
        WHEN LOWER(TRIM(type_inventaire)) LIKE '%corbeille%' THEN 4
        WHEN LOWER(TRIM(type_inventaire)) LIKE '%borne%' THEN 5
        WHEN LOWER(TRIM(type_inventaire)) LIKE '%panneau%' THEN 6
        ELSE NULL
    END AS type_inventaire,
    CASE
    WHEN LOWER(TRIM(materiau)) LIKE '%bois%' THEN 1
        WHEN LOWER(TRIM(materiau)) LIKE '%métal%' THEN 2
        WHEN LOWER(TRIM(materiau)) LIKE '%sodium%' THEN 3
        WHEN LOWER(TRIM(materiau)) LIKE '%LED%' THEN 4
        WHEN LOWER(TRIM(materiau)) LIKE '%pierre%' THEN 5
        WHEN LOWER(TRIM(materiau)) LIKE '%béton%' THEN 6
        ELSE NULL
    END AS materiau,
    lieu,
    latitude,
    longitude,
    date_installation,
    etat,
    remarques
FROM staging.inventaire_mobiliers;