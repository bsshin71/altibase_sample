# 설치

## go odbc 드라이버 설치

```
go get github.com/alexbrainman/odbc
```

https://github.com/alexbrainman/odbc/wiki/GettingStartedOnLinux 참고



## unixodbc 설치

<https://github.com/alexbrainman/odbc/wiki/InstallingUnixODBC>  참조



# 환경설정

## odbc 환경변수 설정

.bashrc 에 아래 설정

```
export ODBCINI=$HOME/odbc.ini
export ODBCINSTINI=$HOME/odbcinst.ini
export ODBCSYSINI=$HOME/odbcinst.ini
```



## odbc.ini 설정

```
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
```

## odbcinst.ini 설정

```
[ODBC]
TraceFile = /tmp/odbctrace.log
Trace = Yes 

[AltibaseDriver]
Driver      =/home/altibase/altibase_home/lib/libaltibase_odbc-64bit-ul64.so
ServerType  =Altibase HDB 
Description =Altibase Driver
FileUsage   =1
```

## 테이블 생성

```
is -f $ALTIBASE_HOME/sample/SQLCLI/demo_ex1.sql
```



# 실행

```
$ go run altidodbc.go
```

