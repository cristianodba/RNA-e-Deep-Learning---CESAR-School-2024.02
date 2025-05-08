-- Conectar como SYSDBA antes de executar
-- Exemplo: sqlplus / as sysdba
SET LINES 300

-- Salva log do ambiente antes da execução
SPOOL pre_catproc_log.txt

PROMPT Verificando objetos inválidos...
SELECT owner, object_name, object_type
FROM dba_objects
WHERE status = 'INVALID';

PROMPT Verificando sessões ativas...
SELECT username, status, osuser, program
FROM v$session
WHERE username IS NOT NULL;

PROMPT Verificando status do banco...
SELECT instance_name, status, database_status FROM v$instance;

PROMPT Verificando alertas recentes...
SELECT originating_timestamp, message_text
FROM v$diag_alert_ext
WHERE originating_timestamp > SYSDATE - 1
ORDER BY originating_timestamp DESC FETCH FIRST 10 ROWS ONLY;

PROMPT Removendo componentes OLAP...
@?/olap/admin/catnoolap.sql

PROMPT Recompilando objetos padrão Oracle...
@?/rdbms/admin/catproc.sql

PROMPT Recompilando objetos inválidos restantes...
EXEC UTL_RECOMP.RECOMP_SERIAL();

PROMPT Verificando se ainda existem objetos OLAP inválidos...
SELECT object_name, object_type, status
FROM dba_objects
WHERE object_name LIKE '%CUBE_EXP%' OR object_name LIKE '%OLAP%'
ORDER BY status DESC;

PROMPT Verificando componentes OLAP no registro do banco...
SELECT comp_name, status
FROM dba_registry
WHERE comp_name LIKE '%OLAP%';


SPOOL OFF


