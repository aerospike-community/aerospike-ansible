#!/usr/bin/bash

source multiple-act-common.sh
RUN_NUMBER=$CURRENT_MULTI_ACT_RUN

if [ ! -z $1 ]
then
        RUN_NUMBER=$1
fi

FORMATTED_RUN_NUMBER=$(printf $NUMBER_PAD_FORMAT $RUN_NUMBER)

echo Output for run $FORMATTED_RUN_NUMBER
echo ====================================
echo

ls -l ${REPORTING_DIRECTORY}/${ACT_PREFIX}.$FORMATTED_RUN_NUMBER*
