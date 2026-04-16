-- Active: 1776325076709@@127.0.0.1@5432

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
    public.urgences_signalement (libelle)
VALUES ('urgent'),
    ('normal')
ON CONFLICT (libelle) DO NOTHING;

INSERT INTO
    public.statuts_signalement (libelle)
VALUES ('fait'),
    ('en attente'),
    ('en cours')
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
    public.inventaire_mobiliers (
        id_inventaire,
        type_inventaire, --id
        materiau, --id
        lieu,
        geom,
        date_installation,
        etat, --id
        remarques,
        id_fournisseur
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
        WHEN date_installation ~ '^\d{4}$' THEN TO_DATE(
            '01.01.' || date_installation,
            'DD.MM.YYYY'
        )
        WHEN date_installation ~ '^\d{2}\.\d{2}\.\d{4}$' THEN TO_DATE(
            date_installation,
            'DD.MM.YYYY'
        )
        WHEN date_installation ~ '^\d{4}-\d{2}-\d{2}$' THEN TO_DATE(
            date_installation,
            'YYYY-MM-DD'
        )
        WHEN date_installation ~ '^[a-zéû]+ \d{4}$' THEN TO_DATE(
            '01.' || CASE LOWER(
                    split_part(date_installation, ' ', 1)
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
            END || '.' || split_part(date_installation, ' ', 2),
            'DD.MM.YYYY'
        )
        ELSE NULL
    END AS date_installation,
    CASE
        WHEN LOWER(TRIM(etat)) LIKE '%remplace%' THEN 1
        WHEN LOWER(TRIM(etat)) LIKE '%bon%' THEN 2
        WHEN LOWER(TRIM(etat)) LIKE '%usé%' THEN 3
    END AS etat,
    remarques,
    id_fournisseur -- A FAIRE
FROM staging.inventaire_mobiliers;

INSERT INTO
    public.signalements (
        date_signalement,
        signale_par,
        inventaire_mobilier, --FK
        description_probleme,
        id_urgence,
        id_statut
    )
SELECT
    CASE
        WHEN date_signalement ~ '^\d{4}$' THEN TO_DATE(
            '01.01.' || date_signalement,
            'DD.MM.YYYY'
        )
        WHEN date_signalement ~ '^\d{2}\.\d{2}\.\d{4}$' THEN TO_DATE(
            date_signalement,
            'DD.MM.YYYY'
        )
        WHEN date_signalement ~ '^\d{4}-\d{2}-\d{2}$' THEN TO_DATE(
            date_signalement,
            'YYYY-MM-DD'
        )
        WHEN date_signalement ~ '^[a-zéû]+ \d{4}$' THEN TO_DATE(
            '01.' || CASE LOWER(
                    split_part(date_signalement, ' ', 1)
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
            END || '.' || split_part(date_signalement, ' ', 2),
            'DD.MM.YYYY'
        )
        ELSE NULL
    END AS date_signalement,
    signale_par,
    inventaire_mobilier, --A mettre une FK si possible -> processus manuel
    description_probleme,
    CASE
        WHEN s.id_urgence IS NULL
        OR TRIM(s.id_urgence) = '' THEN NULL
        ELSE us.id
    END AS id_urgence,
    CASE
        WHEN s.id_statut IS NULL
        OR TRIM(s.id_statut) = '' THEN NULL
        ELSE ss.id
    END AS id_statut
FROM staging.signalements s
    LEFT JOIN public.urgences_signalement us ON s.id_urgence = us.libelle
    LEFT JOIN public.statuts_signalement ss ON s.id_statut = ss.libelle;

INSERT INTO
    public.interventions (
        date_intervention,
        type_intervention,
        technicien,
        duree_heure,
        cout_materiau,
        remarques,
        id_signalement
    )
SELECT
    CASE
        WHEN date_intervention ~ '^\d{4}$' THEN TO_DATE(
            '01.01.' || date_intervention,
            'DD.MM.YYYY'
        )
        WHEN date_intervention ~ '^\d{2}\.\d{2}\.\d{4}$' THEN TO_DATE(
            date_intervention,
            'DD.MM.YYYY'
        )
        WHEN date_intervention ~ '^\d{4}-\d{2}-\d{2}$' THEN TO_DATE(
            date_intervention,
            'YYYY-MM-DD'
        )
        WHEN date_intervention ~ '^[a-zéû]+ \d{4}$' THEN TO_DATE(
            '01.' || CASE LOWER(
                    split_part(date_intervention, ' ', 1)
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
            END || '.' || split_part(date_intervention, ' ', 2),
            'DD.MM.YYYY'
        )
        ELSE NULL
    END AS date_intervention,
    CASE
        WHEN LOWER(TRIM(type_intervention)) LIKE '%' || ti.libelle || '%' THEN ti.id
        ELSE (
            SELECT id
            FROM public.types_intervention
            WHERE
                libelle = 'autre'
        )
    END AS type_intervention,
    CASE
        WHEN technicien = 'JM'
        OR technicien = 'Jean-Marc' THEN 'Jean-Marc Bonvin'
        ELSE technicien
    END AS technicien,
    CASE
        WHEN duree_heure = 'une matinée' THEN 4.00
        WHEN duree_heure = 'une journée' THEN 8.00
        WHEN duree_heure ~ '^\d+h\d{2}$' THEN (
            SPLIT_PART(duree_heure, 'h', 1)::INT + SPLIT_PART(duree_heure, 'h', 2)::INT / 60.0
        )::REAL
        WHEN duree_heure ~ '^\d+h$' THEN SPLIT_PART(duree_heure, 'h', 1)::INT::REAL
        WHEN duree_heure ~ '^\d+\s*min$' THEN (
            SPLIT_PART(TRIM(duree_heure), ' ', 1)::INT / 60.0
        )::REAL
        ELSE NULL
    END AS duree_heure,
    CASE
        WHEN cout_materiau LIKE '%gratuit%' THEN 0.0
        WHEN REGEXP_REPLACE(
            cout_materiau,
            '[^0-9.]',
            '',
            'g'
        ) ~ '^\d+\.?\d*$' THEN REGEXP_REPLACE(
            cout_materiau,
            '[^0-9.]',
            '',
            'g'
        )::FLOAT
        ELSE NULL
    END AS cout_materiau,
    remarques,
    NULL AS id_signalement --A CHANGER par la vraie FK
FROM
    staging.interventions i
    LEFT JOIN types_intervention ti ON LOWER(TRIM(i.type_intervention)) LIKE '%' || ti.libelle || '%';