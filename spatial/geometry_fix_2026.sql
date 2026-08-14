CREATE TEMPORARY TABLE spatial_amphibians_clean AS 
SELECT id_no,(ST_DUMP(geom)).* FROM species_2026.spatial_amphibians ORDER BY id_no;
UPDATE spatial_amphibians_clean SET geom = ST_MAKEVALID(geom) WHERE ST_ISVALID(geom) IS FALSE;
CREATE TABLE species_2026.spatial_amphibians_clean AS
SELECT * FROM spatial_amphibians_clean ORDER BY id_no;
