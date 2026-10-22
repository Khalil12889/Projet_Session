Prompt Création du package spec cours_tapi.
CREATE OR REPLACE PACKAGE cours_tapi IS
    TYPE cours_tapi_rec IS RECORD (
            credit cours.credit%TYPE, id_cours cours.id_cours%TYPE, nom_cours cours.nom_cours%TYPE
            , description_cours cours.description_cours%TYPE
    );
    TYPE cours_tapi_tab IS
        TABLE OF cours_tapi_rec;

-- insert
    FUNCTION ins_cours (
        p_credit cours.credit%TYPE, p_nom_cours cours.nom_cours%TYPE,
        p_description_cours cours.description_cours%TYPE, p_test VARCHAR2 DEFAULT 'N')
    return VARCHAR2;
-- update
    FUNCTION upd_cours (
        p_credit IN cours.credit%TYPE DEFAULT NULL, p_id_cours IN cours.id_cours%TYPE
        , p_nom_cours IN cours.nom_cours%TYPE DEFAULT NULL, p_description_cours IN cours.description_cours%TYPE
        DEFAULT NULL, p_test VARCHAR2 DEFAULT 'N'
    )
    return VARCHAR2;
-- delete
    FUNCTION del_cours (
        p_id_cours IN cours.id_cours%TYPE, p_test VARCHAR2 DEFAULT 'N'
    )
    return VARCHAR2;
-- select    
    FUNCTION get_cours (
        p_id_cours IN cours.id_cours%type,
        p_limite IN NUMBER DEFAULT 5,
        p_debut IN NUMBER DEFAULT 0,
        p_taille IN NUMBER DEFAULT 4
    ) RETURN VARCHAR2;
END cours_tapi;
/
SHOW ERRORS;
