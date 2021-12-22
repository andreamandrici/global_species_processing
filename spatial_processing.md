### spatial

Spatial tables present other differences which need harmonization, which are be solved with a specific [flattening](https://github.com/andreamandrici/dopa_workflow) workflow: 
  +  Geometric objects are polygons for IUCN source, and MultiPolygons for Birdlife source
  +  IDs (id_no) are redundant (by presence, origin, seasonality).

"Sytematic" groups (_corals, sharks_rays_chimaeras, amphibians, birds, mammals_) are processed independently.

#### input dataset

Geometries of all groups are filtered to include only species (selected in the previous "harmonization - step 5").

Code is: [creates_geoms.sql](./species_2020/creates_geoms.sql).
Output tables are:

+  **species_202001.geom_corals**
+  **species_202001.geom_sharks_rays_chimaeras**
+  **species_202001.geom_amphibians**
+  **species_202001.geom_mammals**
+  **species_202001.geom_birds**

#### groups flattening

[Flattening](../../flattening/) at 30 arcsec (~900 meters at equator) is applied to each group. Steps `00_create infrastructure`) and `a_import input` tables) are executed independently.

If needed, geometry fix is applied after step `a_`.

All the other steps are executed inside `z_do_it_all.sh` script.

Outputs are exported as raster vrt, with attribute table (to be used for reclass) containing:
"cid"|"species"|"richness"|"endemic_threatened"|"richness_endemic_threatened"
+  cid = pixel_value
+  species = array of species existing in the pixel
+  richness (number of species) by pixel
+  endemic_threatened = array of species which are endemic and threatened. **This information is derived from non-spatial processing**.    
+  richness_endemic_threatened = richness of endemic and threatened species by pixel.

[Environment](https://github.com/andreamandrici/dopa_workflow/tree/master/processing/species/species_2020/confs) and [log](https://github.com/andreamandrici/dopa_workflow/tree/master/processing/species/species_2020/logs) files are reported.
[SQL](https://github.com/andreamandrici/dopa_workflow/tree/master/processing/species/species_2020/sql) files are also reported, when geometry fix was needed (after step `a_` of flattening).

**Some of the species distribution ranges are too small to be (psuedo)rasterised at 1 Km (EG: 8 amphibians are left out, of which 3 are Data Deficient, 4 are Critically Endangered). They can be recovered assigning an artificial minimum range of 1 sqkm (the single pixel intersecting the centroid), then calculating the "boost" applied as ratio artificial/original. This goes in the todo-list**
