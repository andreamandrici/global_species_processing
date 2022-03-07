#!/bin/bash
### PLEASE CHECK THE CHANGEME LINES!

####################################################################################################################################################

# TIMER START
START_T1=$(date +%s)

####################################################################################################################################################

# PARAMETERS
source workflow_parameters.conf

outpath=`pwd`"/raster_output"
echo ${outpath}
rm -r -f ${outpath}
echo "removing ${outpath}"
mkdir ${outpath}
mkdir ${outpath}/tiles
echo "creating ${outpath}"

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

# PROCESSING
## SELECT
sql_select=$(cat<<EOF
DROP TABLE IF EXISTS ${SCH}.export_raster_onprocess;
CREATE TABLE ${SCH}.export_raster_onprocess AS
SELECT DISTINCT eid FROM ${SCH}.z_grid WHERE qid IN (SELECT DISTINCT qid FROM ${SCH}.o_raster) ORDER BY eid;
SELECT eid FROM ${SCH}.export_raster_onprocess;
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
SELECT eid FROM ${SCH}.export_raster_onprocess
EOF
)

for ((OFF=0 ; OFF<=${elements}; OFF+=${objects}))
	do
		OBJS=`psql ${dbpar2} -t -c "$sql_execute OFFSET ${OFF} LIMIT ${objects};"`
		for OBJ in ${OBJS}
		do
			echo "processing "${OBJ}
			gdal_translate \
			-co COMPRESS=DEFLATE \
			-co NUM_THREADS=ALL_CPUS \
			-co "TILED=YES" -co BLOCKXSIZE=512 -co BLOCKYSIZE=512 \
			PG:"${dbpar1} schema=${SCH} table=o_raster mode=2 WHERE='qid IN (SELECT qid FROM ${SCH}.z_grid WHERE eid = ${OBJ} ORDER BY qid)'" \
			${outpath}/tiles/${OBJ}.tiff
			echo "processing of "${OBJ}" ended"
		done &
	done 
wait

psql ${dbpar2} -t -c "DROP TABLE IF EXISTS ${SCH}.export_raster_onprocess;"

cd ${outpath}
#find ./tiles/*.tiff | sort -n > list.txt
ls -dv1 ./tiles/*.tiff > list.txt
wait
gdalbuildvrt -input_file_list list.txt raster_output.vrt
wait
gdalinfo -approx_stats raster_output.vrt

psql ${dbpar2} -t -c "\COPY (SELECT * FROM ${SCH}.fb_atts_all) TO '${outpath}/raster_output_attibutes.csv' DELIMITER '|' CSV HEADER;"

echo "analysis done"
# stop timer
END_T1=$(date +%s)
TOTAL_DIFF=$(($END_T1 - $START_T1))
echo "TOTAL SCRIPT TIME: $TOTAL_DIFF"
