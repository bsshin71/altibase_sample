#include <sql.h>
#include <sqlext.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>


#define PRINT_DIAGNOSTIC(handle_type, handle, str) print_diagnostic_core(handle_type, handle, __LINE__, str)
static void print_diagnostic_core(SQLSMALLINT handle_type, SQLHANDLE handle, int line, const char *str);

SQLRETURN execute_select(SQLHDBC dbc);



int main()
{
    SQLHENV   env = SQL_NULL_HENV;
    SQLHDBC   dbc = SQL_NULL_HDBC;
    SQLRETURN rc;

    /* allocate Environment handle */
    rc = SQLAllocEnv(&env);
    if (!SQL_SUCCEEDED(rc))
    {
        printf("SQLAllocEnv error!!\n");
        goto EXIT;
    }

    /* allocate Connection handle */
    rc = SQLAllocConnect(env, &dbc);
    if (!SQL_SUCCEEDED(rc))
    {
        PRINT_DIAGNOSTIC(SQL_HANDLE_ENV, env, "SQLAllocConnect");
        goto EXIT_ENV;
    }

    /* establish connection */
    rc = SQLDriverConnect(dbc, NULL,
                          (SQLCHAR *)"DRIVER=/home/altibase/altibase_home/lib/libaltibase_odbc-64bit-ul64.so;Server=127.0.0.1;User=SYS;Password=MANAGER;PORT=20300", SQL_NTS,
                          NULL, 0, NULL, SQL_DRIVER_NOPROMPT);
    if (!SQL_SUCCEEDED(rc))
    {
        PRINT_DIAGNOSTIC(SQL_HANDLE_DBC, dbc, "SQLDriverConnect");
        goto EXIT_DBC;
    }

    rc = execute_select(dbc);
    if (!SQL_SUCCEEDED(rc))
    {
        goto EXIT_DBC;
    }

    EXIT_DBC:

    if (dbc != SQL_NULL_HDBC)
    {
        (void)SQLDisconnect(dbc);
        (void)SQLFreeHandle(SQL_HANDLE_DBC, dbc);
    }

    EXIT_ENV:

    if (env != SQL_NULL_HENV)
    {
        (void)SQLFreeHandle(SQL_HANDLE_ENV, env);
    }

    EXIT:

    return 0;
}



static void print_diagnostic_core(SQLSMALLINT handle_type, SQLHANDLE handle, int line, const char *str)
{
    SQLRETURN   rc;
    SQLSMALLINT rec_num;
    SQLCHAR     sqlstate[6];
    SQLCHAR     message[2048];
    SQLSMALLINT message_len;
    SQLINTEGER  native_error;

    printf("Error : %d : %s\n", line, str);
    for (rec_num = 1; ; rec_num++)
    {
        rc = SQLGetDiagRec(handle_type,
                           handle,
                           rec_num,
                           sqlstate,
                           &native_error,
                           message,
                           sizeof(message),
                           &message_len);
        if (rc == SQL_NO_DATA || !SQL_SUCCEEDED(rc))
        {
            break;
        }

        printf("  Diagnostic Record %d\n", rec_num);
        printf("    SQLSTATE     : %s\n", sqlstate);
        printf("    Message text : %s\n", message);
        printf("    Message len  : %d\n", message_len);
        printf("    Native error : 0x%X\n", native_error);
    }
}



SQLRETURN execute_select(SQLHDBC dbc)
{
    SQLHSTMT     stmt = SQL_NULL_HSTMT;
    SQLRETURN    rc;
    SQLINTEGER   len;

    char 	name[21];
    int         age;
    

    /* allocate Statement handle */
    rc = SQLAllocStmt(dbc, &stmt);
    if (!SQL_SUCCEEDED(rc))
    {
        PRINT_DIAGNOSTIC(SQL_HANDLE_DBC, dbc, "SQLAllocStmt");
        goto EXIT;
    }

    rc = SQLExecDirect(stmt, (SQLCHAR *)"SELECT name, age FROM DEMO_EX1", SQL_NTS);
    if (!SQL_SUCCEEDED(rc))
    {
        PRINT_DIAGNOSTIC(SQL_HANDLE_STMT, stmt, "SQLExecDirect");
        goto EXIT_STMT;
    }

    /* Select의 결과값을 변수에 저장 */
    rc = SQLBindCol(stmt, 1, SQL_C_CHAR, name, 21, &len);
    if (!SQL_SUCCEEDED(rc))
    {
        PRINT_DIAGNOSTIC(SQL_HANDLE_STMT, stmt, "SQLBindCol(1)");
        goto EXIT_STMT;
    }

    rc = SQLBindCol(stmt, 2, SQL_C_SLONG, &age, 0, NULL) ;
    if (!SQL_SUCCEEDED(rc))
    {
        PRINT_DIAGNOSTIC(SQL_HANDLE_STMT, stmt, "SQLBindCol(2)");
        goto EXIT_STMT;
    }


    while ((rc = SQLFetch(stmt)) != SQL_NO_DATA)
    {
        if (rc == SQL_ERROR)
        {
            PRINT_DIAGNOSTIC(SQL_HANDLE_STMT, stmt, "SQLFetch");
            goto EXIT_STMT;
        }
	
        printf("name =%s,  age=%d \n", name, age);
    }

    rc = SQL_SUCCESS;

    EXIT_STMT:

    if (stmt != SQL_NULL_HSTMT)
    {
        (void)SQLFreeHandle(SQL_HANDLE_STMT, stmt);
    }

    EXIT:

    return rc;
}
