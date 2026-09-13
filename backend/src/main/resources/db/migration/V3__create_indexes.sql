------------------------------------------------------------
-- PETCARE HUB - CREATE INDEXES
-- Índices auxiliares para melhorar buscas por FK e filtros (Transact-SQL)
------------------------------------------------------------

------------------------------------------------------------
-- LIMPEZA OPCIONAL
-- Remove os índices caso já existam
------------------------------------------------------------

IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_pet_responsavel' AND object_id = OBJECT_ID('PET')) DROP INDEX idx_pet_responsavel ON PET;
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_pet_clinica' AND object_id = OBJECT_ID('PET')) DROP INDEX idx_pet_clinica ON PET;
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_consulta_pet' AND object_id = OBJECT_ID('CONSULTA')) DROP INDEX idx_consulta_pet ON CONSULTA;
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_consulta_clinica' AND object_id = OBJECT_ID('CONSULTA')) DROP INDEX idx_consulta_clinica ON CONSULTA;
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_evento_pet' AND object_id = OBJECT_ID('EVENTO_PREVENTIVO')) DROP INDEX idx_evento_pet ON EVENTO_PREVENTIVO;
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_evento_protocolo' AND object_id = OBJECT_ID('EVENTO_PREVENTIVO')) DROP INDEX idx_evento_protocolo ON EVENTO_PREVENTIVO;
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_dispositivo_pet' AND object_id = OBJECT_ID('DISPOSITIVO_IOT')) DROP INDEX idx_dispositivo_pet ON DISPOSITIVO_IOT;
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_leitura_pet' AND object_id = OBJECT_ID('LEITURA_SENSOR')) DROP INDEX idx_leitura_pet ON LEITURA_SENSOR;
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_leitura_dispositivo' AND object_id = OBJECT_ID('LEITURA_SENSOR')) DROP INDEX idx_leitura_dispositivo ON LEITURA_SENSOR;
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_alerta_pet' AND object_id = OBJECT_ID('ALERTA_SAUDE')) DROP INDEX idx_alerta_pet ON ALERTA_SAUDE;
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_alerta_leitura' AND object_id = OBJECT_ID('ALERTA_SAUDE')) DROP INDEX idx_alerta_leitura ON ALERTA_SAUDE;
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_score_pet' AND object_id = OBJECT_ID('SCORE_SAUDE')) DROP INDEX idx_score_pet ON SCORE_SAUDE;
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_alerta_resolvido' AND object_id = OBJECT_ID('ALERTA_SAUDE')) DROP INDEX idx_alerta_resolvido ON ALERTA_SAUDE;
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_evento_status' AND object_id = OBJECT_ID('EVENTO_PREVENTIVO')) DROP INDEX idx_evento_status ON EVENTO_PREVENTIVO;
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_score_categoria' AND object_id = OBJECT_ID('SCORE_SAUDE')) DROP INDEX idx_score_categoria ON SCORE_SAUDE;

------------------------------------------------------------
-- ÍNDICES DE RELACIONAMENTO
------------------------------------------------------------

CREATE INDEX idx_pet_responsavel ON PET (id_responsavel);
CREATE INDEX idx_pet_clinica ON PET (id_clinica);
CREATE INDEX idx_consulta_pet ON CONSULTA (id_pet);
CREATE INDEX idx_consulta_clinica ON CONSULTA (id_clinica);
CREATE INDEX idx_evento_pet ON EVENTO_PREVENTIVO (id_pet);
CREATE INDEX idx_evento_protocolo ON EVENTO_PREVENTIVO (id_protocolo);
CREATE INDEX idx_dispositivo_pet ON DISPOSITIVO_IOT (id_pet);
CREATE INDEX idx_leitura_pet ON LEITURA_SENSOR (id_pet);
CREATE INDEX idx_leitura_dispositivo ON LEITURA_SENSOR (id_dispositivo);
CREATE INDEX idx_alerta_pet ON ALERTA_SAUDE (id_pet);
CREATE INDEX idx_alerta_leitura ON ALERTA_SAUDE (id_leitura);
CREATE INDEX idx_score_pet ON SCORE_SAUDE (id_pet);

------------------------------------------------------------
-- ÍNDICES PARA FILTROS FREQUENTES
------------------------------------------------------------

CREATE INDEX idx_alerta_resolvido ON ALERTA_SAUDE (resolvido);
CREATE INDEX idx_evento_status ON EVENTO_PREVENTIVO (status);
CREATE INDEX idx_score_categoria ON SCORE_SAUDE (categoria);

------------------------------------------------------------
-- VERIFICAÇÃO: LISTAR ÍNDICES CRIADOS
------------------------------------------------------------

SELECT i.name AS index_name, t.name AS table_name
FROM sys.indexes i
JOIN sys.tables t ON i.object_id = t.object_id
WHERE i.name IN (
    'idx_pet_responsavel',
    'idx_pet_clinica',
    'idx_consulta_pet',
    'idx_consulta_clinica',
    'idx_evento_pet',
    'idx_evento_protocolo',
    'idx_dispositivo_pet',
    'idx_leitura_pet',
    'idx_leitura_dispositivo',
    'idx_alerta_pet',
    'idx_alerta_leitura',
    'idx_score_pet',
    'idx_alerta_resolvido',
    'idx_evento_status',
    'idx_score_categoria'
)
ORDER BY t.name, i.name;