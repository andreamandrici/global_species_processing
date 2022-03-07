#!/bin/bash

## EXECUTE IT AS ./z_do_it_all.sh > logs/z_do_it_all_log.txt 2>&1 &

# TIMER START
START_T1=$(date +%s)

# set number of dedicated cores for all the subscripts
ncores=140

# PRE RUN
#------------------------------------------------------------------------

## OPTIONAL - MAKE A BACKUP
## drops the previous backup, and MOVES the working schema as backup
#./x_backup_script.sh > logs/x_backup_script_log.txt 2>&1 wait 

# CREATE ALL INFRASTRUCTURE
## drops (if exists) and creates processing schema,tables and functions, evaluating dynamically parameters defined in workflow parameters
#./00_create_infrastructure.sh > logs/00_create_infrastructure_log.txt 2>&1 wait

# OPTIONAL - SETUP A FILTER ON TILE NUMBERS
## filters the grid by qid (setting FALSE qfilter field in the grid) - set parameters in THIS script!
#./01_create_filter.sh > logs/01_create_filter_log.txt 2>&1 wait

# OPTIONAL - RESTORE A BACKUP
## MOVES tables from backup to working schema - set parameters in THIS script!
#./y_restore_script.sh > logs/y_restore_script_log.txt 2>&1 wait 
 
# FOR EACH INPUT TOPIC
#------------------------------------------------------------------------

# A-INPUT TABLES
## populates input tables
#./a_input_corals.sh ${ncores} > logs/a_input_corals_log.txt 2>&1 wait

# B-CLIP TABLES
## populates clip tables
./b_clip_corals.sh ${ncores} > logs/b_clip_corals_log.txt 2>&1 wait

# C-RASTER TABLES
## populates raster tables
./c_rast_corals.sh ${ncores} > logs/c_raster_corals_log.txt 2>&1 wait

# D-TILED TABLES
## DA-populates tiled tables (in parallel)
./da_tiled_corals.sh ${ncores} > logs/da_tiled_corals_log.txt 2>&1 wait

## FOR AGGREGATED INPUTS
##------------------------------------------------------------------------

### DB-populates tiled tables (single core)
./db_tiled_all.sh ${ncores} > logs/db_tiled_all_log.txt 2>&1 wait

## E-FLAT TABLE
### populates flat_all table
./e_flat_all.sh ${ncores} > logs/e_flat_all_log.txt 2>&1 wait

## F-ATTRIBUTE TABLE
#### populates atts_tile, THEN atts_all tables
./f_attributes_all.sh ${ncores} > logs/f_attributes_all_log.txt 2>&1 wait

# FLAT_TEMP
## populates flat_temp
./g_final_all.sh ${ncores} > logs/g_final_all_log.txt 2>&1 wait

# FLAT_FINAL
## populates flat
./h_output.sh > logs/h_output_log.txt 2>&1 wait

# RAST_FINAL
## populates output rast
./o_raster.sh ${ncores} > logs/o_raster_log.txt 2>&1 wait

## export rast
./p_export_raster.sh $((ncores/3)) > logs/p_export_raster_log.txt 2>&1 wait

# USEFUL COMMANDS
#------------------------------------------------------------------------

# READ LOGS
### lists completed
# less e_flat_all_log.txt | grep " in "

### counts completed
# less e_flat_all_log.txt | grep " in " | wc -l

### shows the end of the process
# tail -n 30 e_flat_all_log.txt

# stop timer
END_T1=$(date +%s)
TOTAL_DIFF=$(($END_T1 - $START_T1))
echo "TOTAL SCRIPT TIME: $TOTAL_DIFF"
echo "analysis end"
exit
