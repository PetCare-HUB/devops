
-- ============================================================================
-- 1. TABELAS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1.1 TUTOR
-- ----------------------------------------------------------------------------

CREATE TABLE dbo.TUTOR (
    id_tutor        BIGINT          NOT NULL,
    nome            VARCHAR(120)    NOT NULL,
    email           VARCHAR(150)    NOT NULL,
    telefone        VARCHAR(20)     NULL,
    cpf             VARCHAR(11)     NULL,
    data_cadastro   DATETIME2       NOT NULL CONSTRAINT df_tutor_data_cadastro DEFAULT SYSDATETIME(),
    ativo           CHAR(1)         NOT NULL CONSTRAINT df_tutor_ativo DEFAULT 'S',
    senha_hash      VARCHAR(255)    NULL,
    status_acesso   VARCHAR(20)     NOT NULL CONSTRAINT df_tutor_status_acesso DEFAULT 'PRE_CADASTRADO',

    CONSTRAINT pk_tutor PRIMARY KEY (id_tutor),
    CONSTRAINT uk_tutor_email UNIQUE (email),
    CONSTRAINT uk_tutor_cpf UNIQUE (cpf),
    CONSTRAINT ck_tutor_ativo CHECK (ativo IN ('S', 'N')),
    CONSTRAINT ck_tutor_status_acesso CHECK (
        status_acesso IN ('PRE_CADASTRADO', 'ATIVO', 'BLOQUEADO', 'INATIVO')
    )
);

-- ----------------------------------------------------------------------------
-- 1.2 CLINICA
-- ----------------------------------------------------------------------------

CREATE TABLE dbo.CLINICA (
    id_clinica     BIGINT          NOT NULL,
    nome           VARCHAR(120)    NOT NULL,
    cnpj           VARCHAR(18)     NOT NULL,
    email          VARCHAR(150)    NOT NULL,
    telefone       VARCHAR(20)     NULL,
    endereco       VARCHAR(200)    NOT NULL,
    ativo          CHAR(1)         NOT NULL CONSTRAINT df_clinica_ativo DEFAULT 'S',
    senha_hash     VARCHAR(255)    NULL,

    CONSTRAINT pk_clinica PRIMARY KEY (id_clinica),
    CONSTRAINT uk_clinica_cnpj UNIQUE (cnpj),
    CONSTRAINT uk_clinica_email UNIQUE (email),
    CONSTRAINT ck_clinica_ativo CHECK (ativo IN ('S', 'N'))
);

-- ----------------------------------------------------------------------------
-- 1.3 PET
-- ----------------------------------------------------------------------------

CREATE TABLE dbo.PET (
    id_pet              BIGINT          NOT NULL,
    id_tutor            BIGINT          NOT NULL,
    id_clinica          BIGINT          NOT NULL,
    nome                VARCHAR(100)    NOT NULL,
    especie             VARCHAR(20)     NOT NULL,
    raca                VARCHAR(100)    NULL,
    data_nascimento     DATETIME2       NULL,
    peso_kg             DECIMAL(5,2)    NOT NULL,
    sexo                CHAR(1)         NULL,
    condicoes_cronicas  VARCHAR(500)    NULL,
    data_cadastro       DATETIME2       NOT NULL CONSTRAINT df_pet_data_cadastro DEFAULT SYSDATETIME(),
    ativo               CHAR(1)         NOT NULL CONSTRAINT df_pet_ativo DEFAULT 'S',

    CONSTRAINT pk_pet PRIMARY KEY (id_pet),
    CONSTRAINT fk_pet_tutor FOREIGN KEY (id_tutor)
        REFERENCES dbo.TUTOR (id_tutor),
    CONSTRAINT fk_pet_clinica FOREIGN KEY (id_clinica)
        REFERENCES dbo.CLINICA (id_clinica),

    CONSTRAINT ck_pet_especie CHECK (especie IN ('CAO', 'GATO', 'OUTRO')),
    CONSTRAINT ck_pet_peso CHECK (peso_kg > 0),
    CONSTRAINT ck_pet_sexo CHECK (sexo IN ('M', 'F')),
    CONSTRAINT ck_pet_ativo CHECK (ativo IN ('S', 'N'))
);

