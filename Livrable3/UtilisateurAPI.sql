CREATE OR REPLACE PACKAGE utilisateur_api AS 
FUNCTION retourner_utilisateur (p_idutilisateur number) return varchar2;
END utilisateur_api ;

