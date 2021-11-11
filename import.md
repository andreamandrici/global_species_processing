## Import

Spatial and non-spatial data are made available as foreign tables pointing at external files (shp, gdb, csv, xlsx) files in different schemas. Actions needed are:

---
All data sources are extracted in `/data/swap/inputdata/` subfolders according to the format:

`/data/swap/inputdata/shp/` accepts many \*.shp (and ancillary files \*.shx, \*.dbf, etc...)

`/data/swap/inputdata/csv/` accepts many \*.csv

`/data/swap/inputdata/gdb/input.gdb` accepts a single folder named exactly _input.gdb_.

`/data/swap/inputdata/gpkg/input.gpkg` accepts a single file named exactly _input.gpkg_.

`/data/swap/inputdata/xlsx/input.xlsx` accepts a single file named exactly _input.xlsx_.

### foreign data wrapper
Foreign data servers are created in bulk; foreign data tables are imported in bulk in specific, temporary schemes.
Each foreign table is converted to real table (geometric or non-geometric).

Geometric tables include: **Extant** and **Probably Extant** (IUCN will discontinue this code); **Native** and **Reintroduced**; **Resident**, **Breeding Season** and **Non-breeding Season** (above corresponds to sql `WHERE presence IN (1,2) AND origin IN (1,2) AND seasonal IN (1,2,3)`).

