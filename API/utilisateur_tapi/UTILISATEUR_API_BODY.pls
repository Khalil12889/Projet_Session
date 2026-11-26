create or replace PACKAGE BODY utilisateur_api AS

gc_scope_prefix CONSTANT VARCHAR2(31) := LOWER($$PLSQL_UNIT) || '.';


--DEBUT DE LA FONCTION INSERT

FUNCTION ajouter_utilisateur(
        p_nomutilisateur utilisateur.nomutilisateur%TYPE,
        p_motdepasse utilisateur.motdepasse%TYPE,
        p_test VARCHAR2 DEFAULT 'N'
    ) RETURN VARCHAR2 AS
    l_scope logger_logs.scope%TYPE := gc_scope_prefix || 'ajouter_utilisateur';
    l_params logger.tab_param;
    l_idutilisateur utilisateur.idutilisateur%TYPE;
    l_reponse VARCHAR2(4000);
    l_error_mess      VARCHAR2(4000);
    l_error_code      NUMBER;

    --nommer les exceptions
    ex_valeurutilisateur_null EXCEPTION;
    PRAGMA EXCEPTION_INIT(ex_valeurutilisateur_null, -1400);

    BEGIN

   logger.append_param(l_params, 'p_nomutilisateur', p_nomutilisateur);
   logger.log('Ajout d un utilisateur', l_scope);

    INSERT INTO utilisateur (nomutilisateur, motdepasse)
    VALUES (p_nomutilisateur, p_motdepasse)
    RETURNING idutilisateur INTO l_idutilisateur;
    logger.log_info('Insertion utilisateur réussie', l_scope);


    IF p_test = 'N' THEN
    COMMIT;
    END IF;

    --reponse du json
    l_reponse := JSON_OBJECT('data' VALUE JSON_OBJECT(
        'type' VALUE 'utilisateur',
        'id' VALUE l_idutilisateur,
        'attributes' VALUE JSON_OBJECT('nomUtilisateur' VALUE p_nomutilisateur) ),
        'meta' VALUE JSON_OBJECT('status' VALUE 'success', 'statusCode' VALUE 201) );

    return l_reponse;

    --exception

  EXCEPTION
    WHEN ex_valeurutilisateur_null THEN
        l_error_mess := SQLERRM;
        l_error_code := SQLCODE;
        ROLLBACK;
        logger.log_error('>>>ERREUR de type ex_valeurutilisateur_null', l_scope, null, l_params);

        l_reponse := JSON_OBJECT( 'errors' VALUE JSON_ARRAY(
            JSON_OBJECT(
            'status' VALUE '400',
            'title' VALUE 'Champ obligatoire manquant',
            'detail' VALUE 'Erreur lors de l insertion d un utilisateur : valeur NULL interdite ORA-01400',
            'code' VALUE TO_CHAR(l_error_code),
            'meta' VALUE JSON_OBJECT(
            'timestamp' VALUE TO_CHAR(SYSDATE, 'YYYY-MM-DD"T"HH24:MI:SS')
                                    )
                       )
                                                           )
             );
             return l_reponse;



     WHEN OTHERS THEN
     ROLLBACK;
     l_error_mess := sqlerrm;
     l_error_code := sqlcode;
    logger.log_error('>>>ERREUR de de type OTHERS', l_scope, null, l_params);


     l_reponse := JSON_OBJECT('errors' VALUE JSON_ARRAY( JSON_OBJECT(
                    'status'  VALUE '500',
                    'title'   VALUE 'erreur',
                    'detail'  VALUE 'Erreur systeme lors de linsertion dun utilisateur',
                    'code'    VALUE TO_CHAR(l_error_code),
                    'meta'    VALUE JSON_OBJECT(
                    'timestamp' VALUE TO_CHAR(SYSDATE, 'YYYY-MM-DD"T"HH24:MI:SS')
                    )
                )
                )
            );

    RETURN l_reponse;


    END ajouter_utilisateur;

--DEBUT DE LA FONCTION SELECT

FUNCTION retourner_utilisateur( 
        p_idutilisateur IN utilisateur.idutilisateur%TYPE,
        p_limite IN NUMBER DEFAULT 5,
        p_debut IN NUMBER DEFAULT 0,
        p_taille IN NUMBER DEFAULT 4 )
        RETURN VARCHAR2 IS