-- ----------------------------------------------------------------------------
-- 1.4 CONSULTA
-- ----------------------------------------------------------------------------

CREATE TABLE dbo.CONSULTA (
    id_consulta          BIGINT          NOT NULL,
    id_pet               BIGINT          NOT NULL,
    id_clinica           BIGINT          NOT NULL,
    data_consulta        DATETIME2       NOT NULL,
    tipo_consulta        VARCHAR(30)     NOT NULL,
    descricao            VARCHAR(500)    NULL,
    diagnostico          VARCHAR(500)    NULL,
    valor                DECIMAL(8,2)    NULL,
    retorno_recomendado  CHAR(1)         NOT NULL CONSTRAINT df_consulta_retorno DEFAULT 'N',
    data_retorno         DATETIME2       NULL,

    CONSTRAINT pk_consulta PRIMARY KEY (id_consulta),
    CONSTRAINT fk_consulta_pet FOREIGN KEY (id_pet)
        REFERENCES dbo.PET (id_pet),
    CONSTRAINT fk_consulta_clinica FOREIGN KEY (id_clinica)
        REFERENCES dbo.CLINICA (id_clinica),

    CONSTRAINT ck_consulta_tipo CHECK (
        tipo_consulta IN ('CHECKUP', 'VACINA', 'EMERGENCIA', 'RETORNO', 'EXAME')
    ),
    CONSTRAINT ck_consulta_retorno CHECK (retorno_recomendado IN ('S', 'N')),
    CONSTRAINT ck_consulta_valor CHECK (valor IS NULL OR valor >= 0)
);

-- ----------------------------------------------------------------------------
-- 1.5 PROTOCOLO_PREVENTIVO
-- ----------------------------------------------------------------------------

CREATE TABLE dbo.PROTOCOLO_PREVENTIVO (
    id_protocolo             BIGINT          NOT NULL,
    especie                  VARCHAR(20)     NOT NULL,
    raca                     VARCHAR(100)    NULL,
    tipo_evento              VARCHAR(30)     NOT NULL,
    descricao                VARCHAR(500)    NOT NULL,
    idade_meses_recomendada  INT             NULL,
    intervalo_dias           INT             NULL,
    ativo                    CHAR(1)         NOT NULL CONSTRAINT df_protocolo_preventivo_ativo DEFAULT 'S',

    CONSTRAINT pk_protocolo_preventivo PRIMARY KEY (id_protocolo),

    CONSTRAINT ck_protocolo_especie CHECK (
        especie IN ('CAO', 'GATO', 'OUTRO')
    ),
    CONSTRAINT ck_protocolo_tipo CHECK (
        tipo_evento IN ('VACINA', 'CHECKUP', 'VERMIFUGO', 'RETORNO', 'MEDICAMENTO')
    ),
    CONSTRAINT ck_protocolo_idade CHECK (
        idade_meses_recomendada IS NULL OR idade_meses_recomendada >= 0
    ),
    CONSTRAINT ck_protocolo_intervalo CHECK (
        intervalo_dias IS NULL OR intervalo_dias > 0
    ),
    CONSTRAINT ck_protocolo_ativo CHECK (ativo IN ('S', 'N'))
);

-- ----------------------------------------------------------------------------
-- 1.6 EVENTO_PREVENTIVO
-- ----------------------------------------------------------------------------

