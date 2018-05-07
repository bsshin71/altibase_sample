#-------------------------------------------------------------------------------
# 2018.05.07 created by omegaman                       (Ver1.0)
#-------------------------------------------------------------------------------



# Message Function -----------------------------
pr_done(){
  echo "Press Enter Key to continue..."
}


pr_version()
{
  echo "============================="
  echo " Altibase Monitoring Script "
  echo "============================="
}

# Get sys user password from prompt
get_syspass(){
  stty -echo
  echo
  if [ $OS = "Linux" ] ; then
    echo -e "Enter SYS Password : \c"
  elif [ $OS = "SunOS" ] ; then
    if [ $OSVER = "5.10" ] ; then
      echo "Enter SYS Password : \c"
    else
      echo -n "Enter SYS Password : "
    fi
  else
    echo 'Enter SYS Password : \c'
  fi
  read PASS
  stty echo
}

# Check Altibase Version -----------------------
altibase_version_chk(){
    ALTI_VER_CHK=`$ISQL <<EOF
              set heading off;
              set feedback off;
              set timing off;
              select substring(PRODUCT_VERSION,1, 1) from v\\$VERSION; 
              exit;
EOF`


  MAJOR_ALTI_VER=`echo $ALTI_VER_CHK | cut -c 1-1`

  if [ $MAJOR_ALTI_VER -lt 5  ] ; then
     echo 'The lower version Than Aitbase 5 do not support yet'
     exit
  elif [  $MAJOR_ALTI_VER -lt 6  ] ; then
     echo 'Altibase 5'
     echo 'set colsize 10' > $MONITOR/sql/sqlid_format.sql
  elif [  $MAJOR_ALTI_VER -eq 7  ] ; then
     echo 'Altibase 7'
   #  echo 'column sql_id format 999999999999999' > $MONITOR/sql/sqlid_format.sql
  fi
 
}


# SQL Run Function ----------------------------
run_sql(){
  $ISQL -f $MONITOR/sql/$1 | grep -v ";" | awk 'BEGIN { prflag=0;} {
    checkhead=tolower($1);
    if(checkhead  ~ /sqlend/ ) {
        prflag=1;
        next;
    }

    if( prflag == 1 ) {
        print $0;
    }
}'

  echo
}

