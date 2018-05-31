DBA Tibero이 부분 수정
oracle dup record 지우기
delete from t
where t.c1 in (select c1 from t group by c1 having count(*) > 1)
and   t.rowid not in ( select min(rowid) rid from t group by c1 having count(*) > 1)
/

create table t (c1 char(1), c2 char(1));
insert into t values('1', 'a');
insert into t values('2', 'b');
insert into t values('1', 'c');
insert into t values('2', 'd');
insert into t values('3', 'e');
insert into t values('4', 'e');

delete from  item where i_id||I_NAME in (
select i_id||min(I_NAME) from tpcc.item group by i_id having count(i_id) > 1
);
이 부분 수정
grant user to user all tables
declare
cursor c1 is select table_name from user_tables;
cmd varchar2(200);
begin
    for c in c1 loop
        cmd := 'GRANT SELECT ON '||c.table_name||' TO YOURUSERNAME';
        execute immediate cmd;
    end loop;
end;

이 부분 수정
create index nologging
CREATE INDEX cust_dup_idx    
ON customer(sex, hair_color, customer_id) 
PARALLEL 35 
NOLOGGING 
COMPRESS 2 
TABLESPACE 32k_ts
; 
이 부분 수정
LOCK 문제를 일으키는 SQL 명령 찾기 (세션)
column username format a10
column sid format 999
column lock_type format a15
column MODE_HELD format a11
column MODE_REQUESTED format a10
column LOCK_ID1 format a8
column LOCK_ID2 format a8
select a.sess_id,
       decode(a.type,
                     'MR', 'Media Recovery',
                     'RT', 'Redo Thread',
                     'UN', 'User Name',
                     'TX', 'Transaction',
                     'TM', 'DML',
                     'UL', 'PL/SQL User Lock',
                     'DX', 'Distributed Xaction',
                     'CF', 'Control File',
                     'IS', 'Instance State',
                     'FS', 'File Set',
                     'IR', 'Instance Recovery',
                     'ST', 'Disk Space Transaction',
                     'IR', 'Instance Recovery',
                     'ST', 'Disk Space Transaction',
                     'TS', 'Temp Segment',
                     'IV', 'Library Cache Invalidation',
                     'LS', 'Log Start or Switch',
                     'RW', 'Row Wait',
                     'SQ', 'Sequence Number',
                     'TE', 'Extend Table',
                     'TT', 'Temp Table',
              a.type) lock_type,
       decode(a.lmode,
                     0, 'None', /* Mon Lock equivalent */
                     1, 'Null', /* N */
                     2, 'Row-S (SS)', /* L */
                     3, 'Row-X (SX)', /* R */
                     3, 'Row-X (SX)', /* R */
                     4, 'Share', /* S */
                     5, 'S/Row-X (SSX)', /* C */
                     6, 'Exclusive', /* X */
              to_char(a.lmode)) mode_held,
              decode(a.requested,
                     0, 'None', /* Mon Lock equivalent */
                     1, 'Null', /* N */
                     2, 'Row-S (SS)', /* L */
                     3, 'Row-X (SX)', /* R */
                     4, 'Share', /* S */
                     5, 'S/Row-X (SSX)', /* C */
                     6, 'Exclusive', /* X */
              to_char(a.requested)) mode_requested,
              to_char(a.id1) lock_id1, to_char(a.id2) lock_id2
from v$lock a
where (id1,id2) in
(select b.id1, b.id2 from v$lock b where b.id1=a.id1 and
b.id2=a.id2 and b.requested>0)
/
이 부분 수정
LOCK 문제를 일으키는 SQL 명령 찾기 (테이블)
column username format a10
column wlock_wait format a10
column sql_text format a80
column object_owner format a14
column object format a15
select b.username username, c.sid sid, c.owner object_owner,
          c.object object, b.wlock_wait, a.sql_text SQL
from v$sqltext a, v$session b, v$access c
where a.sql_id=b.sql_id and
         a.child_number=b.sql_child_number and
         b.sid = c.sid and c.owner != 'SYS';
