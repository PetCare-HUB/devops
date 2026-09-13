------------------------------------------------------------
-- PETCARE HUB - CREATE SEQUENCES
-- Sequences para gerar IDs das tabelas (Transact-SQL)
------------------------------------------------------------

------------------------------------------------------------
-- LIMPEZA OPCIONAL
-- Remove as sequences caso já existam
------------------------------------------------------------

IF OBJECT_ID('seq_responsavel', 'SO') IS NOT NULL DROP SEQUENCE seq_responsavel;
IF OBJECT_ID('seq_clinica', 'SO') IS NOT NULL DROP SEQUENCE seq_clinica;
IF OBJECT_ID('seq_pet', 'SO') IS NOT NULL DROP SEQUENCE seq_pet;
IF OBJECT_ID('seq_consulta', 'SO') IS NOT NULL DROP SEQUENCE seq_consulta;
IF OBJECT_ID('seq_protocolo_preventivo', 'SO') IS NOT NULL DROP SEQUENCE seq_protocolo_preventivo;
IF OBJECT_ID('seq_evento_preventivo', 'SO') IS NOT NULL DROP SEQUENCE seq_evento_preventivo;
IF OBJECT_ID('seq_dispositivo_iot', 'SO') IS NOT NULL DROP SEQUENCE seq_dispositivo_iot;
IF OBJECT_ID('seq_leitura_sensor', 'SO') IS NOT NULL DROP SEQUENCE seq_leitura_sensor;
IF OBJECT_ID('seq_alerta_saude', 'SO') IS NOT NULL DROP SEQUENCE seq_alerta_saude;
IF OBJECT_ID('seq_score_saude', 'SO') IS NOT NULL DROP SEQUENCE seq_score_saude;
IF OBJECT_ID('seq_log_erros', 'SO') IS NOT NULL DROP SEQUENCE seq_log_erros;

------------------------------------------------------------
-- CRIAÇÃO DAS SEQUENCES
------------------------------------------------------------

CREATE SEQUENCE seq_responsavel          AS BIGINT START WITH 1 INCREMENT BY 1 NO CACHE;
CREATE SEQUENCE seq_clinica              AS BIGINT START WITH 1 INCREMENT BY 1 NO CACHE;
CREATE SEQUENCE seq_pet                  AS BIGINT START WITH 1 INCREMENT BY 1 NO CACHE;
CREATE SEQUENCE seq_consulta             AS BIGINT START WITH 1 INCREMENT BY 1 NO CACHE;
CREATE SEQUENCE seq_protocolo_preventivo  AS BIGINT START WITH 1 INCREMENT BY 1 NO CACHE;
CREATE SEQUENCE seq_evento_preventivo     AS BIGINT START WITH 1 INCREMENT BY 1 NO CACHE;
CREATE SEQUENCE seq_dispositivo_iot       AS BIGINT START WITH 1 INCREMENT BY 1 NO CACHE;
CREATE SEQUENCE seq_leitura_sensor        AS BIGINT START WITH 1 INCREMENT BY 1 NO CACHE;
CREATE SEQUENCE seq_alerta_saude          AS BIGINT START WITH 1 INCREMENT BY 1 NO CACHE;
CREATE SEQUENCE seq_score_saude           AS BIGINT START WITH 1 INCREMENT BY 1 NO CACHE;
CREATE SEQUENCE seq_log_erros             AS BIGINT START WITH 1 INCREMENT BY 1 NO CACHE;

------------------------------------------------------------
-- VERIFICAÇÃO: LISTAR SEQUENCES CRIADAS
------------------------------------------------------------

SELECT name, start_value, increment, current_value
FROM sys.sequences
WHERE name IN (
    'seq_responsavel',
    'seq_clinica',
    'seq_pet',
    'seq_consulta',
    'seq_protocolo_preventivo',
    'seq_evento_preventivo',
    'seq_dispositivo_iot',
    'seq_leitura_sensor',
    'seq_alerta_saude',
    'seq_score_saude',
    'seq_log_erros'
)
ORDER BY name;