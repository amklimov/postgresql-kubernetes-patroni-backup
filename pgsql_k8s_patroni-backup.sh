#!/usr/bin/env bash

DATE=`date +%F_%H.%M`
DIR="/opt/backup/database"
NS=(Name_NS)
BASE=(Base1 Base2 Base3)

# Определим какая из реплик является лидером в заданном неймспейсе:
Leader=$(/usr/local/bin/kubectl exec -i $NS-postgres-cluster-0 -n $NS -- patronictl list | grep -i Leader | awk '{print $2}')


for DB in ${BASE[@]}
do
    /usr/local/bin/kubectl exec -i $Leader -n $NS -- bash -c "pg_dump -U postgres -d $DB" | gzip  > $DIR/$DB'_'$DATE.gz
    find $DIR -name $DB* -ctime + 30 | xargs rm -rf
done

