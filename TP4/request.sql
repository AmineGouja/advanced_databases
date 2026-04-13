SET SERVEROUTPUT ON;

-- ============================================================
-- TP4 - PL/SQL (Partie I)
-- ============================================================

-- ============================================================
-- Exercice 1
-- ============================================================

-- 1) Demander 2 entiers et afficher leur somme
ACCEPT p_a NUMBER PROMPT 'Entier 1: '
ACCEPT p_b NUMBER PROMPT 'Entier 2: '
DECLARE
    v_a NUMBER := &p_a;
    v_b NUMBER := &p_b;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Somme = ' || (v_a + v_b));
END;
/

-- 2) Demander un nombre et afficher sa table de multiplication
ACCEPT p_n NUMBER PROMPT 'Nombre pour table de multiplication: '
DECLARE
    v_n NUMBER := &p_n;
BEGIN
    FOR i IN 1..10 LOOP
        DBMS_OUTPUT.PUT_LINE(v_n || ' x ' || i || ' = ' || (v_n * i));
    END LOOP;
END;
/

-- 3) Fonction recursive x^n (x et n entiers positifs)
CREATE OR REPLACE FUNCTION puissance_rec(p_x IN NUMBER, p_n IN NUMBER)
RETURN NUMBER
IS
BEGIN
    IF p_n < 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'n doit etre positif.');
    ELSIF p_n = 0 THEN
        RETURN 1;
    ELSE
        RETURN p_x * puissance_rec(p_x, p_n - 1);
    END IF;
END;
/

-- Test rapide
BEGIN
    DBMS_OUTPUT.PUT_LINE('2^10 = ' || puissance_rec(2, 10));
END;
/

-- 4) Factorielle d'un entier strictement positif saisi par l'utilisateur
--    et stockage dans resultatFactoriel
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE resultatFactoriel PURGE';
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END;
/

CREATE TABLE resultatFactoriel (
    n NUMBER PRIMARY KEY,
    valeur NUMBER
);

ACCEPT p_fact NUMBER PROMPT 'Entier strictement positif (factorielle): '
DECLARE
    v_n NUMBER := &p_fact;
    v_fact NUMBER := 1;
BEGIN
    IF v_n <= 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Le nombre doit etre strictement positif.');
    END IF;

    FOR i IN 1..v_n LOOP
        v_fact := v_fact * i;
    END LOOP;

    INSERT INTO resultatFactoriel(n, valeur) VALUES (v_n, v_fact);
    DBMS_OUTPUT.PUT_LINE('Factorielle(' || v_n || ') = ' || v_fact || ' (inseree)');
END;
/

-- 5) Calculer/stocker les factorielles des 20 premiers entiers
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE resultatsFactoriels PURGE';
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END;
/

CREATE TABLE resultatsFactoriels (
    n NUMBER PRIMARY KEY,
    valeur NUMBER
);

DECLARE
    v_fact NUMBER := 1;
BEGIN
    FOR i IN 1..20 LOOP
        v_fact := v_fact * i;
        INSERT INTO resultatsFactoriels(n, valeur) VALUES (i, v_fact);
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('Factorielles 1..20 inserees dans resultatsFactoriels.');
END;
/

SELECT * FROM resultatsFactoriels ORDER BY n;


-- ============================================================
-- Exercice 2
-- ============================================================

-- Creation table emp + jeu de donnees
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE emp PURGE';
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END;
/

CREATE TABLE emp (
    matr NUMBER(10) NOT NULL,
    nom VARCHAR2(50) NOT NULL,
    sal NUMBER(7,2),
    adresse VARCHAR2(96),
    dep NUMBER(10) NOT NULL,
    CONSTRAINT emp_pk PRIMARY KEY (matr)
);

INSERT INTO emp VALUES (1, 'Amine', 2200, 'Paris', 92000);
INSERT INTO emp VALUES (2, 'Nora', 2800, 'Saint-Denis', 75000);
INSERT INTO emp VALUES (3, 'Yassine', 3100, 'Nanterre', 92000);
COMMIT;

-- 1) Inserer un nouvel employe via bloc anonyme
DECLARE
    v_employe emp%ROWTYPE;
BEGIN
    v_employe.matr := 4;
    v_employe.nom := 'Youcef';
    v_employe.sal := 2500;
    v_employe.adresse := 'Avenue de la Republique';
    v_employe.dep := 92002;

    INSERT INTO emp VALUES v_employe;
    DBMS_OUTPUT.PUT_LINE('Employe insere: matr=4');
END;
/

-- 2) Supprimer les employes dont le dep est connu (non NULL)
DECLARE
    v_nb_lignes NUMBER;
BEGIN
    DELETE FROM emp WHERE dep IS NOT NULL;
    v_nb_lignes := SQL%ROWCOUNT;
    DBMS_OUTPUT.PUT_LINE('v_nb_lignes: ' || v_nb_lignes);
    ROLLBACK; -- garde les donnees de test
END;
/

-- 3) Somme des salaires via curseur explicite + LOOP
DECLARE
    v_salaire emp.sal%TYPE;
    v_total emp.sal%TYPE := 0;
    CURSOR c_salaires IS
        SELECT sal FROM emp;
BEGIN
    OPEN c_salaires;
    LOOP
        FETCH c_salaires INTO v_salaire;
        EXIT WHEN c_salaires%NOTFOUND;
        IF v_salaire IS NOT NULL THEN
            v_total := v_total + v_salaire;
        END IF;
    END LOOP;
    CLOSE c_salaires;
    DBMS_OUTPUT.PUT_LINE('Total salaires = ' || v_total);
END;
/

