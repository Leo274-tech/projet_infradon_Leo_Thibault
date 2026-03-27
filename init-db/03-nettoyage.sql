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
FROM staging.fournisseurs ON CONFLICT (id) DO NOTHING;

INSERT INTO
    public.inventaire_mobiliers (
        id_inventaire,
        type_inventaire, --id
        materiau, --id
        lieu,
        geom,
        date_installation,
        etat, --id
        remarques
    )
SELECT
    id_inventaire,
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
    ST_SetSRID (
        ST_MakePoint (
            (
                CAST(latitude AS DOUBLE PRECISION)
            ),
            CAST(longitude AS DOUBLE PRECISION)
        ),
        2056
    ) AS geom,
    CASE
        WHEN date_installation ~ '^\d{4}$' THEN TO_DATE (
            '01.01.' || date_installation,
            'DD.MM.YYYY'
        )
        WHEN date_installation ~ '^\d{2}\.\d{2}\.\d{4}$' THEN TO_DATE (
            date_installation,
            'DD.MM.YYYY'
        )
        WHEN date_installation ~ '^\d{4}-\d{2}-\d{2}$' THEN TO_DATE (
            date_installation,
            'YYYY-MM-DD'
        )
        WHEN date_installation ~ '^[a-zéû]+ \d{4}$' THEN TO_DATE (
            '01.' || CASE LOWER(
                    split_part (date_installation, ' ', 1)
                )
                WHEN 'janvier' THEN '01'
                WHEN 'février' THEN '02'
                WHEN 'mars' THEN '03'
                WHEN 'avril' THEN '04'
                WHEN 'mai' THEN '05'
                WHEN 'juin' THEN '06'
                WHEN 'juillet' THEN '07'
                WHEN 'août' THEN '08'
                WHEN 'septembre' THEN '09'
                WHEN 'octobre' THEN '10'
                WHEN 'novembre' THEN '11'
                WHEN 'décembre' THEN '12'
            END || '.' || split_part (date_installation, ' ', 2),
            'DD.MM.YYYY'
        )
        ELSE NULL
    END AS date_installation,
    CASE
        WHEN LOWER(TRIM(etat)) LIKE '%remplace%' THEN 1
        WHEN LOWER(TRIM(etat)) LIKE '%bon%' THEN 2
        WHEN LOWER(TRIM(etat)) LIKE '%usé%' THEN 3
    END AS etat,
    remarques
FROM staging.inventaire_mobiliers;