create or replace PACKAGE BODY membre_api_tests IS

    g_id_membre NUMBER := 0;
    g_reponse_obj VARCHAR2(4000);
    g_mode_test CHAR(1) := 'O';

    --procedure du test d insertion d un membre ins_membre

    PROCEDURE ins_membre IS
        l_nom                membre.nom%TYPE;
        l_prenom             membre.prenom%TYPE;
        l_numeroTelephone    membre.numeroTelephone%TYPE;
        l_adresseCourriel    membre.adresseCourriel%TYPE;
        l_dateAbonnement     membre.dateAbonnement%TYPE;
        l_status_idStatus    membre.status_idStatus%TYPE;
        l_adresse_idAdresse  membre.adresse_idAdresse%TYPE;
    BEGIN
        -- arrange
        l_nom := 'Tremblay';
        l_prenom := 'Marie';
        l_numeroTelephone := '5145551234';
        l_adresseCourriel := 'marie@test.ca';
        l_dateAbonnement := SYSDATE;
        l_status_idStatus := 1;
        l_adresse_idAdresse := 1;

        -- act
        g_reponse_obj := membre_tapi.ins_membre(
            NULL,
            l_nom,
            l_prenom,
            l_numeroTelephone,
            l_adresseCourriel,
            l_dateAbonnement,
            l_status_idStatus,
            l_adresse_idAdresse,
            g_mode_test
        );

        g_id_membre := COALESCE(
            JSON_VALUE(g_reponse_obj, '$.data.id'),
            -99999
        );

        DBMS_OUTPUT.PUT_LINE('g_reponse_obj: ' || g_reponse_obj);
        DBMS_OUTPUT.PUT_LINE('g_id_membre: ' || g_id_membre);

        -- assert
        ut.expect(g_id_membre).to_be_greater_or_equal(1);

    END ins_membre;

--procedure du test dinsertion dun membre null ins_membre_null

   PROCEDURE ins_membre_null IS
        l_nom                membre.nom%TYPE;
        l_prenom             membre.prenom%TYPE;
        l_numeroTelephone    membre.numeroTelephone%TYPE;
        l_adresseCourriel    membre.adresseCourriel%TYPE;
        l_dateAbonnement     membre.dateAbonnement%TYPE;
        l_status_idStatus    membre.status_idStatus%TYPE;
        l_adresse_idAdresse  membre.adresse_idAdresse%TYPE;
        l_status_code        NUMBER;
    BEGIN
        -- arrange
        l_nom := NULL;
        l_prenom := 'Marie';
        l_numeroTelephone := '5145551234';
        l_adresseCourriel := 'marie@test.ca';
        l_dateAbonnement := SYSDATE;
        l_status_idStatus := 1;
        l_adresse_idAdresse := 1;

        -- act
        g_reponse_obj := membre_tapi.ins_membre(
            NULL,
            l_nom,
            l_prenom,
            l_numeroTelephone,
            l_adresseCourriel,
            l_dateAbonnement,
            l_status_idStatus,
            l_adresse_idAdresse,
            g_mode_test
        );

        l_status_code := COALESCE(
            JSON_VALUE(g_reponse_obj, '$.errors[0].code'),
            '-99999'
        );

        DBMS_OUTPUT.PUT_LINE('g_reponse_obj: ' || g_reponse_obj);
        DBMS_OUTPUT.PUT_LINE('l_status_code: ' || l_status_code);

        -- assert
        ut.expect(l_status_code).to_equal(-1400);

    END ins_membre_null;

--procedure du test de recuperation d'un membre existant get_membre

   PROCEDURE get_membre IS
        l_expected NUMBER;
        l_id_membre membre.idMembre%TYPE;
    BEGIN
        -- arrange
        l_expected := 21;
        l_id_membre := 21;


        -- act
        g_reponse_obj := membre_tapi.get_membre(l_id_membre, 2, 0, 2);

        l_id_membre := JSON_VALUE(g_reponse_obj, '$.data[0].id');

        DBMS_OUTPUT.PUT_LINE('g_reponse_obj: ' || g_reponse_obj);
        DBMS_OUTPUT.PUT_LINE('l_id_membre: ' || l_id_membre);

        -- assert
        ut.expect(l_id_membre).to_equal(l_expected);

    END get_membre;

