#!/bin/bash
### PLEASE CHECK THE CHANGEME LINES!

####################################################################################################################################################

# TIMER START
START_T1=$(date +%s)

####################################################################################################################################################

# PARAMETERS
source workflow_parameters.conf
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
## TILED TABLES
####################################################################################################################################################
TOPIC_T=${TOPIC_1}

# CLEAN OUTPUT TABLES
psql ${dbpar2} -t -c "TRUNCATE TABLE ${SCH}.da_tiled_${TOPIC_T} RESTART IDENTITY;"

# PROCESSING
## SELECT
sql_select=$(cat<<EOF
DROP TABLE IF EXISTS ${SCH}.tiled_${TOPIC_T}_onprocess;
CREATE TABLE ${SCH}.tiled_${TOPIC_T}_onprocess AS SELECT qid,complex,nid FROM ${SCH}.z_grid
JOIN
(SELECT qid,nid,complex FROM
(SELECT ROW_NUMBER () OVER () nid,* FROM
(SELECT *,MOD(id,${threads})+1 s FROM
(SELECT ROW_NUMBER () OVER (ORDER BY complex DESC) id,* FROM
(SELECT qid,(COUNT(geom)*SUM(ST_NPoints(geom))) complex FROM
(SELECT qid,geom FROM ${SCH}.c_raster_${TOPIC_T}) a
GROUP BY qid) b) c
ORDER BY s,complex DESC) d) e
ORDER BY nid) f USING (qid);

SELECT qid FROM ${SCH}.tiled_${TOPIC_T}_onprocess;
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
SELECT qid FROM ${SCH}.tiled_${TOPIC_T}_onprocess
EOF
)

for ((OFF=0 ; OFF<=${elements}; OFF+=${objects}))
	do
		OBJS=`psql ${dbpar2} -t -c "$sql_execute OFFSET ${OFF} LIMIT ${objects};"`
		for OBJ in ${OBJS}
		do
			echo "start processing tile "${OBJ}
			START_TT1=$(date +%s)
			psql ${dbpar2} -t -c "SELECT ${SCH}.f_pop_tiled('${SCH}.da_tiled_${TOPIC_T}','${SCH}.c_raster_${TOPIC_T}',${OBJ});"
			wait
			END_TT1=$(date +%s)
			PARTIAL_DIFF=$(($END_TT1 - $START_TT1))
			echo "end processing tile "${OBJ}" in $PARTIAL_DIFF"
		done &
	done 
wait

psql ${dbpar2} -t -c "UPDATE ${SCH}.da_tiled_${TOPIC_T}
SET valid=(ST_IsValidDetail(geom)).valid,reason=(ST_IsValidDetail(geom)).reason,location=(ST_IsValidDetail(geom)).location
WHERE ST_IsValid(geom) = FALSE;" &
wait
psql ${dbpar2} -t -c "UPDATE ${SCH}.da_tiled_${TOPIC_T}
SET st_geometrytype=ST_GeometryType(geom)
WHERE ST_GeometryType(geom) != 'ST_Polygon';" &
wait
psql ${dbpar2} -t -c "UPDATE ${SCH}.da_tiled_${TOPIC_T}
SET sqkm=(ST_Area(geom::geography)/1000000)
WHERE valid IS NULL AND st_geometrytype IS NULL;" &
wait

psql ${dbpar2} -t -c "DROP TABLE IF EXISTS ${SCH}.tiled_${TOPIC_T}_onprocess;"

echo "analysis done"
# stop timer
END_T1=$(date +%s)
TOTAL_DIFF=$(($END_T1 - $START_T1))
echo "TOTAL SCRIPT TIME: $TOTAL_DIFF"
