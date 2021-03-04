#!/bin/bash

dump_cmd="mysqldump -h"$MYSQL_HOST" -u"$MYSQL_USER""

if [ -z "$BACKUP_FILE" ]; then
	BACKUP_FILE="/tmp/mysql-backup.sql"
fi

if [ -n "$MYSQL_PASS" ]; then
	dump_cmd="$dump_cmd -p"$MYSQL_PASS""
fi

if [ -n "$MYSQLDUMP_OPTIONS" ]; then
	dump_cmd="$dump_cmd $MYSQLDUMP_OPTIONS"
fi

echo "command: $dump_cmd"
$dump_cmd > $BACKUP_FILE