Download of non spatial data for birds from [IUCN Red List of Threatened Species](https://www.iucnredlist.org/search) is affected by an annoying limit of 10K objects, which is bypassed by dividing the search query for _non passeriformes_ and _passeriformes_. This implies the duplication of homonymous tables, which must undergo an append before becoming useful, which is done going through the creation of two temporary schemes.

At the end of the import all foreign objects and temporary schemes are dropped.

```
--------------------------------------------------------------
-- CREATE INPUT TARGET SCHEMA
--------------------------------------------------------------
DROP SCHEMA IF EXISTS import_tables CASCADE;
CREATE SCHEMA import_tables;

--------------------------------------------------------------
-- IMPORT IUCN SPATIAL
--------------------------------------------------------------
-- CREATE FDW SERVER
---------------------------------------------------------------
DROP SERVER IF EXISTS fdw_iucn_spatial CASCADE;
CREATE SERVER fdw_iucn_spatial
FOREIGN DATA WRAPPER ogr_fdw
OPTIONS (datasource '/data/swap/inputdata/iucn/spatial/', format 'ESRI Shapefile');
--------------------------------------------------------------
-- CREATE FDW SCHEMA AND TABLES (temporary)
---------------------------------------------------------------
DROP SCHEMA IF EXISTS iucn_spatial CASCADE;CREATE SCHEMA iucn_spatial;
IMPORT FOREIGN SCHEMA ogr_all FROM SERVER fdw_iucn_spatial INTO iucn_spatial;
--------------------------------------------------------------
-- IMPORT CORALS
--------------------------------------------------------------
-- split sources are merged
DROP TABLE IF EXISTS import_tables.spatial_corals;
SELECT * INTO import_tables.spatial_corals FROM
(SELECT * FROM iucn_spatial.reef_forming_corals_part1 WHERE presence IN (1,2) AND origin IN (1,2) AND seasonal IN (1,2,3)
 UNION
 SELECT * FROM iucn_spatial.reef_forming_corals_part2 WHERE presence IN (1,2) AND origin IN (1,2) AND seasonal IN (1,2,3)
 UNION
 SELECT * FROM iucn_spatial.reef_forming_corals_part3 WHERE presence IN (1,2) AND origin IN (1,2) AND seasonal IN (1,2,3)
ORDER BY id_no,fid
) a
ORDER BY id_no,fid;
--SELECT 842
--Query returned successfully in 1 min 53 secs.
--------------------------------------------------------------
-- IMPORT SHARKS,RAYS,CHIMAERAS
--------------------------------------------------------------
DROP TABLE IF EXISTS import_tables.spatial_sharks_rays_chimaeras;
SELECT * INTO import_tables.spatial_sharks_rays_chimaeras
FROM iucn_spatial.sharks_rays_chimaeras
WHERE presence IN (1,2) AND origin IN (1,2) AND seasonal IN (1,2,3)
ORDER BY id_no,fid;
--SELECT 1194
--Query returned successfully in 51 secs 657 msec.
--------------------------------------------------------------
-- IMPORT AMPHIBIANS
--------------------------------------------------------------
DROP TABLE IF EXISTS import_tables.spatial_amphibians;
SELECT * INTO import_tables.spatial_amphibians
FROM iucn_spatial.amphibians WHERE presence IN (1,2) AND origin IN (1,2) AND seasonal IN (1,2,3) ORDER BY id_no,fid;
--SELECT 7823
--Query returned successfully in 34 secs 327 msec.
--------------------------------------------------------------
-- IMPORT MAMMALS
--------------------------------------------------------------
DROP TABLE IF EXISTS import_tables.spatial_mammals;
SELECT * INTO import_tables.spatial_mammals
FROM iucn_spatial.mammals
WHERE presence IN (1,2) AND origin IN (1,2) AND seasonal IN (1,2,3)
ORDER BY id_no,fid;
--SELECT 11867
--Query returned successfully in 1 min 3 secs.

--------------------------------------------------------------
-- IMPORT BIRDLIFE
--------------------------------------------------------------
-- CREATE FDW SERVER
---------------------------------------------------------------
DROP SERVER IF EXISTS fdw_birdlife CASCADE;
CREATE SERVER fdw_birdlife FOREIGN DATA WRAPPER ogr_fdw
OPTIONS (datasource '/data/swap/inputdata/birdlife/BOTW.gdb', format 'OpenFileGDB');
--------------------------------------------------------------
-- CREATE FDW SCHEMA AND TABLES (temporary)
---------------------------------------------------------------
DROP SCHEMA IF EXISTS birdlife CASCADE;CREATE SCHEMA birdlife;
IMPORT FOREIGN SCHEMA ogr_all FROM SERVER fdw_birdlife INTO birdlife;
--------------------------------------------------------------
-- CREATE BIRDS (spatial and non-spatial)
---------------------------------------------------------------
-- spatial
DROP TABLE IF EXISTS import_tables.spatial_birds;
SELECT * INTO import_tables.spatial_birds
FROM birdlife.all_species
WHERE PRESENCE IN (1,2) AND ORIGIN IN (1,2) AND SEASONAL IN (1,2,3);
--SELECT 14963
--Query returned successfully in 15 min 18 secs.
---------------------------------------------------------------
-- non-spatial
DROP TABLE IF EXISTS import_tables.non_spatial_birds;
SELECT * INTO import_tables.non_spatial_birds
FROM birdlife.birdlife_taxonomic_checklist_v5;
--SELECT 11158
--Query returned successfully in 259 ms.


--------------------------------------------------------------
-- IMPORT IUCN NON-SPATIAL
--------------------------------------------------------------
-- CREATE FDW SERVERS
---------------------------------------------------------------
-- non passeriformes
DROP SERVER IF EXISTS fdw_iucn_non_spatial_non_passeriformes CASCADE;
CREATE SERVER fdw_iucn_non_spatial_non_passeriformes FOREIGN DATA WRAPPER ogr_fdw
OPTIONS (datasource '/data/swap/inputdata/iucn/non_spatial/non_passeriformes/', format 'CSV');
-- passeriformes
DROP SERVER IF EXISTS fdw_iucn_non_spatial_passeriformes CASCADE;
CREATE SERVER fdw_iucn_non_spatial_passeriformes FOREIGN DATA WRAPPER ogr_fdw
OPTIONS (datasource '/data/swap/inputdata/iucn/non_spatial/passeriformes/', format 'CSV');
--------------------------------------------------------------
-- CREATE FDW SCHEMA AND TABLES (temporary)
---------------------------------------------------------------
-- non passeriformes
DROP SCHEMA IF EXISTS iucn_non_spatial_non_passeriformes CASCADE;CREATE SCHEMA iucn_non_spatial_non_passeriformes;
IMPORT FOREIGN SCHEMA ogr_all FROM SERVER fdw_iucn_non_spatial_non_passeriformes INTO iucn_non_spatial_non_passeriformes;
-- passeriformes
DROP SCHEMA IF EXISTS iucn_non_spatial_passeriformes CASCADE;CREATE SCHEMA iucn_non_spatial_passeriformes;
IMPORT FOREIGN SCHEMA ogr_all FROM SERVER fdw_iucn_non_spatial_passeriformes INTO iucn_non_spatial_passeriformes;

--------------------------------------------------------------
-- IMPORT AND MERGE ALL IUCN NON-SPATIAL
--------------------------------------------------------------
DROP TABLE IF EXISTS import_tables.non_spatial_all_other_fields;
SELECT * INTO import_tables.non_spatial_all_other_fields FROM (
SELECT * FROM iucn_non_spatial_non_passeriformes.all_other_fields
UNION 
SELECT * FROM iucn_non_spatial_passeriformes.all_other_fields
) a;

DROP TABLE IF EXISTS import_tables.non_spatial_assessments;
SELECT * INTO import_tables.non_spatial_assessments FROM (
SELECT * FROM iucn_non_spatial_non_passeriformes.assessments
UNION 
SELECT * FROM iucn_non_spatial_passeriformes.assessments
) a;

DROP TABLE IF EXISTS import_tables.non_spatial_common_names;
SELECT * INTO import_tables.non_spatial_common_names FROM (
SELECT * FROM iucn_non_spatial_non_passeriformes.common_names
UNION 
SELECT * FROM iucn_non_spatial_passeriformes.common_names
) a;

DROP TABLE IF EXISTS import_tables.non_spatial_conservation_needed;
SELECT * INTO import_tables.non_spatial_conservation_needed FROM (
SELECT * FROM iucn_non_spatial_non_passeriformes.conservation_needed
UNION 
SELECT * FROM iucn_non_spatial_passeriformes.conservation_needed
) a;

DROP TABLE IF EXISTS import_tables.non_spatial_countries;
SELECT * INTO import_tables.non_spatial_countries FROM (
SELECT * FROM iucn_non_spatial_non_passeriformes.countries
UNION 
SELECT * FROM iucn_non_spatial_passeriformes.countries
) a;

DROP TABLE IF EXISTS import_tables.non_spatial_credits;
SELECT * INTO import_tables.non_spatial_credits FROM (
SELECT * FROM iucn_non_spatial_non_passeriformes.credits
UNION 
SELECT * FROM iucn_non_spatial_passeriformes.credits
) a;

DROP TABLE IF EXISTS import_tables.non_spatial_dois;
SELECT * INTO import_tables.non_spatial_dois FROM (
SELECT * FROM iucn_non_spatial_non_passeriformes.dois
UNION 
SELECT * FROM iucn_non_spatial_passeriformes.dois
) a;

DROP TABLE IF EXISTS import_tables.non_spatial_habitats;
SELECT * INTO import_tables.non_spatial_habitats FROM (
SELECT * FROM iucn_non_spatial_non_passeriformes.habitats
UNION 
SELECT * FROM iucn_non_spatial_passeriformes.habitats
) a;

DROP TABLE IF EXISTS import_tables.non_spatial_references;
SELECT * INTO import_tables.non_spatial_references FROM (
SELECT * FROM iucn_non_spatial_non_passeriformes.references
UNION 
SELECT * FROM iucn_non_spatial_passeriformes.references
) a;

DROP TABLE IF EXISTS import_tables.non_spatial_research_needed;
SELECT * INTO import_tables.non_spatial_research_needed FROM (
SELECT * FROM iucn_non_spatial_non_passeriformes.research_needed
UNION 
SELECT * FROM iucn_non_spatial_passeriformes.research_needed
) a;

DROP TABLE IF EXISTS import_tables.non_spatial_simple_summary;
SELECT * INTO import_tables.non_spatial_simple_summary FROM (
SELECT * FROM iucn_non_spatial_non_passeriformes.simple_summary
UNION 
SELECT * FROM iucn_non_spatial_passeriformes.simple_summary
) a;

DROP TABLE IF EXISTS import_tables.non_spatial_synonyms;
SELECT * INTO import_tables.non_spatial_synonyms FROM (
SELECT * FROM iucn_non_spatial_non_passeriformes.synonyms
UNION 
SELECT * FROM iucn_non_spatial_passeriformes.synonyms
) a;

DROP TABLE IF EXISTS import_tables.non_spatial_taxonomy;
SELECT * INTO import_tables.non_spatial_taxonomy FROM (
SELECT * FROM iucn_non_spatial_non_passeriformes.taxonomy
UNION 
SELECT * FROM iucn_non_spatial_passeriformes.taxonomy
) a;

DROP TABLE IF EXISTS import_tables.non_spatial_threats;
SELECT * INTO import_tables.non_spatial_threats FROM (
SELECT * FROM iucn_non_spatial_non_passeriformes.threats
UNION 
SELECT * FROM iucn_non_spatial_passeriformes.threats
) a;

DROP TABLE IF EXISTS import_tables.non_spatial_usetrade;
SELECT * INTO import_tables.non_spatial_usetrade FROM (
SELECT * FROM iucn_non_spatial_non_passeriformes.usetrade
UNION 
SELECT * FROM iucn_non_spatial_passeriformes.usetrade
) a;

---- NON-PASSERIFORMES ONLY
DROP TABLE IF EXISTS import_tables.non_spatial_fao;
SELECT * INTO import_tables.non_spatial_fao FROM iucn_non_spatial_non_passeriformes.fao;

DROP TABLE IF EXISTS import_tables.non_spatial_lme;
SELECT * INTO import_tables.non_spatial_lme FROM iucn_non_spatial_non_passeriformes.lme;

--------------------------------------------------------------
-- CLEANUP TEMPORARY OBJECTS
--------------------------------------------------------------
DROP SERVER IF EXISTS fdw_birdlife CASCADE;
DROP SERVER IF EXISTS fdw_iucn_non_spatial_non_passeriformes CASCADE;
DROP SERVER IF EXISTS fdw_iucn_non_spatial_passeriformes CASCADE;
DROP SERVER IF EXISTS fdw_iucn_spatial CASCADE;

DROP SCHEMA IF EXISTS birdlife CASCADE;
DROP SCHEMA IF EXISTS iucn_non_spatial_non_passeriformes CASCADE;
DROP SCHEMA IF EXISTS iucn_non_spatial_passeriformes CASCADE;
DROP SCHEMA IF EXISTS iucn_spatial CASCADE;
```

**NOTE** The most expensive of the above operations is import/coversion to real table of birds geographic dataset. This operation is tested on different servers (dedicated exclusive D6 VS shared JEODPP), with different versions of gdal-ogr, postgres-postgis, data disk:

+  DB 247p - PostgreSQL 10.5 - postgis 2.4 - GDAL 2.2.2 - import from SSD (/data/swap/inputdata/birdlife/BOTW.gdb)

Query returned successfully in **6 min 42 secs**

There is actually a failure: `SELECT * FROM import_tables.spatial_birds WHERE ST_NPoints(shape) < 4 --> sisid:105965570,binomial:Amaurospiza moesta)`

+  DB 321p - PostgreSQL 13.3 - postgis 3.1 - GDAL 3.3.2 - import from SSD (/data/swap/inputdata/birdlife/BOTW.gdb)

Query returned successfully in **15 min 18 secs**

+  JEODPP-GCAD - PostgreSQL 13.0- postgis 3.0 - GDAL 3.2.1 - import from network (/eos/jeodpp/home/users/mandand/data/inputdata/birdlife/BOTW.gdb)

Query returned successfully in **76 min 27 secs**
