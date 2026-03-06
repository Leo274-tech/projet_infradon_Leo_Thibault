-- Active: 1764341819867@@127.0.0.1@5432
-- Active: 1772794232287@@127.0.0.1@5432@infradon-- Active: 1772794232287@@127.0.0.1@5432@infradon-- Active: 1772794232287@@127.0.0.1@5432@postgres-- Active: 1772794232287@@127.0.0.1@5432@infradon@public-- Active: 1772794232287@@127.0.0.1@5432@infradon-- Active: 1772794232287@@127.0.0.1@5432@infradon-- Active: 1772794232287@@127.0.0.1@5432@infradon-- Active: 1766063369847@@127.0.0.1@5438-- Active: 1766063369847@@127.0.0.1@5438-- Active: 1766063369847@@127.0.0.1@5438-- Active: 1764341819867@@127.0.0.1@5437
CREATE TABLE signalements (
    id SERIAL PRIMARY KEY,
    date_signalement DATE,
    signale_par VARCHAR(50),
    objet VARCHAR(50),
    description VARCHAR(120) NOT NULL, 
    urgence VARCHAR(20),
    statut VARCHAR(20)

);