### non-spatial

An _output_schema_ is created.
Temporary tables are created, selecting id_no according to existance in previously created table: `import_tables.all_species_list`

+ **Taxonomy** information is taken from _import_tables.non_spatial_taxonomy_
+ **Ecosystems** information is taken from _import_tables.non_spatial_assessments_, field _systems_
+ **Category** information is taken from _import_tables.non_spatial_assessments_, field _redlistcategory_
+ **Threatened** information is derived from _import_tables.non_spatial_assessments_, field _redlistcategory_, selecting _'Critically Endangered','Endangered' and 'Vulnerable'_ species.
+ **Country** information is derived from _import_tables.non_spatial_countries, field _code_ (ISO2 country code), selecting in the fields
	+  `presence`: **Extant**
	+  `origin`:  **Native**, **Reintroduced**, **Assisted Colonisation**
	+  `seasonality`:**Non-Breeding Season**, **Breeding Season**, **Resident**, _**NULL**_ (this is a weakness, we wait for clairfication from IUCN).
+ **conservation_needed** information is derived from _import_tables.non_spatial_conservation_needed_
+ **habitats** information is derived from _import_tables.non_spatial_habitats_
+ **research_needed** information is derived from _import_tables.non_spatial_research_needed_
+ **stress** information is derived from _import_tables.non_spatial_threats_, fields _stresscode_,_stressname_ 
+ **threats** information is derived from _import_tables.non_spatial_threats_
+ **usetrade** information is derived from _import_tables.non_spatial_usetrade_
	 
After processing (scripted in [non_spatial_processing.sql](./non_spatial_processing.sql)), the output schema contains:

+  output_schema.dopa_species
   +  id_no bigint
   +  phylum text
   + class text
   + order_ text
   + family text
   + genus text
   + binomial text
   + endemic boolean
   + ecosystems text[]
   + category text
   + threatened boolean
   + country text[]
   + country_n integer
   + conservation_needed text[]
   + habitats text[]
   + research_needed text[]
   + stresses text[]
   + threats text[]
   + usetrade integer[]

+  mt_attributes
   +  mt_categories
   +  mt_conservation_needed
   +  mt_countries
   +  mt_habitats
   +  mt_research_needed
   +  mt_stresses
   +  mt_threats
   +  mt_usetrade

+  lookup tables (lt_):
   +  lt_species_conservation_needed
   +  lt_species_countries;
   +  lt_species_habitats
   +  lt_species_research_needed
   +  lt_species_stresses
   +  lt_species_threats
   +  lt_species_usetrade

	
+  derived tables (dt_):
   +  dt_species_conservation_needed
   +  dt_species_country_endemics
   +  dt_species_ecosystems
   +  dt_species_habitats
   +  dt_species_research_needed
   +  dt_species_stresses
   +  dt_species_threatened
   +  dt_species_threats
   +  dt_species_usetrade

### Outputs

The final step creates:
+  mt_species_output: this table rebuild relations within `mt_attributes` table and all  `dt_` tables.
+  get_list_species_output: this function interrogates the above table, and returns a list of species, allowing filtering on columns
+  get_single_species_output: this function interrogates the above table filtering on a single id_no, and returns related informations expanded, with names
+  The following functions interrogate the related main tables, and shows existing values that can be used as filters on the main function:
   +  get_list_categories
   +  get_list_conservation_needed
   +  get_list_countries
   +  get_list_habitats
   +  get_list_research_needed 
   +  get_list_stresses
   +  get_list_threats
   +  get_list_usetrade


   Code is: [creates_output_table_function.sql](./species_2020/creates_output_table_function.sql).



3.  Birdlife **geometric** data are processed, and **selected attributes** are extracted, in the way to get the **same structure** of processed IUCN data. Species flagged as **sensitive** are removed to avoid to disseminate their distribution (directly, or as intersection with protected areas). For Birdlife 2019-1 they are: *Thalasseus bernsteini* and *Garrulax courtoisi* (id_no: 22694585,22732350).

    Code is: [creates_attributes_sp_birdlife.sql](./species_2020/creates_attributes_sp_birdlife.sql).
    Output table is: **species_202001.attributes_sp_birdlife**.

4.  IUCN and Birdlife **selected attributes from geometric** data are appended each other.

    Code is: [creates_attributes_sp.sql](./species_2020/creates_attributes_sp.sql).
    Output table is: **species_202001.attributes_sp**.
 
	
	Code is: [creates_attributes.sql](./species_2020/creates_attributes.sql).
    Output table is: **species_202001.attributes**.

6.  Spatial tables present other differences which need harmonization, which will be solved with a specific flattening workflow: 
    +  Geometric objects are polygons for IUCN source, and MultiPolygons for Birdlife source
    +  IDs (id_no and sisrecid) are redundant (by presence, origin, seasonality).

### spatial

"Sytematic" groups (_corals, sharks_rays_chimaeras, amphibians, birds, mammals_) are processed independently using the flattening workflow (fully described in another section).

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
