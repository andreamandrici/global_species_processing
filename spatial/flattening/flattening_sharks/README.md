# DOPA flattening workflow

Calculating a [DOPA](https://dopa.jrc.ec.europa.eu/en) indicator means, in general, to do a spatial intersection within **at least** two layers. EG:

+  country dataset intersecting protected areas dataset gives protection coverage for countries
+  ecoregion dataset intersecting protected country dataset gives coverage of ecoregion in country, or country in ecoregion
+  country, ecoregion and protected areas datasets intersecting each other give various coverages: percentage of ecoregion in country which is protected, etc...
+  country, ecoregion, protected areas and IUCN species ranges datasets intersecting each other give very complex coverages: endangered species living out of the protected portion of a specific country included in a specific ecoregion...  

Things are complicated by:

+  some dataset (eg: protected areas, species) has overlapping features
+  boundaries and or coastline do not match within datasets
+  big numbers of features. Eg: 250K protected areas, 25K species
+  big size: DOPA indicators are global, and uses global datasets
+  big numbers of indicators (and consequently of input datasets). Eg: DOPA currently reports 155 metrics for countries, intersecting them with many thematic layers (eg: landcover, species, etc...).

Due to the reasons above, updating the indicators requires a long processing time, which is a constraint for frequence of update.

A few (but not cheap) steps have been identified as necessary to improve the process in quality and speed:

+  a structured and standardised workflow: avoid desktop analysis conducted by different operators with different tools/methods/speeds/results
+  reduce the number of runs needed, identifying:
    +  a base layer (aggregation of country/ecoregions/wdpa), which provides the principal coverage indicators, and intersects
    +  thematic datasets (aggregated too, when possible), providing the rest of the metrics
+  simplify complexity:
    +  reducing overlaps
    +  harmonizing boundaries
+  optimize the process
    +  parallelizing calculations
    +  reducing redundant processes.

Above targets are reached **scripting all the sequence of actions needed to build a pseudo-topology** (eg: merging information from countries, ecoregions and protected areas to build the base layer).

## Flat layers

**Pseudo-topology** is meant as a [simple feature](https://www.ogc.org/standards/sfa) layer, flattened, which keeps the information from the original sources at the level of each single atomic geometry in which it can be destructured.

Building a real topology would be too expensive due to the size of the input datasets.

Key parts of the process are:

+  **tiling**: each input object is split in tiles (defaults to one degree).
+  **parallelizing**: calculations are distributed to cores, by tile. Different cores calculates in parallel values for different tiles. The number of tiles calculated in series is dependant by the number of the available cores.
+  **pseudo-rasterizing**: in every tile, every object is
   +  temporary rasterized (defaults to 1 arcsec resolution: about 30 meters at equator), then
   +  re-vectorized.

   This step, despite increasing the number of vector nodes participating to each tile, simplifies the overlapping geometries, in a more efficient way respect to other (tested) approaches: snap to grid; snap to other geometries; simplify; the already mentioned, unsustainable, real topology building.

+  **flattening**: simplified geometries from previous step are intersected, by tile.
+  **re-joining**: the attributes of the original objects are spatially joined to the new geometric objects. Multiple attributes related (coming from overlapping objects) become ordered arrays collected in a single row.
+  **aggregating**:  objects (geometry and attributes) are aggregated by unique combinations of attributes.

The result is a spatial table, in which each box has a unique ID (qid) and contains MultiPolygons, named (cid) according to the unique combination of the original components (topic1, topic2, topic_N_ ...)

Basically, the process consists of:

+  one bash script which creates from scratch (according to few parameters passed through an env file) a series of:
   +  bash scripts (a\_\*.sh, b\_\*.sh, etc... optimized for the input files) 
   +  postgresql/postgis functions and tables.
 
 Running in sequence the above scripts, will in turn run the postgis functions, which in turn fill fill the postgres tables.

It takes 27 hours to process the whole CEP (global country, ecoregion, protection) on 40 cores hardware.

Some sample output deriving from [this 10 Mb sample inputs](./cep_sample/dopa_cep_input_sample.gpkg.tar.7z):

+  [CEP sample output 30 arcsec - 41 seconds processing time](./cep_sample/dopa_cep_output_sample_30arcsec_41sec.geojson)

<iframe height="260" width="620" frameborder="0" src="https://render.githubusercontent.com/view/geojson?url=https://raw.githubusercontent.com/andreamandrici/dopa_workflow/master/flattening/cep_sample/dopa_cep_output_sample_30arcsec_41sec.geojson" title="CEP sample output 30 arcsec - 41 seconds processing time"></iframe>

+  [CEP output 10 arcsec - 41 seconds processing time](./cep_sample/dopa_cep_output_sample_10arcsec_41sec.geojson)

<iframe height="260" width="620" frameborder="0" src="https://render.githubusercontent.com/view/geojson?url=https://raw.githubusercontent.com/andreamandrici/dopa_workflow/master/flattening/cep_sample/dopa_cep_output_sample_10arcsec_41sec.geojson" title="CEP output 10 arcsec - 41 seconds processing time"></iframe>

+  [CEP sample output 3 arcsec - 53 seconds processing time](./cep_sample/dopa_cep_output_sample_3arcsec_53sec.geojson)

<iframe height="260" width="620" frameborder="0" src="https://render.githubusercontent.com/view/geojson?url=https://raw.githubusercontent.com/andreamandrici/dopa_workflow/master/flattening/cep_sample/dopa_cep_output_sample_3arcsec_53sec.geojson" title="CEP sample output 3 arcsec - 53 seconds processing time"></iframe>

+  [CEP output 1 arcsec - 151 seconds processing time](./cep_sample/dopa_cep_output_sample_1arcsec_151sec.geojson)

<iframe height="260" width="620" frameborder="0" src="https://render.githubusercontent.com/view/geojson?url=https://raw.githubusercontent.com/andreamandrici/dopa_workflow/master/flattening/cep_sample/dopa_cep_output_sample_1arcsec_151sec.geojson" title="CEP output 1 arcsec - 151 seconds processing time"></iframe>
.

A lot of effort has been put in making the above task universal, and not exclusively targeted to the above objects (country/ecoregion/pa).
It can be applied as-it-is to pre-process other datasets (eg IUCN species).

### Detailed instructions

#### 0.  Prerequisites

It is tested on 
+  Xubuntu 18.04 amd64 - postgresql 10 - postgis 3.0.1 - gdal (3.0.4)
+  Ubuntu Mate 20.04 amd64 - postgresql 12 - postgis 3.0.1 - gdal (3.0.4)

A [.pgpass file](https://www.postgresql.org/docs/10/libpq-pgpass.html) is required.
As alternative, add the line:
`export PGPASSWORD=<your password here>`
to the `#database parameters` section in the env file. 

#### 1.  Define the environment

In **workflow_parameters.conf**

`TOPICS=NN` -- _defines the number of processed "topics" (eg: for CEP (country+ecoregion+pa) it would be 3)_

`TOPIC_N="topic name"` -- _defines a name to be used for topic N_

`VERSION_TOPIC_N="schema name.table name"` -- _specifies which table contains data for topic N_

`FID_TOPIC_N="topic ID"` -- _specifies which is the numeric field (not required to be unique at this stage) for topic N_

_... repeat the above for the NN number of the defined topics)..._

`SCH="working schema name"` -- _this one defines the working schema, WHICH WILL BE DROPPED AND RECREATED!_

`GS=x` -- _defines grid tile size in degrees, integer submultiple of 180; default is 1 degree_

`CS=y` -- _defines raster cell size in arcasec, integer submultiple of 3600; default is 1 arcsec_

#### 2.  Create the infrastructure

If needed, `chmod +x` all the pre-existing scripts.

Run **`./00_create_infrastructure.sh`**, which will create from scratch the following scripts:

#### 3.  Run scripts

1.  For each topic defined in **workflow_parameters.conf**
    1.  `a_input_topic_n.sh` populates input tables: copies data inside the working schema; dumps them as single Polygons (redundant by FID) and check geometries; it starts the function `f_pop_input()`, which will write results into table `a_input_topic_n_`;
    2.  `b_clip_topic_n.sh` clips input geometries according to grid tile size; it starts the function `f_clip()`, which will write results into table `b_clip_topic_n`;
    3.  `c_rast_topic_n.sh` pseudo-rasterizes above clipped data: rasterize at cell size, then vectorize back collecting as MultiPolygons; it starts the function `f_raster()`, which will write results into table `c_raster_topic_n`;
    4.  `da_tiled_topic_n.sh` dumps and checks above geometries to single part, by tile, by topic; it starts the function `f_pop_tiled()`, which will write results into table `da_tiled_topic_n`;
2.  For aggregated results from above steps;
    1.  `db_tiled_all.sh` collects above geometries by tile in a single table; it starts the function `f_pop_tiled_temp()`, which will write results:
        + into table `db_tiled_temp` (for each topic);
        + into table `dc_tiled_all` (for all the topics);
    2.  `e_flat_all.sh` flat all above polygons by tile: breaks polygons at intersections, collects unique geometries, then calculates the centroid; it starts the function `f_flatter()`, which will write results into table `e_flat_all` (except the field cid; see later);
	3.  `f_attributes_all.sh` calculate and define numeric id (CID) for unique combinations of topics within the whole dataset; it starts the function `f_pop_atts_tile()`, which will write results:
	    + into table `fa_atts_tile` (all combinations of qid,tid,topic-array);
	    + into table `fb_atts_all` (all the unique combinations of topic-arry, with unique id-cid);  
    4.  `g_final_all.sh` JOINS flat geometries to unique combinations of attributes; it starts the function `f_flat_recode()`, which will write results:
        + into table `e_flat_all` (UPDATE only the field CID);
        + into table `g_flat_temp` (this is actually the result, just not ordered);
    5.  `h_output.sh` exports the flat final layer with dynamic SQL. **This is the only single core process, the rest is parallelized on multicores.**
3.   If needed, output is exported as raster with two additional steps:
    1.  `o_raster.sh` rasterize the flat layer at the same resolution of the pseudo-rasterization step
    2.  `p_export_raster` export the flat layer as external raster: vrt (gdal virtual raster) made out of tif files (which in turn are made by 10x10 blocks of original vector tiles). It also exports an attribute table (cid=pixel value=unique combination of input topics).

All the scripts from `a_*` to `g_*` (and `o_`, `p_`) must run in parallel, launching them in background.

EG: `./a_input_country.sh Ncores > logs/a_input_country_log.txt 2>&1`

where **Ncores** is the number of cores to assign to the process, and the following part of the command will write a detailed log.

All the **scripts** (not the **resulting tables**, which are striclty interconnected) are independent from each other: this allows to debug (through the aforementioned logs) every step, and check every output.

Still, all the commands can be collected and launched in a unique script.

EG:`z_do_it_all.sh` is the real world script used to generate DOPA CEP (read inline comments for instructions), which will generate the infrastructure according to the provided **workflow_parameters.conf**, and will launch in sequence all the scripts generated.

Further ancillary scripts for specific tasks should be self-explanatory:

EG: `01_create_filter.sh` gives the option to filter only few tiles (EG: specific BIOPAMA needs).

DOPA CEP has been generated using:

+  administrative_units.gaul_eez_dissolved_201912 (300 MultiPolygons)
+  habitats_and_biotopes.ecoregions_2019 (1097 MultiPolygons)
+  protected_sites.wdpa_202003 (238032 MultiPolygons)

| loop                   | stage                     | script                | n dedicated threads | n objects | time (seconds)    |
|------------------------|---------------------------|-----------------------|---------------------|-----------|-------------------|
| for each input topic   | a-input tables            | a_input_country.sh    | 72                  | 2409      | 11                |
|                        |                           | a_input_ecoregion.sh  | 72                  | 405496    | 83                |
|                        |                           | a_input_wdpa.sh       | 72                  | 940614    | 914               |
|                        | b-clip tables             | b_clip_country.sh     | 72                  | 77261     | 215               |
|                        |                           | b_clip_ecoregion.sh   | 72                  | 532073    | 626               |
|                        |                           | b_clip_wdpa.sh        | 72                  | 1004269   | 1353              |
|                        | c-raster tables           | c_rast_country.sh     | 72                  | 74235     | 3120              |
|                        |                           | c_rast_ecoregion.sh   | 72                  | 103900    | 4022              |
|                        |                           | c_rast_wdpa.sh        | 72                  | 278315    | 1691              |
|                        | da-tiled tables           | da_tiled_country.sh   | 72                  | 78551     | 266               |
|                        |                           | da_tiled_ecoregion.sh | 72                  | 651673    | 780               |
|                        |                           | da_tiled_wdpa.sh      | 72                  | 2144176   | 797               |
| for aggregated results | db-tiled aggregated table | db_tiled_all.sh       | 72                  | 2874400   | 6514              |
|                        | e-flat table              | e_flat_all.sh         | 36                  | 7425625   | 77273             |
|                        | f-attributes table        | f_attributes_all.sh   | 36                  | 424944    | 27294             |
|                        | g-final table             | g_final_all.sh        | 36                  | 598264    | 8524              |
|                        | h-output                  | h_output.sh           | 1                   | 598264    | 280               |
|                        | total                     |                       |                     |           | 133763 (37 hours) |


