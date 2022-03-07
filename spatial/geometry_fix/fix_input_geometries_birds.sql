-- CHECK birds
SELECT DISTINCT valid,st_geometrytype FROM spatial_tables.geom_birds;
-- non valid geoms exists

-- count total
SELECT COUNT(*) FROM spatial_tables.geom_birds;
-- 2709269 total geoms (id_no,path)

--extract id_no whith valid geoms only
DROP TABLE IF EXISTS birds_valid_1;
CREATE TEMPORARY TABLE birds_valid_1 AS
SELECT * FROM spatial_tables.geom_birds
WHERE id_no NOT IN (SELECT DISTINCT id_no FROM spatial_tables.geom_birds WHERE valid IS false)
ORDER BY id_no,path;
-- 1065843 id_no with valid paths

--extract id_no whith some non valid paths
DROP TABLE IF EXISTS birds_non_valid_1;
CREATE TEMPORARY TABLE birds_non_valid_1 AS
SELECT * FROM spatial_tables.geom_birds
WHERE id_no IN (SELECT DISTINCT id_no FROM spatial_tables.geom_birds WHERE valid IS false)
ORDER BY id_no,path;
-- 1643426 id_no with valid/non-valid paths

--split valid/non-valid geoms from non-valid subset
--valid paths
DROP TABLE IF EXISTS birds_non_valid_2;
CREATE TEMPORARY TABLE birds_non_valid_2 AS
SELECT * FROM birds_non_valid_1 WHERE valid is TRUE;
-- 1640439 valid paths

--non-valid paths
DROP TABLE IF EXISTS birds_non_valid_3;
CREATE TEMPORARY TABLE birds_non_valid_3 AS
SELECT * FROM birds_non_valid_1 WHERE valid is FALSE;
-- 2987 non-valid paths

--fix non valid
DROP TABLE IF EXISTS birds_non_valid_fix;
CREATE TEMPORARY TABLE birds_non_valid_fix AS
SELECT *,(ST_ISVALIDDETAIL(geom)).*,ST_GEOMETRYTYPE(geom)
FROM (SELECT id_no,(ST_DUMP(ST_MAKEVALID(geom))).* FROM birds_non_valid_3) tf
ORDER BY id_no,path;
--2997
--Query returned successfully in 51 min 39 secs.

--check fixed
SELECT DISTINCT valid,st_geometrytype FROM birds_non_valid_fix;
--all fixed

--merge valid/non-valid
DROP TABLE IF EXISTS birds_validated1;
CREATE TEMPORARY TABLE birds_validated1 AS
SELECT * FROM birds_non_valid_2
UNION ALL
SELECT * FROM birds_non_valid_fix;
--1643436

--collect/dump validated
DROP TABLE IF EXISTS birds_validated2;
CREATE TEMPORARY TABLE birds_validated2 AS
SELECT *,(ST_ISVALIDDETAIL(geom)).*,ST_GEOMETRYTYPE(geom) FROM 
(SELECT id_no,(ST_DUMP(geom)).* FROM
(SELECT id_no,ST_COLLECT(geom) geom FROM birds_validated1
GROUP BY id_no ORDER BY id_no) a) b;
--SELECT 1643436
--Query returned successfully in 9 min 35 secs.

--merge all; final step
DROP TABLE IF EXISTS birds_valid;
CREATE TEMPORARY TABLE birds_valid AS
SELECT * FROM birds_valid_1
UNION ALL
SELECT * FROM birds_validated2
ORDER BY id_no,path;
--SELECT 2709279

--CREATE SINGLE GEOM TABLE
DROP TABLE IF EXISTS spatial_tables.geom_birds_fixed;
CREATE TABLE spatial_tables.geom_birds_fixed AS
SELECT * FROM birds_valid;

--CREATE MULTI GEOM TABLE
DROP TABLE IF EXISTS spatial_tables.geom_birds_2;
CREATE TABLE spatial_tables.geom_birds_2 AS
SELECT id_no,ST_MULTI(ST_COLLECT(geom)) geom
FROM  spatial_tables.geom_birds_fixed
GROUP BY id_no
ORDER BY id_no;
ALTER TABLE spatial_tables.geom_birds_2 ADD PRIMARY KEY (id_no);
CREATE INDEX ON spatial_tables.geom_birds_2 USING GIST(geom);
