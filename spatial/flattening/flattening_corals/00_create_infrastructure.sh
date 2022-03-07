#!/bin/bash
####################################################################################################################################################

# TIMER START
START_T1=$(date +%s)

####################################################################################################################################################

# PARAMETERS
source workflow_parameters.conf

####################################################################################################################################################
# START PROCESSING SCHEMA
####################################################################################################################################################
# maybe with a little of care...
psql ${dbpar2} -t -c "DROP SCHEMA IF EXISTS ${SCH} CASCADE; CREATE SCHEMA ${SCH};"
####################################################################################################################################################
# END PROCESSING SCHEMA
####################################################################################################################################################

####################################################################################################################################################
# START RECURSIVE PART (loop for number of topics)
####################################################################################################################################################

echo "NUMBER OF TOPICS ${TOPICS}"

for (( i = 1; i <= ${TOPICS};  i++))

do
   echo "processing topic ${i}"
   TOPIC="TOPIC_$i"
   
   echo "Topic $i is ${!TOPIC}"

FIELDS+=",${!TOPIC}  integer[]"

ORDERS+=",${!TOPIC}"

INDEX_FLAT+="CREATE INDEX ON ${SCH}.h_flat USING GIN(${!TOPIC});
"

L_ATTS_AGG_JOINS+="LEFT JOIN (SELECT qid,tid,ARRAY_AGG(DISTINCT fid ORDER BY fid) ${!TOPIC} FROM atts_tile WHERE source='${!TOPIC}' GROUP BY qid,tid) ${!TOPIC} USING(qid,tid)
"

L_ATTS_AGG_UPD+="UPDATE atts_tile_agg SET ${!TOPIC} = ARRAY[0] WHERE ${!TOPIC} IS NULL;
"

UNIONS+=" UNION ALL SELECT qid,geom FROM ${SCH}.da_tiled_${!TOPIC}"

POPS+="wait\npsql \${dbpar2} -t -c \"SELECT \${SCH}.f_pop_tiled_temp(\${OBJ},'\${SCH}','${!TOPIC}');\"\n"

FLAT+=",''${!TOPIC}''"


rm a_input_${!TOPIC}.sh
cat ./templates/a_input_topic.template > a_input_${!TOPIC}.sh
rm b_clip_${!TOPIC}.sh
cat ./templates/b_clip_topic.template > b_clip_${!TOPIC}.sh
rm c_rast_${!TOPIC}.sh
cat ./templates/c_rast_topic.template > c_rast_${!TOPIC}.sh
rm da_tiled_${!TOPIC}.sh
cat ./templates/da_tiled_topic.template > da_tiled_${!TOPIC}.sh

sed -i 's/THISTOPIC/'"${TOPIC}"'/' a_input_${!TOPIC}.sh
sed -i 's/THISTOPIC/'"${TOPIC}"'/' b_clip_${!TOPIC}.sh
sed -i 's/THISTOPIC/'"${TOPIC}"'/' c_rast_${!TOPIC}.sh
sed -i 's/THISTOPIC/'"${TOPIC}"'/' da_tiled_${!TOPIC}.sh

chmod +x a_input_${!TOPIC}.sh
chmod +x b_clip_${!TOPIC}.sh
chmod +x c_rast_${!TOPIC}.sh
chmod +x da_tiled_${!TOPIC}.sh


####################################################################################################################################################
## START TOPIC TABLES
####################################################################################################################################################

####################################################################################################################################################
### START PREPARING TOPIC TABLES
####################################################################################################################################################

# TABLE INPUT TOPIC PREPARATION
sql_input_topic=$(cat<<EOF
DROP TABLE IF EXISTS ${SCH}.a_input_${!TOPIC};
CREATE TABLE ${SCH}.a_input_${!TOPIC}
(
    tid serial PRIMARY KEY,
	fid integer,
    path integer,
    geom geometry,
    valid boolean,
    reason character varying,
    location geometry,
    st_geometrytype text
);
CREATE INDEX ON ${SCH}.a_input_${!TOPIC} USING GIST(geom);
EOF
)

# TABLE CLIP TOPIC PREPARATION
sql_clip_topic=$(cat<<EOF
DROP TABLE IF EXISTS ${SCH}.b_clip_${!TOPIC};
CREATE TABLE ${SCH}.b_clip_${!TOPIC}
(
	tid serial PRIMARY KEY,
    qid integer,
	fid integer,
	path integer,
    geom geometry,
    valid boolean,
    reason character varying,
    location geometry,
    st_geometrytype text
);
CREATE INDEX ON ${SCH}.b_clip_${!TOPIC} USING GIST(geom);
EOF
)

# TABLE RASTER TOPIC PREPARATION
sql_raster_topic=$(cat<<EOF
DROP TABLE IF EXISTS ${SCH}.c_raster_${!TOPIC};
CREATE TABLE ${SCH}.c_raster_${!TOPIC}
(
	rid serial PRIMARY KEY,
    qid integer,
	fid integer,
	rast raster,
	geom geometry
);
CREATE INDEX ON ${SCH}.c_raster_${!TOPIC} USING gist(ST_ConvexHull(rast));
CREATE INDEX ON ${SCH}.c_raster_${!TOPIC} USING gist(geom);
EOF
)

