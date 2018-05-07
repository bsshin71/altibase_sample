#cat a.dat |  awk 'BEGIN { printflag=0;} {
is -silent -f ./sql/1*.sql | grep -v ";" |   awk 'BEGIN { printflag=0;} {
      check=$1
      if(check ~ /sqlend/) {
        printflag=1;
        next;
      }
      if( printflag == 1 ) {
         print $0;
      }
}'