CREATE TABLE dbo.EVENTO_PREVENTIVO (
    id_evento        BIGINT          NOT NULL,
    id_pet           BIGINT          NOT NULL,
    id_protocolo     BIGINT          NULL,
    tipo_evento      VARCHAR(30)     NOT NULL,
    descricao        VARCHAR(500)    NOT NULL,
    data_prevista    DATETIME2       NOT NULL,
    data_realizacao  DATETIME2       NULL,
    status           VARCHAR(20)     NOT NULL CONSTRAINT df_evento_preventivo_status DEFAULT 'PENDENTE',

    CONSTRAINT pk_evento_preventivo PRIMARY KEY (id_evento),
    CONSTRAINT fk_evento_pet FOREIGN KEY (id_pet)
        REFERENCES dbo.PET (id_pet),
    CONSTRAINT fk_evento_protocolo FOREIGN KEY (id_protocolo)
        REFERENCES dbo.PROTOCOLO_PREVENTIVO (id_protocolo),

    CONSTRAINT ck_evento_tipo CHECK (
        tipo_evento IN ('VACINA', 'CHECKUP', 'VERMIFUGO', 'RETORNO', 'MEDICAMENTO')
    ),
    CONSTRAINT ck_evento_status CHECK (
        status IN ('PENDENTE', 'REALIZADO', 'ATRASADO', 'CANCELADO')
    )
);

-- ----------------------------------------------------------------------------
-- 1.7 DISPOSITIVO_IOT
-- ----------------------------------------------------------------------------

CREATE TABLE dbo.DISPOSITIVO_IOT (
    id_dispositivo    BIGINT          NOT NULL,
    id_pet            BIGINT          NOT NULL,
    tipo_dispositivo  VARCHAR(30)     NOT NULL,
    codigo_serie      VARCHAR(80)     NOT NULL,
    data_ativacao     DATETIME2       NOT NULL CONSTRAINT df_dispositivo_iot_data_ativacao DEFAULT SYSDATETIME(),
    ativo             CHAR(1)         NOT NULL CONSTRAINT df_dispositivo_iot_ativo DEFAULT 'S',

    CONSTRAINT pk_dispositivo_iot PRIMARY KEY (id_dispositivo),
    CONSTRAINT fk_dispositivo_pet FOREIGN KEY (id_pet)
        REFERENCES dbo.PET (id_pet),
    CONSTRAINT uk_dispositivo_codigo UNIQUE (codigo_serie),
    CONSTRAINT ck_dispositivo_tipo CHECK (
        tipo_dispositivo IN ('COLEIRA', 'COMEDOURO', 'AMBIENTE')
    ),
    CONSTRAINT ck_dispositivo_ativo CHECK (ativo IN ('S', 'N'))
);

-- ----------------------------------------------------------------------------
-- 1.8 LEITURA_COLEIRA
-- ----------------------------------------------------------------------------

CREATE TABLE dbo.LEITURA_COLEIRA (
    id_leitura_coleira  BIGINT          NOT NULL,
    id_pet               BIGINT          NOT NULL,
    status_atividade     VARCHAR(30)     NOT NULL,
    nivel_bateria       INT             NOT NULL,
    timestamp_leitura   DATETIME2       NOT NULL CONSTRAINT df_leitura_coleira_timestamp DEFAULT SYSDATETIME(),

    CONSTRAINT pk_leitura_coleira PRIMARY KEY (id_leitura_coleira),
    CONSTRAINT fk_leitura_coleira_pet FOREIGN KEY (id_pet)
        REFERENCES dbo.PET (id_pet),
    CONSTRAINT ck_leitura_coleira_status CHECK (
        status_atividade IN ('ATIVO', 'MODERADO', 'SEDENTARIO')
    ),
    CONSTRAINT ck_leitura_coleira_bateria CHECK (
        nivel_bateria BETWEEN 0 AND 100
    )
);

-- ----------------------------------------------------------------------------
-- 1.9 LEITURA_COMEDOURO
-- ----------------------------------------------------------------------------

