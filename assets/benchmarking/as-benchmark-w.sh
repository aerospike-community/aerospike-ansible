#!/bin/bash

PATH=$PATH:.

source as-benchmark-common.sh

run_benchmarks $ADDITIONAL_FLAGS \
	-h $HOST \
	-p $PORT \
	-n $NAMESPACE \
	-k $KEYS \
    -g $RATE \
	-o $OBJECT_SPEC \
	-w I \
	-z $THREADS 
