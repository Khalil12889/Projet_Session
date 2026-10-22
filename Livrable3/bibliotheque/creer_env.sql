--CREER_ENV.SQL
spool resultat.log
SELECT to_char(sysdate, 'YYYY-MM-YY HH24:MI')
FROM dual;
/
@logger/logger_install.sql
@cours.sql
@source/cours_tapi.pks
@source/cours_tapi.pkb
@test/test_cours_tapi.pks
@test/test_cours_tapi.pkb
exec logger.purge_all;
/
@exec_tests.sql
SELECT id, to_char(time_stamp, 'YYYY-MM-YY HH24:MI') log_date, substr(text, 1, 20) texte, substr(scope, 1, 20) scope, ltrim(substr(extra, instr(extra, '*'), 35), chr(42)) extra_texte
FROM logger_logs
ORDER BY id DESC;
/
spool off