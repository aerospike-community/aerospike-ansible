#!/bin/bash

RUN_ID_RECORD=run_id.txt
OUTPUT_DIR=/tmp
NUMBER_PAD_FORMAT="%04d"

RUN_ID=$(cat $RUN_ID_RECORD)
RUN_ID=$(( $RUN_ID + 1 ))

echo $RUN_ID > $RUN_ID_RECORD

FORMATTED_RUN_ID=$(printf $NUMBER_PAD_FORMAT $RUN_ID)

./as-benchmark-rw.sh 2>$OUTPUT_DIR/error-${FORMATTED_RUN_ID}.out | tee $OUTPUT_DIR/output-${FORMATTED_RUN_ID}.txt

