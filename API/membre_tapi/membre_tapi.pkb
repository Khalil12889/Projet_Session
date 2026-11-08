
CREATE OR REPLACE PACKAGE BODY membre_tapi IS

    
    gc_scope_prefix CONSTANT VARCHAR2(31) := LOWER($$PLSQL_UNIT) || '.';

    /**
     * Description  Fonction pour inserer un membre
     *
     * @version     1.0.0
     *
     * @example     l_reponse := membre_tapi.ins_membre(NULL, 'Tremblay', 'Marie', '5145551234', 'marie@test.ca', SYSDATE, 1, 1, 'O');
     *
     * @issue       n/a
     *
     * @author      Zakaria Harcha
     * @created     2026-11-05
     * @param       p_id_membre         Identifiant NULL pour generation automatique
     * @param       p_nom               Nom du membre
     * @param       p_prenom            Prenom du membre
     * @param       p_numero_telephone  Telephone du membre
     * @param       p_adresse_courriel  Courriel du membre
     * @param       p_date_abonnement   Date de son abonnement
     * @param       p_status_idstatus   Identifiant de son statut
     * @param       p_adresse_idadresse Identifiant de son adresse
     * @param       p_test              Si N, effectuer COMMIT
     * @return      l_reponse           Reponse JSON avec statut 201 et identifiant cree
     * @exception   ex_valeur_null      Valeur obligatoire manquante (ORA-01400)
     * @exception   OTHERS              Erreur journalisee puis propagee
     */


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
    ) RETURN VARCHAR2 IS
        l_scope     logger_logs.scope%TYPE := gc_scope_prefix || 'ins_membre';
        l_params    logger.tab_param;
        l_id_membre membre.idmembre%TYPE;
        l_reponse   VARCHAR2(4000);
        ex_valeur_null EXCEPTION;
        PRAGMA EXCEPTION_INIT(ex_valeur_null, -1400);
    BEGIN
        logger.append_param(l_params, 'p_id_membre: ', p_id_membre);
        logger.append_param(l_params, 'p_nom: ', p_nom);
        logger.append_param(l_params, 'p_prenom: ', p_prenom);
        logger.append_param(l_params, 'p_numero_telephone: ', p_numero_telephone);
        logger.append_param(l_params, 'p_adresse_courriel: ', p_adresse_courriel);
        logger.append_param(l_params, 'p_date_abonnement: ', p_date_abonnement);
        logger.append_param(l_params, 'p_status_idstatus: ', p_status_idstatus);
        logger.append_param(l_params, 'p_adresse_idadresse: ', p_adresse_idadresse);
        logger.append_param(l_params, 'p_test: ', p_test);
        logger.log('>>>DEBUT de la fonction', l_scope, NULL, l_params);

        
        INSERT INTO membre (
            idmembre, nom, prenom, numerotelephone, adressecourriel,
            dateabonnement, status_idstatus, adresse_idadresse
        ) VALUES (
            p_id_membre, p_nom, p_prenom, p_numero_telephone, p_adresse_courriel,
            p_date_abonnement, p_status_idstatus, p_adresse_idadresse
        ) RETURNING idmembre INTO l_id_membre;

        l_reponse := JSON_OBJECT(
            'data' VALUE JSON_OBJECT(
                'type' VALUE 'membre',
                'id' VALUE l_id_membre,
                'attributes' VALUE JSON_OBJECT(
                    'nom' VALUE p_nom,
                    'prenom' VALUE p_prenom,
                    'numeroTelephone' VALUE p_numero_telephone,
                    'adresseCourriel' VALUE p_adresse_courriel,
                    'dateAbonnement' VALUE TO_CHAR(p_date_abonnement, 'YYYY-MM-DD'),
                    'status_idStatus' VALUE p_status_idstatus,
                    'adresse_idAdresse' VALUE p_adresse_idadresse
                )
            ),
            'meta' VALUE JSON_OBJECT('status' VALUE 'success', 'statusCode' VALUE 201)
            RETURNING VARCHAR2(4000)
        );

        logger.append_param(l_params, 'l_id_membre: ', l_id_membre);
        logger.log('>>>FIN de la fonction', l_scope, NULL, l_params);
        IF p_test = 'N' THEN
            COMMIT;
        END IF;
        RETURN l_reponse;
    EXCEPTION
        WHEN ex_valeur_null THEN
            ROLLBACK;
            logger.log_error('>>>ERREUR valeur obligatoire manquante', l_scope, NULL, l_params);
            RETURN JSON_OBJECT(
                'errors' VALUE JSON_ARRAY(JSON_OBJECT(
                    'status' VALUE '400',
                    'title' VALUE 'Champ obligatoire manquant',
                    'detail' VALUE 'Une valeur NULL est interdite',
                    'code' VALUE '-1400'
                )) RETURNING VARCHAR2(4000)
            );
        WHEN OTHERS THEN
            ROLLBACK;
            logger.log_error('>>>ERREUR ins_membre', l_scope, NULL, l_params);
            RAISE;
    END ins_membre;

    /**
     * Description  Fonction pour modifier les informations d'un membre
     *              
     * @version     1.0.0
     *
     * @example     l_reponse := membre_tapi.upd_membre(p_id_membre => 10, p_nom => 'Gagnon', p_test => 'O');
     *
     * @issue       n/a
     *
     * @author      Zakaria Harcha
     * @created     2026-11-05
     * @param       p_id_membre         Identifiant du membre
     * @param       p_nom               Nouveau nom
     * @param       p_prenom            Nouveau prenom
     * @param       p_numero_telephone  Nouveau telephone
     * @param       p_adresse_courriel  Nouveau courriel
     * @param       p_date_abonnement   Nouvelle date d abonnement
     * @param       p_status_idstatus   Nouveau statut
     * @param       p_adresse_idadresse Nouvelle adresse
     * @param       p_test              Si N, effectuer COMMIT
     * @return      l_reponse           Reponse JSON avec statut 200 et membre modifie
     * @exception   ex_id_null          Identifiant non fourni
     * @exception   NO_DATA_FOUND       Identifiant inexistant
     * @exception   OTHERS              Erreur journalisee puis propagee
     */

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
    ) RETURN VARCHAR2 IS
        l_scope     logger_logs.scope%TYPE := gc_scope_prefix || 'upd_membre';
        l_params    logger.tab_param;
        rec_membre  membre%ROWTYPE;
        l_id_membre membre.idmembre%TYPE;
        l_reponse   VARCHAR2(4000);
        ex_id_null  EXCEPTION;
    BEGIN
        logger.append_param(l_params, 'p_id_membre: ', p_id_membre);
        logger.append_param(l_params, 'p_nom: ', p_nom);
        logger.append_param(l_params, 'p_prenom: ', p_prenom);
        logger.append_param(l_params, 'p_numero_telephone: ', p_numero_telephone);
        logger.append_param(l_params, 'p_adresse_courriel: ', p_adresse_courriel);
        logger.append_param(l_params, 'p_date_abonnement: ', p_date_abonnement);
        logger.append_param(l_params, 'p_status_idstatus: ', p_status_idstatus);
        logger.append_param(l_params, 'p_adresse_idadresse: ', p_adresse_idadresse);
        logger.append_param(l_params, 'p_test: ', p_test);
        logger.log('>>>DEBUT de la fonction', l_scope, NULL, l_params);

        IF p_id_membre IS NULL THEN
            RAISE ex_id_null;
        END IF;

        SELECT * INTO rec_membre
        FROM membre
        WHERE idmembre = p_id_membre;

        UPDATE membre SET
            nom = COALESCE(p_nom, rec_membre.nom),
            prenom = COALESCE(p_prenom, rec_membre.prenom),
            numerotelephone = COALESCE(p_numero_telephone, rec_membre.numerotelephone),
            adressecourriel = COALESCE(p_adresse_courriel, rec_membre.adressecourriel),
            dateabonnement = COALESCE(p_date_abonnement, rec_membre.dateabonnement),
            status_idstatus = COALESCE(p_status_idstatus, rec_membre.status_idstatus),
            adresse_idadresse = COALESCE(p_adresse_idadresse, rec_membre.adresse_idadresse)
        WHERE idmembre = p_id_membre
        RETURNING idmembre INTO l_id_membre;

        l_reponse := JSON_OBJECT(
            'data' VALUE JSON_OBJECT(
                'type' VALUE 'membre',
                'id' VALUE l_id_membre,
                'attributes' VALUE JSON_OBJECT(
                    'nom' VALUE COALESCE(p_nom, rec_membre.nom),
                    'prenom' VALUE COALESCE(p_prenom, rec_membre.prenom),
                    'numeroTelephone' VALUE COALESCE(p_numero_telephone, rec_membre.numerotelephone),
                    'adresseCourriel' VALUE COALESCE(p_adresse_courriel, rec_membre.adressecourriel),
                    'dateAbonnement' VALUE TO_CHAR(COALESCE(p_date_abonnement, rec_membre.dateabonnement), 'YYYY-MM-DD'),
                    'status_idStatus' VALUE COALESCE(p_status_idstatus, rec_membre.status_idstatus),
                    'adresse_idAdresse' VALUE COALESCE(p_adresse_idadresse, rec_membre.adresse_idadresse)
                )
            ),
            'meta' VALUE JSON_OBJECT('status' VALUE 'success', 'statusCode' VALUE 200)
            RETURNING VARCHAR2(4000)
        );

        logger.append_param(l_params, 'l_id_membre: ', l_id_membre);
        logger.log('>>>FIN de la fonction', l_scope, NULL, l_params);
        IF p_test = 'N' THEN
            COMMIT;
        END IF;
        RETURN l_reponse;
    EXCEPTION
        WHEN ex_id_null THEN
            ROLLBACK;
            logger.log_error('>>>ERREUR ID null', l_scope, NULL, l_params);
            RETURN JSON_OBJECT('errors' VALUE JSON_ARRAY(JSON_OBJECT(
                'status' VALUE '400', 'title' VALUE 'ID du membre requis',
                'detail' VALUE 'Identifiant non fourni', 'code' VALUE '-1'
            )) RETURNING VARCHAR2(4000));
        WHEN NO_DATA_FOUND THEN
            ROLLBACK;
            logger.log_error('>>>ERREUR membre inexistant', l_scope, NULL, l_params);
            RETURN JSON_OBJECT('errors' VALUE JSON_ARRAY(JSON_OBJECT(
                'status' VALUE '404', 'title' VALUE 'Membre non trouve',
                'detail' VALUE 'ID inexistant : ' || p_id_membre, 'code' VALUE '-2'
            )) RETURNING VARCHAR2(4000));
        WHEN OTHERS THEN
            ROLLBACK;
            logger.log_error('>>>ERREUR upd_membre', l_scope, NULL, l_params);
            RAISE;
    END upd_membre;

    /**
     * Description  Fonction pour supprimer un membre
     *
     * @version     1.0.0
     *
     * @example     l_reponse := membre_tapi.del_membre(10, 'O');
     *
     * @issue       n/a
     *
     * @author      Zakaria Harcha
     * @created     2026-11-05
     * @param       p_id_membre Identifiant du membre a supprimer
     * @param       p_test      Si N effectuer COMMIT
     * @return      l_reponse   Reponse JSON avec statut 200 et membre supprime
     * @exception   ex_id_null       Identifiant non fourni
     * @exception   ex_id_inexistant Identifiant inexistant
     * @exception   OTHERS           Erreur journalisee puis propagee
     */

    FUNCTION del_membre (
        p_id_membre IN membre.idmembre%TYPE,
        p_test      IN VARCHAR2 DEFAULT 'N'
    ) RETURN VARCHAR2 IS
        l_scope        logger_logs.scope%TYPE := gc_scope_prefix || 'del_membre';
        l_params       logger.tab_param;
        l_nbre_rangee  NUMBER;
        l_reponse      VARCHAR2(4000);
        ex_id_null       EXCEPTION;
        ex_id_inexistant EXCEPTION;
    BEGIN
        logger.append_param(l_params, 'p_id_membre: ', p_id_membre);
        logger.append_param(l_params, 'p_test: ', p_test);
        logger.log('>>>DEBUT de la fonction', l_scope, NULL, l_params);

        IF p_id_membre IS NULL THEN
            RAISE ex_id_null;
        END IF;

        DELETE FROM membre WHERE idmembre = p_id_membre;
        l_nbre_rangee := SQL%ROWCOUNT;
        IF l_nbre_rangee = 0 THEN
            RAISE ex_id_inexistant;
        END IF;

        l_reponse := JSON_OBJECT(
            'data' VALUE JSON_OBJECT('type' VALUE 'membre', 'id' VALUE p_id_membre),
            'meta' VALUE JSON_OBJECT('status' VALUE 'success', 'statusCode' VALUE 200)
            RETURNING VARCHAR2(4000)
        );
        logger.append_param(l_params, 'l_nbre_rangee: ', l_nbre_rangee);
        logger.log('>>>FIN de la fonction', l_scope, NULL, l_params);
        IF p_test = 'N' THEN
            COMMIT;
        END IF;
        RETURN l_reponse;
    EXCEPTION
        WHEN ex_id_null THEN
            ROLLBACK;
            logger.log_error('>>>ERREUR ID null', l_scope, NULL, l_params);
            RETURN JSON_OBJECT('errors' VALUE JSON_ARRAY(JSON_OBJECT(
                'status' VALUE '400', 'title' VALUE 'ID du membre requis',
                'detail' VALUE 'Identifiant non fourni', 'code' VALUE '-1'
            )) RETURNING VARCHAR2(4000));
        WHEN ex_id_inexistant THEN
            ROLLBACK;
            logger.log_error('>>>ERREUR membre inexistant', l_scope, NULL, l_params);
            RETURN JSON_OBJECT('errors' VALUE JSON_ARRAY(JSON_OBJECT(
                'status' VALUE '404', 'title' VALUE 'Membre non trouve',
                'detail' VALUE 'ID inexistant : ' || p_id_membre, 'code' VALUE '-2'
            )) RETURNING VARCHAR2(4000));
        WHEN OTHERS THEN
            ROLLBACK;
            logger.log_error('>>>ERREUR del_membre', l_scope, NULL, l_params);
            RAISE;
    END del_membre;

    /**
     * Description  Fonction pour retourner un membre
     *
     * @version     1.0.0
     *
     * @example     l_reponse := membre_tapi.get_membre(NULL, 5, 0, 4);
     *
     * @issue       n/a
     *
     * @author      Zakaria Harcha
     * @created     2026-11-05
     * @param       p_id_membre Identifiant a rechercher NULL pour tous
     * @param       p_limite    Nombre maximum de membres
     * @param       p_debut     Nombre de rangees a ignorer
     * @param       p_taille    Nombre de membres demandes
     * @return      l_reponse   Reponse JSON avec les membres et la pagination
     * @exception   ex_aucun_membre Membre non trouve
     * @exception   ex_pagination   Parametres de pagination invalides
     * @exception   OTHERS          Erreur journalisee puis propagee
     */

    FUNCTION get_membre (
        p_id_membre IN membre.idmembre%TYPE,
        p_limite    IN NUMBER DEFAULT 5,
        p_debut     IN NUMBER DEFAULT 0,
        p_taille    IN NUMBER DEFAULT 4
    ) RETURN VARCHAR2 IS
        l_scope         logger_logs.scope%TYPE := gc_scope_prefix || 'get_membre';
        l_params        logger.tab_param;
        l_reponse       VARCHAR2(4000);
        l_json_membres  VARCHAR2(4000);
        l_taille        NUMBER;
        ex_aucun_membre EXCEPTION;
        ex_pagination   EXCEPTION;
    BEGIN
        logger.append_param(l_params, 'p_id_membre: ', p_id_membre);
        logger.append_param(l_params, 'p_limite: ', p_limite);
        logger.append_param(l_params, 'p_debut: ', p_debut);
        logger.append_param(l_params, 'p_taille: ', p_taille);
        logger.log('>>>DEBUT de la fonction', l_scope, NULL, l_params);

        IF p_debut IS NULL OR p_debut < 0 OR p_taille IS NULL OR p_taille <= 0
           OR p_limite IS NULL OR p_limite < 0 THEN
            RAISE ex_pagination;
        END IF;

        l_taille := CASE WHEN p_limite > 0
                        THEN LEAST(p_limite, p_taille)
                        ELSE p_taille END;

        SELECT JSON_ARRAYAGG(
            JSON_OBJECT(
                'type' VALUE 'membre',
                'id' VALUE m.idmembre,
                'attributes' VALUE JSON_OBJECT(
                    'nom' VALUE m.nom,
                    'prenom' VALUE m.prenom,
                    'numeroTelephone' VALUE m.numerotelephone,
                    'adresseCourriel' VALUE m.adressecourriel,
                    'dateAbonnement' VALUE TO_CHAR(m.dateabonnement, 'YYYY-MM-DD'),
                    'status_idStatus' VALUE m.status_idstatus,
                    'adresse_idAdresse' VALUE m.adresse_idadresse
                )
            ) RETURNING VARCHAR2(4000)
        ) INTO l_json_membres
        FROM (
            SELECT idmembre, nom, prenom, numerotelephone, adressecourriel,
                   dateabonnement, status_idstatus, adresse_idadresse
            FROM membre
            WHERE p_id_membre IS NULL OR idmembre = p_id_membre
            ORDER BY idmembre
            OFFSET p_debut ROWS FETCH NEXT l_taille ROWS ONLY
        ) m;

        IF l_json_membres IS NULL THEN
            RAISE ex_aucun_membre;
        END IF;

        l_reponse := JSON_OBJECT(
            'data' VALUE l_json_membres FORMAT JSON,
            'meta' VALUE JSON_OBJECT(
                'status' VALUE 'success',
                'statusCode' VALUE 200,
                'pagination' VALUE JSON_OBJECT('offset' VALUE p_debut, 'limit' VALUE l_taille)
            ) RETURNING VARCHAR2(4000)
        );

        logger.append_param(l_params, 'l_reponse: ', l_reponse);
        logger.log('>>>FIN de la fonction', l_scope, NULL, l_params);
        RETURN l_reponse;
    EXCEPTION
        WHEN ex_pagination THEN
            logger.log_error('>>>ERREUR pagination invalide', l_scope, NULL, l_params);
            RETURN JSON_OBJECT('errors' VALUE JSON_ARRAY(JSON_OBJECT(
                'status' VALUE '400', 'title' VALUE 'Pagination invalide',
                'detail' VALUE 'Verifier limite, debut et taille', 'code' VALUE '-3'
            )) RETURNING VARCHAR2(4000));
        WHEN ex_aucun_membre THEN
            logger.log_error('>>>ERREUR aucun membre trouve', l_scope, NULL, l_params);
            RETURN JSON_OBJECT('errors' VALUE JSON_ARRAY(JSON_OBJECT(
                'status' VALUE '404', 'title' VALUE 'Membre non trouve',
                'detail' VALUE 'Aucun membre pour cette recherche', 'code' VALUE '-20001'
            )) RETURNING VARCHAR2(4000));
        WHEN OTHERS THEN
            logger.log_error('>>>ERREUR get_membre', l_scope, NULL, l_params);
            RAISE;
    END get_membre;

END membre_tapi;
/
SHOW ERRORS PACKAGE BODY membre_tapi;