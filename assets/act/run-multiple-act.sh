#!/bin/bash

source multiple-act-common.sh

ACT_EXE=~/act/target/bin/act_storage
REPORTING_DIRECTORY=/tmp/act
TIME=`date +%Y-%m-%d:%H-%M-%S`

# Batch No
if [ ! -f $COUNTER_FILE ]
then
        echo 0 > $COUNTER_FILE
fi

# Reporting Directory
if [ ! -e $REPORTING_DIRECTORY ]
then
	mkdir -p $REPORTING_DIRECTORY
        echo Created dir $REPORTING_DIRECTORY
fi

COUNTER=$(cat $COUNTER_FILE)
COUNTER=$(($COUNTER+1))
echo $COUNTER > $COUNTER_FILE

ACT_CONFIG_FILES=$(ls ${ACT_CONFIG_DIRECTORY}/act_storage*conf | grep -v template)

TYPE_LENGTH=0

for config in $ACT_CONFIG_FILES
do
	type=$(echo $config | awk 'BEGIN{FS="."}{print $2}')
	if [ ${#type} -gt $TYPE_LENGTH ]
	then
		TYPE_LENGTH=${#type}
	fi
done

function pad(){
	while [ ${#line} -lt $TYPE_LENGTH ]; do
  		line=$line-
	done
}

# Iostat output
line=$IOSTAT_LABEL;pad;type=$line
IOSTAT_OUTPUT=${ACT_PREFIX}.$(printf $NUMBER_PAD_FORMAT $COUNTER).${line}.${TIME}.out
IOSTAT_OUTPUT_PATH=${REPORTING_DIRECTORY}/${IOSTAT_OUTPUT}
iostat -xmt 10 > $IOSTAT_OUTPUT_PATH &

for config in $ACT_CONFIG_FILES
do
	type=$(echo $config | awk 'BEGIN{FS="."}{print $2}')
	line=$type;pad;type=$line
	ACT_OUTPUT=$ACT_PREFIX.$(printf $NUMBER_PAD_FORMAT $COUNTER).$type.${TIME}.out
	ACT_OUTPUT_PATH=${REPORTING_DIRECTORY}/$ACT_OUTPUT
	sudo $ACT_EXE $config > $ACT_OUTPUT_PATH &
done


wait %2 %3 %4
kill %1