/

이 부분 수정
LOCK 문제를 일으키는 SQL 명령 찾기 (프로세스)
column "ORACLE USER" format a11
column SERIAL# format 9999999
column "OS USER" format a8
select substr(s.username,1,11) "ORACLE USER", p.pid "PROCESS ID",
          s.sid "SESSION ID", s.serial#, osuser "OS USER",
          p.spid "PROC SPID",s.WLOCK_WAIT "LOCK WAIT"
from v$process p, v$session s, v$access a
where a.sid=s.sid and
          p.pid=s.pid and
          s.username != 'SYS'
/

이 부분 수정
세션 죽이기
ALTER SYSTEM KILL SESSION '5,31';
이 부분 수정
테이블스페이스 용량보기
SELECT b.file_name "FILE_NAME", -- DataFile Name 
       b.tablespace_name "TABLESPACE_NAME", -- TableSpace Name 
       b.bytes / 1024 / 1024 "TOTAL SIZE(MB)", -- 총 Bytes 
       ((b.bytes - sum(nvl(a.bytes,0)))) / 1024 / 1024 "USED(MB)", -- 사용한 용량 
       (sum(nvl(a.bytes,0))) / 1024 "FREE SIZE(KB)", -- 남은 용량 
       (sum(nvl(a.bytes,0)) / (b.bytes)) * 100 "FREE %", -- 남은 % 
       round((b.bytes / 1024 / 1024) - ((((b.bytes - sum(nvl(a.bytes,0)))) / 1024 / 1024) + 150)) ForFree
      --,'alter database datafile '''||b.file_name||''' resize '||round((((b.bytes - sum(nvl(a.bytes,0)))) / 1024 / 1024) + 150)||'M;' str
FROM  DBA_FREE_SPACE a, DBA_DATA_FILES b 
WHERE a.file_id(+) = b.file_id 
  AND b.tablespace_name like 'TS_%' 
GROUP BY b.tablespace_name, b.file_name, b.bytes 
ORDER BY b.tablespace_name; 

-- 또는 간단하게..

 select TABLESPACE_NAME, to_char(sum(BYTES/1024/1024), '999,999') AS "FREE(MB)"
 from DBA_FREE_SPACE
 group by TABLESPACE_NAME;
이 부분 수정
Temp TBS 보기
set linesize 120
col FILE_NAME for a50
col TABLESPACE_NAME for a20

select FILE_NAME,TABLESPACE_NAME,BYTES/1024/1024 M,AUTOEXTENSIBLE 
from dba_temp_files;

이 부분 수정
테이블 용량보기
select SEGMENT_NAME,BYTES from USER_SEGMENTS where SEGMENT_NAME = 'AUDIT_';
이 부분 수정
성능저하 질의문(danger.sql)
col to_day new_value to_day_new noprint

select instance_name||'_'||to_char(sysdate, 'mmddhh24miss') to_day
from v$instance ;
column sql_text format a80 word_wrapped
column buffer_gets    format 999,999,999
column bufgets/exe    format 999,999,999
column disk_reads     format 99999999
column rows           format 99999999
column execnt         format 99999999
column parcnt         format 99999999
spool danger_sql_&&to_day_new

prompt ==========================================
prompt Find problem queries Hurting Memory 
prompt ==========================================

select buffer_gets/decode(executions,NULL,1,0,1,executions) "bufgets/exe",
       buffer_gets, disk_reads,
       rows_processed "ROWS", executions execnt, parse_calls parcnt,
       first_load_time, hash_value, 
       sql_text
  from v$sqlarea
 where disk_reads > 5000 
    or buffer_gets > 50000 
    or buffer_gets/decode(executions,NULL,1,0,1,executions) > 5000
 order by  buffer_gets/decode(executions,NULL,1,0,1,executions)
-- where disk_reads > 5000
-- order by  disk_reads
-- where buffer_gets > 50000
-- order by buffer_gets 

-- where buffer_gets/decode(executions,NULL,1,0,1,executions) > 5000
-- order by  buffer_gets/decode(executions,NULL,1,0,1,executions)
/

spool off
이 부분 수정
Excel Lock 1
select /*+ ordered */
       sysdate as "Dtime"
     , s.sql_et dur
     , s.sid
     , s.serial# sr#
     , s.username
     , s.machine
     , s.module
     , s.prog_name
     , (select sql_text from v$sqlarea where sql_id=s.sql_id) sqltxt
     , s.client_pid "OS-Pid"
     , w.time_waited as ws --"Wait(sec)"
     , decode(w.time_waited,0,'Waiting','Waited') stus--status
     , case when w.event = 'latch free' then 'latch free (' ||(select name from v$latchname b where b.latch#=w.p2)||')'
            --when w.event = 'row cache lock' then 'row cache lock (' || c.parameter || ')'
            when w.event in ('enqueue', 'DFS lock handle')
                 then w.event||' ('||chr(bitand(w.p1, -16777216)/16777215) ||chr(bitand(w.p1, 16711680)/65535)||':' 
                                   ||decode(bitand(w.p1, 65535) , 1, 'N', 2, 'SS', 3, 'SX', 4, 'S', 5, 'SSX', 6, 'X') 
                                   ||')'
            else w.event 
        end event
     , w.p1text || ':' || decode(w.event,'latch free',rawtohex(w.p1raw), to_char(w.p1)) ||',' 
              ||w.p2text || ':' || to_char(w.p2) ||','|| w.p3text || ':' || to_char(w.p3) "Additional Info"
     , rawtohex(s.sql_address) "sql_addr"
     , s.sql_hash_value "sql_hash"
     , s.sql_id --10g over
from v$session s
   , v$session_wait w
where 1=1
  and s.sid=w.sid
  and s.status = 'ACTIVE'
  and s.sql_et >= 3
  and s.username > ' ' --and module not like 'racgimon%' and module not like 'OEM.%' and module not like 'emagent%'
order by dur desc
이 부분 수정
Excel Lock 2
select /*+ ordered */
       sysdate as "Dtime"
     , s.last_call_et dur
     , s.sid
     , s.serial# sr#
     , s.username
     , s.machine
     , s.module
     , s.program
     , (select sql_text from v$sqlarea where hash_value=s.sql_hash_value and address=s.sql_address) sqltxt
     , p.spid "OS-Pid"
     , w.seconds_in_wait as ws --"Wait(sec)"
     , decode(w.wait_time,0,'Waiting','Waited') stus--status
     , case when w.event = 'latch free' then 'latch free (' ||(select name from v$latchname b where b.latch#=w.p2)||')'
            --when w.event = 'row cache lock' then 'row cache lock (' || c.parameter || ')'
            when w.event in ('enqueue', 'DFS lock handle')
                 then w.event||' ('||chr(bitand(w.p1, -16777216)/16777215) ||chr(bitand(w.p1, 16711680)/65535)||':' 
                                   ||decode(bitand(w.p1, 65535) , 1, 'N', 2, 'SS', 3, 'SX', 4, 'S', 5, 'SSX', 6, 'X') 
                                   ||')'
            else w.event 
        end event
     , w.p1text || ':' || decode(w.event,'latch free',rawtohex(w.p1raw), to_char(w.p1)) ||',' 
              ||w.p2text || ':' || to_char(w.p2) ||','|| w.p3text || ':' || to_char(w.p3) "Additional Info"
     , rawtohex(s.sql_address) "sql_addr"
     , s.sql_hash_value "sql_hash"
     , s.sql_id --10g over
from v$session s
   , v$session_wait w
   , v$process p
where 1=1
  and s.sid=w.sid
  and s.paddr = p.addr
  and s.status = 'ACTIVE'
  and s.last_call_et >= 3
  and s.username > ' ' and module not like 'racgimon%' and module not like 'OEM.%' and module not like 'emagent%'
order by dur desc
이 부분 수정
Excel Lock 3
select /*+ ordered */
       sysdate as "Dtime"
     , s.last_call_et dur
     , s.sid
     , s.serial# sr#
     , s.username
     , s.machine
     , s.module
     , s.program
     , (select sql_text from v$sqlarea where hash_value=s.sql_hash_value and address=s.sql_address) sqltxt
     , p.spid "OS-Pid"
     , w.seconds_in_wait as ws --"Wait(sec)"
     , decode(w.wait_time,0,'Waiting','Waited') stus--status
     , decode(w.event ,'latch free', 'latch free (' ||(select name from v$latchname b where b.latch#=w.p2)||')'
                      --,'row cache lock', 'row cache lock (' || c.parameter || ')'
                       ,'enqueue', 'enqueue ('||chr(bitand(w.p1, -16777216)/16777215) ||chr(bitand(w.p1, 16711680)/65535)||':' 
                                   ||decode(bitand(w.p1, 65535) , 1, 'N', 2, 'SS', 3, 'SX', 4, 'S', 5, 'SSX', 6, 'X') 
                                   ||')' ,w.event 
                      ) event
     , w.p1text || ':' || decode(w.event,'latch free',rawtohex(w.p1raw), to_char(w.p1)) ||',' 
              ||w.p2text || ':' || to_char(w.p2) ||','|| w.p3text || ':' || to_char(w.p3) "Additional Info"
     , rawtohex(s.sql_address) "sql_addr"
     , s.sql_hash_value "sql_hash"
     , s.sql_id --10g over
from v$session s
   , v$session_wait w
   , v$process p
where 1=1
  and s.sid=w.sid
  and s.paddr = p.addr
  and s.status = 'ACTIVE'
  and s.last_call_et >= 3
  and s.username > ' ' and module not like 'racgimon%'
  and w.event not in ('PX Deq Credit: send blkd'
                 ,'PX Idle Wait'
                 ,'PX Deq: Execution Msg'
                 ,'PX Deq: Table Q Normal'
                 ,'PX Deq Credit: send blkd'
                 ,'PX Deq: Execute Reply'
                 ,'PX Deq Credit: need buffer'
                 ,'PX Deq: Signal ACK'
                 ,'PX Deque wait')
order by dur desc
이 부분 수정
Excel Lock 4
select /*+ rule */
       sysdate as "Dtime"
      ,decode(a.request,0,'',' └')||a.sid||','||s.serial# sid
      ,s.status
      ,a.id1
      ,a.ctime
      ,a.lmode
      ,a.request
      ,c.name ObjName
      ,s.username
      ,s.machine
      ,s.program
      ,p.spid Server
      ,s.process Client
      ,q.sql_text
from v$lock a, v$lock b, sys.obj$ c, v$session s, v$process p, v$sql q
where a.id1 in ( select id1 from v$lock where lmode = 0 )
  and a.sid = b.sid
  and c.obj# = b.id1
  and b.type = 'TM'
  and a.sid=s.sid
  and s.paddr = p.addr
  and s.sql_address = q.address(+)
  and s.sql_hash_value = q.hash_value(+)
order by a.id1,a.request,b.sid,c.name
이 부분 수정
Excel Lock 5
-- oracle 10g
select /*+ ordered no_merge(b) */ lpad('+-',(level-1)*2)||s.sid lockt, sys_connect_by_path(s.sid,'/') path, s.status
     , last_call_et lcall
     , seconds_in_wait waits
     , username, event
     , (select name from sys.obj$ where obj#= s.row_wait_obj#) obj
     , (select sql_text from v$sql q where q.sql_id=nvl(s.sql_id,s.prev_sql_id)) sql_text
     , osuser
     , (select spid from v$process where addr = s.paddr) spid
     , process, machine, terminal, program, nvl(s.sql_id, s.prev_sql_id) sql_id
from 
    (select sid from v$session where blocking_session > 0
     union all
     select distinct blocking_session from v$session where blocking_session > 0
    ) b
   , v$session s
where b.sid=s.sid
start with s.blocking_session is null
connect by prior s.sid = s.blocking_session
이 부분 수정
Excel Lock 6

select /*+ ordered */
       sysdate as "Dtime"
     , s.last_call_et dur
     , s.sid
     , s.serial# sr#
     , s.username
     , s.machine
     , s.module
     , s.program
     , (select sql_text from v$sqlarea where hash_value=s.sql_hash_value and address=s.sql_address) sqltxt
     , p.spid "OS-Pid"
     , w.seconds_in_wait as ws --"Wait(sec)"
     , decode(w.wait_time,0,'Waiting','Waited') stus--status
     , decode(w.event ,'latch free', 'latch free (' ||(select name from v$latchname b where b.latch#=w.p2)||')'
                      --,'row cache lock', 'row cache lock (' || c.parameter || ')'
                       ,'enqueue', 'enqueue ('||chr(bitand(w.p1, -16777216)/16777215) ||chr(bitand(w.p1, 16711680)/65535)||':' 
                                   ||decode(bitand(w.p1, 65535) , 1, 'N', 2, 'SS', 3, 'SX', 4, 'S', 5, 'SSX', 6, 'X') 
                                   ||')' ,w.event 
                      ) event
     , w.p1text || ':' || decode(w.event,'latch free',rawtohex(w.p1raw), to_char(w.p1)) ||',' 
              ||w.p2text || ':' || to_char(w.p2) ||','|| w.p3text || ':' || to_char(w.p3) "Additional Info"
     , rawtohex(s.sql_address) "sql_addr"
     , s.sql_hash_value "sql_hash"
     /*, s.sql_id */
from v$session s
   , v$session_wait w
   , v$process p
where 1=1
  and s.sid=w.sid
  and s.paddr = p.addr
  and s.status = 'ACTIVE'
  and s.last_call_et >=5
  and s.username > ' '
order by dur desc
이 부분 수정
Excel Lock 7 (LockInfo2)

select /*+ ordered */
         sysdate
       , w.sid wsid
       , decode(h.sid,w.sid,'',h.sid||','||h.serial#||':'||h.spid) "Hold(sid,ser#:OSid)"
       , w.type
       , w.id1
       , w.id2
       , w.request
       , h.lmode hold
       , w.ctime
       , u.name owner
       , o.name obj
       , s.username
       , s.osuser
       , s.machine
       , s.program
       , s.module
       , q.sql_text
from
    (select  /*+ ordered */
             l.sid, s.serial#, p.spid
           , l.type, l.id1, l.id2, l.lmode, l.ctime
     from v$lock l, v$session s, v$process p
     where l.block > 0 and l.sid = s.sid
       and s.paddr = p.addr
    ) h,
    (select
            sid, type, id1, id2, request, ctime
     from v$lock k
     where request > 0
        or exists
           (select sid from v$lock
            where sid=k.sid
            group by sid
            having sum(block) > 0
               and sum(request) < 1)
    ) w,
    v$session s,
    sys.obj$ o,
    sys.user$ u,
    v$sql q
where w.id1 = h.id1
  and w.id2 = h.id2
  and w.sid = s.sid
  and s.type = 'USER'
  and s.row_wait_obj# = o.obj#(+)
  and o.owner#=u.user#(+)
  and s.sql_hash_value = q.hash_value
  and s.sql_address = q.address;
이 부분 수정
alternative sub-query
    (select sid, type, id1, id2, request, ctime
     from v$lock k
     where request > 0 
        or exists
           (select sid from v$lock
            where sid=k.sid
            group by sid
            having sum(block) > 0
               and sum(request) < 1)
    ) w,
    (select  /*+ ordered */
             l.sid, s.serial#, p.spid
           , l.type, l.id1, l.id2, l.lmode, l.ctime
     from v$lock l, v$session s, v$process p
     where l.block > 0 and l.sid = s.sid 
       and s.paddr = p.addr       
    ) h,
