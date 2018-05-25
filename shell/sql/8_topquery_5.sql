set feedback off;
set timing off;
set pagesize 30
SET LINESIZE 1024;
SET COLSIZE 30;
select 
            rpad( ss.DB_USERNAME, 12, ' ') as USERNAME
          , lpad( round(st.total_time/1000, 3), 10, ' ')  as "Elapsed_Tim(ms)"
          , lpad( (st.EXECUTE_SUCCESS + st.EXECUTE_FAILURE ), 10, ' ') as "EXECUTIONS"
          , lpad( round(st.GET_PAGE/(st.EXECUTE_SUCCESS + st.EXECUTE_FAILURE ),3), 10, ' ' )  "Gets/Exec"
          , lpad( round(st.total_time /(st.EXECUTE_SUCCESS + st.EXECUTE_FAILURE )/1000,3), 10, ' ')  as "Elap/Exec(ms)"
          , decode(ss.CLIENT_APP_INFO,'', CLIENT_TYPE , ss.CLIENT_APP_INFO || '('  || CLIENT_TYPE || ')' ) as "Client"
          , st.id AS STMT_ID
          , substring( query, 1, 30) as query 
from  
         V$STATEMENT st         
      ,  V$SESSION   ss
where 
      st.SESSION_ID  =  ss.ID
  and st.total_time > 0
  and (st.EXECUTE_SUCCESS + st.EXECUTE_FAILURE ) > 0
order by 2 desc
limit 10
--sqlend
;
