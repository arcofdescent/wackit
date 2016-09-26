#!/bin/sh

# create log file if not exists
if [ ! -e "logs/web.log" ]; then
    echo "Creating logs/web.log ..."
    touch logs/web.log
fi

# log file should be writable by all
echo "Changing mode of log file to 666 ..."
chmod 666 logs/web.log

# session directory should be writable
echo "Making session directory (tmp) writable ..."
chmod 777 tmp

# index.pl
chmod 755 www/index.pl