-- 4) Salaire moyen via curseur explicite + LOOP
DECLARE
    v_salaire emp.sal%TYPE;
    v_total NUMBER := 0;
    v_count NUMBER := 0;
    CURSOR c_salaires IS
        SELECT sal FROM emp;
BEGIN
    OPEN c_salaires;
    LOOP
        FETCH c_salaires INTO v_salaire;
        EXIT WHEN c_salaires%NOTFOUND;
        IF v_salaire IS NOT NULL THEN
            v_total := v_total + v_salaire;
            v_count := v_count + 1;
        END IF;
    END LOOP;
    CLOSE c_salaires;

    IF v_count = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Aucun salaire.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Salaire moyen = ' || ROUND(v_total / v_count, 2));
    END IF;
END;
/

-- 5) Meme calculs avec boucle FOR IN
DECLARE
    v_total NUMBER := 0;
    v_count NUMBER := 0;
BEGIN
    FOR r IN (SELECT sal FROM emp) LOOP
        IF r.sal IS NOT NULL THEN
            v_total := v_total + r.sal;
            v_count := v_count + 1;
        END IF;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Total salaires (FOR IN) = ' || v_total);
    IF v_count = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Salaire moyen (FOR IN) = N/A');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Salaire moyen (FOR IN) = ' || ROUND(v_total / v_count, 2));
    END IF;
END;
/

-- 6) Noms des employes des dep 92000 et 75000 via curseur parametre
DECLARE
    CURSOR c(p_dep emp.dep%TYPE) IS
        SELECT dep, nom
        FROM emp
        WHERE dep = p_dep;
BEGIN
    FOR v_employe IN c(92000) LOOP
        DBMS_OUTPUT.PUT_LINE('Dep 92000: ' || v_employe.nom);
    END LOOP;

    FOR v_employe IN c(75000) LOOP
        DBMS_OUTPUT.PUT_LINE('Dep 75000: ' || v_employe.nom);
    END LOOP;
END;
/


-- ============================================================
-- Exercice 3
-- Package de gestion des clients (surcharge + exceptions)
-- ============================================================

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE client_gestion PURGE';
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END;
/

CREATE TABLE client_gestion (
    id_client NUMBER PRIMARY KEY,
    nom VARCHAR2(50) NOT NULL,
    prenom VARCHAR2(50) NOT NULL,
    email VARCHAR2(120) UNIQUE
);

CREATE OR REPLACE PACKAGE pkg_client AS
    PROCEDURE ajouter_client(
        p_id_client IN NUMBER,
        p_nom IN VARCHAR2,
        p_prenom IN VARCHAR2,
        p_email IN VARCHAR2
    );

    PROCEDURE ajouter_client(
        p_nom IN VARCHAR2,
        p_prenom IN VARCHAR2,
        p_email IN VARCHAR2
    );
END pkg_client;
/

CREATE OR REPLACE PACKAGE BODY pkg_client AS
    PROCEDURE valider_client(
        p_nom IN VARCHAR2,
        p_prenom IN VARCHAR2,
        p_email IN VARCHAR2
    ) IS
    BEGIN
        IF p_nom IS NULL OR p_prenom IS NULL THEN
            RAISE_APPLICATION_ERROR(-20010, 'Nom et prenom obligatoires.');
        END IF;
        IF p_email IS NULL OR INSTR(p_email, '@') = 0 THEN
            RAISE_APPLICATION_ERROR(-20011, 'Email invalide.');
        END IF;
    END valider_client;

    PROCEDURE ajouter_client(
        p_id_client IN NUMBER,
        p_nom IN VARCHAR2,
        p_prenom IN VARCHAR2,
        p_email IN VARCHAR2
    ) IS
    BEGIN
        valider_client(p_nom, p_prenom, p_email);

        INSERT INTO client_gestion(id_client, nom, prenom, email)
        VALUES (p_id_client, p_nom, p_prenom, p_email);

        DBMS_OUTPUT.PUT_LINE('Client ajoute (id fourni): ' || p_id_client);
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            DBMS_OUTPUT.PUT_LINE('Erreur: id ou email deja existant.');
        WHEN VALUE_ERROR THEN
            DBMS_OUTPUT.PUT_LINE('Erreur: type/longueur de valeur invalide.');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erreur inattendue: ' || SQLERRM);
    END ajouter_client;

    PROCEDURE ajouter_client(
        p_nom IN VARCHAR2,
        p_prenom IN VARCHAR2,
        p_email IN VARCHAR2
    ) IS
        v_new_id NUMBER;
    BEGIN
        valider_client(p_nom, p_prenom, p_email);

        SELECT NVL(MAX(id_client), 0) + 1
        INTO v_new_id
        FROM client_gestion;

        INSERT INTO client_gestion(id_client, nom, prenom, email)
        VALUES (v_new_id, p_nom, p_prenom, p_email);

        DBMS_OUTPUT.PUT_LINE('Client ajoute (id auto): ' || v_new_id);
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            DBMS_OUTPUT.PUT_LINE('Erreur: email deja existant.');
        WHEN VALUE_ERROR THEN
            DBMS_OUTPUT.PUT_LINE('Erreur: type/longueur de valeur invalide.');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erreur inattendue: ' || SQLERRM);
    END ajouter_client;
END pkg_client;
/

-- Tests package
BEGIN
    pkg_client.ajouter_client(1, 'Dupont', 'Alice', 'alice.dupont@mail.fr');
    pkg_client.ajouter_client('Martin', 'Leo', 'leo.martin@mail.fr');
    pkg_client.ajouter_client('Martin', 'Leo', 'leo.martin@mail.fr'); -- email duplique
END;
/

SELECT * FROM client_gestion ORDER BY id_client;
