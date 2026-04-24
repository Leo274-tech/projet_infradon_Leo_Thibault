-- Active: 1776325076709@@127.0.0.1@5432

-- Tables de normalisation
INSERT INTO
    public.types_inventaire (libelle)
VALUES ('lampadaire'),
    ('fontaine'),
    ('banc'),
    ('poubelle'),
    ('borne recharge'),
    ('panneau'),
    ('autre');

INSERT INTO
    public.etats_inventaire (libelle)
VALUES ('à remplacer'),
    ('bon'),
    ('usé');

INSERT INTO
    public.urgences_signalement (libelle)
VALUES ('urgent'),
    ('normal');

INSERT INTO
    public.statuts_signalement (libelle)
VALUES ('fait'),
    ('en attente'),
    ('en cours');

INSERT INTO
    public.types_materiau (libelle)
VALUES ('bois'),
    ('métal'),
    ('sodium'),
    ('LED'),
    ('pierre'),
    ('béton');

INSERT INTO
    public.types_intervention (libelle)
VALUES ('peinture'),
    ('remplacement'),
    ('réparation'),
    ('nettoyage'),
    ('hivernage'),
    ('redressage'),
    ('détartrage'),
    ('autre');

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
FROM staging.fournisseurs;

INSERT INTO
    public.inventaire_mobiliers (
        id_inventaire,
        id_type_inventaire,
        id_type_materiau,
        lieu,
        geom,
        date_installation,
        id_etat,
        remarques
    )
SELECT
    id_inventaire,
    CASE
        WHEN LOWER(id_type_inventaire) LIKE '%lampadaire%' THEN 1
        WHEN LOWER(id_type_inventaire) LIKE '%fontaine%' THEN 2
        WHEN LOWER(id_type_inventaire) LIKE '%banc%' THEN 3
        WHEN LOWER(id_type_inventaire) LIKE '%poubelle%' THEN 4
        WHEN LOWER(id_type_inventaire) LIKE '%corbeille%' THEN 4
        WHEN LOWER(id_type_inventaire) LIKE '%borne%' THEN 5
        WHEN LOWER(id_type_inventaire) LIKE '%panneau%' THEN 6
        ELSE 7 -- 'autre'
    END AS id_type_inventaire,
    CASE
        WHEN LOWER(id_type_materiau) LIKE '%bois%' THEN 1
        WHEN LOWER(id_type_materiau) LIKE '%métal%' THEN 2
        WHEN LOWER(id_type_materiau) LIKE '%sodium%' THEN 3
        WHEN LOWER(id_type_materiau) LIKE '%LED%' THEN 4
        WHEN LOWER(id_type_materiau) LIKE '%pierre%' THEN 5
        WHEN LOWER(id_type_materiau) LIKE '%béton%' THEN 6
        ELSE NULL
    END AS id_type_materiau,
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
    normalize_date (date_installation) AS date_installation,
    CASE
        WHEN LOWER(id_etat) LIKE '%remplace%' THEN 1
        WHEN LOWER(id_etat) LIKE '%bon%' THEN 2
        WHEN LOWER(id_etat) LIKE '%usé%' THEN 3
    END AS id_etat,
    remarques
FROM staging.inventaire_mobiliers;

INSERT INTO
    public.signalements (
        date_signalement,
        signale_par,
        inventaire_mobilier, -- colonne temporaire pour permettre une jointure
        description_probleme,
        id_urgence,
        id_statut
    )
SELECT
    normalize_date (date_signalement) AS date_signalement,
    signale_par,
    inventaire_mobilier,
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
        inventaire_mobilier, -- colonne temporaire pour permettre une jointure
        type_intervention,
        technicien,
        duree_heure,
        cout_materiau,
        remarques
        -- id_signalement est très difficile à compléter de manière rigoureuse et n'est pas utile pour notre brief. La colonne sera donc ignorée.
    )
SELECT
    normalize_date (date_intervention) AS date_intervention,
    inventaire_mobilier,
    CASE
        WHEN LOWER(type_intervention) LIKE '%' || ti.libelle || '%' THEN ti.id
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
    remarques
FROM
    staging.interventions i
    LEFT JOIN types_intervention ti ON LOWER(i.type_intervention) LIKE '%' || ti.libelle || '%';

INSERT INTO
    public.interventions_inventaires (
        id_intervention,
        id_inventaire
    )
SELECT DISTINCT
    ON (i.id) i.id AS id_intervention,
    im.id AS id_inventaire
FROM public.inventaire_mobiliers im
    LEFT JOIN public.types_inventaire ti ON im.id_type_inventaire = ti.id
    INNER JOIN public.interventions i ON i.inventaire_mobilier ILIKE '%' || ti.libelle || '%' || im.lieu || '%'
ORDER BY i.id, im.date_installation ASC;

ALTER TABLE public.interventions DROP COLUMN inventaire_mobilier;

INSERT INTO
    public.signalements_inventaires (id_signalement, id_inventaire)
SELECT DISTINCT
    ON (s.id) s.id AS id_signalement,
    im.id AS id_inventaire
FROM public.inventaire_mobiliers im
    LEFT JOIN public.types_inventaire ti ON im.id_type_inventaire = ti.id
    INNER JOIN public.signalements s ON s.inventaire_mobilier ILIKE '%' || ti.libelle || '%' || im.lieu || '%'
ORDER BY s.id, im.date_installation ASC;

ALTER TABLE public.signalements DROP COLUMN inventaire_mobilier;

WITH
    fournisseurs_normalises AS (
        SELECT entreprise, regexp_split_to_table(id_type_inventaire, ',') AS types_normalises
        FROM staging.fournisseurs
    )
INSERT INTO
    public.fournisseurs_typesinventaire (
        id_fournisseur,
        id_type_inventaire
    )
SELECT
    pf.id AS id_fournisseur,
    CASE
        WHEN LOWER(TRIM(fn.types_normalises)) LIKE '%lampadaire%' THEN 1
        WHEN LOWER(TRIM(fn.types_normalises)) LIKE '%fontaine%' THEN 2
        WHEN LOWER(TRIM(fn.types_normalises)) LIKE '%banc%' THEN 3
        WHEN LOWER(TRIM(fn.types_normalises)) LIKE '%poubelle%' THEN 4
        WHEN LOWER(TRIM(fn.types_normalises)) LIKE '%corbeille%' THEN 4
        WHEN LOWER(TRIM(fn.types_normalises)) LIKE '%borne%' THEN 5
        WHEN LOWER(TRIM(fn.types_normalises)) LIKE '%panneau%' THEN 6
        ELSE 7 -- 'autre'
    END AS id_type_inventaire
FROM
    fournisseurs_normalises fn
    INNER JOIN public.fournisseurs pf ON fn.entreprise = pf.entreprise;