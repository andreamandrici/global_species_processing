-----------------------------------------------------------------------------
DROP SCHEMA IF EXISTS foreign_data CASCADE;
CREATE SCHEMA foreign_data;
-----------------------------------------------------------------------------
DROP SERVER IF EXISTS species_iucn_spatial_202607_fdw CASCADE;
CREATE SERVER species_iucn_spatial_202607_fdw
  FOREIGN DATA WRAPPER ogr_fdw
  OPTIONS (
	datasource '/data/swap/species_2026/spatial',
	format 'ESRI Shapefile' );
------------------------------------------------------------------------------------------------------
IMPORT FOREIGN SCHEMA ogr_all FROM SERVER species_iucn_spatial_202607_fdw INTO foreign_data;
-------------------------------------------------------------------------------------------------------
DO
$$
DECLARE
    tbname name;
BEGIN
   FOR tbname IN SELECT foreign_table_name::text FROM information_schema._pg_foreign_tables WHERE foreign_table_schema::text = 'foreign_data' LOOP
        RAISE NOTICE 'CREATING TABLE : species_2026_input_data_original.%', tbname;
        EXECUTE format('CREATE TABLE species_2026_input_data_original.%I AS SELECT * FROM foreign_data.%I;', tbname,tbname);
   END LOOP;
