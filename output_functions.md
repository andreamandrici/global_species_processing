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

   Code is: [output_functions.sql](./output_functions.sql).
