--Ecrit par Khalil Arrahmen Bouraoui

CREATE OR REPLACE PACKAGE utilisateur_api_test IS

   --%suite(utilisateur_api_test)
   --%suitepath(alltests)
   --%rollback(manual)

   --%test(test_ajouter_utilisateur : ajout d'un utilisateur)
   PROCEDURE test_ajouter_utilisateur;
   
   --%test(test_ajouter_utilisateur_valeur_null : ajout d'un utilisateur avec une valuer null)
   PROCEDURE test_ajouter_utilisateur_valeur_null;
   
   
    --%test(test_retourner_utilisateur : recuperation d'un utilisateur)
   PROCEDURE test_retourner_utilisateur;
   
   --%test(test_retourner_utilisateur_non_existant : recuperation d'un utilisateur avec un id non existant)
   PROCEDURE test_retourner_utilisateur_non_existant;
   
   
   --%test(test_supprimer_utilisateur : suppression d'un utilisateur)
   PROCEDURE test_supprimer_utilisateur;
   
   --%test(test_supprimer_utilisateur_avec_id_null : suppression d'un utilisateur avec un id null)
   PROCEDURE test_supprimer_utilisateur_avec_id_null;
    
    --%test(test_supprimer_utilisateur_avec_id_null_inexistant; : suppression d'un utilisateur avec un id inexistant)
   PROCEDURE test_supprimer_utilisateur_avec_id_inexistant;
   
   
   
   --%test(test_modifier_utilisateur : modification d'un utilisateur)
   PROCEDURE test_modifier_utilisateur;
   
   --%test(test_modifier_utilisateur_avec_id_null : modification d'un utilisateur avec un id null)
   PROCEDURE test_modifier_utilisateur_avec_id_null;
   
   --%test(test_modifier_utilisateur_avec_id_inexistant : modification d'un utilisateur avec un id inexistant)
   PROCEDURE test_modifier_utilisateur_avec_id_inexistant;


END utilisateur_api_test;