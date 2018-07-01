package main

import (
	"database/sql"
	"flag"
	"fmt"
	_ "github.com/alexbrainman/odbc"
	"os"
)

var (
	//mydriver = flag.String("mydriver",
	//		"/home/omegaman/altibase/lib/libaltibase_odbc-64bit-ul64.so", "Altibase driver")
	//		"/home/omegaman/altibase/lib/libaltibase_odbc-64bit-ul64.so", "Altibase driver")
	mydriver = flag.String("mydriver",
		"Altiodbc", "Altibase driver")
	mysrv  = flag.String("mysrv", "127.0.0.1", "altibase server ip")
	mydb   = flag.String("mydb", "mydb", "altibase database name")
	myuser = flag.String("myuser", "sys", "altibase user name")
	mypass = flag.String("mypass", "manager", "altibase password")
	myport = flag.String("myport", "20300", "altibase port")
)

func altiConnect() (db *sql.DB, err error) {
	conn := fmt.Sprintf("DSN=%s;Server=%s;User=%s;Password=%s;PORT=%s;",
		*mydriver, *mysrv, *myuser, *mypass, *myport)
	fmt.Println(conn)

	db, err = sql.Open("odbc", conn)
	if err != nil {
		return nil, err
	}
	db.Driver()

	return db, nil
}

func execQuery(st *sql.Stmt) error {
	rows, err := st.Query()
	if err != nil {
		return err
	}
	defer rows.Close()
	for rows.Next() {
		var name string
		err = rows.Scan(&name)
		if err != nil {
			return err
		}
		fmt.Printf("name: %s\n", name)
	}
	return rows.Err()
}

func main() {
	db, err := altiConnect()
	if err != nil {
		panic(err)
	}
	defer db.Close()

	st, err := db.Prepare("select name from demo_ex1")
	if err != nil {
		panic(err)
	}
	defer st.Close()

	if err := execQuery(st); err != nil {
		fmt.Fprintln(os.Stderr, err)
	}

}
