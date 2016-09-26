#!/bin/sh

LOCAL=$1
DRY_RUN=$2
REMOTE=$LOCAL

HOST=user@remoteserver.com:path/


if [ -n $DRY_RUN ];
then
    if [ "$DRY_RUN" = "-d" ];
    then
        echo rsync -f "- .svn/" -avz --dry-run $LOCAL $HOST$REMOTE
        rsync -f "- .svn/" -avz --dry-run $LOCAL $HOST$REMOTE
        exit
    fi
fi

echo rsync -f "- .svn/" -avz $LOCAL $HOST$REMOTE
rsync -f "- .svn/" -avz $LOCAL $HOST$REMOTE
exit

