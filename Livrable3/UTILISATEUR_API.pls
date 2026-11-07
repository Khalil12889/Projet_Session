create or replace PACKAGE utilisateur_api AS


    FUNCTION ajouter_utilisateur(
        p_nomutilisateur utilisateur.nomutilisateur%TYPE,
        p_motdepasse utilisateur.motdepasse%TYPE,
        p_test VARCHAR2 DEFAULT 'N'
    ) RETURN VARCHAR2;

     FUNCTION retourner_utilisateur(
        p_idutilisateur IN utilisateur.idutilisateur%TYPE,
        p_limite IN NUMBER DEFAULT 5,
        p_debut IN NUMBER DEFAULT 0,
        p_taille IN NUMBER DEFAULT 4
    ) RETURN VARCHAR2;

   FUNCTION supprimer_utilisateur (
        p_idutilisateur utilisateur.idutilisateur%TYPE,
        p_test VARCHAR2 DEFAULT 'N'
    ) return VARCHAR2;


    FUNCTION modifier_utilisateur (
      p_idutilisateur utilisateur.idutilisateur%TYPE,
      p_nomutilisateur utilisateur.nomutilisateur%TYPE DEFAULT NULL,
      p_motdepasse utilisateur.motdepasse%TYPE DEFAULT NULL,
      p_test VARCHAR2 DEFAULT 'N'
    )RETURN VARCHAR2;

END utilisateur_api;
