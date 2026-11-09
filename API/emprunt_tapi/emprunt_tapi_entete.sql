CREATE OR REPLACE PACKAGE emprunt_tapi AS
    
    

    FUNCTION retourner(p_id_emprunt emprunt.idemprunt%Type) RETURN VARCHAR2;
    FUNCTION supprimer(p_id_emprunt emprunt.idemprunt%Type, p_test VARCHAR2 DEFAULT 'N') RETURN VARCHAR2;
    FUNCTION ajouter(p_id_membre membre.idmembre%TYPE, p_id_livre livre.idlivre%TYPE, p_id_utilisateur utilisateur.idutilisateur%TYPE, p_date_debut emprunt.datedebut%TYPE, 
                    p_date_retour_prevue emprunt.dateretourprevue%TYPE, p_test VARCHAR2 DEFAULT 'N') RETURN VARCHAR2;
    FUNCTION modifier(p_id_emprunt emprunt.idemprunt%Type,  p_nouv_id_membre IN membre.idmembre%TYPE DEFAULT NULL,p_nouv_id_livre IN livre.idlivre%TYPE DEFAULT NULL ,
                    p_nouv_id_utilisateur IN utilisateur.idutilisateur%TYPE DEFAULT NULL,p_nouv_dateretourprevue IN emprunt.dateretourprevue%TYPE DEFAULT NULL,
                    p_nouv_dateretour IN emprunt.dateretour%TYPE DEFAULT NULL, p_nouv_enretard IN emprunt.enretard%TYPE DEFAULT NULL, p_test VARCHAR2 DEFAULT 'N') RETURN VARCHAR2;

END emprunt_tapi;