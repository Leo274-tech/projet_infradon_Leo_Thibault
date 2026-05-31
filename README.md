# Projet Léo & Thibault

## Analyse
### Problèmes de Qualité
- Les données ne sont pas normalisées -> tables de valeurs à faire impérativement
- Certaines cases sont NULL alors qu’elles ne devraient pas -> implémenter des contraintes NOT NULL
- Les colonnes latitude / longitude doivent être transformées en geom

### Tables et Colonnes Importantes
Les tables inventaire_mobiliers et interventions vont être primordiales pour le brief.

inventaire_mobiliers :
- id_inventaire_mobilier
- id_type_materiel
- lieu
- geom
- date_installation

interventions :
- date_intervention
- cout_materiau

## Éléments Manquants & Limites
Dans les interventions, les inventaires du même type et du même lieu ne sont pas différencié. Si deux lampadaires partagent la même zone, il devront donc se partager également le nombre d'interventions.

La description de interventions(objet) n'était pas assez précise pour relier les inventaire_mobiliers et les interventions. Certains lieux possèdent plusieurs objets du même type les rendant indistinguables. Nous avons donc choisi d'attribuer l'intervention à l'**objet d'inventaire le plus ancien** en cas de doute.

## Modélisation des données
### Modlèle Conceptuel de Données (MCD) & Modlèle Logique de Données (MLD)
Lien des diagramme : [cliquez ici](https://app.diagrams.net/#G1RyfIgxZ6X6b_RugQosdPgRoexjX0Adxi#%7B%22pageId%22%3A%225_qenR7KUMMb5oFbrNIR%22%7D)
*Deux pages existent, une pour la version originale, et une pour la version mise à jour et fidèle à l'implémentation physique.*

### Modlèle Physique de Données (MPD)
Voir `init-db/01-init.sql`

## Livrables
### Détails lampadaires
fichier : `livrables/v_lampadaires_detail.sql`

### Priorités lampadaires
fichier : `livrables/v_lampadaires_priorite.sql`


### Budget lampadaires
*pas effectué*