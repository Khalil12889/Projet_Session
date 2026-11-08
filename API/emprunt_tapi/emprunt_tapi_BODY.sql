CREATE OR REPLACE PACKAGE BODY emprunt_tapi AS
    
    gc_scope_prefix CONSTANT VARCHAR2(31) := lower($$plsql_unit) || '.';
    
/**
    * Description   fonction pour retourner un emprunt (Fait a partir du document fournit par JF Brodeur)
    *
    *@version   1.0
    *
    * @example      l_resultant := emprunt_tapi.retourner(2);
    *
    * @issue        n/a
    *
    * @author       Khalil Arrahmen Bouraoui
    * @created      2026-11-08
    * @param        p_id_emprunt        id de l'emprunt cherche
    * @return       l_resultat          objet JSON avec l'id de l'emprunt, le titre du livre, le nom du membre, le nom de l'utilisateur, la date de debut, la date de fin prevue, la date de fin et le number indiquant s'il est en retard  
    * @exception    ex_id_null          si l'id entre est null, retourné dans un objet JSON avec status et code d erreur -20001
    * @exception    no_data_found       si aucun emrunt ne correspond a l'id entre, retourné dans un objet JSON avec status et code d erreur -20002
    * @exception    OTHERS              excepttion autre non traitée, retourné dans un objet JSON avec status et son code d erreur
    */    

    FUNCTION retourner(p_id_emprunt emprunt.idemprunt%Type) RETURN VARCHAR2 AS
    
             l_scope              logger_logs.scope%type := gc_scope_prefix || 'retourner';
             l_params             logger.tab_param;
             
            rec_emprunt emprunt%RowType;
            l_nom_utilisateur VARCHAR2(100);
            l_tite_livre VARCHAR2(100);
            l_nom_membre VARCHAR2(100);
            ex_id_null Exception;
            l_resultat VARCHAR2(4000);
            l_json_emprunt VARCHAR2(4000);
            l_error_code    VARCHAR2(4000);
            
        BEGIN
            
            logger.append_param(l_params, 'p_id_emprunt: ',p_id_emprunt);
            logger.log('>>>DÉBUT de la procédure', l_scope, NULL, l_params);
        
        
        
        
        
            IF p_id_emprunt IS NULL THEN
                RAISE ex_id_null;
            END IF;
            
            
            SELECT * INTO rec_emprunt FROM emprunt WHERE idemprunt=p_id_emprunt;
            
            
            SELECT nomutilisateur INTO l_nom_utilisateur FROM utilisateur WHERE idutilisateur = rec_emprunt.utilisateur_idutilisateur;
            SELECT prenom || ' ' || nom INTO l_nom_membre FROM membre WHERE idmembre = rec_emprunt.membre_idmembre;
            SELECT titre INTO l_tite_livre FROM livre WHERE idlivre = rec_emprunt.livre_idlivre;
            
           SELECT JSON_ARRAYAGG(
            JSON_OBJECT(
                'type'  VALUE 'emprunt',
                'id'    VALUE rec_emprunt.idemprunt,
                'attributes' VALUE JSON_OBJECT(
                    'titreLivre'        VALUE l_tite_livre,
                    'nomMembre'         VALUE l_nom_membre,
                    'nomUtilisateur'    VALUE l_nom_utilisateur,
                    'dateDebut'         VALUE rec_emprunt.datedebut,
                    'dateRetourPruvue'  VALUE rec_emprunt.dateretourprevue,
                    'dateRetour'        VALUE rec_emprunt.dateretour,
                    'enRetard'          VALUE rec_emprunt.enretard
                )
             )
            ) INTO l_json_emprunt;
            
            
            l_resultat := JSON_OBJECT(
            'data' VALUE l_json_emprunt FORMAT JSON,
            'meta' VALUE JSON_OBJECT(
                'status'     VALUE 'success',
                'statusCode' VALUE 200
            )
        );
        
        
        logger.append_param(l_params, 'l_resultat: ', l_resultat);
        logger.log('>>>FIN de la procédure', l_scope, NULL, l_params);
        
        RETURN l_resultat;
        
     EXCEPTION
        WHEN ex_id_null THEN
            ROLLBACK;
            logger.log_error('>>>ERREUR de de type ex_id_null', l_scope, null, l_params);
        
        
            l_resultat :=  JSON_OBJECT(
                'errors' VALUE JSON_ARRAY(
                    JSON_OBJECT(
                        'status'  VALUE '400',
                        'title'   VALUE 'id non valide',
                        'detail'  VALUE 'l id entre est null',
                        'code'    VALUE TO_CHAR(-20001),
                        'meta'    VALUE JSON_OBJECT(
                            'timestamp' VALUE TO_CHAR(SYSDATE, 'YYYY-MM-DD"T"HH24:MI:SS')
                        )
                    )
                )
            );
        
            RETURN  l_resultat;
     
        WHEN no_data_found THEN
             
             ROLLBACK;
            logger.log_error('>>>ERREUR de de type no_data_found', l_scope, null, l_params);
        
        
            l_resultat :=  JSON_OBJECT(
                'errors' VALUE JSON_ARRAY(
                    JSON_OBJECT(
                        'status'  VALUE '404',
                        'title'   VALUE 'Emprunt non trouve',
                        'detail'  VALUE 'Aucun cours correspondant a cet id',
                        'code'    VALUE TO_CHAR(-20002),
                        'meta'    VALUE JSON_OBJECT(
                            'timestamp' VALUE TO_CHAR(SYSDATE, 'YYYY-MM-DD"T"HH24:MI:SS')
                        )
                    )
                )
            );
        
            RETURN  l_resultat;
        
        WHEN others THEN
            ROLLBACK;
            l_error_code := sqlcode;
            logger.log_error('>>>ERREUR de de type OTHERS la procédure', l_scope, null, l_params);
            l_resultat := JSON_OBJECT(
                'errors' VALUE JSON_ARRAY(
                    JSON_OBJECT(
                        'status'  VALUE '500',
                        'title'   VALUE 'Erreur système',
                        'detail'  VALUE 'Erreur OTHERS lors de la récupération de l emprunt',
                        'code'    VALUE TO_CHAR(l_error_code),
                        'meta'    VALUE JSON_OBJECT(
                            'timestamp' VALUE TO_CHAR(SYSDATE, 'YYYY-MM-DD"T"HH24:MI:SS')
                        )
                    )
                )
            );
            RETURN l_resultat;
        
     END retourner;      
     
     


