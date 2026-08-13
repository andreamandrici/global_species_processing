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