--procedure du test de recuperation d'un membre inexistant get_membre_inexistant   
    PROCEDURE get_membre_inexistant IS
        l_id_membre membre.idMembre%TYPE;
    BEGIN
        -- arrange
        l_id_membre := -1;

        -- act
        g_reponse_obj := membre_tapi.get_membre(l_id_membre);

        DBMS_OUTPUT.PUT_LINE('g_reponse_obj: ' || g_reponse_obj);

        -- assert
        DECLARE
            l_error_code VARCHAR2(20);
        BEGIN
            l_error_code := JSON_VALUE(g_reponse_obj, '$.errors[0].code');

            ut.expect(l_error_code).to_equal('-20001');
        END;

    END get_membre_inexistant;

--procedure du test de modification des donnees d'un membre existant upd_membre 

    PROCEDURE upd_membre IS
    l_nom membre.nom%TYPE;
    l_id_membre membre.idMembre%TYPE;
    l_id_membre_ret membre.idMembre%TYPE;
    BEGIN
    -- arrange
    l_nom := 'Gagnon';

    l_id_membre := 21;

    -- act
    g_reponse_obj := membre_tapi.upd_membre(
        p_id_membre => l_id_membre,
        p_nom => l_nom,
        p_test => g_mode_test
    );

    l_id_membre_ret := JSON_VALUE(g_reponse_obj, '$.data.id');

    DBMS_OUTPUT.PUT_LINE('g_reponse_obj: ' || g_reponse_obj);
    DBMS_OUTPUT.PUT_LINE('l_id_membre_ret: ' || l_id_membre_ret);

    -- assert
    ut.expect(l_id_membre_ret).to_equal(l_id_membre);

    END upd_membre;


--procedure du test de modification des donnees d'un membre inexistant upd_membre_inexistant

    PROCEDURE upd_membre_inexistant IS
    l_nom membre.nom%TYPE;
    l_id_membre membre.idMembre%TYPE;
    l_status_code NUMBER;
    l_status_expected NUMBER;
    BEGIN
    -- arrange
    l_id_membre := -1;
    l_nom := 'Gagnon';
    l_status_expected := -2;

    -- act
    g_reponse_obj := membre_tapi.upd_membre(
        p_id_membre => l_id_membre,
        p_nom => l_nom,
        p_test => g_mode_test
    );

    l_status_code := COALESCE(
        JSON_VALUE(g_reponse_obj, '$.errors[0].code'),
        '-99999'
    );

    DBMS_OUTPUT.PUT_LINE('g_reponse_obj: ' || g_reponse_obj);
    DBMS_OUTPUT.PUT_LINE('l_status_code: ' || l_status_code);

    -- assert
    ut.expect(l_status_code).to_equal(l_status_expected);

    END upd_membre_inexistant;

--procedure de test de suppression d'un membre existant del_membre

    PROCEDURE del_membre IS
    l_id_membre membre.idMembre%TYPE;
    l_id_membre_ret membre.idMembre%TYPE;
    BEGIN
    -- arrange
    l_id_membre := 21;

    -- act
    g_reponse_obj := membre_tapi.del_membre(l_id_membre, g_mode_test);

    l_id_membre_ret := JSON_VALUE(g_reponse_obj, '$.data.id');

    DBMS_OUTPUT.PUT_LINE('g_reponse_obj: ' || g_reponse_obj);
    DBMS_OUTPUT.PUT_LINE('l_id_membre_ret: ' || l_id_membre_ret);

    -- assert
    ut.expect(l_id_membre_ret).to_equal(l_id_membre);

    END del_membre;


--procedure de test de suppression d'un membre qui nexiste pas del_membre_inexistant


    PROCEDURE del_membre_inexistant IS
    l_id_membre membre.idMembre%TYPE;
    l_status_code NUMBER;
    l_status_expected NUMBER;
    BEGIN
    -- arrange
    l_id_membre := -1;
    l_status_expected := -2;

    -- act
    g_reponse_obj := membre_tapi.del_membre(l_id_membre, g_mode_test);

    l_status_code := COALESCE(
        JSON_VALUE(g_reponse_obj, '$.errors[0].code'),
        '-99999'
    );

    DBMS_OUTPUT.PUT_LINE('g_reponse_obj: ' || g_reponse_obj);
    DBMS_OUTPUT.PUT_LINE('l_status_code: ' || l_status_code);

    -- assert
    ut.expect(l_status_code).to_equal(l_status_expected);

    END del_membre_inexistant;


END membre_api_tests;