CREATE TABLE dbo.LEITURA_COMEDOURO (
    id_leitura_comedouro  BIGINT          NOT NULL,
    id_pet                BIGINT          NOT NULL,
    nivel_racao_pct       INT             NOT NULL,
    peso_consumido_g      DECIMAL(8,2)    NOT NULL,
    timestamp_leitura     DATETIME2       NOT NULL CONSTRAINT df_leitura_comedouro_timestamp DEFAULT SYSDATETIME(),

    CONSTRAINT pk_leitura_comedouro PRIMARY KEY (id_leitura_comedouro),
    CONSTRAINT fk_leitura_comedouro_pet FOREIGN KEY (id_pet)
        REFERENCES dbo.PET (id_pet),
    CONSTRAINT ck_leitura_comedouro_racao CHECK (
        nivel_racao_pct BETWEEN 0 AND 100
    ),
    CONSTRAINT ck_leitura_comedouro_peso CHECK (
        peso_consumido_g >= 0
    )
);

-- ----------------------------------------------------------------------------
-- 1.10 LEITURA_AMBIENTE
-- ----------------------------------------------------------------------------

CREATE TABLE dbo.LEITURA_AMBIENTE (
    id_leitura_ambiente   BIGINT          NOT NULL,
    id_pet                BIGINT          NOT NULL,
    temperatura_ambiente  DECIMAL(5,2)    NOT NULL,
    umidade_pct           INT             NOT NULL,
    qualidade_ar_ppm      INT             NOT NULL,
    pet_presente          BIT             NOT NULL,
    timestamp_leitura     DATETIME2       NOT NULL CONSTRAINT df_leitura_ambiente_timestamp DEFAULT SYSDATETIME(),

    CONSTRAINT pk_leitura_ambiente PRIMARY KEY (id_leitura_ambiente),
    CONSTRAINT fk_leitura_ambiente_pet FOREIGN KEY (id_pet)
        REFERENCES dbo.PET (id_pet),
    CONSTRAINT ck_leitura_ambiente_umidade CHECK (
        umidade_pct BETWEEN 0 AND 100
    ),
    CONSTRAINT ck_leitura_ambiente_ar CHECK (
        qualidade_ar_ppm >= 0
    )
);

-- ----------------------------------------------------------------------------
-- 1.11 ALERTA_SAUDE
-- ----------------------------------------------------------------------------

CREATE TABLE dbo.ALERTA_SAUDE (
    id_alerta          BIGINT          NOT NULL,
    id_pet             BIGINT          NOT NULL,
    tipo_alerta        VARCHAR(40)     NOT NULL,
    nivel_alerta       VARCHAR(20)     NOT NULL,
    mensagem           VARCHAR(500)    NOT NULL,
    valor_detectado    DECIMAL(10,2)   NOT NULL,
    limite_referencia  DECIMAL(10,2)   NOT NULL,
    resolvido          CHAR(1)         NOT NULL CONSTRAINT df_alerta_saude_resolvido DEFAULT 'N',
    data_alerta        DATETIME2       NOT NULL,
    data_resolucao     DATETIME2       NULL,

    CONSTRAINT pk_alerta_saude PRIMARY KEY (id_alerta),
    CONSTRAINT fk_alerta_pet FOREIGN KEY (id_pet)
        REFERENCES dbo.PET (id_pet),
    CONSTRAINT ck_alerta_nivel CHECK (
        nivel_alerta IN ('BAIXO', 'MEDIO', 'ALTO', 'CRITICO')
    ),
    CONSTRAINT ck_alerta_resolvido CHECK (resolvido IN ('S', 'N'))
);

-- ----------------------------------------------------------------------------
-- 1.12 SCORE_SAUDE
-- ----------------------------------------------------------------------------

