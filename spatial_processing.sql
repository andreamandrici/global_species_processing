------------------------------------------------------------------------------
--create spatial tables schema
------------------------------------------------------------------------------
DROP SCHEMA IF EXISTS spatial_tables CASCADE; CREATE SCHEMA spatial_tables;
------------------------------------------------------------------------------
--create table geom_corals
------------------------------------------------------------------------------
DROP TABLE IF EXISTS spatial_tables.geom_corals;
CREATE TABLE spatial_tables.geom_corals AS
SELECT *,(ST_ISVALIDDETAIL(geom)).*,ST_GEOMETRYTYPE(geom)
FROM (
		SELECT id_no,(ST_DUMP(geom)).*
		FROM import_tables.spatial_corals
		WHERE id_no IN (SELECT DISTINCT id_no FROM import_tables.all_species_list)
) a
ORDER BY id_no;
------------------------------------------------------------------------------
--create table geom_sharks
------------------------------------------------------------------------------
DROP TABLE IF EXISTS spatial_tables.geom_sharks;
CREATE TABLE spatial_tables.geom_sharks AS
SELECT *,(ST_ISVALIDDETAIL(geom)).*,ST_GEOMETRYTYPE(geom)
FROM (
		SELECT id_no,(ST_DUMP(geom)).*
		FROM import_tables.spatial_sharks_rays_chimaeras
		WHERE id_no IN (SELECT DISTINCT id_no FROM import_tables.all_species_list)
) a
ORDER BY id_no;
-- SELECT 283381
-- Query returned successfully in 1 min 42 secs.
------------------------------------------------------------------------------
--create table geom_amphibians
------------------------------------------------------------------------------
DROP TABLE IF EXISTS spatial_tables.geom_amphibians;
CREATE TABLE spatial_tables.geom_amphibians AS
SELECT *,(ST_ISVALIDDETAIL(geom)).*,ST_GEOMETRYTYPE(geom)
FROM (
		SELECT id_no,(ST_DUMP(geom)).*
		FROM import_tables.spatial_amphibians
		WHERE id_no IN (SELECT DISTINCT id_no FROM import_tables.all_species_list)
) a
ORDER BY id_no;
--SELECT 136094
--Query returned successfully in 1 min 2 secs.
------------------------------------------------------------------------------
--create table geom_mammals
------------------------------------------------------------------------------
DROP TABLE IF EXISTS spatial_tables.geom_mammals;
CREATE TABLE spatial_tables.geom_mammals AS
SELECT *,(ST_ISVALIDDETAIL(geom)).*,ST_GEOMETRYTYPE(geom)
FROM (
		SELECT id_no,(ST_DUMP(geom)).*
		FROM import_tables.spatial_mammals
		WHERE id_no IN (SELECT DISTINCT id_no FROM import_tables.all_species_list)
) a
ORDER BY id_no;
--SELECT 115651
--Query returned successfully in 3 min.
------------------------------------------------------------------------------
--create table geom_birds
------------------------------------------------------------------------------
DROP TABLE IF EXISTS spatial_tables.geom_birds;
CREATE TABLE spatial_tables.geom_birds AS
SELECT *,(ST_ISVALIDDETAIL(geom)).*,ST_GEOMETRYTYPE(geom)
FROM (
		SELECT id_no,(ST_DUMP(shape)).*
		FROM import_tables.spatial_birds
		WHERE id_no IN (SELECT DISTINCT id_no FROM import_tables.all_species_list)
) a
ORDER BY id_no;
