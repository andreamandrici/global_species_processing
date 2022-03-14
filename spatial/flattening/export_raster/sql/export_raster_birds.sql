----------------------------------------------------------
-- DATA INPUT SETUP!
DROP TABLE IF EXISTS flat;CREATE TEMPORARY TABLE flat AS
SELECT qid,cid,geom
FROM species_2022_all_taxa.birds_flat ---<---- DEFINE IT HERE!
--WHERE birds && '{59468,136135}'
; ---<---- FILTER IT HERE!
----------------------------------------------------------
DROP TABLE IF EXISTS flat_attributes;CREATE TEMPORARY TABLE flat_attributes AS
SELECT cid,
birds_richness ncid ---<---- DEFINE IT HERE!
FROM species_2022_all_taxa.birds_attributes ---<---- DEFINE IT HERE!
;
-- threatened
DROP TABLE IF EXISTS flat_attributes;CREATE TEMPORARY TABLE flat_attributes AS
SELECT cid,
birds_threatened_richness ncid ---<---- DEFINE IT HERE!
FROM species_2022_all_taxa.birds_attributes ---<---- DEFINE IT HERE!
WHERE birds_threatened_richness IS NOT NULL ---<---- DEFINE IT HERE!
; 
--- endemic
DROP TABLE IF EXISTS flat_attributes;CREATE TEMPORARY TABLE flat_attributes AS
SELECT cid,
birds_endemic_richness ncid ---<---- DEFINE IT HERE!
FROM species_2022_all_taxa.birds_attributes ---<---- DEFINE IT HERE!
WHERE birds_endemic_richness IS NOT NULL ---<---- DEFINE IT HERE!
;
--- threatened_endemic
DROP TABLE IF EXISTS flat_attributes;CREATE TEMPORARY TABLE flat_attributes AS
SELECT cid,
birds_threatened_endemic_richness ncid ---<---- DEFINE IT HERE!
FROM species_2022_all_taxa.birds_attributes ---<---- DEFINE IT HERE!
WHERE birds_threatened_endemic_richness IS NOT NULL ---<---- DEFINE IT HERE!
;
----------------------------------------------------------
-- END OF DATA INPUT SETUP!
----------------------------------------------------------
DROP TABLE IF EXISTS export_raster.flat;SELECT * INTO export_raster.flat FROM flat;
DROP TABLE IF EXISTS export_raster.flat_attributes;SELECT * INTO export_raster.flat_attributes FROM flat_attributes;
----------------------------------------------------------------
DROP TABLE IF EXISTS export_raster.step1;CREATE TABLE export_raster.step1 AS
SELECT a.qid,b.ncid,a.geom
FROM export_raster.flat a
JOIN export_raster.flat_attributes b USING(cid)
ORDER BY qid,ncid;
----------------------------------------------------------------
DROP TABLE IF EXISTS export_raster.step2;CREATE TABLE export_raster.step2 AS
SELECT qid,ncid cid,(ST_DUMP(geom)).geom FROM export_raster.step1 ORDER BY qid,cid,geom;
----------------------------------------------------------------
DROP TABLE IF EXISTS export_raster.step3;CREATE TABLE export_raster.step3 AS
SELECT qid,cid,ST_MULTI(ST_COLLECT(geom)) geom FROM export_raster.step2 GROUP BY qid,cid ORDER BY qid,cid;
----------------------------------------------------------
TRUNCATE TABLE export_raster.h_flat;
INSERT INTO export_raster.h_flat(qid,cid,geom) SELECT * FROM export_raster.step3;
----------------------------------------------------------
