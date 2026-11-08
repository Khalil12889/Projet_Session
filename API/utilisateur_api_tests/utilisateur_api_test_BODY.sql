--Ecrit par Khalil Arrahmen Bouraoui a partir du document fournt par JF Brodeur


CREATE OR REPLACE PACKAGE BODY utilisateur_api_test AS


        PROCEDURE test_ajouter_utilisateur AS
        
            l_reponse VARCHAR2(4000);
            l_id_utilisateur utilisateur.idutilisateur%type;
            l_nom_utilisateur utilisateur.nomutilisateur%type;
            l_motdepasse utilisateur.motdepasse%type;
            
        BEGIN
        
        -- arrange
            l_nom_utilisateur := 'employerTest';
            l_motdepasse := 'empTest';
        -- act
            l_reponse := utilisateur_api.ajouter_utilisateur(l_nom_utilisateur,l_motdepasse,'O');
            l_id_utilisateur := COALESCE(JSON_VALUE(l_reponse, '$.data.id'),-99999);
            DBMS_OUTPUT.PUT_LINE('l_reponse '||l_reponse);
            DBMS_OUTPUT.PUT_LINE('l_id_utilisateur '||l_id_utilisateur);
            
        -- assert
            UT.EXPECT(l_id_utilisateur).to_be_greater_or_equal(1);
            ROLLBACK;
        END test_ajouter_utilisateur;
        
        
        
        
        
        PROCEDURE test_ajouter_utilisateur_valeur_null AS
        
            l_reponse VARCHAR2(4000);
            l_status VARCHAR2(10);
            l_nom_utilisateur utilisateur.nomutilisateur%type;
            l_motdepasse utilisateur.motdepasse%type;
            
        BEGIN
        
        -- arrange
            l_nom_utilisateur := NULL;
            l_motdepasse := 'empTest';
        -- act
            l_reponse := utilisateur_api.ajouter_utilisateur(l_nom_utilisateur,l_motdepasse,'O');
            l_status := COALESCE(JSON_VALUE(l_reponse, '$.errors.status'),'-99999');
            DBMS_OUTPUT.PUT_LINE('l_reponse '||l_reponse);
            DBMS_OUTPUT.PUT_LINE('l_status '||l_status);
            
        -- assert
            UT.EXPECT(l_status).to_equal('400');
            ROLLBACK;
        END test_ajouter_utilisateur_valeur_null;
        
        
        
        
        PROCEDURE test_retourner_utilisateur AS
            l_expected NUMBER;
            l_id_utilisateur utilisateur.idutilisateur%TYPE;
            l_reponse VARCHAR2(4000);
        BEGIN
        --arrange
            SELECT idutilisateur INTO l_expected FROM utilisateur FETCH FIRST 1 ROW ONLY;
        --act
            l_reponse := utilisateur_api.retourner_utilisateur(l_expected);
            l_id_utilisateur := COALESCE(JSON_VALUE(l_reponse, '$.data.id'),-99999);
            DBMS_OUTPUT.PUT_LINE('l_reponse: ' || l_reponse);
            dbms_output.put_line('l_id_utilisateur: ' || l_id_utilisateur);
        --assert
            UT.EXPECT(l_id_utilisateur).TO_EQUAL(l_expected);
        END test_retourner_utilisateur;
        
        
        
        
        PROCEDURE test_retourner_utilisateur_non_existant AS
            l_id_inexistant NUMBER;
            l_status_erreur VARCHAR2(10);
            l_reponse VARCHAR2(4000);
        BEGIN
        --arrange
            l_id_inexistant := 999999;
        --act
            l_reponse := utilisateur_api.retourner_utilisateur(l_id_inexistant);
            l_status_erreur := COALESCE(JSON_VALUE(l_reponse, '$.errors.status'),'-99999');
            DBMS_OUTPUT.PUT_LINE('l_reponse: ' || l_reponse);
            DBMS_OUTPUT.PUT_LINE('l_status_erreur ' || l_status_erreur);
        --assert
            UT.EXPECT(l_status_erreur).TO_EQUAL('404');
        END test_retourner_utilisateur_non_existant;
        
        
        PROCEDURE test_supprimer_utilisateur AS
            l_id_utilisateur utilisateur.idutilisateur%TYPE;
            l_reponse   VARCHAR(4000);
            l_reponse_ajout VARCHAR(4000);
            l_id_supprime utilisateur.idutilisateur%TYPE;
        BEGIN
        --arrange
            l_reponse_ajout := utilisateur_api.ajouter_utilisateur('Asupprimer','Asupprimer');
            l_id_utilisateur := JSON_VALUE(l_reponse_ajout, '$.data.id');
        --act
            l_reponse := utilisateur_api.supprimer_utilisateur(l_id_utilisateur);
            l_id_supprime := COALESCE(JSON_VALUE(l_reponse, '$.data.id'),-9999);
            DBMS_OUTPUT.PUT_LINE('l_reponse: ' || l_reponse);
            DBMS_OUTPUT.PUT_LINE('l_id_supprime ' || l_id_supprime);
        --assert
            ut.expect(l_id_utilisateur).to_equal(l_id_utilisateur);
        END test_supprimer_utilisateur;
        
        
        PROCEDURE test_supprimer_utilisateur_avec_id_null AS
            l_reponse   VARCHAR(4000);
            l_status VARCHAR(10);
        BEGIN
        --arrange
        --act
            l_reponse := utilisateur_api.supprimer_utilisateur(NULL);
            l_status := COALESCE(JSON_VALUE(l_reponse, '$.errors.status'),'-9999');
            DBMS_OUTPUT.PUT_LINE('l_reponse: ' || l_reponse);
            DBMS_OUTPUT.PUT_LINE('l_status ' || l_status);
        --assert
            ut.expect(l_status).to_equal('400');
            
        END test_supprimer_utilisateur_avec_id_null;
        
        
        
        
        PROCEDURE test_supprimer_utilisateur_avec_id_inexistant AS
            l_reponse   VARCHAR(4000);
            l_status VARCHAR(10);
        BEGIN
        --arrange
        --act
            l_reponse := utilisateur_api.supprimer_utilisateur(-999);
            l_status := COALESCE(JSON_VALUE(l_reponse, '$.errors.status'),'-9999');
            DBMS_OUTPUT.PUT_LINE('l_reponse: ' || l_reponse);
            DBMS_OUTPUT.PUT_LINE('l_status ' || l_status);
        --assert
            ut.expect(l_status).to_equal('404');
            
        END test_supprimer_utilisateur_avec_id_inexistant;
        
        
        
        
        
        PROCEDURE test_modifier_utilisateur AS
            l_id_utilisateur utilisateur.idutilisateur%TYPE;
            l_reponse   VARCHAR(4000);
            l_reponse_ajout VARCHAR(4000);
            l_modification utilisateur.nomutilisateur%TYPE;
        BEGIN
        --arrange
            l_reponse_ajout := utilisateur_api.ajouter_utilisateur('Asupprimer','Asupprimer','O');
            l_id_utilisateur := JSON_VALUE(l_reponse_ajout, '$.data.id');
        --act
            l_reponse := utilisateur_api.modifier_utilisateur(l_id_utilisateur,'Asupprier2','Asupprimer2','O');
            l_modification := COALESCE(JSON_VALUE(l_reponse, '$.data.attributes.nomUtilisateur'),'-9999');
            DBMS_OUTPUT.PUT_LINE('l_reponse: ' || l_reponse);
            DBMS_OUTPUT.PUT_LINE('l_modification ' || l_modification);
        --assert
            ut.expect(l_modification).to_equal('Asupprier2');
            ROLLBACK;
        END test_modifier_utilisateur;
        
        
        
        
        PROCEDURE test_modifier_utilisateur_avec_id_null AS
            l_reponse   VARCHAR(4000);
            l_status VARCHAR2(10);
        BEGIN
        --arrange
        --act
            l_reponse := utilisateur_api.modifier_utilisateur(NULL,'Asupprier2','Asupprimer2','O');
            l_status := COALESCE(JSON_VALUE(l_reponse, '$.errors.status'),'-9999');
            DBMS_OUTPUT.PUT_LINE('l_reponse: ' || l_reponse);
            DBMS_OUTPUT.PUT_LINE('l_status ' || l_status);
        --assert
            ut.expect(l_status).to_equal('400');
        END test_modifier_utilisateur_avec_id_null;
        
        
        PROCEDURE test_modifier_utilisateur_avec_id_inexistant AS
            l_reponse   VARCHAR(4000);
            l_status VARCHAR2(10);
        BEGIN
        --arrange
        --act
            l_reponse := utilisateur_api.modifier_utilisateur(-999,'Asupprier2','Asupprimer2','O');
            l_status := COALESCE(JSON_VALUE(l_reponse, '$.errors.status'),'-9999');
            DBMS_OUTPUT.PUT_LINE('l_reponse: ' || l_reponse);
            DBMS_OUTPUT.PUT_LINE('l_status ' || l_status);
        --assert
            ut.expect(l_status).to_equal('404');
        END test_modifier_utilisateur_avec_id_inexistant;
        
        
END ;
            