END;
$$ LANGUAGE plpgsql;
-------------------------------------------------------------------------------------------------------
DROP SCHEMA foreign_data CASCADE;
CREATE SCHEMA foreign_data;
-------------------------------------------------------------------------------------------------------
DROP SERVER IF EXISTS species_iucn_spatial_202607_fdw CASCADE;
-------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
CREATE SCHEMA species_2026;
-------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
--corals
DROP TABLE IF EXISTS species_2026.spatial_corals;
CREATE TABLE species_2026.spatial_corals AS
SELECT
fid,geom,id_no,sci_name::text,presence,origin,seasonal,compiler::text,yrcompiled,citation::text,subspecies::text,subpop::text,source::text,island::text,tax_comm::text,dist_comm::text,generalisd,legend::text,kingdom::text,phylum::text,class::text,order_::text,family::text,genus::text,category::text,marine::text,terrestria::text,freshwater::text,shape_leng,shape_area
FROM species_2026_input_data_original.reef_forming_corals_part1 WHERE presence IN (1) AND origin IN (1,2,6) AND seasonal IN (1,2,3)
UNION ALL
SELECT
fid,geom,id_no,sci_name::text,presence,origin,seasonal,compiler::text,yrcompiled,citation::text,subspecies::text,subpop::text,source::text,island::text,tax_comm::text,dist_comm::text,generalisd,legend::text,kingdom::text,phylum::text,class::text,order_::text,family::text,genus::text,category::text,marine::text,terrestria::text,freshwater::text,shape_leng,shape_area
FROM species_2026_input_data_original.reef_forming_corals_part2 WHERE presence IN (1) AND origin IN (1,2,6) AND seasonal IN (1,2,3)
UNION ALL
SELECT
fid,geom,id_no,sci_name::text,presence,origin,seasonal,compiler::text,yrcompiled,citation::text,subspecies::text,subpop::text,source::text,island::text,tax_comm::text,dist_comm::text,generalisd,legend::text,kingdom::text,phylum::text,class::text,order_::text,family::text,genus::text,category::text,marine::text,terrestria::text,freshwater::text,shape_leng,shape_area
FROM species_2026_input_data_original.reef_forming_corals_part3 WHERE presence IN (1) AND origin IN (1,2,6) AND seasonal IN (1,2,3)
ORDER BY id_no;
-------------------------------------------------------------------------------------------------------
--amphibians
DROP TABLE IF EXISTS species_2026.spatial_amphibians;
CREATE TABLE species_2026.spatial_amphibians AS
SELECT
fid,geom,id_no,sci_name::text,presence,origin,seasonal,compiler::text,yrcompiled,citation::text,subspecies::text,subpop::text,source::text,island::text,tax_comm::text,dist_comm::text,generalisd,legend::text,kingdom::text,phylum::text,class::text,order_::text,family::text,genus::text,category::text,marine::text,terrestria::text,freshwater::text,shape_leng,shape_area
FROM species_2026_input_data_original.amphibians_part1 WHERE presence IN (1) AND origin IN (1,2,6) AND seasonal IN (1,2,3)
UNION ALL
SELECT
fid,geom,id_no,sci_name::text,presence,origin,seasonal,compiler::text,yrcompiled,citation::text,subspecies::text,subpop::text,source::text,island::text,tax_comm::text,dist_comm::text,generalisd,legend::text,kingdom::text,phylum::text,class::text,order_::text,family::text,genus::text,category::text,marine::text,terrestria::text,freshwater::text,shape_leng,shape_area
FROM species_2026_input_data_original.amphibians_part2 WHERE presence IN (1) AND origin IN (1,2,6) AND seasonal IN (1,2,3)
ORDER BY id_no;
-------------------------------------------------------------------------------------------------------
--reptiles
DROP TABLE IF EXISTS species_2026.spatial_reptiles;
CREATE TABLE species_2026.spatial_reptiles AS
SELECT
fid,geom,id_no,sci_name::text,presence,origin,seasonal,compiler::text,yrcompiled,citation::text,subspecies::text,subpop::text,source::text,island::text,tax_comm::text,dist_comm::text,generalisd,legend::text,kingdom::text,phylum::text,class::text,order_::text,family::text,genus::text,category::text,marine::text,terrestria::text,freshwater::text,shape_leng,shape_area
FROM species_2026_input_data_original.reptiles_part1 WHERE presence IN (1) AND origin IN (1,2,6) AND seasonal IN (1,2,3)
UNION ALL
SELECT
fid,geom,id_no,sci_name::text,presence,origin,seasonal,compiler::text,yrcompiled,citation::text,subspecies::text,subpop::text,source::text,island::text,tax_comm::text,dist_comm::text,generalisd,legend::text,kingdom::text,phylum::text,class::text,order_::text,family::text,genus::text,category::text,marine::text,terrestria::text,freshwater::text,shape_leng,shape_area
FROM species_2026_input_data_original.reptiles_part2 WHERE presence IN (1) AND origin IN (1,2,6) AND seasonal IN (1,2,3)
ORDER BY id_no;
-------------------------------------------------------------------------------------------------------
--mammals
DROP TABLE IF EXISTS species_2026.spatial_mammals;
CREATE TABLE species_2026.spatial_mammals AS
SELECT
fid,geom,id_no,sci_name::text,presence,origin,seasonal,compiler::text,yrcompiled,citation::text,subspecies::text,subpop::text,source::text,island::text,tax_comm::text,dist_comm::text,generalisd,legend::text,kingdom::text,phylum::text,class::text,order_::text,family::text,genus::text,category::text,marine::text,terrestria::text,freshwater::text,shape_leng,shape_area
FROM species_2026_input_data_original.mammals_part1 WHERE presence IN (1) AND origin IN (1,2,6) AND seasonal IN (1,2,3)
UNION ALL
SELECT
fid,geom,id_no,sci_name::text,presence,origin,seasonal,compiler::text,yrcompiled,citation::text,subspecies::text,subpop::text,source::text,island::text,tax_comm::text,dist_comm::text,generalisd,legend::text,kingdom::text,phylum::text,class::text,order_::text,family::text,genus::text,category::text,marine::text,terrestria::text,freshwater::text,shape_leng,shape_area
FROM species_2026_input_data_original.mammals_part2 WHERE presence IN (1) AND origin IN (1,2,6) AND seasonal IN (1,2,3)
ORDER BY id_no;
-------------------------------------------------------------------------------------------------------
--sharks_rays_chimaeras
DROP TABLE IF EXISTS species_2026.spatial_sharks;
CREATE TABLE species_2026.spatial_sharks AS
SELECT
fid,geom,id_no,sci_name::text,presence,origin,seasonal,compiler::text,yrcompiled,citation::text,subspecies::text,subpop::text,source::text,island::text,tax_comm::text,dist_comm::text,generalisd,legend::text,kingdom::text,phylum::text,class::text,order_::text,family::text,genus::text,category::text,marine::text,terrestria::text,freshwater::text,shape_leng,shape_area
FROM species_2026_input_data_original.spatial_sharks_rays_chimaeras WHERE presence IN (1) AND origin IN (1,2,6) AND seasonal IN (1,2,3)
ORDER BY id_no;
--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
-- NON SPATIAL
-----------------------------------------------------------------------------
DROP SERVER IF EXISTS species_iucn_non_spatial_1_202607_fdw CASCADE;
CREATE SERVER species_iucn_non_spatial_1_202607_fdw
  FOREIGN DATA WRAPPER ogr_fdw
  OPTIONS (
	datasource '/data/swap/species_2026/nonspatial/all_taxa',
	format 'CSV' );
------------------------------------------------------------------------------------------------------
IMPORT FOREIGN SCHEMA ogr_all FROM SERVER species_iucn_non_spatial_1_202607_fdw INTO foreign_data;
-------------------------------------------------------------------------------------------------------
DO
$$
DECLARE
    tbname name;
    newname name;
