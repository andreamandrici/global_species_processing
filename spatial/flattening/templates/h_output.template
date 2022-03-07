#!/bin/bash
### PLEASE CHECK THE CHANGEME LINES!

####################################################################################################################################################

# TIMER START
START_T1=$(date +%s)

####################################################################################################################################################

# PARAMETERS
source workflow_parameters.conf
####################################################################################################################################################

# INSTRUCTIONS
Usage () {
    echo "
This script will parallelize postgis processing. Execute it as:
time ./command_name.sh > logs/command_name_log.txt 2>&1
"
}
####################################################################################################################################################
## ATTRIBUTE TILE TABLES
####################################################################################################################################################
REORDERS_F="REORDERS_T"

# CLEAN OUTPUT TABLES

psql ${dbpar2} -t -c "
TRUNCATE TABLE ${SCH}.h_flat RESTART IDENTITY;
INSERT INTO ${SCH}.h_flat SELECT qid,cid,geom,
${REORDERS_F}
,sqkm FROM ${SCH}.g_flat_temp ORDER BY qid,cid;"

echo "analysis done"
# stop timer
END_T1=$(date +%s)
TOTAL_DIFF=$(($END_T1 - $START_T1))
echo "TOTAL SCRIPT TIME: $TOTAL_DIFF"
