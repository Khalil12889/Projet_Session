create or replace PACKAGE membre_api_tests IS

    --%suite(test_membre_tapi)
    --%suitepath(alltests)
    --%rollback(manual)

    --%test(ins_membre normal: insertion d'un membre)
    PROCEDURE ins_membre;

    --%test(ins_membre_null: insertion d'un membre avec un nom null)
    PROCEDURE ins_membre_null;

    --%test(get_membre normal: extraction d'un membre)
    PROCEDURE get_membre;

    --%test(get_membre_inexistant: extraction d'un membre inexistant)
    PROCEDURE get_membre_inexistant;

    --%test(upd_membre normal: modification d'un membre)
    PROCEDURE upd_membre;

    --%test(upd_membre_inexistant: modification d'un membre inexistant)
    PROCEDURE upd_membre_inexistant;

    --%test(del_membre normal: suppression d'un membre)
    PROCEDURE del_membre;

    --%test(del_membre_inexistant: suppression d'un membre inexistant)
    PROCEDURE del_membre_inexistant;

END membre_api_tests;
