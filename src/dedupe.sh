#!/bin/bash

source config/variables.sh

main() {
    initialize
    processSwitches $@
    {
        skipIf() {
            local step=$1
            local cond=$2
            if "$condY";then
                II "NOTE: skipping step [$step]"
            else
                step
            fi
        }
        skipIf identifyDocuments "$ARG_SKIP_IDENTIFY"
        skipIf mergeDocuments "$ARG_SKIP_MERGE"
        skipIf cleanupDocuments "$ARG_SKIP_CLEANUP"
    }
    teardown
}


processSwitches() {
    while [ "$@" -gt "0" ];do
        case $1 in
            --limit-identify) shift; ARG_LIMIT_IDENTIFY=$1;  shift ;;
            --limit-merge)    shift; ARG_LIMIT_MERGE=$1;     shift ;;
            --limit-cleanup)  shift; ARG_LIMIT_CLEANUP=$1;   shift ;;
            --skip-identify)  shift; ARG_SKIP_IDENTIFY=true; shift ;;
            --skip-merge)     shift; ARG_SKIP_MERGE=true;    shift ;;
            --skip-cleanup)   shift; ARG_SKIP_CLEANUP=true;  shift ;;
            *)
                echo "Unknown switch [$1]"
                exit 1
                ;;
        esac
    done
}

II() { echo "II $@"; }
initialize() {
    if [ ! -d "$SD_TEMP_FOLDER" ];then
        mkdir $SD_TEMP_FOLDER
    else
        rm -rf $SD_TEMP_FOLDER
        mkdir $SD_TEMP_FOLDER
    fi
    
    if [ ! -x $SD_XCC_JAR ];then
        echo "ERROR: Missing XCC JAR: [$SD_XCC_JAR]"
        exit 1
    fi
    if [ ! -x $SD_CORB_JAR ];then
        echo "ERROR: Missing CORB JAR: [$SD_CORB_JAR]"
        exit 1
    fi
}

teardown() {
    # todo: archive move produced data into timestamped folder
}

######################
# Wrapper for running corb in the same environment
runCorb() {
    local dataReport=$1
    local step=$2
    II "Running corb for step [$step]..."
    test -d $SD_TEMP_FOLDER/reports || mkdir -p $SD_TEMP_FOLDER/reports
    II "Logging to [$SD_LOG_FILE]"
    #set -o xtrace
    java -server -cp .:$SD_XCC_JAR:$SD_CORB_JAR \
                -DXCC-CONNECTION-URI=xcc://$SD_USER:$SD_PASS@$SD_HOST:$SD_PORT \
                -DOPTIONS-FILE="config/${step}.properties" \
                -DEXPORT-FILE-NAME="$dataReport" \
                com.marklogic.developer.corb.Manager \
                > $SD_LOG_FILE 2>&1
    #set -o xtrace
}

######################
# Execute corb job in steps to add instant hashes to documents
# 
identifyDocuments() {
    # if this step has already been complete, don't execute
    # if less documents are returned tha
    II "Document identification step..."
    local stillProcessing=true
    local step="1.identify"
    local rep=
    while $stillProcessing;do
        rep=$SD_TEMP_FOLDER/report-${step}.txt
        touch $rep
        runCorb $rep $step
        if [ ! -x "$rep" ];then
            if [ -f "$rep" ];then
                numProcessed=`cat $rep|wc -l`
            else
                numProcessed=0
            fi
        else
            echo "No file [$rep] found!"
        fi
        II "Processed [${numProcessed}] documents with identity. Limit [$SD_IDENTIFY_LIMIT]."
        if [ "$numProcessed" -ne "$SD_IDENTIFY_LIMIT" ];then
            stillProcessing=false
        fi
        test -f $rep && rm $rep
    done
}

######################
# Loop over gather and merge steps until no more duplicates exist
# 
mergeDocuments() {
    # if this step has already been complete, don't execute
    # if less documents are returned tha
    II "Starting merge step (gather & relink)"
    local stepA="2.gather"
    local stepB="3.relink"
    local repA=
    local repB=
    local iter=1
    local stillProcessing=true
    while $stillProcessing;do
        # Gather work list
        repA=$SD_TEMP_FOLDER/report-${stepA}.txt
        touch $repA
        runCorb $repA $stepA

        if [ ! -x "$repA" ];then
            numToProcess=`cat $repA|wc -l`
        else
            numToProcess=0
        fi
        II "Iteration [$iter]. Fragments to merge [${numToProcess}]."
        if [ "$numToProcess" -eq "0" ];then
            stillProcessing=false
        else
            ## Relink those documents ...
            repB=$SD_TEMP_FOLDER/report-${stepB}.txt
            touch $repB
            runCorb $repB $stepB
            # Keep a compressed copy of reports
            repBakA="$repA.$iter"
            repBakB="$repB.$iter"
            mv $repA $repA.$iter
            mv $repB $repB.$iter
            gzip $repA.$iter
            gzip $repB.$iter
        fi
        iter=$(($iter + 1))
    done
}

######################
# Non-mandatory remove unwanted collections in database
# 
cleanupDocuments() {
    # if this step has already been complete, don't execute
    # if less documents are returned tha
    II "Document cleanup step..."
    local stillProcessing=true
    local step="4.cleanup"
    local rep=
    while $stillProcessing;do
        rep=$SD_TEMP_FOLDER/report-${step}.txt
        touch $rep
        runCorb $rep $step
        if [ ! -x "$rep" ];then
            if [ -f "$rep" ];then
                numProcessed=`cat $rep|wc -l`
            else
                numProcessed=0
            fi
        else
            echo "No file [$rep] found!"
        fi
        II "Processed [${numProcessed}] documents with cleanup. Limit [$SD_CLEANUP_LIMIT]."
        if [ "$numProcessed" -ne "$SD_CLEANUP_LIMIT" ];then
            stillProcessing=false
        fi
        test -f $rep && rm $rep
    done
}

main $@