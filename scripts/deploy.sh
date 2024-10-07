#!/bin/bash

if [ ! -d src/ext/corb ];then
    echo "This must be run from top level directory of repo! Exiting."
    exit 1
fi
startTime=`date +%s`
if [ -f "config/variables.sh" ];then
    source config/variables.sh
else
    echo "No env variables found at [config/variables.sh]"
    exit
fi

pdbin=$CS_REPO/src/tools/partial-deploy/pdeploy

# Deploy corb scripts
for f in $(find $SD_DIST_DIR/ext -type f);do
    node $pdbin \
     --server https://admin:admin@localhost:8000 \
     --from $f \
     --to ${f//$SD_DIST_DIR/} \
     --database Modules 2>&1 > /dev/null
done

# Copy over test scripts
for f in $(find $SD_DIST_DIR/test -type f);do
    node $pdbin \
     --server https://admin:admin@localhost:8000 \
     --from $f \
     --to ${f//$SD_DIST_DIR/} \
     --database Modules 2>&1 > /dev/null
done

echo "Deploy complete in $((`date +%s` - $startTime)) seconds"

