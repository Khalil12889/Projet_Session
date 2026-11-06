create or replace PACKAGE utilisateur_api AS


    FUNCTION ajouter_utilisateur(
        p_nomutilisateur utilisateur.nomutilisateur%TYPE,
        p_motdepasse utilisateur.motdepasse%TYPE,
        p_test VARCHAR2 DEFAULT 'N'
    ) RETURN VARCHAR2;

     FUNCTION retourner_utilisateur(
        p_idutilisateur utilisateur.idutilisateur%TYPE
    ) RETURN VARCHAR2;

END utilisateur_api;
