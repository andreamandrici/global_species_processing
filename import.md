## Import

Spatial and non-spatial data are made available as foreign tables pointing at external files (shp, gdb, csv, xlsx) files in different schemas. Actions needed are:

---
All data sources are extracted in `/data/swap/inputdata/` subfolders according to the format:

`/data/swap/inputdata/shp/` accepts many \*.shp (and ancillary files \*.shx, \*.dbf, etc...)

`/data/swap/inputdata/csv/` accepts many \*.csv

`/data/swap/inputdata/gdb/input.gdb` accepts a single folder named exactly _input.gdb_.

`/data/swap/inputdata/gpkg/input.gpkg` accepts a single file named exactly _input.gpkg_.

`/data/swap/inputdata/xlsx/input.xlsx` accepts a single file named exactly _input.xlsx_.

Spatial birds data are stored in a format (ESRI FileGeoDB) which would introduce MultiSurface objects (ST_CircularString and ST_LineString instead of expected ST_Polygons) within Postigis. To avoid this, \*.gdb is converted before being imported, with the following:  

`ogr2ogr -f GPKG -nlt CONVERT_TO_LINEAR botw_2021.gpkg BOTW.gdb All_Species`

which will produce an 8GB gpkg in about 15m.

### foreign data wrapper
Foreign data servers are created in bulk; foreign data tables are imported in bulk in specific, temporary schemes.
Each foreign table is converted to real table (geometric or non-geometric).

Geometric tables are filtered in the way to include:
+  PRESENCE:1-Extant
+  ORIGIN:1-Native,2-Reintroduced,6-Assisted Colonisation
+  SEASONALITY:1-Resident,2-Breeding Season,3-Non-breeding Season

(above corresponds to sql `WHERE presence IN (1) AND origin IN (1,2,6) AND seasonal IN (1,2,3)`).

Download of non spatial data for birds from [IUCN Red List of Threatened Species](https://www.iucnredlist.org/search) is affected by an annoying limit of 10K objects, which is bypassed by dividing the search query for _non passeriformes_ and _passeriformes_. This implies the duplication of homonymous tables, which must undergo an append before becoming useful, which is done going through the creation of two temporary schemes.

At the end of the import all foreign objects and temporary schemes are dropped.

All the import process is scripted in [import.sql](./harmonization/import.sql).

**NOTE** The most expensive of the above operations is import/coversion to real table of birds geographic dataset. This operation is tested on different servers (dedicated exclusive D6 VS shared JEODPP), with different versions of gdal-ogr, postgres-postgis, data disk:

+  DB 321p - PostgreSQL 13.3 - postgis 3.1 - GDAL 3.3.2 - import from SSD (/data/swap/inputdata/birdlife/BOTW.gdb)

Query returned successfully in **15 min 18 secs**

+  DB 247p - PostgreSQL 10.5 - postgis 2.4 - GDAL 2.2.2 - import from SSD (/data/swap/inputdata/birdlife/BOTW.gdb); previous dataset version (2020-v1).

Query returned successfully in **6 min 42 secs** (this is most probably due to previous gdal version, most probably discarding complex/broken geometries).

There is actually a failure: `SELECT * FROM import_tables.spatial_birds WHERE ST_NPoints(shape) < 4 --> sisid:105965570,binomial:Amaurospiza moesta)`

+  JEODPP-GCAD - PostgreSQL 13.0- postgis 3.0 - GDAL 3.2.1 - import from network (/eos/jeodpp/home/users/mandand/data/inputdata/birdlife/BOTW.gdb); previous dataset version (2020-v1).

Query returned successfully in **76 min 27 secs** (this is most probably due to importing from network share, and not from dedicated SSD).
