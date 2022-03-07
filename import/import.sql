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
(SELECT * FROM iucn_spatial.reef_forming_corals_part1 WHERE presence IN (1) AND origin IN (1,2,6) AND seasonal IN (1,2,3)
 UNION
 SELECT * FROM iucn_spatial.reef_forming_corals_part2 WHERE presence IN (1) AND origin IN (1,2,6) AND seasonal IN (1,2,3)
 UNION
 SELECT * FROM iucn_spatial.reef_forming_corals_part3 WHERE presence IN (1) AND origin IN (1,2,6) AND seasonal IN (1,2,3)
ORDER BY id_no,fid
) a
ORDER BY id_no,fid;
--SELECT 842
--Query returned successfully in 1 min 47 secs.
--------------------------------------------------------------
-- IMPORT SHARKS,RAYS,CHIMAERAS
--------------------------------------------------------------
DROP TABLE IF EXISTS import_tables.spatial_sharks_rays_chimaeras;
SELECT * INTO import_tables.spatial_sharks_rays_chimaeras
FROM iucn_spatial.sharks_rays_chimaeras
WHERE presence IN (1) AND origin IN (1,2,6) AND seasonal IN (1,2,3)
ORDER BY id_no,fid;
--SELECT 1194
--Query returned successfully in 49 secs 648 msec.
--------------------------------------------------------------
-- IMPORT AMPHIBIANS
--------------------------------------------------------------
DROP TABLE IF EXISTS import_tables.spatial_amphibians;
SELECT * INTO import_tables.spatial_amphibians
FROM iucn_spatial.amphibians WHERE presence IN (1) AND origin IN (1,2,6) AND seasonal IN (1,2,3);
--SELECT 7934
--Query returned successfully in 34 secs 459 msec.
--------------------------------------------------------------
-- IMPORT MAMMALS
--------------------------------------------------------------
DROP TABLE IF EXISTS import_tables.spatial_mammals;
SELECT * INTO import_tables.spatial_mammals
FROM iucn_spatial.mammals
WHERE presence IN (1) AND origin IN (1,2,6) AND seasonal IN (1,2,3)
ORDER BY id_no,fid;
--SELECT 11761
--Query returned successfully in 1 min 7 secs.

--------------------------------------------------------------
-- IMPORT BIRDLIFE
--------------------------------------------------------------
-- CREATE FDW SERVER
---------------------------------------------------------------
DROP SERVER IF EXISTS fdw_birdlife CASCADE;
CREATE SERVER fdw_birdlife FOREIGN DATA WRAPPER ogr_fdw
OPTIONS (datasource '/data/swap/inputdata/birdlife/botw_2021.gpkg', format 'GPKG');
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
WHERE PRESENCE IN (1) AND origin IN (1,2,6) AND seasonal IN (1,2,3);
--SELECT 14765
--Query returned successfully in 3 min 14 secs.
---------------------------------------------------------------
-- non-spatial
DROP TABLE IF EXISTS import_tables.non_spatial_birds;
SELECT * INTO import_tables.non_spatial_birds
FROM birdlife.ancillary_taxonomic_details;
--SELECT 11162
--Query returned successfully in 476 ms.

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
-- endemic
DROP SERVER IF EXISTS fdw_iucn_non_spatial_endemic CASCADE;
CREATE SERVER fdw_iucn_non_spatial_endemic FOREIGN DATA WRAPPER ogr_fdw
OPTIONS (datasource '/data/swap/inputdata/iucn/non_spatial/global_endemic/', format 'CSV');
--------------------------------------------------------------
-- CREATE FDW SCHEMA AND TABLES (temporary)
---------------------------------------------------------------
-- non passeriformes
DROP SCHEMA IF EXISTS iucn_non_spatial_non_passeriformes CASCADE;CREATE SCHEMA iucn_non_spatial_non_passeriformes;
IMPORT FOREIGN SCHEMA ogr_all FROM SERVER fdw_iucn_non_spatial_non_passeriformes INTO iucn_non_spatial_non_passeriformes;
-- passeriformes
DROP SCHEMA IF EXISTS iucn_non_spatial_passeriformes CASCADE;CREATE SCHEMA iucn_non_spatial_passeriformes;
IMPORT FOREIGN SCHEMA ogr_all FROM SERVER fdw_iucn_non_spatial_passeriformes INTO iucn_non_spatial_passeriformes;
-- endemic
DROP SCHEMA IF EXISTS iucn_non_spatial_endemic CASCADE;CREATE SCHEMA iucn_non_spatial_endemic;
IMPORT FOREIGN SCHEMA ogr_all FROM SERVER fdw_iucn_non_spatial_endemic INTO iucn_non_spatial_endemic;
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

---- ENDEMIC LIST FROM simple_summary (endemics only)
DROP TABLE IF EXISTS import_tables.non_spatial_endemic;
SELECT * INTO import_tables.non_spatial_endemic
FROM iucn_non_spatial_endemic.simple_summary;

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
DROP SERVER IF EXISTS fdw_iucn_non_spatial_endemic CASCADE;
DROP SERVER IF EXISTS fdw_iucn_spatial CASCADE;

DROP SCHEMA IF EXISTS birdlife CASCADE;
DROP SCHEMA IF EXISTS iucn_non_spatial_non_passeriformes CASCADE;
DROP SCHEMA IF EXISTS iucn_non_spatial_passeriformes CASCADE;
DROP SCHEMA IF EXISTS iucn_non_spatial_endemic CASCADE;
DROP SCHEMA IF EXISTS iucn_spatial CASCADE;