BEGIN
    FOR tbname IN
        SELECT foreign_table_name::text
        FROM information_schema._pg_foreign_tables
        WHERE foreign_table_schema = 'foreign_data'
    LOOP
        newname := tbname || '_1';

        RAISE NOTICE 'CREATING TABLE : foreign_data.%', newname;

        EXECUTE format(
            'CREATE TABLE foreign_data.%I AS SELECT * FROM foreign_data.%I',
            newname,
            tbname
        );
    END LOOP;
END;
$$ LANGUAGE plpgsql;
-------------------------------------------------------------------------------------------------------
DO
$$
DECLARE
    tbname name;
BEGIN
    FOR tbname IN
        SELECT foreign_table_name
        FROM information_schema._pg_foreign_tables
        WHERE foreign_table_schema = 'foreign_data'
    LOOP
        EXECUTE format('DROP FOREIGN TABLE foreign_data.%I', tbname);
    END LOOP;
END;
$$ LANGUAGE plpgsql;
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
DROP SERVER IF EXISTS species_iucn_non_spatial_2_202607_fdw CASCADE;
CREATE SERVER species_iucn_non_spatial_2_202607_fdw
  FOREIGN DATA WRAPPER ogr_fdw
  OPTIONS (
	datasource '/data/swap/species_2026/nonspatial/passeriformes',
	format 'CSV' );
------------------------------------------------------------------------------------------------------
IMPORT FOREIGN SCHEMA ogr_all FROM SERVER species_iucn_non_spatial_2_202607_fdw INTO foreign_data;
-------------------------------------------------------------------------------------------------------
DO
$$
DECLARE
    tbname name;
    newname name;
BEGIN
    FOR tbname IN
        SELECT foreign_table_name::text
        FROM information_schema._pg_foreign_tables
        WHERE foreign_table_schema = 'foreign_data'
    LOOP
        newname := tbname || '_2';

        RAISE NOTICE 'CREATING TABLE : foreign_data.%', newname;

        EXECUTE format(
            'CREATE TABLE foreign_data.%I AS SELECT * FROM foreign_data.%I',
            newname,
            tbname
        );
    END LOOP;
END;
$$ LANGUAGE plpgsql;
-------------------------------------------------------------------------------------------------------
DO
$$
DECLARE
    tbname name;
BEGIN
    FOR tbname IN
        SELECT foreign_table_name
        FROM information_schema._pg_foreign_tables
        WHERE foreign_table_schema = 'foreign_data'
    LOOP
        EXECUTE format('DROP FOREIGN TABLE foreign_data.%I', tbname);
    END LOOP;
END;
$$ LANGUAGE plpgsql;
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
DROP SERVER IF EXISTS species_iucn_non_spatial_3_202607_fdw CASCADE;
CREATE SERVER species_iucn_non_spatial_3_202607_fdw
  FOREIGN DATA WRAPPER ogr_fdw
  OPTIONS (
	datasource '/data/swap/species_2026/nonspatial/endemics',
	format 'CSV' );
------------------------------------------------------------------------------------------------------
IMPORT FOREIGN SCHEMA ogr_all FROM SERVER species_iucn_non_spatial_3_202607_fdw INTO foreign_data;
-------------------------------------------------------------------------------------------------------
DO
$$
DECLARE
    tbname name;
    newname name;
BEGIN
    FOR tbname IN
        SELECT foreign_table_name::text
        FROM information_schema._pg_foreign_tables
        WHERE foreign_table_schema = 'foreign_data'
    LOOP
        newname := tbname || '_0';

        RAISE NOTICE 'CREATING TABLE : foreign_data.%', newname;

        EXECUTE format(
            'CREATE TABLE foreign_data.%I AS SELECT * FROM foreign_data.%I',
            newname,
            tbname
        );
    END LOOP;
END;
$$ LANGUAGE plpgsql;
-------------------------------------------------------------------------------------------------------
DO
$$
DECLARE
    tbname name;
BEGIN
    FOR tbname IN
        SELECT foreign_table_name
        FROM information_schema._pg_foreign_tables
        WHERE foreign_table_schema = 'foreign_data'
    LOOP
        EXECUTE format('DROP FOREIGN TABLE foreign_data.%I', tbname);
    END LOOP;
