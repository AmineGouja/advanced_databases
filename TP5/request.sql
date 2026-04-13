-- ============================================================
-- TP5 - Transactions et controle de concurrence
-- ============================================================
-- Important: ce fichier contient des scenarios a executer dans 2 sessions
-- SQL*Plus differentes (S1 et S2). Les commandes sont separees par blocs.

-- ============================================================
-- Exercice 1 - Atomicite d'une transaction
-- ============================================================

-- S1 (initialisation)
SET AUTOCOMMIT OFF;

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE transaction_tp5 PURGE';
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END;
/

CREATE TABLE transaction_tp5 (
    idTransaction VARCHAR2(44),
    valTransaction NUMBER(10)
);

-- S2
-- SET AUTOCOMMIT OFF;
-- INSERT INTO transaction_tp5 VALUES ('T1', 100);
-- INSERT INTO transaction_tp5 VALUES ('T2', 200);
-- UPDATE transaction_tp5 SET valTransaction = 250 WHERE idTransaction = 'T2';
-- DELETE FROM transaction_tp5 WHERE idTransaction = 'T1';
-- ROLLBACK;
-- SELECT * FROM transaction_tp5;

-- S2 (nouveau test)
-- INSERT INTO transaction_tp5 VALUES ('T3', 300);
-- INSERT INTO transaction_tp5 VALUES ('T4', 400);
-- quit;
-- Observation attendue cote S1: aucune preservation sans COMMIT.

-- S1 (nouveau test)
-- INSERT INTO transaction_tp5 VALUES ('T5', 500);
-- Fermeture brutale de la session sans COMMIT.
-- Observation: les changements non valides sont annules.

-- S2 (nouveau test)
-- INSERT INTO transaction_tp5 VALUES ('T6', 600);
-- ALTER TABLE transaction_tp5 ADD val2Transaction NUMBER(10);
-- ROLLBACK;
-- Observation: DDL (ALTER TABLE) provoque un COMMIT implicite avant/apres.

-- Conclusion Ex1:
-- Session: connexion active d'un utilisateur au SGBD.
-- Transaction: suite d'operations atomiques entre debut implicite et COMMIT/ROLLBACK.
-- Validation: COMMIT (changements durables).
-- Annulation: ROLLBACK (retour a l'etat precedent non valide).


-- ============================================================
-- Exercice 2 - Transactions concurrentes
-- ============================================================

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE client_tp5 PURGE';
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE vol_tp5 PURGE';
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END;
/

CREATE TABLE vol_tp5 (
    idVol VARCHAR2(44) PRIMARY KEY,
    capaciteVol NUMBER(10),
    nbrPlacesReserveesVol NUMBER(10)
);

CREATE TABLE client_tp5 (
    idClient VARCHAR2(44) PRIMARY KEY,
    prenomClient VARCHAR2(50),
    nbrPlacesReserveesClient NUMBER(10)
);

INSERT INTO vol_tp5 VALUES ('V1', 100, 0);
INSERT INTO client_tp5 VALUES ('C1', 'Alice', 0);
INSERT INTO client_tp5 VALUES ('C2', 'Bob', 0);
COMMIT;

-- ------------------------------------------------------------
-- A) READ COMMITTED (par defaut Oracle)
-- ------------------------------------------------------------

-- S1
-- SET AUTOCOMMIT OFF;
-- SELECT * FROM vol_tp5 WHERE idVol = 'V1';
-- SELECT * FROM client_tp5 WHERE idClient = 'C1';
-- UPDATE client_tp5
--    SET nbrPlacesReserveesClient = nbrPlacesReserveesClient + 2
--  WHERE idClient = 'C1';
-- UPDATE vol_tp5
--    SET nbrPlacesReserveesVol = nbrPlacesReserveesVol + 2
--  WHERE idVol = 'V1';
-- -- Ne pas COMMIT tout de suite

-- S2
-- SET AUTOCOMMIT OFF;
-- SELECT * FROM vol_tp5 WHERE idVol = 'V1';
-- SELECT * FROM client_tp5 WHERE idClient = 'C1';
-- -- Observation: les updates non commit de S1 ne sont pas visibles.