CREATE TABLE dbo.SCORE_SAUDE (
    id_score            BIGINT          NOT NULL,
    id_pet              BIGINT          NOT NULL,
    score_total         INT             NOT NULL,
    score_atividade     INT             NOT NULL,
    score_alimentacao   INT             NOT NULL,
    score_ambiente      INT             NOT NULL,
    score_consulta      INT             NOT NULL,
    score_preventivo    INT             NOT NULL,
    categoria           VARCHAR(20)     NOT NULL,
    data_calculo        DATETIME2       NOT NULL CONSTRAINT df_score_saude_data_calculo DEFAULT SYSDATETIME(),

    CONSTRAINT pk_score_saude PRIMARY KEY (id_score),
    CONSTRAINT fk_score_pet FOREIGN KEY (id_pet)
        REFERENCES dbo.PET (id_pet),
    CONSTRAINT ck_score_total CHECK (score_total BETWEEN 0 AND 100),
    CONSTRAINT ck_score_atividade CHECK (score_atividade BETWEEN 0 AND 100),
    CONSTRAINT ck_score_alimentacao CHECK (score_alimentacao BETWEEN 0 AND 100),
    CONSTRAINT ck_score_ambiente CHECK (score_ambiente BETWEEN 0 AND 100),
    CONSTRAINT ck_score_consulta CHECK (score_consulta BETWEEN 0 AND 100),
    CONSTRAINT ck_score_preventivo CHECK (score_preventivo BETWEEN 0 AND 100),
    CONSTRAINT ck_score_categoria CHECK (
        categoria IN ('VERDE', 'AMARELO', 'VERMELHO')
    )
);

-- ----------------------------------------------------------------------------
-- 1.13 LOG_ERROS
-- ----------------------------------------------------------------------------

CREATE TABLE dbo.LOG_ERROS (
    id_log           BIGINT          NOT NULL,
    nome_procedure   VARCHAR(100)    NOT NULL,
    nome_usuario     VARCHAR(100)    NOT NULL,
    data_ocorrencia  DATETIME2       NOT NULL CONSTRAINT df_log_erros_data DEFAULT SYSDATETIME(),
    codigo_erro      INT             NOT NULL,
    mensagem_erro    VARCHAR(1000)   NOT NULL,

    CONSTRAINT pk_log_erros PRIMARY KEY (id_log)
);

-- ----------------------------------------------------------------------------
-- 1.14 AUDITORIA_TUTOR
-- ----------------------------------------------------------------------------

CREATE TABLE dbo.AUDITORIA_TUTOR (
    id_auditoria     BIGINT          NOT NULL,
    id_tutor         BIGINT          NULL,
    operacao         VARCHAR(10)     NOT NULL,
    usuario_bd       VARCHAR(128)    NOT NULL,
    data_hora        DATETIME2       NOT NULL CONSTRAINT df_auditoria_tutor_data DEFAULT SYSDATETIME(),
    status_anterior  VARCHAR(20)     NULL,
    status_novo      VARCHAR(20)     NULL,
    email_anterior   VARCHAR(150)    NULL,
    email_novo       VARCHAR(150)    NULL,

    CONSTRAINT pk_auditoria_tutor PRIMARY KEY (id_auditoria),
    CONSTRAINT ck_auditoria_operacao CHECK (
        operacao IN ('INSERT', 'UPDATE', 'DELETE')
    )
);

-- ============================================================================
-- 2. SEQUENCES
-- ============================================================================

CREATE SEQUENCE dbo.seq_tutor
    AS BIGINT START WITH 1 INCREMENT BY 1;

CREATE SEQUENCE dbo.seq_clinica
    AS BIGINT START WITH 1 INCREMENT BY 1;

CREATE SEQUENCE dbo.seq_pet
    AS BIGINT START WITH 1 INCREMENT BY 1;

CREATE SEQUENCE dbo.seq_consulta
    AS BIGINT START WITH 1 INCREMENT BY 1;

CREATE SEQUENCE dbo.seq_protocolo_preventivo
    AS BIGINT START WITH 1 INCREMENT BY 1;

CREATE SEQUENCE dbo.seq_evento_preventivo
    AS BIGINT START WITH 1 INCREMENT BY 1;

CREATE SEQUENCE dbo.seq_dispositivo_iot
    AS BIGINT START WITH 1 INCREMENT BY 1;

CREATE SEQUENCE dbo.seq_leitura_coleira
    AS BIGINT START WITH 1 INCREMENT BY 1;

