CREATE TEMPORARY TABLE spatial_corals_clean AS 
SELECT id_no,(ST_DUMP(geom)).* FROM species_2026.spatial_corals ORDER BY id_no;
UPDATE spatial_corals_clean SET geom = ST_MAKEVALID(geom) WHERE ST_ISVALID(geom) IS FALSE;
CREATE TABLE species_2026.spatial_corals_clean AS
SELECT * FROM spatial_corals_clean ORDER BY id_no;

CREATE TEMPORARY TABLE spatial_amphibians_clean AS 
SELECT id_no,(ST_DUMP(geom)).* FROM species_2026.spatial_amphibians ORDER BY id_no;
UPDATE spatial_amphibians_clean SET geom = ST_MAKEVALID(geom) WHERE ST_ISVALID(geom) IS FALSE;
CREATE TABLE species_2026.spatial_amphibians_clean AS
SELECT * FROM spatial_amphibians_clean ORDER BY id_no;

CREATE TEMPORARY TABLE spatial_reptiles_clean AS 
SELECT id_no,(ST_DUMP(geom)).* FROM species_2026.spatial_reptiles ORDER BY id_no;
UPDATE spatial_reptiles_clean SET geom = ST_MAKEVALID(geom) WHERE ST_ISVALID(geom) IS FALSE;
CREATE TABLE species_2026.spatial_reptiles_clean AS
SELECT * FROM spatial_reptiles_clean ORDER BY id_no;

CREATE TEMPORARY TABLE spatial_mammals_clean AS 
SELECT id_no,(ST_DUMP(geom)).* FROM species_2026.spatial_mammals ORDER BY id_no;
UPDATE spatial_mammals_clean SET geom = ST_MAKEVALID(geom) WHERE ST_ISVALID(geom) IS FALSE;
CREATE TABLE species_2026.spatial_mammals_clean AS
SELECT * FROM spatial_mammals_clean ORDER BY id_no;
