------------------------------------------------------------
-- CAMPOS DE AUTENTICAÇÃO
-- (Transact-SQL / Azure SQL)
------------------------------------------------------------

ALTER TABLE TUTOR
ADD senha_hash VARCHAR(255) NULL;

ALTER TABLE TUTOR
ADD status_acesso VARCHAR(20) NOT NULL
    CONSTRAINT df_tutor_status_acesso
    DEFAULT 'PRE_CADASTRADO';

EXEC(N'
    ALTER TABLE TUTOR
    ADD CONSTRAINT ck_tutor_status_acesso
    CHECK (
        status_acesso IN (
            ''PRE_CADASTRADO'',
            ''ATIVO'',
            ''BLOQUEADO'',
            ''INATIVO''
        )
    );
');

ALTER TABLE CLINICA
ADD senha_hash VARCHAR(255) NULL;