END;
$$ LANGUAGE plpgsql;
-------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------
CREATE TABLE species_2026_input_data_original.nsp_all_other_fields AS 
SELECT * FROM foreign_data.all_other_fields_1 
UNION 
SELECT * FROM foreign_data.all_other_fields_2 
;
CREATE TABLE species_2026_input_data_original.nsp_assessments AS 
SELECT * FROM foreign_data.assessments_1 
UNION 
SELECT * FROM foreign_data.assessments_2 
;
CREATE TABLE species_2026_input_data_original.nsp_assessments_with_html AS 
SELECT * FROM foreign_data.assessments_with_html_1 
UNION 
SELECT * FROM foreign_data.assessments_with_html_2 
;
CREATE TABLE species_2026_input_data_original.nsp_common_names AS 
SELECT * FROM foreign_data.common_names_1 
UNION 
SELECT * FROM foreign_data.common_names_2 
;
CREATE TABLE species_2026_input_data_original.nsp_conservation_needed AS 
SELECT * FROM foreign_data.conservation_needed_1 
UNION 
SELECT * FROM foreign_data.conservation_needed_2 
;
CREATE TABLE species_2026_input_data_original.nsp_countries AS 
SELECT * FROM foreign_data.countries_1 
UNION 
SELECT * FROM foreign_data.countries_2 
;
CREATE TABLE species_2026_input_data_original.nsp_credits AS 
SELECT * FROM foreign_data.credits_1 
UNION 
SELECT * FROM foreign_data.credits_2 
;
CREATE TABLE species_2026_input_data_original.nsp_dois AS 
SELECT * FROM foreign_data.dois_1 
UNION 
SELECT * FROM foreign_data.dois_2 
;
CREATE TABLE species_2026_input_data_original.nsp_fao AS 
SELECT * FROM foreign_data.fao_1 
UNION 
SELECT * FROM foreign_data.fao_2 
;
CREATE TABLE species_2026_input_data_original.nsp_habitats AS 
SELECT * FROM foreign_data.habitats_1 
UNION 
SELECT * FROM foreign_data.habitats_2 
;
CREATE TABLE species_2026_input_data_original.nsp_lme AS 
SELECT * FROM foreign_data.lme_1 
UNION 
SELECT * FROM foreign_data.lme_2 
;
CREATE TABLE species_2026_input_data_original.nsp_references_ AS 
SELECT * FROM foreign_data.references_1 
UNION 
SELECT * FROM foreign_data.references_2 
;
CREATE TABLE species_2026_input_data_original.nsp_research_needed AS 
SELECT * FROM foreign_data.research_needed_1 
UNION 
SELECT * FROM foreign_data.research_needed_2 
;
CREATE TABLE species_2026_input_data_original.nsp_simple_summary AS 
SELECT * FROM foreign_data.simple_summary_1 
UNION 
SELECT * FROM foreign_data.simple_summary_2 
;
CREATE TABLE species_2026_input_data_original.nsp_synonyms AS 
SELECT * FROM foreign_data.synonyms_1 
UNION 
SELECT * FROM foreign_data.synonyms_2 
;
CREATE TABLE species_2026_input_data_original.nsp_taxonomy AS 
SELECT * FROM foreign_data.taxonomy_1 
UNION 
SELECT * FROM foreign_data.taxonomy_2 
;
CREATE TABLE species_2026_input_data_original.nsp_taxonomy_with_html AS 
SELECT * FROM foreign_data.taxonomy_with_html_1 
UNION 
SELECT * FROM foreign_data.taxonomy_with_html_2 
;
CREATE TABLE species_2026_input_data_original.nsp_threats AS 
SELECT * FROM foreign_data.threats_1 
UNION 
SELECT * FROM foreign_data.threats_2 
;
CREATE TABLE species_2026_input_data_original.nsp_usetrade AS 
SELECT * FROM foreign_data.usetrade_1 
UNION 
SELECT * FROM foreign_data.usetrade_2 
;
-------------------------------------------------------------------------------------
CREATE TABLE species_2026_input_data_original.nsp_endemics AS
SELECT DISTINCT internaltaxonid::integer,scientificname::text
FROM foreign_data.endemics_simple_summary_0
ORDER BY internaltaxonid::integer;
-------------------------------------------------------------------------------------------------------
DROP SCHEMA foreign_data CASCADE;
CREATE SCHEMA foreign_data;
-------------------------------------------------------------------------------------------------------
DROP SERVER IF EXISTS species_iucn_non_spatial_1_202607_fdw CASCADE;
DROP SERVER IF EXISTS species_iucn_non_spatial_2_202607_fdw CASCADE;
DROP SERVER IF EXISTS species_iucn_non_spatial_3_202607_fdw CASCADE;

