### non-spatial

An _output_schema_ is created.

After processing (scripted in [non_spatial_processing.sql](./non_spatial_processing.sql)), the output schema contains:

+  **dopa_species** (main table)
   + `id_no` bigint, derived from _non_spatial_taxonomy_, selected if existing in previously created table _all_species_list_
   + `phylum` text, derived from _non_spatial_taxonomy_
   + `class` text, derived from _non_spatial_taxonomy_
   + `order_` text, derived from _non_spatial_taxonomy_
   + `family` text, derived from _non_spatial_taxonomy_
   + `genus` text, derived from _non_spatial_taxonomy_
   + `binomial`, text derived from _non_spatial_taxonomy_
   + `endemic`, boolean
   + `ecosystems` text[], derived from _non_spatial_assessments_, field _systems_
   + `category` text, derived from _non_spatial_assessments_, field _redlistcategory_
   + `threatened` boolean, derived from _non_spatial_assessments_, field _redlistcategory_, selecting _'Critically Endangered','Endangered' and 'Vulnerable'_ species
   + `country` text[], derived from _non_spatial_countries, field _code_ (ISO2 country code), selecting in the fields:
	 +  _presence_: 'Extant'
	 +  _origin_:  _'Native','Reintroduced','Assisted Colonisation'_
	 +  _seasonality_: _'Non-Breeding Season','Breeding Season','Resident',NULL_ (this last one is a weakness, we wait for clairfication from IUCN).
   + `country_n` integer, derived from counts on previous field `country`,
   + `conservation`_needed text[], derived from _non_spatial_conservation_needed_
   + `habitats` text[], derived from _non_spatial_habitats_
   + `research`_needed text[], derived from _non_spatial_research_needed_
   + `stresses` text[], derived from _non_spatial_threats_, fields _stresscode_,_stressname_ 
   + `threats` text[], derived from _non_spatial_threats_
   + `usetrade` integer[], derived from _non_spatial_usetrade_
+  **class_species_category**
+  **class_species_conservation_needed**
+  **class_species_habitats**
+  **class_species_research_needed**
+  **class_species_stresses**
+  **class_species_threats**
+  **class_species_usetrade**.

### Outputs (TO BE REVIEWED)

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
