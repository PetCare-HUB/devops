------------------------------------------------------------
-- PETCARE HUB - SEPARA LEITURA_SENSOR EM 3 TABELAS
-- Alinha o schema com as 3 entidades Java (LeituraColeira,
-- LeituraComedouro, LeituraAmbiente) em vez da tabela
-- genérica LEITURA_SENSOR (tipo_leitura/valor/unidade).
-- (Transact-SQL / Azure SQL)
------------------------------------------------------------

-- 1. Efeito colateral: ALERTA_SAUDE tinha FK e coluna id_leitura
IF OBJECT_ID('fk_alerta_leitura', 'F') IS NOT NULL
    ALTER TABLE ALERTA_SAUDE DROP CONSTRAINT fk_alerta_leitura;

IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_alerta_leitura' AND object_id = OBJECT_ID('ALERTA_SAUDE'))
    DROP INDEX idx_alerta_leitura ON ALERTA_SAUDE;

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'ALERTA_SAUDE' AND COLUMN_NAME = 'id_leitura')
    ALTER TABLE ALERTA_SAUDE DROP COLUMN id_leitura;

-- 2. Remove a tabela genérica antiga e sua sequence
IF OBJECT_ID('df_leitura_sensor_id', 'D') IS NOT NULL
    ALTER TABLE LEITURA_SENSOR DROP CONSTRAINT df_leitura_sensor_id;

IF OBJECT_ID('LEITURA_SENSOR', 'U') IS NOT NULL
    DROP TABLE LEITURA_SENSOR;

IF OBJECT_ID('seq_leitura_sensor', 'SO') IS NOT NULL
    DROP SEQUENCE seq_leitura_sensor;

-- 3. LEITURA_COLEIRA
IF OBJECT_ID('LEITURA_COLEIRA', 'U') IS NOT NULL
    DROP TABLE LEITURA_COLEIRA;

IF OBJECT_ID('seq_leitura_coleira', 'SO') IS NOT NULL
    DROP SEQUENCE seq_leitura_coleira;

CREATE SEQUENCE seq_leitura_coleira AS BIGINT START WITH 1 INCREMENT BY 1 NO CACHE;

CREATE TABLE LEITURA_COLEIRA (
    id_leitura_coleira  BIGINT       NOT NULL CONSTRAINT df_leitura_coleira_id DEFAULT (NEXT VALUE FOR seq_leitura_coleira),
    id_pet              BIGINT       NOT NULL,
    status_atividade    VARCHAR(30)  NOT NULL,
    nivel_bateria       INT          NOT NULL,
    timestamp_leitura   DATETIME2    DEFAULT SYSDATETIME() NOT NULL,

    CONSTRAINT pk_leitura_coleira PRIMARY KEY (id_leitura_coleira),
    CONSTRAINT fk_leitura_coleira_pet FOREIGN KEY (id_pet) REFERENCES PET (id_pet),
    CONSTRAINT ck_leitura_coleira_status CHECK (
        status_atividade IN ('ATIVO', 'MODERADO', 'SEDENTARIO')
    ),
    CONSTRAINT ck_leitura_coleira_bateria CHECK (nivel_bateria BETWEEN 0 AND 100)
);

CREATE INDEX idx_leitura_coleira_pet ON LEITURA_COLEIRA (id_pet);

-- 4. LEITURA_COMEDOURO
IF OBJECT_ID('LEITURA_COMEDOURO', 'U') IS NOT NULL
    DROP TABLE LEITURA_COMEDOURO;

IF OBJECT_ID('seq_leitura_comedouro', 'SO') IS NOT NULL
    DROP SEQUENCE seq_leitura_comedouro;

CREATE SEQUENCE seq_leitura_comedouro AS BIGINT START WITH 1 INCREMENT BY 1 NO CACHE;

CREATE TABLE LEITURA_COMEDOURO (
    id_leitura_comedouro  BIGINT        NOT NULL CONSTRAINT df_leitura_comedouro_id DEFAULT (NEXT VALUE FOR seq_leitura_comedouro),
    id_pet                BIGINT        NOT NULL,
    nivel_racao_pct       INT           NOT NULL,
    peso_consumido_g      DECIMAL(8,2)  NOT NULL,
    timestamp_leitura     DATETIME2     DEFAULT SYSDATETIME() NOT NULL,

    CONSTRAINT pk_leitura_comedouro PRIMARY KEY (id_leitura_comedouro),
    CONSTRAINT fk_leitura_comedouro_pet FOREIGN KEY (id_pet) REFERENCES PET (id_pet),
    CONSTRAINT ck_leitura_comedouro_racao CHECK (nivel_racao_pct BETWEEN 0 AND 100),
    CONSTRAINT ck_leitura_comedouro_peso CHECK (peso_consumido_g >= 0)
);

CREATE INDEX idx_leitura_comedouro_pet ON LEITURA_COMEDOURO (id_pet);

-- 5. LEITURA_AMBIENTE
IF OBJECT_ID('LEITURA_AMBIENTE', 'U') IS NOT NULL
    DROP TABLE LEITURA_AMBIENTE;

IF OBJECT_ID('seq_leitura_ambiente', 'SO') IS NOT NULL
    DROP SEQUENCE seq_leitura_ambiente;

CREATE SEQUENCE seq_leitura_ambiente AS BIGINT START WITH 1 INCREMENT BY 1 NO CACHE;

CREATE TABLE LEITURA_AMBIENTE (
    id_leitura_ambiente   BIGINT        NOT NULL CONSTRAINT df_leitura_ambiente_id DEFAULT (NEXT VALUE FOR seq_leitura_ambiente),
    id_pet                BIGINT        NOT NULL,
    temperatura_ambiente  DECIMAL(5,2)  NOT NULL,
    umidade_pct           INT           NOT NULL,
    qualidade_ar_ppm      INT           NOT NULL,
    pet_presente          TINYINT       NOT NULL,
    timestamp_leitura     DATETIME2     DEFAULT SYSDATETIME() NOT NULL,

    CONSTRAINT pk_leitura_ambiente PRIMARY KEY (id_leitura_ambiente),
    CONSTRAINT fk_leitura_ambiente_pet FOREIGN KEY (id_pet) REFERENCES PET (id_pet),
    CONSTRAINT ck_leitura_ambiente_umidade CHECK (umidade_pct BETWEEN 0 AND 100),
    CONSTRAINT ck_leitura_ambiente_ar CHECK (qualidade_ar_ppm >= 0),
    CONSTRAINT ck_leitura_ambiente_presente CHECK (pet_presente IN (0,1))
);

CREATE INDEX idx_leitura_ambiente_pet ON LEITURA_AMBIENTE (id_pet);

------------------------------------------------------------
-- VERIFICAÇÃO FINAL
------------------------------------------------------------

SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_NAME IN ('LEITURA_COLEIRA', 'LEITURA_COMEDOURO', 'LEITURA_AMBIENTE', 'LEITURA_SENSOR')
ORDER BY TABLE_NAME;
