
			wait			
			END_TT1=$(date +%s)
			PARTIAL_DIFF=$(($END_TT1 - $START_TT1))
			echo "end processing tile "${OBJ}" in $PARTIAL_DIFF"
		done &
	done 
wait
psql ${dbpar2} -t -c "TRUNCATE TABLE ${SCH}.dc_tiled_all RESTART IDENTITY;"
psql ${dbpar2} -t -c "INSERT INTO ${SCH}.dc_tiled_all(qid,fid,source,geom,sqkm) SELECT * FROM ${SCH}.db_tiled_temp ORDER BY qid,source,fid;"
psql ${dbpar2} -t -c "DROP TABLE IF EXISTS ${SCH}.tiled_all_onprocess;"

echo "analysis done"
# stop timer
END_T1=$(date +%s)
TOTAL_DIFF=$(($END_T1 - $START_T1))
echo "TOTAL SCRIPT TIME: $TOTAL_DIFF"
