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
DROP SERVER IF EXISTS ogr_fdw_csv CASCADE;
DROP SERVER IF EXISTS ogr_fdw_gpkg CASCADE;
DROP SERVER IF EXISTS ogr_fdw_xlsx CASCADE;
DROP SERVER IF EXISTS ogr_fdw_gdb CASCADE;

--open "path": the following accept a folder as input
CREATE SERVER ogr_fdw_shp FOREIGN DATA WRAPPER ogr_fdw
OPTIONS (datasource '/data/swap/inputdata/shp/', format 'ESRI Shapefile');
ALTER SERVER ogr_fdw_shp OWNER TO h05ibex;

CREATE SERVER ogr_fdw_csv FOREIGN DATA WRAPPER ogr_fdw
OPTIONS (datasource '/data/swap/inputdata/csv/', format 'CSV');
ALTER SERVER ogr_fdw_csv OWNER TO h05ibex;

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
IMPORT FOREIGN SCHEMA ogr_all FROM SERVER ogr_fdw_csv INTO import_tables;
IMPORT FOREIGN SCHEMA ogr_all FROM SERVER ogr_fdw_gpkg INTO import_tables;
IMPORT FOREIGN SCHEMA ogr_all FROM SERVER ogr_fdw_xlsx INTO import_tables;
IMPORT FOREIGN SCHEMA ogr_all FROM SERVER ogr_fdw_gdb INTO import_tables;
```

## Pre-Processing

### converting from foreign to real tables 

Each foreign table is converted to real table (geometric or non-geometric).
Geometric tables include: **Extant** and **Probably Extant** (IUCN will discontinue this code); **Native** and **Reintroduced**; **Resident**, **Breeding Season** and **Non-breeding Season** (above corresponds to sql `WHERE presence IN (1,2) AND origin IN (1,2) AND seasonal IN (1,2,3)`).

#### corals
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

#### sharks, rays, chimaeras
```
SELECT * INTO import_tables.spatial_sharks_rays_chimaeras
FROM import_tables.sharks_rays_chimaeras
WHERE presence IN (1,2) AND origin IN (1,2) AND seasonal IN (1,2,3)
ORDER BY id_no,fid;
--SELECT 1194
--Query returned successfully in 47 secs 192 msec.
```

#### amphibians
```
SELECT * INTO import_tables.spatial_amphibians
FROM import_tables.amphibians WHERE presence IN (1,2) AND origin IN (1,2) AND seasonal IN (1,2,3) ORDER BY id_no,fid;
--SELECT 7823
--Query returned successfully in 32 secs 52 msec.
```

#### mammals
```
SELECT * INTO import_tables.spatial_mammals
FROM import_tables.mammals
WHERE presence IN (1,2) AND origin IN (1,2) AND seasonal IN (1,2,3)
ORDER BY id_no,fid;
--SELECT 11867
--Query returned successfully in 1 min 3 secs.
```

#### birds
```
SELECT * INTO import_tables.spatial_birds
FROM import_tables.all_species
WHERE PRESENCE IN (1,2) AND ORIGIN IN (1,2) AND SEASONAL IN (1,2,3);
--SELECT 14963
--Query returned successfully in 15 min 1 secs.
```