# TABLE TILED TOPIC PREPARATION
sql_tiled_topic=$(cat<<EOF
DROP TABLE IF EXISTS ${SCH}.da_tiled_${!TOPIC};
CREATE TABLE ${SCH}.da_tiled_${!TOPIC}
(
    tid serial PRIMARY KEY,
    qid integer,
    fid integer,
    path integer,
    geom geometry,
	sqkm double precision,
    valid boolean,
    reason character varying,
    location geometry,
    st_geometrytype text
);
CREATE INDEX ON ${SCH}.da_tiled_${!TOPIC} USING GIST(geom);
EOF
)

# TABLE OUTPUT RASTER TOPIC PREPARATION
sql_output_raster=$(cat<<EOF
DROP TABLE IF EXISTS ${SCH}.o_raster;
CREATE TABLE ${SCH}.o_raster
(
    qid integer PRIMARY KEY,
	rast raster
);
CREATE INDEX ON ${SCH}.o_raster USING gist(ST_ConvexHull(rast));
EOF
)

####################################################################################################################################################
### END PREPARING TOPIC TABLES
####################################################################################################################################################

####################################################################################################################################################
### START CREATING TOPIC TABLES
####################################################################################################################################################

# TABLE INPUT TOPIC CREATION
psql ${dbpar2} -c "$sql_input_topic"

# TABLE CLIP TOPIC CREATION
psql ${dbpar2} -c "$sql_clip_topic"

# TABLE RASTER TOPIC CREATION
psql ${dbpar2} -c "$sql_raster_topic"

# TABLE TILED TOPIC CREATION
psql ${dbpar2} -c "$sql_tiled_topic"

# TABLE OUTPUT RASTER CREATION
psql ${dbpar2} -c "$sql_output_raster"

done

####################################################################################################################################################
### END PREPARING TOPIC TABLES
####################################################################################################################################################

####################################################################################################################################################
## END TOPIC TABLES
####################################################################################################################################################

####################################################################################################################################################
# END RECURSIVE PART (loop for number of topics)
####################################################################################################################################################

####################################################################################################################################################
# START STATIC PART 
####################################################################################################################################################

REFIELDS=${FIELDS:1}
REORDERS=${ORDERS:1}
REUNIONS=${UNIONS:11}
REPOPS=${POPS:4}
REFLAT=${FLAT:1}
####################################################################################################################################################
## START FUNCTIONS
####################################################################################################################################################

####################################################################################################################################################
### START PREPARING FUNCTIONS
####################################################################################################################################################

# FUNCTION FISHNET PREPARATION
sql_fishnet=$(cat<<EOF
DROP FUNCTION IF EXISTS ${SCH}.st_createfishnet(integer,integer,double precision,double precision,double precision,double precision);
CREATE OR REPLACE FUNCTION ${SCH}.st_createfishnet(
	nrow integer,
	ncol integer,
	xsize double precision,
	ysize double precision,
	x0 double precision DEFAULT 0,
	y0 double precision DEFAULT 0,
	OUT "row" integer,
	OUT col integer,
	OUT geom geometry)
    RETURNS SETOF record 
    LANGUAGE 'sql'
AS \$BODY\$

SELECT i + 1 AS row, j + 1 AS col, ST_Translate(cell, j * \$3 + \$5, i * \$4 + \$6) AS geom
FROM generate_series(0, \$1 - 1) AS i,
generate_series(0, \$2 - 1) AS j,
(
SELECT ('POLYGON((0 0, 0 '||\$4||', '||\$3||' '||\$4||', '||\$3||' 0,0 0))')::geometry AS cell
) AS foo;
\$BODY\$;
EOF
)

# FUNCTION POPULATE_Z_GRID PREPARATION
sql_f_pop_z_grid=$(cat<<EOF
DROP FUNCTION IF EXISTS ${SCH}.f_pop_z_grid();
CREATE FUNCTION ${SCH}.f_pop_z_grid ()
    RETURNS void
    LANGUAGE 'plpgsql'
AS \$BODY\$

BEGIN

INSERT INTO ${SCH}.z_grid(row,col,geom)
SELECT
row,
col,
geom
FROM (SELECT row,col,ST_SetSrid(geom,4326) geom FROM ${SCH}.ST_CreateFishnet(${RWS},${CLS},${GS},${GS},-180,-90) cells
ORDER BY row,col) v;
END;
\$BODY\$;

COMMENT ON FUNCTION ${SCH}.f_pop_z_grid() IS
'Populates grid table; no inputs parameters'
EOF
)

# FUNCTION POPULATE_O_GRID PREPARATION
sql_f_pop_o_grid=$(cat<<EOF
DROP FUNCTION IF EXISTS ${SCH}.f_pop_o_grid();
CREATE FUNCTION ${SCH}.f_pop_o_grid ()
    RETURNS void
    LANGUAGE 'plpgsql'
AS \$BODY\$

BEGIN

INSERT INTO ${SCH}.o_grid(row,col,geom)
SELECT
row,
col,
geom
FROM (SELECT row,col,ST_SetSrid(geom,4326) geom FROM ${SCH}.ST_CreateFishnet(${RWS}/10,${CLS}/10,${GS}*10,${GS}*10,-180,-90) cells
ORDER BY row,col) v;
END;
\$BODY\$;

COMMENT ON FUNCTION ${SCH}.f_pop_o_grid() IS
'Populates output grid table; no inputs parameters'
EOF
)

