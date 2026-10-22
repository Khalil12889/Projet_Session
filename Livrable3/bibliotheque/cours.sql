--------------------------------------------------------
--  File created - Saturday-November-04-2023
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Table COURS
--------------------------------------------------------

CREATE TABLE "COURS" (
    "ID_COURS" NUMBER, "NOM_COURS" VARCHAR2(100), "DESCRIPTION_COURS" VARCHAR2(200) , "CREDIT" NUMBER
);
--REM INSERTING INTO COURS SET DEFINE OFF;
INSERT INTO cours (
    id_cours, nom_cours, description_cours, credit
) VALUES (
    1, 'Informatique', 'Introduction à l''informatique', 3
);
INSERT INTO cours (
    id_cours, nom_cours, description_cours, credit
) VALUES (
    2, 'Mathématiques', 'Algèbre linéaire', 4
);
INSERT INTO cours (
    id_cours, nom_cours, description_cours, credit
) VALUES (
    4, 'Programmation Java', 'Un cours super', 12
);
INSERT INTO cours (
    id_cours, nom_cours, description_cours, credit
) VALUES (
    9, 'Programmation JavaScript', 'Un cours pas pire', 12
);
INSERT INTO cours (
    id_cours, nom_cours, description_cours, credit
) VALUES (
    11, 'Programmation PL/SQL', 'Un cours vraiment super', 12
);
--------------------------------------------------------
--  DDL for Index SYS_C0012917
--------------------------------------------------------

CREATE UNIQUE INDEX "SYS_C0012917" ON "COURS" ("ID_COURS");
--------------------------------------------------------
--  DDL for Trigger COURS_ID_COURS_TRG
--------------------------------------------------------
CREATE SEQUENCE cours_id_cours_seq INCREMENT BY 1 START WITH 30;
CREATE OR REPLACE EDITIONABLE TRIGGER "COURS_ID_COURS_TRG" BEFORE
    INSERT ON cours FOR EACH ROW WHEN ( new.id_cours IS NULL )
BEGIN
    :new.id_cours := cours_id_cours_seq.nextval;
END;
/
ALTER TRIGGER "COURS_ID_COURS_TRG" ENABLE;
--------------------------------------------------------
--  Constraints for Table COURS
--------------------------------------------------------
ALTER TABLE "COURS" ADD PRIMARY KEY ("ID_COURS") USING INDEX ENABLE;
ALTER TABLE "COURS" MODIFY ("NOM_COURS" NOT NULL ENABLE);
/