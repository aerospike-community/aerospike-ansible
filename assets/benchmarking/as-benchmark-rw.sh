#!/bin/bash

PATH=$PATH:.

source as-benchmark-common.sh

run_benchmarks $ADDITIONAL_FLAGS \
	-h $HOST \
	-p 3000 \
	-n $NAMESPACE \
	-k $KEYS \
	-o $OBJECT_SPEC \
    -g $RATE \
	-w RU,$READ_PCT \
	-z $THREADS \
#	-D
