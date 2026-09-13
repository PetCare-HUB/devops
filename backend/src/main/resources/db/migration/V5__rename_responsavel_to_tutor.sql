------------------------------------------------------------
-- RENOMEIA RESPONSAVEL -> TUTOR (tabela, PK, constraints, FK, sequence)
-- (Transact-SQL / Azure SQL)
------------------------------------------------------------

-- 1. Renomeia a tabela
EXEC sp_rename 'RESPONSAVEL', 'TUTOR';

-- 2. Renomeia a coluna PK da tabela TUTOR
EXEC sp_rename 'TUTOR.id_responsavel', 'id_tutor', 'COLUMN';

-- 3. Renomeia constraints da tabela TUTOR
EXEC sp_rename 'pk_responsavel', 'pk_tutor', 'OBJECT';
EXEC sp_rename 'uk_responsavel_email', 'uk_tutor_email', 'OBJECT';
EXEC sp_rename 'uk_responsavel_cpf', 'uk_tutor_cpf', 'OBJECT';
EXEC sp_rename 'ck_responsavel_ativo', 'ck_tutor_ativo', 'OBJECT';

-- 4. Renomeia constraint default da PK se existir
IF OBJECT_ID('df_responsavel_id', 'D') IS NOT NULL
    EXEC sp_rename 'df_responsavel_id', 'df_tutor_id', 'OBJECT';

-- 5. Atualiza a tabela PET (FK para TUTOR)
EXEC sp_rename 'PET.id_responsavel', 'id_tutor', 'COLUMN';
EXEC sp_rename 'fk_pet_responsavel', 'fk_pet_tutor', 'OBJECT';

-- 6. Renomeia índice idx_pet_responsavel se existir
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_pet_responsavel' AND object_id = OBJECT_ID('PET'))
    EXEC sp_rename 'PET.idx_pet_responsavel', 'idx_pet_tutor', 'INDEX';

-- 7. Recria a sequence seq_responsavel -> seq_tutor
IF OBJECT_ID('seq_tutor', 'SO') IS NULL
BEGIN
    IF OBJECT_ID('df_tutor_id', 'D') IS NOT NULL
        ALTER TABLE TUTOR DROP CONSTRAINT df_tutor_id;

    IF OBJECT_ID('seq_responsavel', 'SO') IS NOT NULL
        DROP SEQUENCE seq_responsavel;

    CREATE SEQUENCE seq_tutor AS BIGINT START WITH 1 INCREMENT BY 1 NO CACHE;
    ALTER TABLE TUTOR ADD CONSTRAINT df_tutor_id DEFAULT (NEXT VALUE FOR seq_tutor) FOR id_tutor;
END;

------------------------------------------------------------
-- VERIFICAÇÃO: confirmar que ficou tudo certo
------------------------------------------------------------

SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'TUTOR';
SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'PET' AND COLUMN_NAME = 'id_tutor';
SELECT name FROM sys.sequences WHERE name = 'seq_tutor';