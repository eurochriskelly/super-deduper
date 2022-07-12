#!/bin/bash
# to be run from scripts dir!

if [ ! -d src/ext/corb ];then
    echo "This must be run from top level directory of repo! Exiting."
    exit 1
fi

startTime=`date +%s`

source config/variables.sh

if [ -d "$SD_DIST_DIR" ];then rm -rf "$SD_DIST_DIR";fi

mkdir -p $SD_DIST_DIR/$SD_ML_BASE_PATH
mkdir -p $SD_DIST_DIR/config
mkdir -p $SD_DIST_DIR/test/sd
cp -r src/ext/corb/dedupe/* $SD_DIST_DIR/$SD_ML_BASE_PATH
cp -r test/data/* $SD_DIST_DIR/test/sd/
cp config/variable*.sh $SD_DIST_DIR/config/
cp src/dedupe.sh $SD_DIST_DIR/

for f in $(find $SD_DIST_DIR/$SD_ML_BASE_PATH -name "*.properties");do
    mv $f "$SD_DIST_DIR/config"/`basename $(dirname $f)`.properties &
done

wait < <(jobs -p)

## REPLACE VARIABLES IN MODULES
vars=$(cat config/variables.sh | grep "^export"| awk '{print $2}' | awk -F= '{print $1}')
replaceInFile() {
    local f=$1
    for v in $vars;do
        val=${!v}
        sed -i "s/%$v%/${val//\//\\/}/g" $f
    done
}
for f in $(find $SD_DIST_DIR -type f);do
    replaceInFile $f &
done

wait < <(jobs -p)

echo "Build complete in $((`date +%s` - $startTime)) seconds"