l_scope logger_logs.scope%TYPE := gc_scope_prefix || 'retourner_utilisateur';
l_params logger.tab_param;
l_reponse VARCHAR2(4000);
l_json_utilisateur VARCHAR2(4000);
l_error_mess VARCHAR2(4000);
l_error_code NUMBER;

ex_aucun_utilisateur EXCEPTION;



BEGIN

logger.append_param(l_params, 'p_idutilisateur: ', p_idutilisateur);
    logger.log('>>>DÉBUT de la procédure', l_scope, NULL, l_params);


SELECT JSON_ARRAYAGG(JSON_OBJECT(
        'type' VALUE 'utilisateur',
        'id' VALUE idutilisateur,
        'attributes' VALUE JSON_OBJECT(
        'nomUtilisateur' VALUE nomutilisateur) ) )
INTO l_json_utilisateur
FROM (
    SELECT idutilisateur, nomutilisateur
    FROM utilisateur
    WHERE idutilisateur = COALESCE(p_idutilisateur, idutilisateur)
    ORDER BY idutilisateur
    OFFSET p_debut ROWS
    FETCH NEXT CASE WHEN p_limite > 0 
    THEN LEAST(p_limite, p_taille)
    ELSE p_taille
    END
    ROWS ONLY );

IF l_json_utilisateur IS NULL THEN
    RAISE ex_aucun_utilisateur;
END IF;


l_reponse := JSON_OBJECT(
            'data' VALUE l_json_utilisateur FORMAT JSON,
            'meta' VALUE JSON_OBJECT(
                'status'     VALUE 'success',
                'statusCode' VALUE 200,
                'pagination' VALUE JSON_OBJECT(
                    'offset' VALUE p_debut,
                    'limit'  VALUE CASE WHEN p_limite > 0 THEN LEAST(p_limite, p_taille) ELSE p_taille END
                )
            )
        );

logger.append_param(l_params, 'l_reponse: ', l_reponse);
logger.log('>>>FIN de la procédure', l_scope, NULL, l_params);
RETURN l_reponse;

EXCEPTION
    WHEN ex_aucun_utilisateur THEN
        ROLLBACK;
        logger.log_error( '>>>ERREUR de type ex_aucun_utilisateur', l_scope,NULL,l_params);

l_reponse := JSON_OBJECT(
                'errors' VALUE JSON_ARRAY(
                    JSON_OBJECT(
                        'status'  VALUE '404',
                        'title'   VALUE 'Utilisateur non trouvé',
                        'detail'  VALUE 'Aucun utilisateur trouvé pour cette recherche',
                        'code'    VALUE TO_CHAR(-20001),
                        'meta'    VALUE JSON_OBJECT(
                            'timestamp' VALUE TO_CHAR(SYSDATE, 'YYYY-MM-DD"T"HH24:MI:SS') )  ) )
                   );

RETURN l_reponse;
 WHEN OTHERS THEN
            ROLLBACK;
            l_error_mess := sqlerrm;
            l_error_code := sqlcode;
            logger.log_error('>>>ERREUR de type OTHERS ', l_scope, null, l_params);
            l_reponse := JSON_OBJECT(
                'errors' VALUE JSON_ARRAY(
                    JSON_OBJECT(
                        'status'  VALUE '500',
                        'title'   VALUE 'Erreur système',
                        'detail'  VALUE 'Erreur OTHERS lors de la récupération de utilisateur',
                        'code'    VALUE TO_CHAR(l_error_code),
                        'meta'    VALUE JSON_OBJECT(
                            'timestamp' VALUE TO_CHAR(SYSDATE, 'YYYY-MM-DD"T"HH24:MI:SS')
                        )
                    )
                )
            );
RETURN l_reponse;



END retourner_utilisateur;

--DEBUT DE LA FONCTION DELETE
FUNCTION supprimer_utilisateur(
    p_idutilisateur IN utilisateur.idutilisateur%TYPE,
    p_test VARCHAR2 DEFAULT 'N')
    RETURN VARCHAR2 IS

l_scope          logger_logs.scope%TYPE := gc_scope_prefix || 'supprimer_utilisateur';
l_params         logger.tab_param;
l_nbre_rangee    NUMBER;
l_reponse        VARCHAR2(4000);
l_error_mess     VARCHAR2(4000);
l_error_code     NUMBER;
ex_id_is_null    EXCEPTION;
ex_id_inexistant EXCEPTION;

