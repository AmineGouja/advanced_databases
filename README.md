# Advanced Databases - ING2

Travaux pratiques du module de base de donnees (2eme annee).

## Structure du depot

- `TP1/`
  - `BDATP1.pdf` : enonce du TP1
  - `create_database.sql` : creation du schema
  - `database_seeding.sql` : insertion des donnees
  - `request.sql` : reponses SQL du TP1
- `TP2/`
  - `TP2.pdf` : enonce du TP2
  - `universityDB-createschema.sql` : creation du schema
  - `universityDB-data.sql` : insertion des donnees
  - `request.sql` : reponses SQL (exercice 1)
  - `exercise4.py` : implementation Python (exercice 4)
- `TP4/`
  - `PLSQLSolution.pdf` : enonce du TP4
  - `request.sql` : reponses PL/SQL (exercices 1, 2 et 3)
- `TP5/`
  - `TPTransactions.pdf` : enonce du TP5
  - `request.sql` : scenarios SQL de transactions/concurrence

## Execution rapide

### Lancer SQLPlus

Depuis la racine du projet:

```bash
sqlplus votre_login/votre_mot_de_passe@votre_base
```

### SQL (TP1)

Dans SQLPlus, executer dans l'ordre:

1. `@TP1/create_database.sql`
2. `@TP1/database_seeding.sql`
3. `@TP1/request.sql`

### SQL (TP2)

Dans SQLPlus, executer dans l'ordre:

1. `@TP2/universityDB-createschema.sql`
2. `@TP2/universityDB-data.sql`
3. `@TP2/request.sql`

### Python (TP2 - Exercice 4)

```bash
python3 TP2/exercise4.py
```

### SQL (TP4)

Dans SQLPlus:

1. `@TP4/request.sql`

### SQL (TP5)

Dans SQLPlus:

1. `@TP5/request.sql`
2. Suivre les blocs `S1` et `S2` du fichier dans deux sessions SQLPlus ouvertes en parallele.

## Verification TP1

- `TP1/request.sql` contient bien 24 requetes numerotees (1 a 24).
- La structure et le contenu correspondent a l'enonce de `TP1/BDATP1.pdf` (partie requetes SQL).

## Auteur

- Amine Gouja étudiant ING2 - module BDA
