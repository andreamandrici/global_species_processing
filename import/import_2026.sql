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