/**
    * Description   fonction pour supprimer un emprunt (Fait a partir du document fournit par JF Brodeur)
    *
    *@version       1.0
    *
    * @example      l_resultant := emprunt_tapi.supprimer(2);
    *
    * @issue        n/a
    *
    * @author       Khalil Arrahmen Bouraoui
    * @created      2026-11-08
    * @param        p_id_emprunt        id de l'emprunt a supprimer
    * @param        p_test              variable indiquant si c'est un test ou pas pour commiter les nouvelles changement
    * @return       l_reponse           objet JSON avec l'id de l'emprunt, status et statusCode  
    * @exception    ex_id_null          si l'id entre est null, retourné dans un objet JSON avec status et code d erreur -1
    * @exception    ex_id_inexistant    si aucun emrunt ne correspond a l'id entre, retourné dans un objet JSON avec status et code d erreur -2
    * @exception    OTHERS              excepttion autre non traitée, retourné dans un objet JSON avec status et son code d erreur
    */  

    FUNCTION supprimer(p_id_emprunt emprunt.idemprunt%Type, p_test VARCHAR2 DEFAULT 'N') RETURN VARCHAR2 AS
    
        l_scope              logger_logs.scope%type := gc_scope_prefix || 'supprimer';
        l_params             logger.tab_param;
        
        ex_id_null EXCEPTION;
        ex_id_inexistant EXCEPTION;
        l_reponse VARCHAR2(4000);
        l_nbre_range NUMBER;
        l_error_code VARCHAR2(4000);
        
    BEGIN
        
        logger.append_param(l_params, 'p_id_emprunt: ',p_id_emprunt);
        logger.log('>>>DÉBUT de la procédure', l_scope, NULL, l_params);
    
    
    
        IF p_id_emprunt IS NULL THEN
            RAISE ex_id_null;
        END IF;
        
        DELETE FROM emprunt WHERE idemprunt=p_id_emprunt;
        
        l_nbre_range := sql%rowcount;
        
        logger.append_param(l_params, 'SQL%ROWCOUNT: ', sql%rowcount);
        logger.log('>>>FIN de la procédure', l_scope, NULL, l_params);
        
        IF l_nbre_range = 0 THEN
            RAISE ex_id_inexistant;
        END IF;
        
        IF p_test='N' THEN
            COMMIT;
        END IF;
        
        l_reponse := JSON_OBJECT(
            'data' VALUE JSON_OBJECT(
                'type'  VALUE 'emprunt',
                'id'    VALUE p_id_emprunt
            ),
            'meta' VALUE JSON_OBJECT(
                'status'     VALUE 'success',
                'statusCode' VALUE 200
            )
        );
        
        RETURN l_reponse;
    EXCEPTION
    
        WHEN ex_id_null THEN
        
            ROLLBACK;
            logger.log_error('>>>ERREUR de de type ex_id_null', l_scope, null, l_params);
            l_reponse := JSON_OBJECT(
                'errors' VALUE JSON_ARRAY(
                    JSON_OBJECT(
                        'status'  VALUE '400',
                        'title'   VALUE 'ID de l emprunt requis',
                        'detail'  VALUE 'Erreur id est null lors de l effacement de l emprunt',
                        'code'    VALUE TO_CHAR(-1),
                        'meta'    VALUE JSON_OBJECT(
                            'timestamp' VALUE TO_CHAR(SYSDATE, 'YYYY-MM-DD"T"HH24:MI:SS')
                        )
                    )
                )
            );
            RETURN l_reponse;
        
        WHEN ex_id_inexistant THEN
            
            ROLLBACK;
            logger.log_error('>>>ERREUR de de type ex_id_inexistant', l_scope, null, l_params);
            l_reponse := JSON_OBJECT(
                'errors' VALUE JSON_ARRAY(
                    JSON_OBJECT(
                        'status'  VALUE '400',
                        'title'   VALUE 'Emprunt non trouve',
                        'detail'  VALUE 'Erreur id inexistant dans la table',
                        'code'    VALUE TO_CHAR(-2),
                        'meta'    VALUE JSON_OBJECT(
                            'timestamp' VALUE TO_CHAR(SYSDATE, 'YYYY-MM-DD"T"HH24:MI:SS')
                        )
                    )
                )
            );
            RETURN l_reponse;
    
    
        WHEN others THEN
            ROLLBACK;
            l_error_code := sqlcode;
            logger.log_error('>>>ERREUR de de type OTHERS la procédure', l_scope, null, l_params);
            
            
            l_reponse := JSON_OBJECT(
                'errors' VALUE JSON_ARRAY(
                    JSON_OBJECT(
                        'status'  VALUE '500',
                        'title'   VALUE 'Erreur système',
                        'detail'  VALUE 'Erreur OTHERS lors de l effacement du cours',
                        'code'    VALUE TO_CHAR(l_error_code),
                        'meta'    VALUE JSON_OBJECT(
                            'timestamp' VALUE TO_CHAR(SYSDATE, 'YYYY-MM-DD"T"HH24:MI:SS')
                        )
                    )
                )
            );
            RETURN l_reponse;
            
    END supprimer;
        



