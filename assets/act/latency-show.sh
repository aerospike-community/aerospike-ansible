#!/bin/bash

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

for file in $REPORTING_DIRECTORY/${ACT_PREFIX}.${FORMATTED_RUN_NUMBER}*
do 
	if [[ ! $file =~ $IOSTAT_LABEL ]]
	then
		OBJECT_TYPE=$(echo $file | awk 'BEGIN{FS="."}{print $3}' | sed 's/-//g')
		echo Latency for $OBJECT_TYPE table
		echo =================================================================
		echo
		~/act/analysis/act_latency.py -l $file | tail -n 8
		echo
	fi
done
