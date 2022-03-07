## spatial

Spatial tables present differences which need harmonization, solved with a specific [flattening](https://github.com/andreamandrici/dopa_workflow) workflow: 
  +  Geometric objects are
    +  polygons for IUCN source
    +  MultiPolygons for Birdlife source
  +  IDs (id_no) are redundant (by presence, origin, seasonality)
  +  often need geometry fix.

"Sytematic" groups (_corals, sharks_rays_chimaeras, amphibians, birds, mammals_) are processed independently.

## input dataset

Geometries of all groups are filtered to include only species common to both dataset (spatial and non-spatial; selected in the previous "Species selection" step).

Code is: [spatial_processing.sql](./spatial/spatial_processing.sql).

Output tables are:

+  **spatial_tables.geom_corals**
+  **spatial_tables.geom_amphibians**
+  **spatial_tables.geom_sharks**
+  **spatial_tables.geom_mammals**
+  **spatial_tables.geom_birds**

## geometry fix

Geometries are [checked (and, when needed, fixed)](./geometry_fix/) for validity and type.

## groups flattening

[Flattening](https://andreamandrici.github.io/dopa_workflow/flattening/) at 10 arcsec (~900 meters at equator) is applied to each group. Steps `00_create infrastructure`) and `a_import input` tables) are executed independently. If needed, geometry fix is applied after step `a_`.

All the other steps are executed inside `z_do_it_all.sh` script.

xxxxxxxx edit from here

Outputs are exported as raster vrt, with attribute table (to be used for reclass) containing:
"cid"|"species"|"richness"|"endemic_threatened"|"richness_endemic_threatened"
+  cid = pixel_value
+  species = array of species existing in the pixel
+  richness (number of species) by pixel
+  endemic_threatened = array of species which are endemic and threatened. **This information is derived from non-spatial processing**.    
+  richness_endemic_threatened = richness of endemic and threatened species by pixel.

[Environment and log files](./spatial/flattening/) are reported. SQL files are also reported, when geometry fix was needed (after step `a_` of flattening).



each taxon has configuration parameters and generating script.
template folder is needed INSIDE taxon folder

additional steps:
`taxon/sql/attributes_taxon.sql` --> generates additional attribute table
`taxon/p_export_raster.sh` --> export attribute table as CSV

`export_raster/sql/export_raster_taxon.sql` --> change cid in eport_raster.h_flat
`export_raster/z_do_it_all.sh' (steps o,p,q) ---> export raster export_raster.h_flat

final_species_schema.sql --> collects all taxa in schema species_year_all_taxa

flatter sequence

--db_tiled_all.sh
--execute schema.f_pop_tiled_temp
--writes on schema.db_tiled_temp
--execute A SELECT FROM schema.db_tiled_temp
--writes on schema.dc_tiled_all
SELECT * FROM cep202202.db_tiled_temp WHERE qid = 50683 
SELECT * FROM cep202202.dc_tiled_all WHERE qid = 50683 

--e_flat_all.sh
--executes schema.f_flatter()
--writes on schema.e_flat_all
--writes on schema.fb_atts_all
SELECT * FROM cep202202.e_flat_all WHERE qid = 50683 AND cid IN (286964,286766)
SELECT * FROM cep202202.fb_atts_all WHERE cid IN (286964,286766)

--f_attributes_all.sh
--executes schema.f_pop_atts_file()
--writes on schema.fa_atts_tile
SELECT * FROM cep202202.fa_atts_tile WHERE qid = 50683 AND tid IN (8,1)

--g_final_all.sh
--execute schema.f_flat_recode()
--which updates schema.e_flat_all AS SELECT tid,cid FROM schema.fa_atts_tile JOIN schema.fb_atts_all USING(country,ecoregion,wdpa)
--writes on schema.g_flat_temp
SELECT * FROM cep202202.g_flat_temp WHERE qid = 50683 AND cid IN (286964,286766)

--h_output.sh
--executes a SELECT * FROM g_flat_temp
--writes on schema.h_flat
SELECT * FROM cep202202.fb_atts_all WHERE country && '{188}' AND ecoregion && '{80519}' AND wdpa && '{0}'


**Some of the species distribution ranges are too small to be (psuedo)rasterised at 1 Km (EG: 8 amphibians are left out, of which 3 are Data Deficient, 4 are Critically Endangered). They can be recovered assigning an artificial minimum range of 1 sqkm (the single pixel intersecting the centroid), then calculating the "boost" applied as ratio artificial/original. This goes in the todo-list**