# Start monitor shell --------------------------
# Shell Check ----------------------------------
if [ $# -ne 0 ] ;  then
  echo
  echo " Altibase Monitoring Shell"
  echo " ---------------------"
  echo " Usage : $0 "
  echo " "
  echo
  exit
fi

# Configuration --------------------------------
MONITOR=./
USER=sys; export USER
PASS=manager; export PASS
OS=`uname -s`; export OS
OSVER=`uname -r`; export OSVER
ALTI_VER_CHK=5 ; export ALTI_VER_CHK
ALTIBASE_PORT_NO=30300; export ALTIBASE_PORT_NO


# Message Printing -----------------------------
clear
pr_version

# Get sys user password  -----------------------
#get_syspass
ISQL="$ALTIBASE_HOME/bin/isql -s 127.0.0.1 -u $USER -P manager -silent"; export ISQL


# Altibase version check -----------------------
altibase_version_chk


#-----------------------------------------------

while true
do
clear
pr_version
echo "  Altibase Version :"$ALTI_VER_CHK "(Long-length column FORMAT: "`cat $MONITOR/sql/sqlid_format.sql`")"
echo " -----------------------------------------------------------------------------------"
echo "  1.GENERAL                               |  2.SHARED MEMORY                        "
echo " ---------------------------------------- + ----------------------------------------"
echo "  11 - Instance/Database Info             |  21 - Database Buffer Hit Ratio         "
echo "  12 - Parameter Info                     |  22 - Shared Cache    Hit Ratio         "
echo "  13 - Altibase Memory Info               |  23 - Spinlock(Latch) Hit Ratio         "
echo "  14 - Memory Usage By Each Module        |                                         "
echo " -----------------------------------------------------------------------------------"
echo "  3.SESSION                               |  4.WAIT EVENT/LOCK                      "
echo " ---------------------------------------- + ----------------------------------------"
echo "  31 - Current Session Info               |  41 - Current Lock Info                 "
echo "  32 - Current Running Session Info       |  42 - Hierarchical Lock Info            "
echo "  33 - Current Running Session Wait Info  |  43 - Hierarchical Lock Info(TAC)       "
echo "  34 - Running Session SQL Info           |  44 - System Event                      "
echo "  35 - Current Transaction                |  45 - Session Event                     "
echo "  36 - Open Cursor                        |  46 - Session Wait                      "
echo "  37 - Current Session(TAC)               |  47 - Sysstat                           "
echo "  38 - Current Running Session(TAC)       |  48 - Jcntstat                          "
echo "  39 - Current Running Session Wait(TAC)  |  49 - Redo Nowait Info                  "
echo " -----------------------------------------------------------------------------------"
echo "  5.SPACE                                 |  6.I/O                                  "
echo " ---------------------------------------- + ----------------------------------------"
echo "  51 - Database File Info                 |  61 - File I/O Info                     "
echo "  52 - Tablespace Usage                   |  62 - Session I/O Info                  "
echo "  53 - Undo Segment Usage                 |  63 - Archivelog Count                  "
echo "  54 - Temp Segment Usage                 |                                         "
echo " -----------------------------------------------------------------------------------"
echo "  7.OBJECT                                |  8.SQL                                  "
echo " ---------------------------------------- + ----------------------------------------"
echo "  71 - Schema Object Count                |  81 - SQL Plan(Input SQL_ID)            "
echo "  72 - Object Invalid Count               |  82 - Top SQL                           "
echo "  73 - Object Invalid Object              |  83 - Check Static Query Pattern        "
echo "  74 - Segment Size(Top 50)               |                                         "
echo " -----------------------------------------------------------------------------------"
echo "  9.APM (Use Carefully)                   |  0.OTHER                                "
echo " ---------------------------------------- + ----------------------------------------"
echo "  91 - Create APM Snapshot                |  M - Auto Refresh Monitoring            "
echo "  92 - Create APM Snapshot For TAC        |  S - Save To File                       "
echo "  93 - Show APM Snapshot                  |  I - Setting SQL_ID Format              "
echo "  94 - Create APM Report                  |  X - EXIT                               "
echo " -----------------------------------------------------------------------------------"
echo
if [ $OS = "Linux" ] ; then
  echo -e " Choose the Number or Command : \c "
elif [ $OS = "SunOS" ] ; then
  if [ $OSVER = "5.10" ] ; then
    echo ' Choose the Number or Command : \c '
  else
    echo -n " Choose the Number or Command : "
  fi
else
  echo ' Choose the Number or Command : \c '
fi
read i_number
case $i_number in
# 1.GENERAL ---------------------------------------

11)
clear
echo "============================"
echo " Altibase Instance Infomation "
echo "============================"
run_sql 1_instance.sql
pr_done
read tm
;;

12)
clear
echo "======================"
echo " Parameter Infomation "
echo "======================"
run_sql 1_parameter.sql
pr_done
read tm
;;

13)
clear
echo "====================="
echo " Memory Data Size Infomation "
echo "====================="
run_sql 1_memdata.sql


echo "====================="
echo " Disk Buffer Pool Infomation "
echo "====================="
run_sql 1_buffinfo.sql


echo "==============================="
echo " Plan Cache Infomation "
echo "==============================="
run_sql 1_plancache.sql
pr_done
read tm
;;

14)
clear
echo "======================"
echo " Memory Usage By Each Module Infomation "
echo "======================"
run_sql 1_memstat.sql
pr_done
read tm
;;

x|X)
clear
echo "Good bye..."
echo
exit
;;


*)
echo
echo
echo
echo "You choose wrong number."
echo "Try Again.."
sleep 1
;;

esac

done
