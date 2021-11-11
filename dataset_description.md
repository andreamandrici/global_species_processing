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

All the non-spatial tables are available in the schema **`import_tables`**:

+  non_spatial_all_other_fields
+  non_spatial_assessments
+  non_spatial_birds
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
+  non_spatial_taxonomy
+  non_spatial_threats
+  non_spatial_usetrade


The available fields (by table) are:
                                      
+  all_other_fields.aoo_range
+  all_other_fields.arearestricted_isrestricted
+  all_other_fields.assessmentid
+  all_other_fields.congregatory_value
+  all_other_fields.cropwildrelative_isrelative
+  all_other_fields.depthlower_limit
+  all_other_fields.depthupper_limit
+  all_other_fields.elevationlower_limit
+  all_other_fields.elevationupper_limit
+  all_other_fields.eoo_range
+  all_other_fields.fid
+  all_other_fields.generationlength_range
+  all_other_fields.inplaceeducationcontrolled_value
+  all_other_fields.inplaceeducationinternationallegislation_value
+  all_other_fields.inplaceeducationsubjecttoprograms_value
+  all_other_fields.inplacelandwaterprotectionareaplanned_value
+  all_other_fields.inplacelandwaterprotectioninpa_value
+  all_other_fields.inplacelandwaterprotectioninvasivecontrol_value
+  all_other_fields.inplacelandwaterprotectionpercentprotected_value
+  all_other_fields.inplacelandwaterprotectionsitesidentified_value
+  all_other_fields.inplaceresearchmonitoringscheme_value
+  all_other_fields.inplaceresearchrecoveryplan_value
+  all_other_fields.inplacespeciesmanagementexsitu_value
+  all_other_fields.inplacespeciesmanagementharvestplan_value
+  all_other_fields.internaltaxonid
+  all_other_fields.locationsnumber_range
+  all_other_fields.movementpatterns_pattern
+  all_other_fields.nothreats_nothreats
+  all_other_fields.populationsize_range
+  all_other_fields.scientificname
+  all_other_fields.severefragmentation_isfragmented
+  all_other_fields.subpopulationnumber_range
+  all_other_fields.threatsunknown_value
+  all_other_fields.yearofpopulationestimate_value
+  assessments.assessmentdate
+  assessments.assessmentid
+  assessments.conservationactions
+  assessments.criteriaversion
+  assessments.fid
+  assessments.habitat
+  assessments.internaltaxonid
+  assessments.language
+  assessments.population
+  assessments.populationtrend
+  assessments.possiblyextinct
+  assessments.possiblyextinctinthewild
+  assessments.range
+  assessments.rationale
+  assessments.realm
+  assessments.redlistcategory
+  assessments.redlistcriteria
+  assessments.scientificname
+  assessments.scopes
+  assessments.systems
+  assessments.threats
+  assessments.usetrade
+  assessments.yearlastseen
+  assessments.yearpublished
+  common_names.fid
+  common_names.internaltaxonid
+  common_names.language
+  common_names.main
+  common_names.name
+  common_names.scientificname
+  conservation_needed.assessmentid
+  conservation_needed.code
+  conservation_needed.fid
+  conservation_needed.internaltaxonid
+  conservation_needed.name
+  conservation_needed.note
+  conservation_needed.scientificname
+  countries.assessmentid
+  countries.code
+  countries.fid
+  countries.formerlybred
+  countries.internaltaxonid
+  countries.name
+  countries.origin
+  countries.presence
+  countries.scientificname
+  countries.seasonality
+  credits.assessmentid
+  credits.fid
+  credits.full
+  credits.internaltaxonid
+  credits.order
+  credits.scientificname
+  credits.text
+  credits.type
+  credits.value
+  dois.assessmentid
+  dois.doi
+  dois.fid
+  dois.internaltaxonid
+  dois.scientificname
+  fao.assessmentid
+  fao.code
+  fao.fid
+  fao.formerlybred
+  fao.internaltaxonid
+  fao.name
+  fao.origin
+  fao.presence
+  fao.scientificname
+  fao.seasonality
+  habitats.assessmentid
+  habitats.code
+  habitats.fid
+  habitats.internaltaxonid
+  habitats.majorimportance
+  habitats.name
+  habitats.scientificname
+  habitats.season
+  habitats.suitability
+  lme.assessmentid
+  lme.code
+  lme.fid
+  lme.formerlybred
+  lme.internaltaxonid
+  lme.name
+  lme.origin
+  lme.presence
+  lme.scientificname
+  lme.seasonality
+  plant_specific.assessmentid
+  plant_specific.code
+  plant_specific.fid
+  plant_specific.internaltaxonid
+  plant_specific.name
+  plant_specific.scientificname
+  references.assessmentid
+  references.author
+  references.citation
+  references.fid
+  references.internaltaxonid
+  references.scientificname
+  references.title
+  references.year
+  research_needed.assessmentid
+  research_needed.code
+  research_needed.fid
+  research_needed.internaltaxonid
+  research_needed.name
+  research_needed.note
+  research_needed.scientificname
+  simple_summary.assessmentid
+  simple_summary.authority
+  simple_summary.classname
+  simple_summary.criteriaversion
+  simple_summary.familyname
+  simple_summary.fid
+  simple_summary.genusname
+  simple_summary.infraauthority
+  simple_summary.infraname
+  simple_summary.infratype
+  simple_summary.internaltaxonid
+  simple_summary.kingdomname
+  simple_summary.ordername
+  simple_summary.phylumname
+  simple_summary.populationtrend
+  simple_summary.redlistcategory
+  simple_summary.redlistcriteria
+  simple_summary.scientificname
+  simple_summary.scopes
+  simple_summary.speciesname
+  synonyms.fid
+  synonyms.genusname
+  synonyms.infrarankauthor
+  synonyms.infratype
+  synonyms.internaltaxonid
+  synonyms.name
+  synonyms.scientificname
+  synonyms.speciesauthor
+  synonyms.speciesname
+  taxonomy.authority
+  taxonomy.classname
+  taxonomy.familyname
+  taxonomy.fid
+  taxonomy.genusname
+  taxonomy.infraauthority
+  taxonomy.infraname
+  taxonomy.infratype
+  taxonomy.internaltaxonid
+  taxonomy.kingdomname
+  taxonomy.ordername
+  taxonomy.phylumname
+  taxonomy.scientificname
+  taxonomy.speciesname
+  taxonomy.subpopulationname
+  taxonomy.taxonomicnotes
+  threats.ancestry
+  threats.assessmentid
+  threats.code
+  threats.fid
+  threats.ias
+  threats.internaltaxonid
+  threats.internationaltrade
+  threats.name
+  threats.scientificname
+  threats.scope
+  threats.severity
+  threats.stresscode
+  threats.stressname
+  threats.text
+  threats.timing
+  threats.virus
+  usetrade.assessmentid
+  usetrade.code
+  usetrade.fid
+  usetrade.internaltaxonid
+  usetrade.international
+  usetrade.name
+  usetrade.national
+  usetrade.other
+  usetrade.scientificname
+  usetrade.subsistence



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