CREATE SEQUENCE dbo.seq_leitura_comedouro
    AS BIGINT START WITH 1 INCREMENT BY 1;

CREATE SEQUENCE dbo.seq_leitura_ambiente
    AS BIGINT START WITH 1 INCREMENT BY 1;

CREATE SEQUENCE dbo.seq_alerta_saude
    AS BIGINT START WITH 1 INCREMENT BY 1;

CREATE SEQUENCE dbo.seq_score_saude
    AS BIGINT START WITH 1 INCREMENT BY 1;

CREATE SEQUENCE dbo.seq_log_erros
    AS BIGINT START WITH 1 INCREMENT BY 1;

CREATE SEQUENCE dbo.seq_auditoria_tutor
    AS BIGINT START WITH 1 INCREMENT BY 1;

-- ============================================================================
-- 3. DEFAULTs UTILIZANDO AS SEQUENCES
-- ============================================================================

ALTER TABLE dbo.TUTOR
    ADD CONSTRAINT df_tutor_id DEFAULT (NEXT VALUE FOR dbo.seq_tutor) FOR id_tutor;

ALTER TABLE dbo.CLINICA
    ADD CONSTRAINT df_clinica_id DEFAULT (NEXT VALUE FOR dbo.seq_clinica) FOR id_clinica;

ALTER TABLE dbo.PET
    ADD CONSTRAINT df_pet_id DEFAULT (NEXT VALUE FOR dbo.seq_pet) FOR id_pet;

ALTER TABLE dbo.CONSULTA
    ADD CONSTRAINT df_consulta_id DEFAULT (NEXT VALUE FOR dbo.seq_consulta) FOR id_consulta;

ALTER TABLE dbo.PROTOCOLO_PREVENTIVO
    ADD CONSTRAINT df_protocolo_preventivo_id DEFAULT (NEXT VALUE FOR dbo.seq_protocolo_preventivo) FOR id_protocolo;

ALTER TABLE dbo.EVENTO_PREVENTIVO
    ADD CONSTRAINT df_evento_preventivo_id DEFAULT (NEXT VALUE FOR dbo.seq_evento_preventivo) FOR id_evento;

ALTER TABLE dbo.DISPOSITIVO_IOT
    ADD CONSTRAINT df_dispositivo_iot_id DEFAULT (NEXT VALUE FOR dbo.seq_dispositivo_iot) FOR id_dispositivo;

ALTER TABLE dbo.LEITURA_COLEIRA
    ADD CONSTRAINT df_leitura_coleira_id DEFAULT (NEXT VALUE FOR dbo.seq_leitura_coleira) FOR id_leitura_coleira;

ALTER TABLE dbo.LEITURA_COMEDOURO
    ADD CONSTRAINT df_leitura_comedouro_id DEFAULT (NEXT VALUE FOR dbo.seq_leitura_comedouro) FOR id_leitura_comedouro;

ALTER TABLE dbo.LEITURA_AMBIENTE
    ADD CONSTRAINT df_leitura_ambiente_id DEFAULT (NEXT VALUE FOR dbo.seq_leitura_ambiente) FOR id_leitura_ambiente;

ALTER TABLE dbo.ALERTA_SAUDE
    ADD CONSTRAINT df_alerta_saude_id DEFAULT (NEXT VALUE FOR dbo.seq_alerta_saude) FOR id_alerta;

ALTER TABLE dbo.SCORE_SAUDE
    ADD CONSTRAINT df_score_saude_id DEFAULT (NEXT VALUE FOR dbo.seq_score_saude) FOR id_score;

ALTER TABLE dbo.LOG_ERROS
    ADD CONSTRAINT df_log_erros_id DEFAULT (NEXT VALUE FOR dbo.seq_log_erros) FOR id_log;

ALTER TABLE dbo.AUDITORIA_TUTOR
    ADD CONSTRAINT df_auditoria_tutor_id DEFAULT (NEXT VALUE FOR dbo.seq_auditoria_tutor) FOR id_auditoria;

