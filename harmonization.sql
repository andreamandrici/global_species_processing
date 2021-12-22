--SPECIES LIST FROM SPATIAL TABLES
DROP TABLE IF EXISTS spatial_list;
CREATE TEMPORARY TABLE spatial_list AS
SELECT DISTINCT id_no,binomial::text FROM import_tables.spatial_corals
UNION
SELECT DISTINCT id_no,binomial::text FROM import_tables.spatial_sharks_rays_chimaeras
UNION
SELECT DISTINCT id_no,binomial::text FROM import_tables.spatial_amphibians
UNION
SELECT DISTINCT id_no,binomial::text FROM import_tables.spatial_mammals
UNION
SELECT DISTINCT id_no,sci_name::text binomial FROM import_tables.spatial_birds
ORDER BY id_no;
--SELECT 25879

--SPECIES LIST FROM NON SPATIAL TABLES
DROP TABLE IF EXISTS non_spatial_list;
CREATE TEMPORARY TABLE non_spatial_list AS
SELECT DISTINCT
internaltaxonid::bigint id_no,
scientificname::text AS binomial,
classname::text AS class
FROM import_tables.non_spatial_taxonomy
ORDER BY id_no;
--SELECT 26533

--SPECIES LIST EXISTING IN BOTH SPATIAL AND NON SPATIAL TABLES
DROP TABLE IF EXISTS all_species_list;
CREATE TEMPORARY TABLE all_species_list AS
SELECT a.* FROM non_spatial_list a JOIN spatial_list USING(id_no) ORDER BY id_no;
--SELECT 25867

--ENDEMIC SPECIES LIST EXISTING IN BOTH SPATIAL AND NON SPATIAL TABLES
DROP TABLE IF EXISTS endemic_species_list;
CREATE TEMPORARY TABLE endemic_species_list AS
SELECT DISTINCT
a.internaltaxonid::bigint id_no,TRUE endemic
FROM import_tables.non_spatial_endemic a
JOIN all_species_list b ON a.internaltaxonid::bigint=b.id_no
ORDER BY id_no;
--SELECT 10663

-------------------------------------------------------------------------------------------------
-- OUTPUT (SPECIES LIST)
-------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS import_tables.all_species_list;CREATE TABLE import_tables.all_species_list AS
SELECT id_no,class,binomial,endemic FROM all_species_list LEFT JOIN endemic_species_list USING(id_no) ORDER BY id_no;
--SELECT 25867