-- S1
-- ROLLBACK;
-- -- Observation: retour a l'etat initial.

-- S1 (rejouer puis valider)
-- UPDATE client_tp5
--    SET nbrPlacesReserveesClient = nbrPlacesReserveesClient + 2
--  WHERE idClient = 'C1';
-- UPDATE vol_tp5
--    SET nbrPlacesReserveesVol = nbrPlacesReserveesVol + 2
--  WHERE idVol = 'V1';
-- COMMIT;
-- -- Observation cote S2: les nouvelles valeurs deviennent visibles apres COMMIT.

-- ------------------------------------------------------------
-- B) Mise a jour perdue en READ COMMITTED
-- ------------------------------------------------------------

UPDATE vol_tp5 SET nbrPlacesReserveesVol = 0 WHERE idVol = 'V1';
UPDATE client_tp5 SET nbrPlacesReserveesClient = 0 WHERE idClient IN ('C1', 'C2');
COMMIT;

-- S1
-- SELECT nbrPlacesReserveesVol FROM vol_tp5 WHERE idVol = 'V1';   -- 0
-- SELECT nbrPlacesReserveesClient FROM client_tp5 WHERE idClient = 'C1'; -- 0

-- S2
-- SELECT nbrPlacesReserveesVol FROM vol_tp5 WHERE idVol = 'V1';   -- 0
-- SELECT nbrPlacesReserveesClient FROM client_tp5 WHERE idClient = 'C2'; -- 0

-- S1 (reserve 2)
-- UPDATE client_tp5 SET nbrPlacesReserveesClient = 2 WHERE idClient = 'C1';
-- UPDATE vol_tp5 SET nbrPlacesReserveesVol = 2 WHERE idVol = 'V1';
-- COMMIT;

-- S2 (reserve 3 mais sur ancienne lecture)
-- UPDATE client_tp5 SET nbrPlacesReserveesClient = 3 WHERE idClient = 'C2';
-- UPDATE vol_tp5 SET nbrPlacesReserveesVol = 3 WHERE idVol = 'V1';
-- COMMIT;

-- Verification
SELECT * FROM client_tp5 ORDER BY idClient;
SELECT * FROM vol_tp5;
-- Observation attendue:
-- C1=2, C2=3 (5 billets clients) mais vol=3 (incoherence due a une mise a jour perdue).

-- ------------------------------------------------------------
-- C) SERIALIZABLE (isolation complete)
-- ------------------------------------------------------------

UPDATE vol_tp5 SET nbrPlacesReserveesVol = 0 WHERE idVol = 'V1';
UPDATE client_tp5 SET nbrPlacesReserveesClient = 0 WHERE idClient IN ('C1', 'C2');
COMMIT;

-- S1
-- SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
-- SELECT nbrPlacesReserveesVol FROM vol_tp5 WHERE idVol = 'V1';
-- UPDATE client_tp5 SET nbrPlacesReserveesClient = nbrPlacesReserveesClient + 2 WHERE idClient = 'C1';
-- UPDATE vol_tp5 SET nbrPlacesReserveesVol = nbrPlacesReserveesVol + 2 WHERE idVol = 'V1';
-- -- Attendre avant COMMIT

-- S2
-- SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
-- SELECT nbrPlacesReserveesVol FROM vol_tp5 WHERE idVol = 'V1';
-- UPDATE client_tp5 SET nbrPlacesReserveesClient = nbrPlacesReserveesClient + 3 WHERE idClient = 'C2';
-- UPDATE vol_tp5 SET nbrPlacesReserveesVol = nbrPlacesReserveesVol + 3 WHERE idVol = 'V1';
-- COMMIT; -- peut echouer (ex: ORA-08177) selon ordre d'execution

-- S1
-- COMMIT;

-- Conclusion Ex2:
-- En SERIALIZABLE, Oracle peut rejeter une transaction concurrente pour conserver la coherence.
-- Le comportement est proche d'un controle optimiste de serialisation (pas strictement 2PL pur).