-- ============================================================================
-- 4. ÍNDICES AUXILIARES
-- ============================================================================

CREATE INDEX idx_pet_tutor
    ON dbo.PET (id_tutor);

CREATE INDEX idx_pet_clinica
    ON dbo.PET (id_clinica);

CREATE INDEX idx_consulta_pet
    ON dbo.CONSULTA (id_pet);

CREATE INDEX idx_consulta_clinica
    ON dbo.CONSULTA (id_clinica);

CREATE INDEX idx_evento_pet
    ON dbo.EVENTO_PREVENTIVO (id_pet);

CREATE INDEX idx_evento_protocolo
    ON dbo.EVENTO_PREVENTIVO (id_protocolo);

CREATE INDEX idx_dispositivo_pet
    ON dbo.DISPOSITIVO_IOT (id_pet);

CREATE INDEX idx_leitura_coleira_pet
    ON dbo.LEITURA_COLEIRA (id_pet);

CREATE INDEX idx_leitura_comedouro_pet
    ON dbo.LEITURA_COMEDOURO (id_pet);

CREATE INDEX idx_leitura_ambiente_pet
    ON dbo.LEITURA_AMBIENTE (id_pet);

CREATE INDEX idx_alerta_pet
    ON dbo.ALERTA_SAUDE (id_pet);

CREATE INDEX idx_score_pet
    ON dbo.SCORE_SAUDE (id_pet);

CREATE INDEX idx_alerta_resolvido
    ON dbo.ALERTA_SAUDE (resolvido);

CREATE INDEX idx_evento_status
    ON dbo.EVENTO_PREVENTIVO (status);

CREATE INDEX idx_score_categoria
    ON dbo.SCORE_SAUDE (categoria);

-- ============================================================================
-- 5. TRIGGER DE AUDITORIA DO TUTOR
-- ============================================================================

CREATE OR ALTER TRIGGER dbo.trg_auditoria_tutor
ON dbo.TUTOR
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.AUDITORIA_TUTOR (
        id_tutor,
        operacao,
        usuario_bd,
        data_hora,
        status_anterior,
        status_novo,
        email_anterior,
        email_novo
    )
    SELECT
        COALESCE(i.id_tutor, d.id_tutor),
        CASE
            WHEN i.id_tutor IS NOT NULL AND d.id_tutor IS NULL THEN 'INSERT'
            WHEN i.id_tutor IS NOT NULL AND d.id_tutor IS NOT NULL THEN 'UPDATE'
            ELSE 'DELETE'
        END,
        SUSER_SNAME(),
        SYSDATETIME(),
        d.status_acesso,
        i.status_acesso,
        d.email,
        i.email
    FROM inserted i
    FULL OUTER JOIN deleted d
        ON i.id_tutor = d.id_tutor;
END;
GO

-- ============================================================================
-- 6. CONSULTAS DE VALIDAÇÃO
-- ============================================================================

SELECT
    TABLE_SCHEMA,
    TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'dbo'
  AND TABLE_NAME IN (
      'TUTOR',
      'CLINICA',
      'PET',
      'CONSULTA',
      'PROTOCOLO_PREVENTIVO',
      'EVENTO_PREVENTIVO',
      'DISPOSITIVO_IOT',
      'LEITURA_COLEIRA',
      'LEITURA_COMEDOURO',
      'LEITURA_AMBIENTE',
      'ALERTA_SAUDE',
      'SCORE_SAUDE',
      'LOG_ERROS',
      'AUDITORIA_TUTOR'
  )
ORDER BY TABLE_NAME;

SELECT
    name AS trigger_name,
    is_disabled
FROM sys.triggers
WHERE name = 'trg_auditoria_tutor';

SELECT
    name AS sequence_name
FROM sys.sequences
WHERE schema_id = SCHEMA_ID('dbo')
ORDER BY name;

-- ============================================================================
-- FIM DO SCRIPT
-- ============================================================================