# FUNCTION POPULATE INPUT PREPARATION
sql_f_pop_input=$(cat<<EOF
DROP FUNCTION IF EXISTS ${SCH}.f_pop_input(text,text,text,integer);
CREATE OR REPLACE FUNCTION ${SCH}.f_pop_input(
	otbl text,
	ifld text,
	itbl text,
	ifid integer)
    RETURNS void
    LANGUAGE 'plpgsql'
AS \$BODY\$

BEGIN

EXECUTE FORMAT ('
INSERT INTO %s (fid,path,geom)
SELECT fid,UNNEST(path) path,geom
FROM (SELECT %s fid,(ST_DUMP(ST_MULTI(geom))).* FROM %s WHERE %s=%s) a ORDER BY path',otbl,ifld,itbl,ifld,ifid);

END;
\$BODY\$;

COMMENT ON FUNCTION ${SCH}.f_pop_input(text,text,text,integer)
IS 'Populates input tables;inputs parameters are:
otbl - text - output table - ''schema_name.table_name'';
ifld - text - numeric field name from input table - ''field_name'';
itbl - text - input table - ''schema_name.table_name'';
ifid - integer - numeric value from input table as selector for the row - number;
eg: ''cep_processing.input_wdpa'',''wdpaid'',''protected_sites.wdpa_201911'',32671 will:
write to cep_processing.input_wdpa table - use wdpaid as fid - read from protected_sites.wdpa_201911 table,selecting row where wdpaid=32671';
EOF
)

# FUNCTION CLIP PREPARATION
sql_f_clip=$(cat<<EOF
DROP FUNCTION IF EXISTS ${SCH}.f_clip(text, text, integer);
CREATE OR REPLACE FUNCTION ${SCH}.f_clip(
	itbl text,
	otbl text,
	iqid integer)
    RETURNS void
    LANGUAGE 'plpgsql'
AS \$BODY\$
DECLARE
ttile GEOMETRY := (SELECT geom FROM ${SCH}.z_grid WHERE qid=iqid);
rec record;
BEGIN
DROP TABLE IF EXISTS iselect;
EXECUTE FORMAT ('CREATE TEMPORARY TABLE iselect AS SELECT fid,ST_COLLECT(geom) geom FROM %s WHERE ST_INTERSECTS(geom,%L) GROUP BY fid ORDER BY fid;',itbl,ttile);
CREATE INDEX ON iselect USING GIST(geom);
DROP TABLE IF EXISTS iout;
CREATE TEMPORARY TABLE iout (fid integer,path integer,geom geometry);
IF
	((SELECT count(fid) FROM iselect)=1 AND (SELECT ST_WITHIN(ttile,geom) FROM iselect) IS TRUE)
THEN
	INSERT INTO iout SELECT fid,1 path,ttile geom FROM iselect;
ELSE
	FOR rec IN SELECT fid,geom FROM iselect ORDER BY fid
	LOOP
	BEGIN
	INSERT INTO iout
	SELECT fid,UNNEST(path) path,geom FROM (SELECT fid,(ST_DUMP(ST_MULTI(geom))).* FROM (SELECT fid,ST_INTERSECTION(ttile,geom) geom FROM iselect WHERE fid=rec.fid) c) d;
	EXCEPTION
	WHEN OTHERS THEN
	INSERT INTO iout
	SELECT fid,UNNEST(path) path,geom FROM (SELECT fid,(ST_DUMP(ST_MULTI(geom))).* FROM (SELECT fid,ST_INTERSECTION(ttile,st_buffer(geom,0)) geom FROM iselect WHERE fid=rec.fid) c) d;
	END;
	END LOOP;
END IF;
EXECUTE FORMAT ('INSERT INTO %s(qid,fid,path,geom) SELECT %s,* FROM iout order by fid,path;',otbl,iqid);
END;
\$BODY\$;
COMMENT ON FUNCTION ${SCH}.f_clip(text,text,integer) IS
'Clips input with a tile; inputs parameters are:
itbl - text - input table - ''schema_name.table_name'';
otbl - text - output table - ''schema_name.table_name'';
iqid - integer - unique id for the tile - number;
eg: ''cep_processing.input_wdpa'',''cep_processing.output_wdpa'',44378 will:
read from cep_processing.input_wdpa table - write to cep_processing.clip_wdpa table - clipping all wdpa geometries intersecting tile number 44378 from cep_processing.z_grid.';
EOF
)

# FUNCTION RASTER_1_ARCSEC PREPARATION
sql_f_raster=$(cat<<EOF
DROP FUNCTION IF EXISTS ${SCH}.f_raster(integer,text,text);
CREATE OR REPLACE FUNCTION ${SCH}.f_raster(iqid integer,ischema text,itable text)
    RETURNS void
    LANGUAGE 'plpgsql'
AS \$BODY\$
DECLARE
sql text;
BEGIN
sql :='
INSERT INTO '||ischema||'.c_raster_'||itable||'(qid,fid,rast)
SELECT '||iqid||',fid,rast
FROM (SELECT fid,ST_AsRaster(geom,rast,''1BB'',1,0) rast
FROM (SELECT fid,ST_COLLECT(geom::geometry(Polygon,4326)) geom FROM '||ischema||'.b_clip_'||itable||' WHERE qid='||iqid||' AND valid IS NULL and st_geometrytype IS NULL
GROUP BY fid ORDER BY fid) a,
(SELECT ST_MakeEmptyRaster(${RCCT},${RCCT},-180,90,(1/${RCC}::double precision),(-1/${RCC}::double precision),0,0,4326) rast) b
ORDER BY fid) c;
UPDATE '||ischema||'.c_raster_'||itable||' SET geom = (SELECT ST_Polygon(rast) geom) WHERE qid='||iqid||';';
EXECUTE sql USING iqid,ischema,itable;
END;
\$BODY\$;
COMMENT ON FUNCTION ${SCH}.f_raster(integer,text,text) IS
'rasterize clip tables by tile/fid, then vectorize by tile/fid as MultiGeometry;inputs parameters are:
iqid - integer - input qid: tile unique id - number;
ischema - text - processing schema - ''schema_name'';
itable - text - input table (actually country,ecoregion,wdpa, without the root ''clip'', which is automatically added by the function) - ''table_name'';
eg: SELECT cep_processing.f_raster(18001,''cep_processing'',''wdpa'') will:
write to cep_processing.raster_wdpa table - read from cep_processing.clip_wdpa table,selecting all rows where qid=18001';
EOF
)

# FUNCTION POPULATE TILED PREPARATION
sql_f_pop_tiled=$(cat<<EOF
DROP FUNCTION IF EXISTS ${SCH}.f_pop_tiled(text,text,integer);
CREATE OR REPLACE FUNCTION ${SCH}.f_pop_tiled(
	otbl text,
	itbl text,
	iqid integer)
    RETURNS void
    LANGUAGE 'plpgsql'
AS \$BODY\$

BEGIN

EXECUTE FORMAT ('
INSERT INTO %s (qid,fid,path,geom)
SELECT qid,fid,UNNEST(path) path,geom 
FROM (SELECT qid,fid,(ST_DUMP(ST_MULTI(geom))).* FROM %s WHERE qid=%s) a ORDER BY qid,fid,path',otbl,itbl,iqid);

END;
\$BODY\$;

COMMENT ON FUNCTION ${SCH}.f_pop_tiled(text,text,integer)
IS 'Populates tiled tables;input parameters are:
otbl - text - output table - ''schema_name.table_name'';
itbl - text - input (tiled) table - ''schema_name.table_name'';
iqid - integer - numeric value from tiled table as selector for the row - number;
eg: ''cep_processing.tiled_wdpa'',''cep_processing.raster_wdpa'',100 will:
write to cep_processing.tiled_wdpa table - read from protected_sites.raster_wdpa table,selecting row where qid=100';
EOF
)

# FUNCTION POPULATE TILED_TEMP PREPARATION
sql_f_pop_tiled_temp=$(cat<<EOF
DROP FUNCTION IF EXISTS ${SCH}.f_pop_tiled_temp(integer,text,text);
CREATE OR REPLACE FUNCTION ${SCH}.f_pop_tiled_temp(iqid integer,ischema text,itable text)
    RETURNS void
    LANGUAGE 'plpgsql'
AS \$BODY\$

DECLARE
sql text;

BEGIN

sql :='
INSERT INTO '||ischema||'.db_tiled_temp(qid,fid,source,geom,sqkm)
SELECT '||iqid||' qid,fid,'''||itable||''' source,geom,sqkm
FROM '||ischema||'.da_tiled_'||itable||' WHERE qid='||iqid||' AND valid IS NULL and st_geometrytype IS NULL;';
EXECUTE sql USING iqid,ischema,itable;

END;
\$BODY\$;

COMMENT ON FUNCTION ${SCH}.f_pop_tiled_temp(integer,text,text) IS 
'populates tiled_temp table; inputs parameters are:
iqid - integer - input qid: tile unique id - number;
ischema - text - processing schema - ''schema_name'';
itable - text - input table (actually country,ecoregion,wdpa, without the root ''clip'', which is automatically added by the function) - ''table_name'';
eg: (18001,''cep_processing'',''wdpa'') will:
write to cep_processing.tiled_all table - read from cep_processing.tiled_wdpa table,selecting all rows where qid=18001';
EOF
)

# FUNCTION FLATTER PREPARATION
sql_f_flatter=$(cat<<EOF
DROP FUNCTION IF EXISTS ${SCH}.f_flatter(text,text,text,integer);
CREATE OR REPLACE FUNCTION ${SCH}.f_flatter(
	itbl text,
	isou text,
	otbl text,
	iqid integer)
    RETURNS void
    LANGUAGE 'plpgsql'
AS \$BODY\$

BEGIN
DROP TABLE IF EXISTS tile_objects;
CREATE TEMPORARY TABLE tile_objects (geom geometry);
EXECUTE FORMAT ('INSERT INTO tile_objects SELECT DISTINCT geom FROM %s WHERE qid=%s AND source IN (%s)',itbl,iqid,isou);

DROP TABLE IF EXISTS flat_objects;
CREATE TEMPORARY TABLE flat_objects (tid bigint,geom geometry,point geometry);

----NEXT IS BROKEN ON POSTGIS: BUG ON ST_AREA for GEOGRAPHY
--IF ((SELECT COUNT(geom) FROM tile_objects)=1 AND (SELECT ST_AREA(geom::geography) FROM tile_objects) > 0)
----NEXT REPLACE THE PREVIOUS UNTIL POSTGIS BUG ST_AREA FOR GEOGRAPHY IS FIXED
IF ((SELECT COUNT(geom) FROM tile_objects)=1 AND (SELECT ST_AREA(ST_TRANSFORM(geom,54009))/1000000 FROM tile_objects) > 0)
THEN
	INSERT INTO flat_objects(tid,geom) SELECT 1::bigint tid,geom FROM tile_objects;
ELSE
	INSERT INTO flat_objects(tid,geom)
	SELECT ROW_NUMBER () OVER () tid,geom FROM 
	(SELECT (ST_DUMP(ST_POLYGONIZE(DISTINCT geom))).geom
	FROM (SELECT (ST_DUMP(geom)).geom
	FROM (SELECT (st_linemerge(st_union(ST_Boundary(geom)))) geom
	FROM tile_objects
	) a) b ) c
----NEXT IS BROKEN ON POSTGIS: BUG ON ST_AREA for GEOGRAPHY
--	WHERE ST_AREA(geom::geography) > 0;
----NEXT REPLACE THE PREVIOUS UNTIL POSTGIS BUG ST_AREA FOR GEOGRAPHY IS FIXED
	WHERE ST_AREA(ST_TRANSFORM(geom,54009))/1000000 > 0;
END IF;

UPDATE flat_objects SET point = ST_PointOnSurface(b.geom) FROM (SELECT tid,(ST_DUMP(ST_BUFFER(geom,-0.000001))).geom FROM flat_objects) b WHERE flat_objects.tid=b.tid;
EXECUTE FORMAT ('INSERT INTO %s(qid,tid,geom,point) SELECT %s,ROW_NUMBER () OVER () tid,geom,point FROM flat_objects WHERE point IS NOT NULL',otbl,iqid);

END;
\$BODY\$;

COMMENT ON FUNCTION ${SCH}.f_flatter(text,text,text,integer)
IS 'flat tiled tables;input parameters are:
itbl - text - input (tiled) table - ''schema_name.table_name'';
isou - text - filter on source in tiled tables - ''source1,source2,sourcen...'' take care of single quotes! 3 at opening/closing, 2 at commas!;
otbl - text - output table - ''schema_name.table_name'';
iqid - integer - numeric value from tiled table as selector for the row - number;
eg: SELECT cep_processing.f_flatter(''cep_processing.tiled_all'',''''country'',''ecoregion'',''wdpa'''',''cep_processing.flat_all'',47714) will:
read from cep_processing.tiled_all table, including the rows where source is country, ecoregion or wdpa, selecting rows where qid=47714 - write to cep_processing.flat_all table';
EOF
)

# following functions use variables defined in the topic loop above
echo "creating function using variables defined in the topic loop"

# FUNCTION ATTRIBUTE TILE PREPARATION
sql_f_pop_atts_tile=$(cat<<EOF
DROP FUNCTION IF EXISTS ${SCH}.f_pop_atts_tile(integer);
CREATE OR REPLACE FUNCTION ${SCH}.f_pop_atts_tile(iqid integer)
    RETURNS void
    LANGUAGE 'plpgsql'
AS \$BODY\$

BEGIN

DROP TABLE IF EXISTS atts_tile;
CREATE TEMPORARY TABLE atts_tile AS
SELECT qid,a.tid,source,fid FROM ${SCH}.e_flat_all a
JOIN ${SCH}.dc_tiled_all b USING(qid)
---- THE FOLLOWING IS REPLACED WITH THE NEXT
-- WHERE qid=iqid AND ST_CONTAINS(b.geom,a.geom)
---- THE FOLLOWING REPLACE THE PREVIOUS - SAME RESULT!?!
WHERE qid=iqid AND ST_CONTAINS(b.geom,a.point)
ORDER BY qid,source,tid;

DROP TABLE IF EXISTS atts_tile_agg;
CREATE TEMPORARY TABLE atts_tile_agg AS
SELECT qid,tid,
${REORDERS}
FROM 
(SELECT qid,tid FROM atts_tile GROUP BY qid,tid) a
${L_ATTS_AGG_JOINS}
;
${L_ATTS_AGG_UPD}

INSERT INTO ${SCH}.fa_atts_tile
SELECT * FROM atts_tile_agg ORDER BY qid,tid,
${REORDERS}
;

END;
\$BODY\$;

COMMENT ON FUNCTION ${SCH}.f_pop_atts_tile(integer) IS
'populates attribute tile table;input parameter is:
iqid - integer - numeric value from tiled table as selector for the row - number;
eg: SELECT current_schema_name.f_pop_atts_tile(47714) will:
read from current_schema_name.flat_all and current_schema_name.tiled_all tables, selecting rows where qid=47714 - write to current_schema_name.atts_tile table';
EOF
)

# FUNCTION RECODE FLAT PREPARATION
sql_f_flat_recode=$(cat<<EOF
DROP FUNCTION IF EXISTS ${SCH}.f_flat_recode(integer);
CREATE OR REPLACE FUNCTION ${SCH}.f_flat_recode(iqid integer)
    RETURNS void
    LANGUAGE 'plpgsql'
AS \$BODY\$

BEGIN
UPDATE ${SCH}.e_flat_all
SET cid=a.cid
FROM 
(SELECT tid,cid FROM ${SCH}.fa_atts_tile JOIN ${SCH}.fb_atts_all USING(${REORDERS}) WHERE qid = iqid) a
WHERE e_flat_all.qid=iqid AND e_flat_all.tid=a.tid;

DROP TABLE IF EXISTS flat;
CREATE TEMPORARY TABLE flat AS
----NEXT IS REPLACED
--SELECT cid,ST_MULTI(ST_COLLECT(geom)) geom FROM ${SCH}.e_flat_all WHERE qid = iqid GROUP BY cid ORDER BY cid;
----NEXT REPLACES THE PREVIOUS
SELECT cid,ST_MULTI(ST_COLLECT(geom)) geom FROM
(SELECT cid,(ST_DUMP(ST_UNION(geom))).geom FROM ${SCH}.e_flat_all WHERE qid = iqid GROUP BY cid ORDER BY cid) a
GROUP BY cid ORDER BY cid;
----END O REPLACED lines
INSERT INTO ${SCH}.g_flat_temp
SELECT iqid,cid,geom,
${REORDERS}
,ST_AREA(geom::geography)/1000000
FROM flat JOIN ${SCH}.fb_atts_all USING(cid);
END;
\$BODY\$;


COMMENT ON FUNCTION ${SCH}.f_flat_recode(integer) IS
'populates final flat_temp table;input parameter is:
iqid - integer - numeric value from tiled table as selector for the row - number;
eg: SELECT current_schema_name.f_flat_recode(47714) will:
read from current_schema_name.flat_all and current_schema_name.tiled_all tables, selecting rows where qid=47714 - write to current_schema_name.flat_temp table';
EOF
)

# FUNCTION EXPORT RASTER PREPARATION
sql_f_pop_o_raster=$(cat<<EOF
DROP FUNCTION IF EXISTS ${SCH}.f_pop_o_raster(integer,text);
CREATE OR REPLACE FUNCTION ${SCH}.f_pop_o_raster(iqid integer,bbit text DEFAULT '16BUI'::text)
    RETURNS void
    LANGUAGE 'plpgsql'
AS \$BODY\$
DECLARE
rrast raster := (SELECT ST_MakeEmptyRaster(${RCCT},${RCCT},-180,90,(1/${RCC}::double precision),(-1/${RCC}::double precision),0,0,4326) AS rast);
BEGIN
INSERT INTO ${SCH}.o_raster(qid,rast)
SELECT iqid,* FROM
(SELECT ST_UNION(ST_AsRaster(geom,rrast,bbit,cid,0)) rast
FROM ${SCH}.h_flat WHERE qid=iqid) a;
END;
\$BODY\$;
COMMENT ON FUNCTION ${SCH}.f_pop_o_raster(integer,text) IS
'rasterize final vector table by tile/cid, at same resolution of input rasterization; inputs parameters are:
iqid - integer - input qid: tile unique id - number';
EOF
)

####################################################################################################################################################
### END PREPARING FUNCTIONS
####################################################################################################################################################

####################################################################################################################################################
### START CREATING FUNCTIONS
####################################################################################################################################################

# FUNCTION FISHNET CREATION
psql ${dbpar2} -c "$sql_fishnet"
wait

# FUNCTION POPULATE_Z_GRID CREATION
psql ${dbpar2} -c "$sql_f_pop_z_grid"

# FUNCTION POPULATE_O_GRID CREATION
psql ${dbpar2} -c "$sql_f_pop_o_grid"

# FUNCTION POPULATE INPUT CREATION
psql ${dbpar2} -c "$sql_f_pop_input"

# FUNCTION CLIP CREATION
psql ${dbpar2} -c "$sql_f_clip"

# FUNCTION RASTER CREATION
psql ${dbpar2} -c "$sql_f_raster"

# FUNCTION POPULATE_TILED CREATION
psql ${dbpar2} -c "$sql_f_pop_tiled"

# FUNCTION POPULATE_TILED_TEMP CREATION
psql ${dbpar2} -c "$sql_f_pop_tiled_temp"

# FUNCTION FLATTER CREATION
psql ${dbpar2} -c "$sql_f_flatter"

# FUNCTION ATTRIBUTE TILE CREATION
psql ${dbpar2} -c "$sql_f_pop_atts_tile"

# FUNCTION RECODE FLAT CREATION
psql ${dbpar2} -c "$sql_f_flat_recode"

# FUNCTION POPULATE OUTPUT RASTER CREATION
psql ${dbpar2} -c "$sql_f_pop_o_raster"

####################################################################################################################################################
### END CREATING FUNCTIONS
####################################################################################################################################################

####################################################################################################################################################
## END FUNCTIONS
####################################################################################################################################################

####################################################################################################################################################
## START STATIC TABLES
####################################################################################################################################################

####################################################################################################################################################
### START PREPARING STATIC TABLES
####################################################################################################################################################

# TABLE GRID PREPARATION
sql_z_grid=$(cat<<EOF
DROP TABLE IF EXISTS ${SCH}.z_grid;
CREATE TABLE ${SCH}.z_grid (
qid serial PRIMARY KEY,
col integer,
row integer,
geom geometry(Polygon,4326),
sqkm double precision,
qfilter boolean,
eid integer);
CREATE INDEX ON ${SCH}.z_grid USING gist(geom);
EOF
)

# TABLE OUTPUT GRID PREPARATION
sql_o_grid=$(cat<<EOF
DROP TABLE IF EXISTS ${SCH}.o_grid;
CREATE TABLE ${SCH}.o_grid (
qid serial PRIMARY KEY,
col integer,
row integer,
geom geometry(Polygon,4326)
);
CREATE INDEX ON ${SCH}.o_grid USING gist(geom);
EOF
)

# TABLE DB_TILED_TEMP PREPARATION
sql_db_tiled_temp=$(cat<<EOF
DROP TABLE IF EXISTS ${SCH}.db_tiled_temp;
CREATE TABLE ${SCH}.db_tiled_temp
(qid integer,fid integer,source text,geom geometry,sqkm double precision);
EOF
)

# TABLE DC_TILED_ALL PREPARATION
sql_dc_tiled_all=$(cat<<EOF
DROP TABLE IF EXISTS ${SCH}.dc_tiled_all;
CREATE TABLE ${SCH}.dc_tiled_all
(tid serial PRIMARY KEY,qid integer,fid integer,source text,geom geometry,sqkm double precision);
CREATE INDEX ON ${SCH}.dc_tiled_all USING gist(geom);
CREATE INDEX ON ${SCH}.dc_tiled_all(qid);
CREATE INDEX ON ${SCH}.dc_tiled_all(fid);
CREATE INDEX ON ${SCH}.dc_tiled_all(source);
EOF
)

# TABLE E_FLAT_ALL PREPARATION
sql_e_flat_all=$(cat<<EOF
DROP TABLE IF EXISTS ${SCH}.e_flat_all;
CREATE TABLE ${SCH}.e_flat_all
(qid integer NOT NULL,tid bigint NOT NULL,cid bigint,geom geometry,point geometry,valid boolean,reason character varying,location geometry,st_geometrytype text,CONSTRAINT flat_all_pkey PRIMARY KEY (qid, tid));
CREATE INDEX ON ${SCH}.e_flat_all USING gist(geom);
CREATE INDEX ON ${SCH}.e_flat_all USING gist(point);
EOF
)

# following tables use variables defined in the topic loop above
echo "creating tables using variables defined in the topic loop"

# TABLE FA_ATTRIBUTES_TILE PREPARATION
sql_fa_atts_tile=$(cat<<EOF
DROP TABLE IF EXISTS ${SCH}.fa_atts_tile;
CREATE TABLE ${SCH}.fa_atts_tile (qid integer,tid bigint,
${REFIELDS}
);
EOF
)

# TABLE ATTRIBUTE ALL PREPARATION
sql_atts_all=$(cat<<EOF
DROP TABLE IF EXISTS ${SCH}.fb_atts_all;
CREATE TABLE ${SCH}.fb_atts_all
(cid bigint,
${REFIELDS}
);
EOF
)

# TABLE FLAT TEMP PREPARATION
sql_flat_temp=$(cat<<EOF
DROP TABLE IF EXISTS ${SCH}.g_flat_temp;
CREATE TABLE ${SCH}.g_flat_temp
(
    qid integer,
    cid bigint,
    geom geometry,
    ${REFIELDS},
    sqkm double precision,
    valid boolean,
    reason character varying,
    location geometry,
    st_geometrytype text,
    CONSTRAINT g_flat_temp_pkey PRIMARY KEY (qid,cid)
);
CREATE INDEX ON ${SCH}.g_flat_temp(qid);
CREATE INDEX ON ${SCH}.g_flat_temp(cid);
EOF
)

# TABLE FLAT FINAL PREPARATION
sql_flat=$(cat<<EOF
DROP TABLE IF EXISTS ${SCH}.h_flat;
CREATE TABLE ${SCH}.h_flat
(
    qid integer,
    cid bigint,
    geom geometry(MultiPolygon,4326),
    ${REFIELDS},
    sqkm double precision,
    CONSTRAINT h_flat_pkey PRIMARY KEY (qid,cid)
);
CREATE INDEX ON ${SCH}.h_flat(qid);
CREATE INDEX ON ${SCH}.h_flat(cid);
${INDEX_FLAT}
CREATE INDEX ON ${SCH}.h_flat USING GIST(geom);
EOF
)

####################################################################################################################################################
### END PREPARING STATIC TABLES
####################################################################################################################################################

####################################################################################################################################################
### START CREATING STATIC TABLES
####################################################################################################################################################
# TABLE GRID CREATION
psql ${dbpar2} -c "$sql_z_grid"
wait

# TABLE OUTPUT GRID CREATION
psql ${dbpar2} -c "$sql_o_grid"
wait

# TABLE DB_TILED_TEMP CREATION
psql ${dbpar2} -c "$sql_db_tiled_temp"

# TABLE DC_TILED_ALL CREATION
psql ${dbpar2} -c "$sql_dc_tiled_all"

# TABLE FLAT ALL CREATION
psql ${dbpar2} -c "$sql_e_flat_all"

# TABLE ATTRIBUTE TILE CREATION
psql ${dbpar2} -c "$sql_fa_atts_tile"

# TABLE ATTRIBUTE TILE CREATION
psql ${dbpar2} -c "$sql_atts_all"

# TABLE FLAT TEMP CREATION
psql ${dbpar2} -c "$sql_flat_temp"

# TABLE FLAT FINAL CREATION
psql ${dbpar2} -c "$sql_flat"

if ((${TOPICS}>1))
then
psql ${dbpar2} -t -c "CREATE INDEX ON ${SCH}.h_flat USING GIN(${REORDERS});"
fi

####################################################################################################################################################
### END CREATING STATIC TABLES
####################################################################################################################################################

####################################################################################################################################################
### POPULATING GRID TABLE
####################################################################################################################################################
### POPULATE OGRID
psql ${dbpar2} -t -c "SELECT ${SCH}.f_pop_o_grid();"
wait
### POPULATE ZGRID
psql ${dbpar2} -t -c "SELECT ${SCH}.f_pop_z_grid();"
wait
psql ${dbpar2} -t -c "UPDATE ${SCH}.z_grid SET sqkm=(ST_Area(geom::geography)/1000000);" &
wait
psql ${dbpar2} -t -c "
WITH e AS (SELECT DISTINCT a.qid,b.qid eid FROM ${SCH}.z_grid a,${SCH}.o_grid b WHERE ST_CONTAINS(b.geom,ST_CENTROID(a.geom)) ORDER BY b.qid,a.qid)
UPDATE ${SCH}.z_grid SET eid=e.eid FROM e WHERE z_grid.qid=e.qid;
"
wait

####################################################################################################################################################
### END STATIC TABLES
####################################################################################################################################################

####################################################################################################################################################
# END STATIC PART 
####################################################################################################################################################


echo "
FIELDS WAS
${FIELDS};
REFIELDS IS
${REFIELDS};

ORDERS WAS
${ORDERS};
REORDERS IS
${REORDERS};

INDEX_FLAT IS
${INDEX_FLAT};

L_ATTS_AGG_JOINS IS
${L_ATTS_AGG_JOINS};

L_ATTS_AGG_UPD IS
${L_ATTS_AGG_UPD};

UNIONS WAS
${UNIONS};
REUNIONS IS
${REUNIONS};

POPS WAS
${POPS};
REPOPS IS
${REPOPS};

FLAT WAS
${FLAT};
REFLAT IS
${REFLAT};
"

echo -e "REPOPS IS ALSO ${REPOPS}"

# create script db_tiled_all.sh
rm db_tiled_all.sh
cat ./templates/db_tiled_all_a.template > db_tiled_all.sh
sed -i 's/REUNIONS_T/'"${REUNIONS}"'/' db_tiled_all.sh
echo -e " "${REPOPS} >> db_tiled_all.sh
cat ./templates/db_tiled_all_b.template >> db_tiled_all.sh

chmod +x db_tiled_all.sh

# create script e_flat_all.sh
rm e_flat_all.sh
cat ./templates/e_flat_all_a.template > e_flat_all.sh
echo ${REFLAT} >> e_flat_all.sh
cat ./templates/e_flat_all_b.template >> e_flat_all.sh
chmod +x e_flat_all.sh

# create script f_attributes_all.sh
rm f_attributes_all.sh
cat ./templates/f_attributes_all.template > f_attributes_all.sh
sed -i 's/REORDERS_T/'"${REORDERS}"'/' f_attributes_all.sh
chmod +x f_attributes_all.sh

# create script g_final_all.sh
rm g_final_all.sh
cat ./templates/g_final_all.template > g_final_all.sh
chmod +x g_final_all.sh

# create script h_output_all.sh
rm h_output.sh
cat ./templates/h_output.template > h_output.sh
sed -i 's/REORDERS_T/'"${REORDERS}"'/' h_output.sh
chmod +x h_output.sh

# create script o_raster.sh
rm o_raster.sh
cat ./templates/o_raster.template > o_raster.sh
chmod +x o_raster.sh

# create script p_export_raster.sh
rm p_export_raster.sh
cat ./templates/p_export_raster.template > p_export_raster.sh
chmod +x p_export_raster.sh

echo "
${GS} # GRID SIZE IN DEGREES
${CS} # CELL SIZE IN ARCSEC
${RWS} # NUMBER OF ROWS IN THE GRID
${CLS} # NUMBER OF COLUMNS IN THE GRID
${RCC} # NUMBER OF ROWS/COLUMNS FOR CELL
${RCCT} # NUMBER OF ROWS/COLUMNS FOR TILE
"

echo "analysis done"
# stop timer
END_T1=$(date +%s)
TOTAL_DIFF=$(($END_T1 - $START_T1))
echo "TOTAL SCRIPT TIME: $TOTAL_DIFF"
