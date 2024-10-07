#!/bin/bash
##
## DO NOT MODIFY THIS FILE (make customizations in varibale_overrides.sh)
##

## Info level
export SD_VERBOSE=1
export SD_IDENTIFY_LIMIT=50
export SD_MERGE_LIMIT=2
export SD_HASHTYPE=json

## Environment specific
export SD_XCC_JAR=../vendor/marklogic-xcc-10.0.7.jar
export SD_CORB_JAR=../vendor/marklogic-corb-2.5.2.jar
export JAVA_HOME=/usr/java/jre1.8.0_181-amd64
export PATH=${JAVA_HOME}/bin:$PATH

## Job specific
export SD_TEMPORAL_MODE=false
export SD_TEMPORAL_COLLECTION=uni-temporal
export SD_DIST_DIR=_dist
export SD_ML_BASE_PATH=/ext/corb/dedupe
export SD_IDENTIFIER_PROPNAME=instanceHash
export SD_THREAD_COUNT=16
export SD_ENTITY_LIST=MyEnt
export SD_TEMP_FOLDER=/tmp/sd_job_data
export SD_LOG_FILE=/tmp/sd_job_data/log.txt
export SD_HOST=localhost
export SD_PORT=9000
export SD_USER=admin
export SD_PASS=admin

# Make customizations here:
source ./config/variable_overrides.sh
