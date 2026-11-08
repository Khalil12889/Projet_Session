--Zakaria Harcha

CREATE OR REPLACE PACKAGE membre_tapi IS

    TYPE membre_tapi_rec IS RECORD (
        idmembre          membre.idmembre%TYPE,
        nom               membre.nom%TYPE,
        prenom            membre.prenom%TYPE,
        numerotelephone   membre.numerotelephone%TYPE,
        adressecourriel   membre.adressecourriel%TYPE,
        dateabonnement    membre.dateabonnement%TYPE,
        status_idstatus   membre.status_idstatus%TYPE,
        adresse_idadresse membre.adresse_idadresse%TYPE
    );

    TYPE membre_tapi_tab IS TABLE OF membre_tapi_rec;

    -- INSERT
    FUNCTION ins_membre (
        p_id_membre         IN membre.idmembre%TYPE,
        p_nom               IN membre.nom%TYPE,
        p_prenom            IN membre.prenom%TYPE,
        p_numero_telephone  IN membre.numerotelephone%TYPE,
        p_adresse_courriel  IN membre.adressecourriel%TYPE,
        p_date_abonnement   IN membre.dateabonnement%TYPE,
        p_status_idstatus   IN membre.status_idstatus%TYPE,
        p_adresse_idadresse IN membre.adresse_idadresse%TYPE,
        p_test              IN VARCHAR2 DEFAULT 'N'
    ) RETURN VARCHAR2;

    -- UPDATE
    FUNCTION upd_membre (
        p_id_membre         IN membre.idmembre%TYPE,
        p_nom               IN membre.nom%TYPE DEFAULT NULL,
        p_prenom            IN membre.prenom%TYPE DEFAULT NULL,
        p_numero_telephone  IN membre.numerotelephone%TYPE DEFAULT NULL,
        p_adresse_courriel  IN membre.adressecourriel%TYPE DEFAULT NULL,
        p_date_abonnement   IN membre.dateabonnement%TYPE DEFAULT NULL,
        p_status_idstatus   IN membre.status_idstatus%TYPE DEFAULT NULL,
        p_adresse_idadresse IN membre.adresse_idadresse%TYPE DEFAULT NULL,
        p_test              IN VARCHAR2 DEFAULT 'N'
    ) RETURN VARCHAR2;

    -- DELETE
    FUNCTION del_membre (
        p_id_membre IN membre.idmembre%TYPE,
        p_test      IN VARCHAR2 DEFAULT 'N'
    ) RETURN VARCHAR2;

    -- SELECT
    FUNCTION get_membre (
        p_id_membre IN membre.idmembre%TYPE,
        p_limite    IN NUMBER DEFAULT 5,
        p_debut     IN NUMBER DEFAULT 0,
        p_taille    IN NUMBER DEFAULT 4
    ) RETURN VARCHAR2;

END membre_tapi;
/
SHOW ERRORS;