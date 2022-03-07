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
