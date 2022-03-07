---------------------------------------------
DROP TABLE IF EXISTS a;CREATE TEMPORARY TABLE a AS
SELECT cid,UNNEST(sharks) id_no FROM species_2022_sharks.fb_atts_all;
---------------------------------------------
DROP TABLE IF EXISTS b;CREATE TEMPORARY TABLE b AS
SELECT id_no,threatened,endemic
FROM dopa.dopa_species
WHERE class = 'Chondrichthyes' AND (threatened IS true OR endemic IS true);
---------------------------------------------
DROP TABLE IF EXISTS c;CREATE TEMPORARY TABLE c AS
SELECT * FROM a JOIN b USING(id_no);
---------------------------------------------
DROP TABLE IF EXISTS d;CREATE TEMPORARY TABLE d AS
WITH
z AS (
SELECT cid,ARRAY_AGG(DISTINCT id_no ORDER BY id_no) sharks_threatened_endemic
FROM c WHERE threatened IS true AND endemic IS TRUE GROUP BY cid)
SELECT *,CARDINALITY(sharks_threatened_endemic) sharks_threatened_endemic_richness FROM z;
---------------------------------------------
DROP TABLE IF EXISTS e;CREATE TEMPORARY TABLE e AS
WITH
z AS (
SELECT cid,ARRAY_AGG(DISTINCT id_no ORDER BY id_no) sharks_threatened
FROM c WHERE threatened IS TRUE GROUP BY cid)
SELECT *,CARDINALITY(sharks_threatened) sharks_threatened_richness FROM z;
---------------------------------------------
DROP TABLE IF EXISTS f;CREATE TEMPORARY TABLE f AS
WITH
z AS (
SELECT cid,ARRAY_AGG(DISTINCT id_no ORDER BY id_no) sharks_endemic
FROM c WHERE endemic IS TRUE GROUP BY cid)
SELECT *,CARDINALITY(sharks_endemic) sharks_endemic_richness FROM z;
---------------------------------------------
DROP TABLE IF EXISTS g;CREATE TEMPORARY TABLE g AS
SELECT *, CARDINALITY(sharks) sharks_richness
FROM species_2022_sharks.fb_atts_all;
---------------------------------------------
DROP TABLE IF EXISTS h;CREATE TEMPORARY TABLE h AS
SELECT * FROM g
LEFT JOIN d USING (cid)
LEFT JOIN e USING (cid)
LEFT JOIN f USING (cid);
---------------------------------------------
DROP TABLE IF EXISTS species_2022_sharks.raster_output_attributes;CREATE TABLE species_2022_sharks.raster_output_attributes AS
SELECT * FROM h;