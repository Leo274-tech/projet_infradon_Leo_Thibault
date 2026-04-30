
CREATE EXTENSION IF NOT EXISTS postgis;

-- Création d'une fonction pour normaliser une date (On effectue cette opération 3 fois.)
CREATE FUNCTION normalize_date(date_string TEXT)
RETURNS DATE 
LANGUAGE sql
IMMUTABLE
AS $$
SELECT 
    CASE
        -- Format: YYYY
        WHEN date_string ~ '^\d{4}$' THEN 
            TO_DATE('01.01.' || date_string, 'DD.MM.YYYY')

        -- Format: DD.MM.YYYY
        WHEN date_string ~ '^\d{2}\.\d{2}\.\d{4}$' THEN 
            TO_DATE(date_string, 'DD.MM.YYYY')

        -- Format: YYYY-MM-DD
        WHEN date_string ~ '^\d{4}-\d{2}-\d{2}$' THEN 
            TO_DATE(date_string, 'YYYY-MM-DD')

        -- Format: mois YYYY
        WHEN date_string ~* '^[a-zâéû]+ \d{4}$' THEN 
            TO_DATE(
                '01.' || 
                CASE LOWER(split_part(date_string, ' ', 1))
                    WHEN 'janvier'   THEN '01'
                    WHEN 'février'   THEN '02'
                    WHEN 'mars'      THEN '03'
                    WHEN 'avril'     THEN '04'
                    WHEN 'mai'       THEN '05'
                    WHEN 'juin'      THEN '06'
                    WHEN 'juillet'   THEN '07'
                    WHEN 'août'      THEN '08'
                    WHEN 'septembre' THEN '09'
                    WHEN 'octobre'   THEN '10'
                    WHEN 'novembre'  THEN '11'
                    WHEN 'décembre'  THEN '12'
                END || '.' || split_part(date_string, ' ', 2),
                'DD.MM.YYYY'
            )
        ELSE NULL
    END;
$$;