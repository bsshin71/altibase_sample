## install unixodbc

## configure  unixodbc 
#set environment variables
```
export ALTIBASE_HOME=/home/altibase/altibase_home
export ODBCINI=/home/user/odbc.ini
export ODBCINSTINI=$HOME/odbcinst.ini
export ODBCSYSINI=$HOME/odbcinst.ini
```

#set configure for odbcini  as like the followings.
<pre><code>
[Altiodbc]
Driver          =/home/altibase/altibase_home/lib/libaltibase_odbc-64bit-ul64.so
Description     =Altibase driver for Linux
LongDataCompat = on
UserName = sys
Password = manager
ServerType = Altibase
Server = 127.0.0.1
User = sys
Port = 20300
NLS_USE = MS949
Database = mydb
FetchBufferSize = 64
ReadOnly = no
</code> </pre>

#set configure for odbcinst.ini  if you want you it.
<pre><code>
[ODBC]
TraceFile = /tmp/odbctrace.log
Trace = Yes

[AltibaseDriver]
Driver      =/home/altibase/altibase_home/lib/libaltibase_odbc-64bit-ul64.so
ServerType  =Altibase HDB
Description =Altibase Driver
FileUsage   =1
</code> </pre>

## configure  Makefile and Source code 
#change Makefile value  with your current setting  to find  unix odbc library
, you might need to change  ODBCLIB  with the  unixodbc library directory that you installed 
<pre><code>
CXX = g++
CFLAGS = -D_GNU_SOURCE -W -Wall -pipe -D_POSIX_PTHREAD_SEMANTICS -D_POSIX_THREADS -D_POSIX_THREAD_SAFE_FUNCTIONS -D_REENTRANT -DPDL_
HAS_AIO_CALLS -m64 -mtune=k8 -O3 -funroll-loops -fno-strict-aliasing -fno-omit-frame-pointer -DPDL_NDEBUG -D_GNU_SOURCE -DACP_CFG_CO
MPILE_64BIT -DACP_CFG_COMPILE_BIT=64 -DACP_CFG_COMPILE_BIT_STR=64

INCLUDE+=-I./ -I./include -I${ALTIBASE_HOME}/include
ODBCLIB=/usr/local/lib

LFLAG = -Wl,-relax -Wl,--no-as-needed -L. -O3 -L$(ALTIBASE_HOME)/lib -L$(ODBCLIB)
LIBS = -ldl -lpthread -lcrypt -lrt -lstdc++ -lodbc

SOURCES = demo_ex1.cpp
OBJECTS = $(SOURCES:.cpp=.o)

EXEC  = demo_ex1

all: $(EXEC)

$(EXEC): $(OBJECTS)
        $(CXX) -o $@ $(OBJECTS) $(INCLUDE) $(LFLAG) $(LIBS)

.cpp.o :
        $(CXX) $(CFLAGS) -c $< $(INCLUDE)
clean:
        rm -f $(EXEC) *.o

</code> </pre>

#change Driver path  and connection information in sample source code
<pre><code>

this sample code shows the way to use driver directly, but if you want to use DSN , then just put "DSN=Altiodbc" in connection strings
..
..............
...............
 /* establish connection */
    rc = SQLDriverConnect(dbc, NULL,
                          (SQLCHAR *)"DRIVER=/home/altibase/altibase_home/lib/libaltibase_odbc-64bit-ul64.so;Server=127.0.0.1;User=S
YS;Password=MANAGER;PORT=20300", SQL_NTS,
                          NULL, 0, NULL, SQL_DRIVER_NOPROMPT);
    if (!SQL_SUCCEEDED(rc))
    {
        PRINT_DIAGNOSTIC(SQL_HANDLE_DBC, dbc, "SQLDriverConnect");
        goto EXIT_DBC;
    }
.........

</code> </pre>

#compile sample code

<pre><code>
$ make

</code> </pre>


# create table  for running  sample program
<pre><code>
iSQL>

drop table demo_ex1;
CREATE TABLE DEMO_EX1 ( id char(8) not null, name varchar(20), age integer,
birth date, sex smallint, etc numeric(10,3) );

insert into demo_ex1 values('10000000', 'name1', 10, to_date('1990-10-11 07:10:10','YYYY-MM-DD HH:MI:SS'), 0, 100.22);

insert into demo_ex1 values('20000000', 'name2', 20, to_date('1980-04-21 12:10:10','YYYY-MM-DD HH:MI:SS'), 0, null);

insert into demo_ex1 values('30000000', 'name3', 30, to_date('1970-12-06 08:08:08','YYYY-MM-DD HH:MI:SS'), 0, 300.22);

insert into demo_ex1 values('40000000', 'name4', 40, to_date('1960-11-10 05:05:05','YYYY-MM-DD HH:MI:SS'), 0, 400.22);

</code> </pre>

#run you sample 
```
$ ./demo_ex1
```
