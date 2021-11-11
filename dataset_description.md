## IUCN tables

### IUCN spatial tables

Spatial data are available in the schema **`import_tables`** as **`spatial_corals, spatial_sharks_rays_chimaeras, spatial_mammals, spatial_amphibians`**, and they all contain the fields (relevants in **bold**):

+  fid bigint,
+  **geom** geometry(Polygon,4326),
+  **id_no** bigint,
+  binomial character varying(254),
+  **presence** integer,
+  **origin** integer,
+  **seasonal** integer,
+  compiler character varying(254),
+  yrcompiled integer,
+  citation character varying(254),
+  subspecies character varying(100),
+  subpop character varying(100),
+  source character varying(254),
+  island character varying(100),
+  tax_comm character varying(254),
+  dist_comm character varying(254),
+  generalisd integer,
+  legend character varying(100),
+  kingdom character varying(20),
+  phylum character varying(30),
+  class character varying(30),
+  order_ character varying(50),
+  family character varying(80),
+  genus character varying(80),
+  category character varying(5),
+  marine character varying(5),
+  terrestial character varying(5),
+  freshwater character varying(5),
+  shape_leng double precision,
+  shape_area double precision

These fields are (partially?) described on [Mapping and Distribution Data Attribute Standards for the IUCN Red List of Threatened Species](https://www.iucnredlist.org/resources/mappingstandards).

**fid** is a weak, temporary, serial field (is not unique in case of appended corals).
The field **id_no** is **unique by species**, but redundant by fields (within the ones of some interest for the analysis): presence, origin, seasonal, subspecies, subpop, (others?), and each row corresponds to a different polygon. A specific steps in spatial processing merge/dissolve these polygons by id_no, making this field unique, Primary Key. 

### IUCN non-spatial tables

All the non-spatial tables are available in the schema **`import_tables`** (relevants in **bold**):

+  non_spatial_all_other_fields
+  **non_spatial_assessments**
+  non_spatial_common_names
+  non_spatial_conservation_needed
+  non_spatial_countries
+  non_spatial_credits
+  non_spatial_dois
+  non_spatial_fao (not available for all the groups)
+  non_spatial_habitat
+  non_spatial_lme (not available for all the groups)
+  non_spatial_references
+  non_spatial_research_needed
+  non_spatial_simple_summary
+  non_spatial_synonyms
+  **non_spatial_taxonomy**
+  non_spatial_threats
+  non_spatial_usetrade

The available fields (by table) are (relevants in **bold**):
                                      
+  non_spatial_all_other_fields.aoo_range
+  non_spatial_all_other_fields.arearestricted_isrestricted
+  non_spatial_all_other_fields.assessmentid
+  non_spatial_all_other_fields.congregatory_value
+  non_spatial_all_other_fields.cropwildrelative_isrelative
+  non_spatial_all_other_fields.depthlower_limit
+  non_spatial_all_other_fields.depthupper_limit
+  non_spatial_all_other_fields.elevationlower_limit
+  non_spatial_all_other_fields.elevationupper_limit
+  non_spatial_all_other_fields.eoo_range
+  non_spatial_all_other_fields.fid
+  non_spatial_all_other_fields.generationlength_range
+  non_spatial_all_other_fields.inplaceeducationcontrolled_value
+  non_spatial_all_other_fields.inplaceeducationinternationallegislation_value
+  non_spatial_all_other_fields.inplaceeducationsubjecttoprograms_value
+  non_spatial_all_other_fields.inplacelandwaterprotectionareaplanned_value
+  non_spatial_all_other_fields.inplacelandwaterprotectioninpa_value
+  non_spatial_all_other_fields.inplacelandwaterprotectioninvasivecontrol_value
+  non_spatial_all_other_fields.inplacelandwaterprotectionpercentprotected_value
+  non_spatial_all_other_fields.inplacelandwaterprotectionsitesidentified_value
+  non_spatial_all_other_fields.inplaceresearchmonitoringscheme_value
+  non_spatial_all_other_fields.inplaceresearchrecoveryplan_value
+  non_spatial_all_other_fields.inplacespeciesmanagementexsitu_value
+  non_spatial_all_other_fields.inplacespeciesmanagementharvestplan_value
+  non_spatial_all_other_fields.internaltaxonid
+  non_spatial_all_other_fields.locationsnumber_range
+  non_spatial_all_other_fields.movementpatterns_pattern
+  non_spatial_all_other_fields.nothreats_nothreats
+  non_spatial_all_other_fields.populationsize_range
+  non_spatial_all_other_fields.scientificname
+  non_spatial_all_other_fields.severefragmentation_isfragmented
+  non_spatial_all_other_fields.subpopulationnumber_range
+  non_spatial_all_other_fields.threatsunknown_value
+  non_spatial_all_other_fields.yearofpopulationestimate_value
+  non_spatial_assessments.assessmentdate
+  non_spatial_assessments.assessmentid
+  non_spatial_assessments.conservationactions
+  non_spatial_assessments.criteriaversion
+  non_spatial_assessments.fid
+  non_spatial_assessments.habitat
+  **non_spatial_assessments.internaltaxonid**
+  non_spatial_assessments.language
+  non_spatial_assessments.population
+  non_spatial_assessments.populationtrend
+  non_spatial_assessments.possiblyextinct
+  non_spatial_assessments.possiblyextinctinthewild
+  non_spatial_assessments.range
+  non_spatial_assessments.rationale
+  non_spatial_assessments.realm
+  non_spatial_assessments.redlistcategory
+  non_spatial_assessments.redlistcriteria
+  non_spatial_assessments.scientificname
+  non_spatial_assessments.scopes
+  **non_spatial_assessments.systems**
+  non_spatial_assessments.threats
+  non_spatial_assessments.usetrade
+  non_spatial_assessments.yearlastseen
+  non_spatial_assessments.yearpublished
+  non_spatial_common_names.fid
+  non_spatial_common_names.internaltaxonid
+  non_spatial_common_names.language
+  non_spatial_common_names.main
+  non_spatial_common_names.name
+  non_spatial_common_names.scientificname
+  non_spatial_conservation_needed.assessmentid
+  non_spatial_conservation_needed.code
+  non_spatial_conservation_needed.fid
+  non_spatial_conservation_needed.internaltaxonid
+  non_spatial_conservation_needed.name
+  non_spatial_conservation_needed.note
+  non_spatial_conservation_needed.scientificname
+  non_spatial_countries.assessmentid
+  non_spatial_countries.code
+  non_spatial_countries.fid
+  non_spatial_countries.formerlybred
+  non_spatial_countries.internaltaxonid
+  non_spatial_countries.name
+  non_spatial_countries.origin
+  non_spatial_countries.presence
+  non_spatial_countries.scientificname
+  non_spatial_countries.seasonality
+  non_spatial_credits.assessmentid
+  non_spatial_credits.fid
+  non_spatial_credits.full
+  non_spatial_credits.internaltaxonid
+  non_spatial_credits.order
+  non_spatial_credits.scientificname
+  non_spatial_credits.text
+  non_spatial_credits.type
+  non_spatial_credits.value
+  non_spatial_dois.assessmentid
+  non_spatial_dois.doi
+  non_spatial_dois.fid
+  non_spatial_dois.internaltaxonid
+  non_spatial_dois.scientificname
+  non_spatial_fao.assessmentid
+  non_spatial_fao.code
+  non_spatial_fao.fid
+  non_spatial_fao.formerlybred
+  non_spatial_fao.internaltaxonid
+  non_spatial_fao.name
+  non_spatial_fao.origin
+  non_spatial_fao.presence
+  non_spatial_fao.scientificname
+  non_spatial_fao.seasonality
+  non_spatial_habitats.assessmentid
+  non_spatial_habitats.code
+  non_spatial_habitats.fid
+  non_spatial_habitats.internaltaxonid
+  non_spatial_habitats.majorimportance
+  non_spatial_habitats.name
+  non_spatial_habitats.scientificname
+  non_spatial_habitats.season
+  non_spatial_habitats.suitability
+  non_spatial_lme.assessmentid
+  non_spatial_lme.code
+  non_spatial_lme.fid
+  non_spatial_lme.formerlybred
+  non_spatial_lme.internaltaxonid
+  non_spatial_lme.name
+  non_spatial_lme.origin
+  non_spatial_lme.presence
+  non_spatial_lme.scientificname
+  non_spatial_lme.seasonality
+  non_spatial_references.assessmentid
+  non_spatial_references.author
+  non_spatial_references.citation
+  non_spatial_references.fid
+  non_spatial_references.internaltaxonid
+  non_spatial_references.scientificname
+  non_spatial_references.title
+  non_spatial_references.year
+  non_spatial_research_needed.assessmentid
+  non_spatial_research_needed.code
+  non_spatial_research_needed.fid
+  non_spatial_research_needed.internaltaxonid
+  non_spatial_research_needed.name
+  non_spatial_research_needed.note
+  non_spatial_research_needed.scientificname
+  non_spatial_simple_summary.assessmentid
+  non_spatial_simple_summary.authority
+  non_spatial_simple_summary.classname
+  non_spatial_simple_summary.criteriaversion
+  non_spatial_simple_summary.familyname
+  non_spatial_simple_summary.fid
+  non_spatial_simple_summary.genusname
+  non_spatial_simple_summary.infraauthority
+  non_spatial_simple_summary.infraname
+  non_spatial_simple_summary.infratype
+  non_spatial_simple_summary.internaltaxonid
+  non_spatial_simple_summary.kingdomname
+  non_spatial_simple_summary.ordername
+  non_spatial_simple_summary.phylumname
+  non_spatial_simple_summary.populationtrend
+  non_spatial_simple_summary.redlistcategory
+  non_spatial_simple_summary.redlistcriteria
+  non_spatial_simple_summary.scientificname
+  non_spatial_simple_summary.scopes
+  non_spatial_simple_summary.speciesname
+  non_spatial_synonyms.fid
+  non_spatial_synonyms.genusname
+  non_spatial_synonyms.infrarankauthor
+  non_spatial_synonyms.infratype
+  non_spatial_synonyms.internaltaxonid
+  non_spatial_synonyms.name
+  non_spatial_synonyms.scientificname
+  non_spatial_synonyms.speciesauthor
+  non_spatial_synonyms.speciesname
+  non_spatial_taxonomy.authority
+  **non_spatial_taxonomy.classname**
+  **non_spatial_taxonomy.familyname**
+  non_spatial_taxonomy.fid
+  **non_spatial_taxonomy.genusname**
+  non_spatial_taxonomy.infraauthority
+  non_spatial_taxonomy.infraname
+  non_spatial_taxonomy.infratype
+  **non_spatial_taxonomy.internaltaxonid**
+  **non_spatial_taxonomy.kingdomname**
+  **non_spatial_taxonomy.ordername**
+  **non_spatial_taxonomy.phylumname**
+  **non_spatial_taxonomy.scientificname**
+  **non_spatial_taxonomy.speciesname**
+  non_spatial_taxonomy.subpopulationname
+  non_spatial_taxonomy.taxonomicnotes
+  non_spatial_threats.ancestry
+  non_spatial_threats.assessmentid
+  non_spatial_threats.code
+  non_spatial_threats.fid
+  non_spatial_threats.ias
+  non_spatial_threats.internaltaxonid
+  non_spatial_threats.internationaltrade
+  non_spatial_threats.name
+  non_spatial_threats.scientificname
+  non_spatial_threats.scope
+  non_spatial_threats.severity
+  non_spatial_threats.stresscode
+  non_spatial_threats.stressname
+  non_spatial_threats.text
+  non_spatial_threats.timing
+  non_spatial_threats.virus
+  non_spatial_usetrade.assessmentid
+  non_spatial_usetrade.code
+  non_spatial_usetrade.fid
+  non_spatial_usetrade.internaltaxonid
+  non_spatial_usetrade.international
+  non_spatial_usetrade.name
+  non_spatial_usetrade.national
+  non_spatial_usetrade.other
+  non_spatial_usetrade.scientificname
+  non_spatial_usetrade.subsistence

## BIRDLIFE tables
Spatial and non-spatial data for **birds** are available as foreign tables pointing at gdb file in schema **species_birdlife_201903**, and they contain the fields (relevants in **bold**):

### Birdlife: spatial table "All_species"

+  fid bigint,
+  **shape geometry(MultiPolygon,4326)**,
+  **sisid** integer **(corresponds to IUCN spatial table field: id_no)**,
+  **sciname** character varying  **(corresponds to IUCN spatial table field: binomial)**,
+  date_ character varying,
+  source character varying,
+  **presence** integer,
+  **origin** integer,
+  **seasonal** integer,
+  data_sens character varying,
+  sens_comm character varying,
+  compiler character varying,
+  tax_com character varying,
+  dist_com character varying,
+  reviewers character varying,
+  citation character varying,
+  version character varying,
+  shape_length double precision,
+  shape_area double precision,
+  filename character varying,
+  vxcount integer

### Birdlife: non-spatial table "SppListAdditional"

+  fid bigint,
+  **id_no** integer,
+  **binomial** character varying,
+  common_name character varying,
+  **kingdom** character varying,
+  **phylum** character varying,
+  **class** character varying,
+  **order_** character varying,
+  **family** character varying,
+  **genus** character varying,
+  **category** character varying,
+  criteria character varying,
+  assessor character varying,
+  assessment_date timestamp with time zone,
+  **biome_marine** character varying **(corresponds to IUCN spatial table field: marine)**,
+  **biome_terrestrial** character varying **(corresponds to IUCN spatial table field: terrestrial)**,
+  **biome_freshwater** character varying **(corresponds to IUCN spatial table field: freshwater)**,
+  publication_yr smallint,
+  population_trend character varying

### Birdlife: non-spatial table "BirdLife_HBW_Taxonomic_Checklist_V4"

+  fid bigint,
+  sequence integer,
+  **order_** character varying,
+  **family_name** character varying **(corresponds to IUCN spatial table field: family)**,
+  family character varying,
+  subfamily_name character varying,
+  tribe_name character varying,
+  common_name character varying,
+  **scientific_name** character varying **(corresponds to IUCN spatial table field: binomial)**,
+  authority character varying,
+  birdlife_taxonomic_treatment character varying,
+  **f2019_iucn_red_list_category** character varying **(corresponds to IUCN spatial table field: category)**,
+  synonyms character varying,
+  alternative_common_names character varying,
+  taxonomic_notes character varying,
+  taxonomic_source character varying,
+  **sisrecid** integer **(corresponds to IUCN spatial table field: id_no)**,
+  **marine character varying**,
+  **freshwater character varying**,
+  **terrestrial character varying**

An additional non spatial table is available as foreign table pointing at xlsx file in schema/table **species_birdlife_non_spatial_201903.sheet1**, and contains just a list with five species ( **22712690, 22716650, 22732350, 103774724, 103878817**) missing information related to ecosystems.

**The analysis and selection of the relevant fields out of the total (216) is one of the target of the preprocessing task.**

