#!/bin/sh

# set variables
WORK_DIR=/data/altibase/script
WORK_LOG=$WORK_DIR/rmarchive.`date "+%Y%m%d"`.log
PRGNAME=$0

#path of archivelog
ARCH_DIR=/data/altibase/arch_logs

# max number of logfile to sustain
MAX_LOGNUM=300

# max size of archivelog path( Unit:Giga )
ARCH_PATH_MAXSIZE=20

# max allowed used percent of archivelog path(Unit : percent)
ARCH_MAXPERCENT=60

# size of archivelog per one
ARCH_LOGSIZE=10

write_log()
{
  echo "["`date '+%Y%m%d %H:%M:%S'`"] $1" | tee -a $WORK_LOG
}


write_log "========Begin  remove archivelog========"

cd $WORK_DIR

#calculate max allowed used size (Giga)
MAX_ALLOWED_SIZE=`echo "$ARCH_PATH_MAXSIZE $ARCH_MAXPERCENT" | awk '{printf("%d", $1 * $2 / 100)}'`

# the total used size of archivelog files(kilo byte)
ARCH_USEDSIZE=`du -sk $ARCH_DIR | awk '{print $1}'`

# change to kilobyte unit
ARCH_PATH_MAXSIZE=`expr $ARCH_PATH_MAXSIZE \* 1024 \* 1024`

# change to kilobyte unit
ARCH_LOGSIZE=`expr $ARCH_LOGSIZE \* 1024`


# calculate used percent
ARCH_USEDPERCENT=`echo "$ARCH_USEDSIZE $ARCH_PATH_MAXSIZE" | awk '{printf("%d", $1/$2 * 100)}'`

# calculate exceeded size of archivelog path
ARCH_EXCEEDSIZE=`echo "$ARCH_PATH_MAXSIZE $ARCH_MAXPERCENT $ARCH_USEDSIZE" | awk '{printf("%d",  $3 - ( $1 * $2/100.0 ) )}'`


write_log "max size of arch path(Giga)         = "`expr $ARCH_PATH_MAXSIZE / 1024 / 1024`" G"
write_log "max allowed size  of arch path(Giga)= $MAX_ALLOWED_SIZE G"
write_log "max allowed percent of arch path (%)= $ARCH_MAXPERCENT %"
write_log "current used percent of arch path(%)= $ARCH_USEDPERCENT %"
write_log "current used size of arch path(Giga)= "`expr $ARCH_USEDSIZE  / 1024 / 1024`" G"
write_log "exceed size of arch log path (Giga) = "`expr $ARCH_EXCEEDSIZE / 1024 / 1024`" G"

#if current used size of arch log path exceed  setting size than the run delete process , or exit
if [ $ARCH_EXCEEDSIZE -lt 0 ] ; then
  write_log "current used percent  $ARCH_USEDPERCENT (%) is less than $ARCH_MAXPERCENT (%)  so we will just. exit...."
  write_log "========End  remove archivelog========"
  exit
fi


write_log "start...remove logfiles......"
# calculate the number of logfiles to delete
ARCH_RMCNT=`expr $ARCH_EXCEEDSIZE / $ARCH_LOGSIZE`

write_log "the number of logfile to delete = $ARCH_RMCNT"

cd $ARCH_DIR

RM_CNT=0
BEGINLOGNUM=`ls -1 logfile* | sed -e 's/logfile//g' | sort -n | head -1`

BEGINLOGFILE="logfile${BEGINLOGNUM}"
ENDLOGFILE=${BEGINLOGFILE}

while [ $RM_CNT -lt $ARCH_RMCNT ]
do
DELFILE="logfile"`expr $BEGINLOGNUM +  $RM_CNT`
RM_CNT=`expr $RM_CNT + 1`

if [ -f "${ARCH_DIR}/${DELFILE}" ] ; then
        #echo "rm $ARCH_DIR/${DELFILE}"
        rm $ARCH_DIR/${DELFILE} 2>& 1 |  tee -a $WORK_LOG
        ENDLOGFILE=${DELFILE}
fi
done

write_log "Delete Result =   $BEGINLOGFILE  ~ $ENDLOGFILE were deleted ,   total $RM_CNT files deleted"
write_log "========End  remove archivelog========"