BEGIN
    logger.append_param(l_params, 'p_idutilisateur: ', p_idutilisateur);
    logger.log('>>>DÉBUT de la procédure', l_scope, NULL, l_params);

    IF p_idutilisateur IS NULL THEN
    RAISE ex_id_is_null;
    END IF;
    DELETE FROM utilisateur
    WHERE idutilisateur = p_idutilisateur;

    l_nbre_rangee := SQL%ROWCOUNT;
    logger.append_param(l_params, 'SQL%ROWCOUNT: ', SQL%ROWCOUNT);
    logger.log('>>>FIN de la procédure', l_scope, NULL, l_params);

    IF l_nbre_rangee = 0 THEN
    RAISE ex_id_inexistant;
    END IF;

    IF p_test = 'N' THEN
    COMMIT;
    END IF;

    l_reponse := JSON_OBJECT(
            'data' VALUE JSON_OBJECT(
            'type'  VALUE 'utilisateur',
            'id'    VALUE p_idutilisateur),
            'meta' VALUE JSON_OBJECT(
            'status' VALUE 'success',
            'statusCode' VALUE 200) );
    RETURN l_reponse;

    EXCEPTION
            WHEN ex_id_is_null THEN
            l_error_mess := sqlerrm;
            l_error_code := sqlcode;
            ROLLBACK;
            logger.log_error('>>>ERREUR de type ex_id_is_null', l_scope, null, l_params);
            l_reponse := JSON_OBJECT( 'errors' VALUE JSON_ARRAY( JSON_OBJECT(
                'status'  VALUE '400',
                'title'   VALUE 'ID utilisateur requis',
                'detail'  VALUE 'Erreur id null lors de l effacement de l utilisateur',
                'code'    VALUE TO_CHAR(-1),
                'meta'    VALUE JSON_OBJECT(
                'timestamp' VALUE TO_CHAR(SYSDATE, 'YYYY-MM-DD"T"HH24:MI:SS') ) ) ) );
            RETURN l_reponse;

            WHEN ex_id_inexistant THEN
            l_error_mess := sqlerrm;
            l_error_code := sqlcode;
            ROLLBACK;
            logger.log_error('>>>ERREUR de type ex_id_inexistant', l_scope, null, l_params);
            --creation d un objet JSON avec un status error et un code d erreur
            l_reponse := JSON_OBJECT('errors' VALUE JSON_ARRAY( JSON_OBJECT(
                'status'  VALUE '404',
                'title'   VALUE 'Utilisateur non trouvé',
                'detail'  VALUE 'Erreur id inexistant '|| p_idutilisateur ||' lors de l effacement de l utilisateur',
                'code'    VALUE TO_CHAR(-2),
                'meta'    VALUE JSON_OBJECT(
                'timestamp' VALUE TO_CHAR(SYSDATE, 'YYYY-MM-DD"T"HH24:MI:SS'))) ));
            RETURN l_reponse;

            WHEN OTHERS THEN
            ROLLBACK;
            l_error_mess := sqlerrm;
            l_error_code := sqlcode;
            logger.log_error('>>>ERREUR de type OTHERS la procédure', l_scope, null, l_params);
            --creation d un objet JSON avec un status error et un code d erreur
            l_reponse := JSON_OBJECT('errors' VALUE JSON_ARRAY( JSON_OBJECT(
                'status'  VALUE '500',
                'title'   VALUE 'Erreur système',
                'detail'  VALUE 'Erreur OTHERS lors de l effacement de l utilisateur',
                'code'    VALUE TO_CHAR(l_error_code),
                'meta'    VALUE JSON_OBJECT(
                'timestamp' VALUE TO_CHAR(SYSDATE, 'YYYY-MM-DD"T"HH24:MI:SS') ) ) ) );
            RETURN l_reponse;

END supprimer_utilisateur;


--DEBUT DE LA FONCTION UPDATE

FUNCTION modifier_utilisateur(
    p_idutilisateur utilisateur.idutilisateur%TYPE,
    p_nomutilisateur utilisateur.nomutilisateur%TYPE DEFAULT NULL,
    p_motdepasse utilisateur.motdepasse%TYPE DEFAULT NULL,
    p_test VARCHAR2 DEFAULT 'N') 
    RETURN VARCHAR2 IS

l_scope       logger_logs.scope%type := gc_scope_prefix || 'modifier_utilisateur';
        l_params             logger.tab_param;
        l_idutilisateur      utilisateur.idutilisateur%type;
        r_utilisateur        utilisateur%rowtype;
        l_nbre_rangee        NUMBER;
        l_reponse            VARCHAR2(4000);
        l_error_mess         VARCHAR2(4000);
        l_error_code         NUMBER;
        ex_id_is_null        EXCEPTION;

