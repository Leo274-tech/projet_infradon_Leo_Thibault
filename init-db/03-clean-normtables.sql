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