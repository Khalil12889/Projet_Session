Prompt Exécution des tests unitaires.
BEGIN
    ut.run('test_cours_tapi'); --ut.run() pour tous les tests
END;
/
SHOW ERRORS;