BEGIN

    logger.append_param(l_params, 'p_idutilisateur: ', p_idutilisateur);
    logger.append_param(l_params, 'p_nomutilisateur: ', p_nomutilisateur);
    logger.log('>>>DÉBUT de la procédure', l_scope, NULL, l_params);

    IF p_idutilisateur IS NULL THEN
        RAISE ex_id_is_null;
    END IF;

    SELECT * INTO r_utilisateur
    FROM utilisateur
    WHERE idutilisateur = p_idutilisateur;
    UPDATE utilisateur
    SET nomutilisateur = COALESCE(p_nomutilisateur, r_utilisateur.nomutilisateur),
    motdepasse = COALESCE(p_motdepasse, r_utilisateur.motdepasse)
    WHERE idutilisateur = p_idutilisateur
    RETURNING idutilisateur INTO l_idutilisateur;

    l_nbre_rangee := SQL%ROWCOUNT;
    logger.append_param(l_params, 'sql%l_nbre_rangee: ', l_nbre_rangee);
    logger.log('>>>FIN de la procédure', l_scope, NULL, l_params);

    IF p_test = 'N' THEN
    COMMIT;
    END IF;

    l_reponse := JSON_OBJECT(
        'data' VALUE JSON_OBJECT(
        'type' VALUE 'utilisateur',
        'id' VALUE l_idutilisateur,
        'attributes' VALUE JSON_OBJECT(
        'nomUtilisateur' VALUE COALESCE(p_nomutilisateur, r_utilisateur.nomutilisateur) ) ),
        'meta' VALUE JSON_OBJECT(
        'status' VALUE 'success',
        'statusCode' VALUE 200 ));
    RETURN l_reponse;



    EXCEPTION
        WHEN ex_id_is_null THEN
            -- pas d utilisation de SQLERRM et SQLCODE car on a une exception personnalisée
            ROLLBACK;
            logger.log_error('>>>ERREUR de type ex_id_is_null la procédure', l_scope, null, l_params);
            l_reponse := JSON_OBJECT('errors' VALUE JSON_ARRAY(JSON_OBJECT(
                'status'  VALUE '400',
                'title'   VALUE 'ID de l utilisateur requis',
                'detail'  VALUE 'Erreur id est null lors de la maj de l utilisateur',
                'code'    VALUE TO_CHAR(-1),
                'meta'    VALUE JSON_OBJECT(
                'timestamp' VALUE TO_CHAR(SYSDATE, 'YYYY-MM-DD"T"HH24:MI:SS') ) ) ) );
            RETURN l_reponse;


            WHEN no_data_found THEN
            l_error_mess := sqlerrm;
            l_error_code := sqlcode;
            ROLLBACK;
            logger.log_error('>>>ERREUR de de type ex_id_inexistant la procédure', l_scope, null, l_params);
            l_reponse := JSON_OBJECT('errors' VALUE JSON_ARRAY(JSON_OBJECT(
                'status'  VALUE '404',
                'title'   VALUE 'utilisateur non trouvé',
                'detail'  VALUE 'Erreur id inexistant '|| p_idutilisateur || ' lors de la maj de l utilisateur',
                'code'    VALUE TO_CHAR(l_error_code),
                'meta'    VALUE JSON_OBJECT(
                'timestamp' VALUE TO_CHAR(SYSDATE, 'YYYY-MM-DD"T"HH24:MI:SS') ) ) ) );
            RETURN l_reponse;



            WHEN OTHERS THEN
            ROLLBACK;
            l_error_mess := sqlerrm;
            l_error_code := sqlcode;
            logger.log_error('>>>ERREUR de type OTHERS la procédure', l_scope, null, l_params);
            l_reponse := JSON_OBJECT( 'errors' VALUE JSON_ARRAY(JSON_OBJECT(
                'status'  VALUE '500',
                'title'   VALUE 'Erreur système',
                'detail'  VALUE 'Erreur OTHERS lors de la mise à jour de l utilisateur',
                'code'    VALUE TO_CHAR(l_error_code),
                'meta'    VALUE JSON_OBJECT(
                'timestamp' VALUE TO_CHAR(SYSDATE, 'YYYY-MM-DD"T"HH24:MI:SS') ) ) ) );
            RETURN l_reponse;

END modifier_utilisateur;


END utilisateur_api;