/**
    * Description   fonction pour ajouter un emprunt (Fait a partir du document fournit par JF Brodeur)
    *
    *@version       1.0
    *
    * @example      l_resultant := emprunt_tapi.ajouter(2,3,1,'2026-01-02','2026-01-09','N');
    *
    * @issue        n/a
    *
    * @author       Khalil Arrahmen Bouraoui
    * @created      2026-11-08
    * @param        p_id_membre         id du membre fesant l'emrunt
    * @param        p_id_livre          id du livre emprunte
    * @param        p_id_utilisateur    id de l'utilisateur (employer) enregistrant l'emprunt
    * @param        p_date_debut       date de debut de l'emprunt
    * @param        p_date_retour_prevue       date de retour prevu
    * @param        p_test              variable indiquant si c'est un test ou pas pour commiter les nouvelles changement
    * @return       l_reponse          objet JSON avec l'id de l'emprunt, le titre du livre, le nom du membre, le nom de l'utilisateur, la date de debut, la date de fin prevue et le number indiquant s'il est en retard  
    * @exception    no_data_found       si l'un des ids entres ne correspond a aucun elements des tables membre, livre ou utilisateur, retourné dans un objet JSON avec status et code d erreur -15
    * @exception    ex_entree_nulle   si l'une des entree (parametres) est nulle, retourné dans un objet JSON avec status et code d erreur -18
    * @exception    OTHERS              excepttion autre non traitée, retourné dans un objet JSON avec status et son code d erreur
    */  


    
    FUNCTION ajouter(p_id_membre membre.idmembre%TYPE, p_id_livre livre.idlivre%TYPE, p_id_utilisateur utilisateur.idutilisateur%TYPE, p_date_debut emprunt.datedebut%TYPE, 
                    p_date_retour_prevue emprunt.dateretourprevue%TYPE, p_test VARCHAR2 DEFAULT 'N') RETURN VARCHAR2 AS
                    
        l_scope              logger_logs.scope%type := gc_scope_prefix || 'ajouter';            
        l_params             logger.tab_param;
        
        l_id_emprunt emprunt.idemprunt%TYPE;
        ex_entree_nulle EXCEPTION;
        l_nom_membre VARCHAR2(100);
        l_nom_livre VARCHAR2(100);
        l_nom_utilisateur VARCHAR2(100);
        l_reponse VARCHAR2(4000);
        l_error_code varchar2(4000);
    BEGIN
        
        logger.append_param(l_params, 'p_id_membre: ',p_id_membre);
        logger.append_param(l_params, 'p_id_livre: ',p_id_livre);
        logger.append_param(l_params, 'p_id_utilisateur: ',p_id_utilisateur);
        logger.append_param(l_params, 'p_date_debut: ',p_date_debut);
        logger.append_param(l_params, 'p_date_retour_prevue: ', p_date_retour_prevue);
        logger.log('>>>DÉBUT de la procédure', l_scope, NULL, l_params);
        
        IF p_id_membre IS NULL OR p_id_livre IS NULL OR p_id_utilisateur IS NULL OR p_date_debut IS NULL OR p_date_retour_prevue IS NULL THEN
            RAISE ex_entree_nulle;
        END IF;
        
        SELECT nom INTO l_nom_membre FROM membre WHERE idmembre = p_id_membre;
        
        
        
        SELECT titre INTO l_nom_livre FROM livre WHERE idlivre = p_id_livre;
        
        
        SELECT nomutilisateur INTO l_nom_utilisateur FROM utilisateur WHERE idutilisateur = p_id_utilisateur;
       
        
        INSERT INTO emprunt (membre_idmembre, livre_idlivre, utilisateur_idutilisateur, datedebut, dateretourprevue, enretard)
        VALUES (p_id_membre, p_id_livre, p_id_utilisateur, p_date_debut, p_date_retour_prevue,0) RETURNING idemprunt INTO l_id_emprunt;
        
        logger.append_param(l_params, 'l_id_emprunt: ', l_id_emprunt);
        
        IF p_test='N' THEN
            COMMIT;
        END IF;
        
        
        l_reponse:= JSON_OBJECT(
                'type'  VALUE 'emprunt',
                'id'    VALUE l_id_emprunt,
                'attributes' VALUE JSON_OBJECT(
                    'titreLivre'        VALUE l_nom_livre,
                    'nomMembre'         VALUE l_nom_membre,
                    'nomUtilisateur'    VALUE l_nom_utilisateur,
                    'dateDebut'         VALUE p_date_debut,
                    'dateRetourPruvue'  VALUE p_date_retour_prevue,
                    'enRetard'          VALUE 0
                ),
                'meta' VALUE JSON_OBJECT(
                    'status'     VALUE 'success',
                    'statusCode' VALUE 201
                )
             );
        
        logger.log('>>>FIN de la procédure', l_scope, NULL, l_params);
        
        RETURN l_reponse;
    
    EXCEPTION 
        
        WHEN no_data_found THEN
            ROLLBACK;
            logger.log_error('>>>ERREUR de type no_data_found', l_scope, null, l_params);
            
            l_reponse := JSON_OBJECT(
                'errors' VALUE JSON_ARRAY(
                JSON_OBJECT(
                    'status'  VALUE '400',
                    'title'   VALUE 'Element non existant',
                    'detail'  VALUE 'Erreur un ou plusieurs des ids entrees ne correspondent a aucun element des tables livre, membre ou utilisateur',
                    'code'    VALUE TO_CHAR(-15),
                    'meta'    VALUE JSON_OBJECT('timestamp' VALUE TO_CHAR(SYSDATE, 'YYYY-MM-DD"T"HH24:MI:SS')
                    )
                )
                )
            );
            RETURN l_reponse;
        
        
        WHEN ex_entree_nulle THEN
            ROLLBACK;
            logger.log_error('>>>ERREUR de type ex_entree_nulle', l_scope, null, l_params);
            
            l_reponse := JSON_OBJECT(
                'errors' VALUE JSON_ARRAY(
                JSON_OBJECT(
                    'status'  VALUE '400',
                    'title'   VALUE 'Entree nulle',
                    'detail'  VALUE 'Erreur une ou plusieurs entrees obligatoires sont nulles',
                    'code'    VALUE TO_CHAR(-18),
                    'meta'    VALUE JSON_OBJECT('timestamp' VALUE TO_CHAR(SYSDATE, 'YYYY-MM-DD"T"HH24:MI:SS')
                    )
                )
                )
            );
            RETURN l_reponse;
        
        
        WHEN others THEN
            l_error_code := sqlcode;
            ROLLBACK;
            logger.log_error('>>>ERREUR de type OTHERS', l_scope, null, l_params);
            
            l_reponse := JSON_OBJECT(
                'errors' VALUE JSON_ARRAY(
                JSON_OBJECT(
                    'status'  VALUE '500',
                    'title'   VALUE 'Erreur système',
                    'detail'  VALUE 'Erreur OTHERS lors de l ajout d un cours',
                    'code'    VALUE TO_CHAR(l_error_code),
                    'meta'    VALUE JSON_OBJECT('timestamp' VALUE TO_CHAR(SYSDATE, 'YYYY-MM-DD"T"HH24:MI:SS')
                    )
                )
                )
            );
            RETURN l_reponse;
        
    END ajouter;
    
        
       
       
