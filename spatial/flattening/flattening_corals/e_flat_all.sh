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
## FLAT TABLE
####################################################################################################################################################

# CLEAN OUTPUT TABLE
psql ${dbpar2} -t -c "TRUNCATE TABLE ${SCH}.e_flat_all RESTART IDENTITY;"

# PROCESSING
## SELECT
sql_select=$(cat<<EOF
DROP TABLE IF EXISTS ${SCH}.flat_onprocess;
CREATE TABLE ${SCH}.flat_onprocess AS SELECT qid FROM ${SCH}.z_grid
JOIN
(SELECT qid,nid,complex FROM
(SELECT ROW_NUMBER () OVER () nid,* FROM
(SELECT *,MOD(id,${threads})+1 s FROM
(SELECT ROW_NUMBER () OVER (ORDER BY complex DESC) id,* FROM
(SELECT qid,(COUNT(geom)*SUM(ST_NPoints(geom))) complex FROM
(SELECT qid,geom FROM ${SCH}.dc_tiled_all) a
GROUP BY qid) b) c
ORDER BY s,complex DESC) d) e
ORDER BY nid) f USING (qid);
SELECT qid FROM ${SCH}.flat_onprocess;
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
SELECT qid FROM ${SCH}.flat_onprocess
EOF
)

for ((OFF=0 ; OFF<=${elements}; OFF+=${objects}))
	do
		OBJS=`psql ${dbpar2} -t -c "$sql_execute OFFSET ${OFF} LIMIT ${objects};"`
		for OBJ in ${OBJS}
		do
			echo "start processing tile "${OBJ}
			START_TT1=$(date +%s)
			psql ${dbpar2} -t -c "SELECT ${SCH}.f_flatter('${SCH}.dc_tiled_all','
''corals''
			','${SCH}.e_flat_all',${OBJ});"
			wait
			END_TT1=$(date +%s)
			PARTIAL_DIFF=$(($END_TT1 - $START_TT1))
			echo "end processing tile "${OBJ}" in $PARTIAL_DIFF"
		done &
	done 
wait

psql ${dbpar2} -t -c "UPDATE ${SCH}.e_flat_all
SET valid=(ST_IsValidDetail(geom)).valid,reason=(ST_IsValidDetail(geom)).reason,location=(ST_IsValidDetail(geom)).location
WHERE ST_IsValid(geom) = FALSE;" &
wait
psql ${dbpar2} -t -c "UPDATE ${SCH}.e_flat_all
SET st_geometrytype=ST_GeometryType(geom)
WHERE ST_GeometryType(geom) != 'ST_Polygon';" &
wait

psql ${dbpar2} -t -c "DROP TABLE IF EXISTS ${SCH}.flat_onprocess;"

echo "analysis done"
# stop timer
END_T1=$(date +%s)
TOTAL_DIFF=$(($END_T1 - $START_T1))
echo "TOTAL SCRIPT TIME: $TOTAL_DIFF"
