------------------------------------------------------------
-- PETCARE HUB - CONFIGURAR DEFAULT DAS SEQUENCES
-- Adiciona DEFAULT (NEXT VALUE FOR seq_xxx) em cada coluna PK
-- (Transact-SQL / Azure SQL)
------------------------------------------------------------

ALTER TABLE RESPONSAVEL          ADD CONSTRAINT df_responsavel_id          DEFAULT (NEXT VALUE FOR seq_responsavel)          FOR id_responsavel;
ALTER TABLE CLINICA              ADD CONSTRAINT df_clinica_id              DEFAULT (NEXT VALUE FOR seq_clinica)              FOR id_clinica;
ALTER TABLE PET                  ADD CONSTRAINT df_pet_id                  DEFAULT (NEXT VALUE FOR seq_pet)                  FOR id_pet;
ALTER TABLE CONSULTA             ADD CONSTRAINT df_consulta_id             DEFAULT (NEXT VALUE FOR seq_consulta)             FOR id_consulta;
ALTER TABLE PROTOCOLO_PREVENTIVO ADD CONSTRAINT df_protocolo_preventivo_id DEFAULT (NEXT VALUE FOR seq_protocolo_preventivo) FOR id_protocolo;
ALTER TABLE EVENTO_PREVENTIVO    ADD CONSTRAINT df_evento_preventivo_id    DEFAULT (NEXT VALUE FOR seq_evento_preventivo)    FOR id_evento;
ALTER TABLE DISPOSITIVO_IOT      ADD CONSTRAINT df_dispositivo_iot_id      DEFAULT (NEXT VALUE FOR seq_dispositivo_iot)      FOR id_dispositivo;
ALTER TABLE LEITURA_SENSOR       ADD CONSTRAINT df_leitura_sensor_id       DEFAULT (NEXT VALUE FOR seq_leitura_sensor)       FOR id_leitura;
ALTER TABLE ALERTA_SAUDE         ADD CONSTRAINT df_alerta_saude_id         DEFAULT (NEXT VALUE FOR seq_alerta_saude)         FOR id_alerta;
ALTER TABLE SCORE_SAUDE          ADD CONSTRAINT df_score_saude_id          DEFAULT (NEXT VALUE FOR seq_score_saude)          FOR id_score;
ALTER TABLE LOG_ERROS            ADD CONSTRAINT df_log_erros_id            DEFAULT (NEXT VALUE FOR seq_log_erros)            FOR id_log;

------------------------------------------------------------
-- VERIFICAÇÃO: confere que os defaults foram aplicados
------------------------------------------------------------

SELECT t.name AS table_name, c.name AS column_name, d.name AS constraint_name, d.definition AS default_value
FROM sys.default_constraints d
JOIN sys.tables t ON d.parent_object_id = t.object_id
JOIN sys.columns c ON d.parent_object_id = c.object_id AND d.parent_column_id = c.column_id
WHERE t.name IN (
    'RESPONSAVEL', 'CLINICA', 'PET', 'CONSULTA',
    'PROTOCOLO_PREVENTIVO', 'EVENTO_PREVENTIVO',
    'DISPOSITIVO_IOT', 'LEITURA_SENSOR',
    'ALERTA_SAUDE', 'SCORE_SAUDE', 'LOG_ERROS'
)
ORDER BY t.name;