#!/bin/bash
### PLEASE CHECK THE CHANGEME LINES!

####################################################################################################################################################

# TIMER START
START_T1=$(date +%s)

####################################################################################################################################################

# PARAMETERS
source workflow_parameters.conf

BIT=`psql ${dbpar2} -t -c "SELECT
CASE
WHEN  MAX(cid) <= 255 THEN '8BUI'::text
WHEN  MAX(cid) > 255 AND  MAX(cid) <= 65536 THEN '16BUI'::text
WHEN  MAX(cid) > 65536 THEN '32BUI'::text
END pixel_type
FROM ${SCH}.h_flat;"`

echo ${BIT}

threads=$1
####################################################################################################################################################

# INSTRUCTIONS
Usage () {
    echo "
This script will parallelize postgis processing. Execute it as:
time ./command_name.sh 72 > logs/command_name_log.txt 2>&1
"
}
####################################################################################################################################################
## ATTRIBUTE TILE TABLES
####################################################################################################################################################
# CLEAN OUTPUT TABLES
psql ${dbpar2} -t -c "TRUNCATE TABLE ${SCH}.o_raster RESTART IDENTITY;"

# PROCESSING
## SELECT
sql_select=$(cat<<EOF
DROP TABLE IF EXISTS ${SCH}.o_raster_onprocess;
CREATE TABLE ${SCH}.o_raster_onprocess AS SELECT qid FROM ${SCH}.z_grid
JOIN
(SELECT qid,nid,complex FROM
(SELECT ROW_NUMBER () OVER () nid,* FROM
(SELECT *,MOD(id,${threads})+1 s FROM
(SELECT ROW_NUMBER () OVER (ORDER BY complex DESC) id,* FROM
(SELECT qid,(COUNT(cid)) complex FROM
(SELECT qid,cid FROM ${SCH}.h_flat) a
GROUP BY qid) b) c
ORDER BY s,complex DESC) d) e
ORDER BY nid) f USING (qid);
SELECT qid FROM ${SCH}.o_raster_onprocess;
EOF
)

## LIST
list=`psql ${dbpar2} -t -c "$sql_select"`
arr=(${list})
elements="${#arr[@]}"
objects=$((elements/threads))
if (( ${objects} == 0))
then
objects=1
fi

echo "number of elements: "${elements}
echo "number of objects in each step: "${objects}
echo "number of dedicated threads: "${threads}

## EXECUTE
sql_execute=$(cat<<EOF
SELECT qid FROM ${SCH}.o_raster_onprocess
EOF
)

for ((OFF=0 ; OFF<=${elements}; OFF+=${objects}))
	do
		OBJS=`psql ${dbpar2} -t -c "$sql_execute OFFSET ${OFF} LIMIT ${objects};"`
		for OBJ in ${OBJS}
		do
			echo "start processing tile "${OBJ}
			START_TT1=$(date +%s)
			psql ${dbpar2} -t -c "SELECT ${SCH}.f_pop_o_raster(${OBJ},'${BIT}');"
			wait
			END_TT1=$(date +%s)
			PARTIAL_DIFF=$(($END_TT1 - $START_TT1))
			echo "end processing tile "${OBJ}" in $PARTIAL_DIFF"
		done &
	done 
wait

psql ${dbpar2} -t -c "DROP TABLE IF EXISTS ${SCH}.o_raster_onprocess;"

echo "analysis done"
# stop timer
END_T1=$(date +%s)
TOTAL_DIFF=$(($END_T1 - $START_T1))
echo "TOTAL SCRIPT TIME: $TOTAL_DIFF"
