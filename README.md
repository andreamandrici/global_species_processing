# GLOBAL SPECIES PROCESSING
# Complete workflow for species import, pre- and post-processing.

## Sources

+  [IUCN Red List of Threatened Species](https://www.iucnredlist.org/search). IUCN, Version 2021-2 (published on 20210904). **Non-spatial** attributes (**only species selected, no subspecies or subpopulations selected**) for:
   +  Reef-forming Corals (_Hydrozoa_ and _Anthozoa_)
   +  Sharks, rays and chimaeras (_Chondrichthyes_)    
   +  Amphibians
   +  Birds
   +  Mammals.

Downloaded on 20210906.


+  [IUCN Red List of Threatened Species Spatial Data](https://www.iucnredlist.org/resources/spatial-data-download).  IUCN, Version 2021-2 (published on 20210904). **Spatial** data for:
   +  Reef-forming Corals (_Hydrozoa_ and _Anthozoa_)
   +  Sharks, rays and chimaeras (_Chondrichthyes_)
   +  Amphibians
   +  Mammals.

Downloaded on 20210906.

+  [BirdLife's species distribution data](http://datazone.birdlife.org/species/requestdis). BirdLife International, Version 2020-v1. Spatial and non-spatial tables for Birds.

Received on 20201217.

## Import

Spatial and non-spatial data are made available as foreign tables pointing at external files (shp, gdb, csv, xlsx) files in different schemas. Actions needed are:

### data preparation
All data sources are extracted in `/data/swap/inputdata/` subfolders according to the format:

`/data/swap/inputdata/shp/` accepts many \*.shp (and ancillary files \*.shx, \*.dbf, etc...)

`/data/swap/inputdata/csv/` accepts many \*.csv

`/data/swap/inputdata/gdb/inputgdb.gdb` accepts a single folder named exactly inputgdb.gdb

`/data/swap/inputdata/gpkg/inputgpkg.gpkg` accepts a single file named exactly inputgpkg.gpkg

`/data/swap/inputdata/xlsx/inputxlsx.xlsx` accepts a single file named exactly inputxlsx.xlsx

### foreign data wrapper
```
------------------------------------------
-- AS SUPERUSER
------------------------------------------
-- DB is called Wallace, user is called h05ibex
CREATE EXTENSION ogr_fdw;
GRANT ALL PRIVILEGES ON FOREIGN DATA WRAPPER ogr_fdw TO h05ibex;
ALTER DATABASE wallace SET postgis.enable_outdb_rasters = true;
ALTER DATABASE wallace SET postgis.gdal_enabled_drivers TO 'ENABLE_ALL';
SELECT pg_reload_conf();

DROP SERVER IF EXISTS ogr_fdw_shp CASCADE;
--DROP SERVER IF EXISTS ogr_fdw_csv CASCADE; -- more on this later
DROP SERVER IF EXISTS ogr_fdw_gpkg CASCADE;
DROP SERVER IF EXISTS ogr_fdw_xlsx CASCADE;
DROP SERVER IF EXISTS ogr_fdw_gdb CASCADE;

--open "path": the following accept a folder as input
CREATE SERVER ogr_fdw_shp FOREIGN DATA WRAPPER ogr_fdw
OPTIONS (datasource '/data/swap/inputdata/shp/', format 'ESRI Shapefile');
ALTER SERVER ogr_fdw_shp OWNER TO h05ibex;

--more on this later
--CREATE SERVER ogr_fdw_csv FOREIGN DATA WRAPPER ogr_fdw
--OPTIONS (datasource '/data/swap/inputdata/csv/', format 'CSV');
--ALTER SERVER ogr_fdw_csv OWNER TO h05ibex;

--closed "path": the following accept a file as input
CREATE SERVER ogr_fdw_gpkg FOREIGN DATA WRAPPER ogr_fdw
OPTIONS (datasource '/data/swap/inputdata/gpkg/inputgpkg.gpkg', format 'GPKG');
ALTER SERVER ogr_fdw_gpkg OWNER TO h05ibex;

CREATE SERVER ogr_fdw_xlsx FOREIGN DATA WRAPPER ogr_fdw
OPTIONS (datasource '/data/swap/inputdata/xlsx/inputxlsx.xlsx', format 'XLSX');
ALTER SERVER ogr_fdw_xlsx OWNER TO h05ibex;

CREATE SERVER ogr_fdw_gdb FOREIGN DATA WRAPPER ogr_fdw
OPTIONS (datasource '/data/swap/inputdata/gdb/inputgdb.gdb', format 'OpenFileGDB');
ALTER SERVER ogr_fdw_gdb OWNER TO h05ibex;

------------------------------------------------
-- AS USER
------------------------------------------------
DROP SCHEMA IF EXISTS import_tables CASCADE; CREATE SCHEMA import_tables;
IMPORT FOREIGN SCHEMA ogr_all FROM SERVER ogr_fdw_shp INTO import_tables;
--IMPORT FOREIGN SCHEMA ogr_all FROM SERVER ogr_fdw_csv INTO import_tables; -- more on this later
IMPORT FOREIGN SCHEMA ogr_all FROM SERVER ogr_fdw_gpkg INTO import_tables;
IMPORT FOREIGN SCHEMA ogr_all FROM SERVER ogr_fdw_xlsx INTO import_tables;
IMPORT FOREIGN SCHEMA ogr_all FROM SERVER ogr_fdw_gdb INTO import_tables;
```

#### special case for IUCN non-spatial data.
Download of non spatial data for birds from [IUCN Red List of Threatened Species](https://www.iucnredlist.org/search) is affected by an annoying limit of 10K objects, which is bypassed by dividing the search query for _non passeriformes_ and _passeriformes_. This implies the duplication of homonymous tables, which must undergo an append before becoming useful. For this reason, import of non-spatial csv from IUCN receive the following different treatment:
```
------------------------------------------
-- AS SUPERUSER
------------------------------------------
DROP SERVER IF EXISTS ogr_fdw_csv1 CASCADE;
DROP SERVER IF EXISTS ogr_fdw_csv2 CASCADE;
DROP SCHEMA IF EXISTS import_tables_1 CASCADE;
DROP SCHEMA IF EXISTS import_tables_2 CASCADE;
CREATE SCHEMA import_tables_1;
CREATE SCHEMA import_tables_2;

CREATE SERVER ogr_fdw_csv1 FOREIGN DATA WRAPPER ogr_fdw
OPTIONS (datasource '/data/swap/inputdata/csv/non_passeriformes', format 'CSV');
ALTER SERVER ogr_fdw_csv1 OWNER TO h05ibex;

CREATE SERVER ogr_fdw_csv2 FOREIGN DATA WRAPPER ogr_fdw
OPTIONS (datasource '/data/swap/inputdata/csv/passeriformes', format 'CSV');
ALTER SERVER ogr_fdw_csv2 OWNER TO h05ibex;
------------------------------------------------
-- AS USER
------------------------------------------------
IMPORT FOREIGN SCHEMA ogr_all FROM SERVER ogr_fdw_csv1 INTO import_tables_1;
IMPORT FOREIGN SCHEMA ogr_all FROM SERVER ogr_fdw_csv2 INTO import_tables_2;
```

## Pre-Processing

### converting from foreign to real tables 

Each foreign table is converted to real table (geometric or non-geometric).
Geometric tables include: **Extant** and **Probably Extant** (IUCN will discontinue this code); **Native** and **Reintroduced**; **Resident**, **Breeding Season** and **Non-breeding Season** (above corresponds to sql `WHERE presence IN (1,2) AND origin IN (1,2) AND seasonal IN (1,2,3)`).

#### spatial data
##### corals
```
-- split sources are merged
SELECT * INTO import_tables.spatial_corals FROM
(SELECT * FROM import_tables.reef_forming_corals_part1 WHERE presence IN (1,2) AND origin IN (1,2) AND seasonal IN (1,2,3)
 UNION
 SELECT * FROM import_tables.reef_forming_corals_part2 WHERE presence IN (1,2) AND origin IN (1,2) AND seasonal IN (1,2,3)
 UNION
 SELECT * FROM import_tables.reef_forming_corals_part3 WHERE presence IN (1,2) AND origin IN (1,2) AND seasonal IN (1,2,3)
ORDER BY id_no,fid
) a
ORDER BY id_no,fid;
--SELECT 842
--Query returned successfully in 1 min 46 secs.
```

##### sharks, rays, chimaeras
```
SELECT * INTO import_tables.spatial_sharks_rays_chimaeras
FROM import_tables.sharks_rays_chimaeras
WHERE presence IN (1,2) AND origin IN (1,2) AND seasonal IN (1,2,3)
ORDER BY id_no,fid;
--SELECT 1194
--Query returned successfully in 47 secs 192 msec.
```

##### amphibians
```
SELECT * INTO import_tables.spatial_amphibians
FROM import_tables.amphibians WHERE presence IN (1,2) AND origin IN (1,2) AND seasonal IN (1,2,3) ORDER BY id_no,fid;
--SELECT 7823
--Query returned successfully in 32 secs 52 msec.
```

##### mammals
```
SELECT * INTO import_tables.spatial_mammals
FROM import_tables.mammals
WHERE presence IN (1,2) AND origin IN (1,2) AND seasonal IN (1,2,3)
ORDER BY id_no,fid;
--SELECT 11867
--Query returned successfully in 1 min 3 secs.
```

##### birds
```
SELECT * INTO import_tables.spatial_birds
FROM import_tables.all_species
WHERE PRESENCE IN (1,2) AND ORIGIN IN (1,2) AND SEASONAL IN (1,2,3);
--SELECT 14963
--Query returned successfully in 15 min 1 secs.
```

### non-spatial data
```
DROP TABLE IF EXISTS import_tables.non_spatial_all_other_fields;
SELECT * INTO import_tables.non_spatial_all_other_fields FROM (
SELECT * FROM import_tables_1.all_other_fields
UNION 
SELECT * FROM import_tables_2.all_other_fields
) a;
--SELECT 27658
--Query returned successfully in 367 msec.
DROP TABLE IF EXISTS import_tables.non_spatial_assessments;
SELECT * INTO import_tables.non_spatial_assessments FROM (
SELECT * FROM import_tables_1.assessments
UNION 
SELECT * FROM import_tables_2.assessments
) a;
--SELECT 27658
--Query returned successfully in 2 secs 672 msec.
DROP TABLE IF EXISTS import_tables.non_spatial_common_names;
SELECT * INTO import_tables.non_spatial_common_names FROM (
SELECT * FROM import_tables_1.common_names
UNION 
SELECT * FROM import_tables_2.common_names
) a;
--SELECT 51427
--Query returned successfully in 273 msec.
DROP TABLE IF EXISTS import_tables.non_spatial_conservation_needed;
SELECT * INTO import_tables.non_spatial_conservation_needed FROM (
SELECT * FROM import_tables_1.conservation_needed
UNION 
SELECT * FROM import_tables_2.conservation_needed
) a;
--SELECT 37530
--Query returned successfully in 255 msec.
DROP TABLE IF EXISTS import_tables.non_spatial_countries;
SELECT * INTO import_tables.non_spatial_countries FROM (
SELECT * FROM import_tables_1.countries
UNION 
SELECT * FROM import_tables_2.countries
) a;
--SELECT 226859
--Query returned successfully in 1 secs 233 msec.
DROP TABLE IF EXISTS import_tables.non_spatial_credits;
SELECT * INTO import_tables.non_spatial_credits FROM (
SELECT * FROM import_tables_1.credits
UNION 
SELECT * FROM import_tables_2.credits
) a;
--SELECT 97746
--Query returned successfully in 742 msec.
DROP TABLE IF EXISTS import_tables.non_spatial_dois;
SELECT * INTO import_tables.non_spatial_dois FROM (
SELECT * FROM import_tables_1.dois
UNION 
SELECT * FROM import_tables_2.dois
) a;
--SELECT 27658
--Query returned successfully in 208 msec.
DROP TABLE IF EXISTS import_tables.non_spatial_habitats;
SELECT * INTO import_tables.non_spatial_habitats FROM (
SELECT * FROM import_tables_1.habitats
UNION 
SELECT * FROM import_tables_2.habitats
) a;
--SELECT 116131
--Query returned successfully in 638 msec.
DROP TABLE IF EXISTS import_tables.non_spatial_references;
SELECT * INTO import_tables.non_spatial_references FROM (
SELECT * FROM import_tables_1.references
UNION 
SELECT * FROM import_tables_2.references
) a;
--SELECT 231966
--Query returned successfully in 1 secs 994 msec.
DROP TABLE IF EXISTS import_tables.non_spatial_research_needed;
SELECT * INTO import_tables.non_spatial_research_needed FROM (
SELECT * FROM import_tables_1.research_needed
UNION 
SELECT * FROM import_tables_2.research_needed
) a;
--SELECT 57547
--Query returned successfully in 319 msec.
DROP TABLE IF EXISTS import_tables.non_spatial_simple_summary;
SELECT * INTO import_tables.non_spatial_simple_summary FROM (
SELECT * FROM import_tables_1.simple_summary
UNION 
SELECT * FROM import_tables_2.simple_summary
) a;
--SELECT 27658
--Query returned successfully in 307 msec.
DROP TABLE IF EXISTS import_tables.non_spatial_synonyms;
SELECT * INTO import_tables.non_spatial_synonyms FROM (
SELECT * FROM import_tables_1.synonyms
UNION 
SELECT * FROM import_tables_2.synonyms
) a;
--SELECT 16791
--Query returned successfully in 189 msec.
DROP TABLE IF EXISTS import_tables.non_spatial_taxonomy;
SELECT * INTO import_tables.non_spatial_taxonomy FROM (
SELECT * FROM import_tables_1.taxonomy
UNION 
SELECT * FROM import_tables_2.taxonomy
) a;
--SELECT 27658
--Query returned successfully in 315 msec.
DROP TABLE IF EXISTS import_tables.non_spatial_threats;
SELECT * INTO import_tables.non_spatial_threats FROM (
SELECT * FROM import_tables_1.threats
UNION 
SELECT * FROM import_tables_2.threats
) a;
--SELECT 75851
--Query returned successfully in 629 msec.
DROP TABLE IF EXISTS import_tables.non_spatial_usetrade;
SELECT * INTO import_tables.non_spatial_usetrade FROM (
SELECT * FROM import_tables_1.usetrade
UNION 
SELECT * FROM import_tables_2.usetrade
) a;
--SELECT 12977
--Query returned successfully in 179 msec.
---- NON-PASSERIFORMES ONLY
DROP TABLE IF EXISTS import_tables.fao;
SELECT * INTO import_tables.fao FROM import_tables_1.fao;
--SELECT 7755
--Query returned successfully in 126 msec.
DROP TABLE IF EXISTS import_tables.lme;
SELECT * INTO import_tables.lme FROM import_tables_1.lme;
--SELECT 9316
--Query returned successfully in 153 msec.