/**
    * Description   fonction pour modifier un emprunt existant (Fait a partir du document fournit par JF Brodeur)
    *
    *@version       1.0
    *
    * @example      l_resultant := emprunt_tapi.modifier(2,null,4,null,'2026-01-20',null,null,'N');
    *
    * @issue        n/a
    *
    * @author       Khalil Arrahmen Bouraoui
    * @created      2026-11-08
    *@param         p_id_emprunt        id de l'emprunt a modifier
    * @param        p_nouv_id_membre    id du nouveau membre relier a l'emprunt si la valeur est null le membre ne change pas
    * @param        p_nouv_id_livre     id du nouveau livre relier a l'emprunt si la valeur est null le livre ne change pas
    * @param        p_nouv_id_utilisateur    id du nouveau utilisateur (employer) relier a l'emprunt si la valeur est null l'utilisateur ne change pas
    * @param        p_nouv_dateretourprevue  nouvelle date de retour prevu si la valeur est null la date ne change pas
    * @param        p_nouv_dateretour    nouvelle date de retour (ou bien date de retour actuelle, car on la garde null lors de l'enregistrement de l'emprunt) si la valeur est null la date ne change pas
    * @param        p_nouv_enretard    marquer si le retour du livre est enretard en changant la valeur de 0 a 1 si la valeur est null la valeur ne change pas
    * @param        p_test              variable indiquant si c'est un test ou pas pour commiter les nouvelles changement
    * @return       l_resultat          objet JSON avec l'id de l'emprunt, le titre du livre, le nom du membre, le nom de l'utilisateur, la date de debut, la date de fin prevue et le number indiquant s'il est en retard  
    * @exception    ex_id_emprunt_null      si p_id_emprunt est null, retourné dans un objet JSON avec status et code d erreur -115
    * @exception    no_data_found   si l'un des ids entres (non null) n'est pas valide, retourné dans un objet JSON avec status et code d erreur -116
    * @exception    OTHERS              excepttion autre non traitée, retourné dans un objet JSON avec status et son code d erreur
    */  
       
    FUNCTION modifier(p_id_emprunt emprunt.idemprunt%Type,  p_nouv_id_membre IN membre.idmembre%TYPE DEFAULT NULL,p_nouv_id_livre IN livre.idlivre%TYPE DEFAULT NULL ,
                    p_nouv_id_utilisateur IN utilisateur.idutilisateur%TYPE DEFAULT NULL,p_nouv_dateretourprevue IN emprunt.dateretourprevue%TYPE DEFAULT NULL,
                    p_nouv_dateretour IN emprunt.dateretour%TYPE DEFAULT NULL, p_nouv_enretard IN emprunt.enretard%TYPE DEFAULT NULL, p_test VARCHAR2 DEFAULT 'N') RETURN VARCHAR2 AS
                    
            l_scope              logger_logs.scope%type := gc_scope_prefix || 'modifier';   
            l_params             logger.tab_param;
            
            l_nbre_range    NUMBER; 
            rec_ancien_emprunt emprunt%ROWTYPE;
            ex_id_emprunt_null EXCEPTION;
            l_resultat VARCHAR2(4000);
            
            l_verif_membre VARCHAR2(100);
            l_verif_livre VARCHAR2(100);
            l_verif_utilisateur VARCHAR2(100);
            
            
            l_error_code VARCHAR2(4000);
    BEGIN
    
            logger.append_param(l_params, 'p_id_emprunt: ',p_id_emprunt);
            logger.append_param(l_params, 'p_nouv_id_membre: ',p_nouv_id_membre);
            logger.append_param(l_params, 'p_nouv_id_livre: ',p_nouv_id_livre);
            logger.append_param(l_params, 'p_nouv_id_utilisateur: ',p_nouv_id_utilisateur);
            logger.append_param(l_params, 'p_nouv_dateretourprevue: ',p_nouv_dateretourprevue);
            logger.append_param(l_params, 'p_nouv_dateretour: ',p_nouv_dateretour);
            logger.append_param(l_params, 'p_nouv_enretard: ',p_nouv_enretard);
            logger.log('>>>DÉBUT de la procédure', l_scope, NULL, l_params);
            
            
            IF p_id_emprunt IS NULL THEN
                RAISE ex_id_emprunt_null;
            END IF;
            
            SELECT * INTO rec_ancien_emprunt FROM emprunt WHERE idemprunt = p_id_emprunt;
            
            
            
            
            IF p_nouv_id_membre IS NOT NULL THEN
              SELECT nom INTO l_verif_membre FROM membre WHERE idmembre = p_nouv_id_membre;
            END IF;
        
        
            IF p_nouv_id_livre IS NOT NULL THEN
             SELECT titre INTO l_verif_livre FROM livre WHERE idlivre = p_nouv_id_livre;
            END IF;
            
            
            IF  p_nouv_id_utilisateur IS NOT NULL THEN
             SELECT nomutilisateur INTO l_verif_utilisateur FROM utilisateur WHERE idutilisateur = p_nouv_id_utilisateur;
            END IF;
        
        
            
            
            UPDATE emprunt SET
            membre_idmembre = COALESCE( p_nouv_id_membre, rec_ancien_emprunt.membre_idmembre),
            livre_idlivre = COALESCE( p_nouv_id_livre, rec_ancien_emprunt.livre_idlivre),
            utilisateur_idutilisateur = COALESCE( p_nouv_id_utilisateur, rec_ancien_emprunt.utilisateur_idutilisateur),
            dateretourprevue = COALESCE( p_nouv_dateretourprevue, rec_ancien_emprunt.dateretourprevue),
            dateretour= COALESCE( p_nouv_dateretour, rec_ancien_emprunt.dateretour),
            enretard= COALESCE (p_nouv_enretard, rec_ancien_emprunt.enretard)
            WHERE idemprunt = p_id_emprunt;
            
            l_nbre_range := sql%rowcount;
            
            logger.append_param(l_params, 'sql%l_nbre_range: ', l_nbre_range);
            logger.log('>>>FIN de la procédure', l_scope, NULL, l_params);
            
            IF p_test = 'N' THEN
                COMMIT;
            END IF;
            
            
             l_resultat := JSON_OBJECT(
            'data' VALUE JSON_OBJECT(
                'type'  VALUE 'emprunt',
                'id'    VALUE p_id_emprunt,
                'attributes' VALUE JSON_OBJECT(
                    'titreLivre'        VALUE l_verif_livre,
                    'nomMembre'         VALUE l_verif_membre,
                    'nomUtilisateur'    VALUE l_verif_utilisateur,
                    'dateRetourPruvue'  VALUE p_nouv_dateretourprevue,
                    'dateRetour'        VALUE p_nouv_dateretour,
                    'enRetard'          VALUE p_nouv_enretard
                )
            ),
            'meta' VALUE JSON_OBJECT(
                'status'     VALUE 'success',
                'statusCode' VALUE 200
                )
             );
            
            RETURN l_resultat;
            
        EXCEPTION
            
            WHEN ex_id_emprunt_null THEN
                ROLLBACK;
                logger.log_error('>>>ERREUR de de type ex_id_emprunt_null la procédure', l_scope, null, l_params);
                l_resultat := JSON_OBJECT(
                    'errors' VALUE JSON_ARRAY(
                        JSON_OBJECT(
                            'status'  VALUE '400',
                            'title'   VALUE 'ID de l emprunt requis',
                            'detail'  VALUE 'Erreur id est null lors de la maj de l emprunt',
                            'code'    VALUE TO_CHAR(-115),
                            'meta'    VALUE JSON_OBJECT(
                                'timestamp' VALUE TO_CHAR(SYSDATE, 'YYYY-MM-DD"T"HH24:MI:SS')
                            )
                        )
                    )
                );
                RETURN l_resultat;
            
            WHEN no_data_found THEN
                ROLLBACK;
                logger.log_error('>>>ERREUR de de type no_data_found la procédure', l_scope, null, l_params);
                l_resultat := JSON_OBJECT(
                    'errors' VALUE JSON_ARRAY(
                        JSON_OBJECT(
                            'status'  VALUE '404',
                            'title'   VALUE 'Id non valide',
                            'detail'  VALUE 'l un des ids entres (non null) n est pas valide',
                            'code'    VALUE TO_CHAR(-116),
                            'meta'    VALUE JSON_OBJECT(
                                'timestamp' VALUE TO_CHAR(SYSDATE, 'YYYY-MM-DD"T"HH24:MI:SS')
                            )
                        )
                    )
                );
                RETURN l_resultat;
            
            
            WHEN others THEN
                ROLLBACK;
                l_error_code := sqlcode;
                logger.log_error('>>>ERREUR de de type OTHERS la procédure', l_scope, null, l_params);
                l_resultat := JSON_OBJECT(
                    'errors' VALUE JSON_ARRAY(
                        JSON_OBJECT(
                            'status'  VALUE '500',
                            'title'   VALUE 'Erreur système',
                            'detail'  VALUE 'Erreur OTHERS lors de la mise à jour du cours',
                            'code'    VALUE TO_CHAR(l_error_code),
                            'meta'    VALUE JSON_OBJECT(
                                'timestamp' VALUE TO_CHAR(SYSDATE, 'YYYY-MM-DD"T"HH24:MI:SS')
                            )
                        )
                    )
                );
                RETURN l_resultat;
        
        END modifier;
        
END emprunt_tapi;