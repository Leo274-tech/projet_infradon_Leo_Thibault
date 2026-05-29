
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
        WHEN LOWER(id_type_materiau) LIKE '%led%' THEN 4
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
FROM staging.inventaire_mobiliers
ON CONFLICT (id_inventaire) DO NOTHING;

INSERT INTO
    public.signalements (
        date_signalement,
        signale_par,
        inventaire_mobilier, -- colonne temporaire pour permettre une jointure
        id_inventaire,
        description_probleme,
        id_urgence,
        id_statut
    )
SELECT
    normalize_date (date_signalement) AS date_signalement,
    signale_par,
    inventaire_mobilier,
    (
        SELECT im.id
        FROM public.inventaire_mobiliers im
            LEFT JOIN public.types_inventaire ti ON im.id_type_inventaire = ti.id
        WHERE
            s.inventaire_mobilier ILIKE '%' || ti.libelle || '%' || im.lieu || '%'
        ORDER BY im.date_installation ASC
        LIMIT 1
    ) AS id_inventaire,
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
        id_inventaire,
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
    (
        SELECT im.id
        FROM public.inventaire_mobiliers im
            LEFT JOIN public.types_inventaire ti_inv ON im.id_type_inventaire = ti_inv.id
        WHERE
            i.inventaire_mobilier ILIKE '%' || ti_inv.libelle || '%' || im.lieu || '%'
        ORDER BY im.date_installation ASC
        LIMIT 1
    ) AS id_inventaire,
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

ALTER TABLE public.interventions DROP COLUMN inventaire_mobilier;

ALTER TABLE public.signalements DROP COLUMN inventaire_mobilier;