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
DROP TABLE IF EXISTS species_2026.spatial_sharks_rays_chimaeras;
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

------ TO DO HERE!

-------------------------------------------------------------------------------------------------------
DROP SCHEMA foreign_data CASCADE;
CREATE SCHEMA foreign_data;
-------------------------------------------------------------------------------------------------------
DROP SERVER IF EXISTS species_iucn_non_spatial_1_202607_fdw CASCADE;
DROP SERVER IF EXISTS species_iucn_non_spatial_2_202607_fdw CASCADE;
DROP SERVER IF EXISTS species_iucn_non_spatial_3202607_fdw CASCADE;
-------------------------------------------------------------------------------------------------------
CREATE TABLE species_2026.spatial_sharks_rays_chimaeras AS
SELECT
fid,geom,id_no,sci_name::text,presence,origin,seasonal,compiler::text,yrcompiled,citation::text,subspecies::text,subpop::text,source::text,island::text,tax_comm::text,dist_comm::text,generalisd,legend::text,kingdom::text,phylum::text,class::text,order_::text,family::text,genus::text,category::text,marine::text,terrestria::text,freshwater::text,shape_leng,shape_area
FROM species_2026_input_data_original.sharks_rays_chimaeras WHERE presence IN (1) AND origin IN (1,2,6) AND seasonal IN (1,2,3)
ORDER BY id_no;
