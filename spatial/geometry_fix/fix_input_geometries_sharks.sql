-- CHECK SHARKS
SELECT DISTINCT valid,st_geometrytype FROM spatial_tables.geom_sharks;
-- non valid geoms exists

-- count total
SELECT COUNT(*) FROM spatial_tables.geom_sharks;
-- 283381 total geoms (id_no,path)

--extract id_no whith valid geoms only
DROP TABLE IF EXISTS sharks_valid_1;
CREATE TEMPORARY TABLE sharks_valid_1 AS
SELECT * FROM spatial_tables.geom_sharks
WHERE id_no NOT IN (SELECT DISTINCT id_no FROM spatial_tables.geom_sharks WHERE valid IS false)
ORDER BY id_no,path;
-- 269124 id_no with valid paths

--extract id_no whith some non valid paths
DROP TABLE IF EXISTS sharks_non_valid_1;
CREATE TEMPORARY TABLE sharks_non_valid_1 AS
SELECT * FROM spatial_tables.geom_sharks
WHERE id_no IN (SELECT DISTINCT id_no FROM spatial_tables.geom_sharks WHERE valid IS false)
ORDER BY id_no,path;
-- 14257 id_no with valid/non-valid paths

--split valid/non-valid geoms from non-valid subset
--valid paths
DROP TABLE IF EXISTS sharks_non_valid_2;
CREATE TEMPORARY TABLE sharks_non_valid_2 AS
SELECT * FROM sharks_non_valid_1 WHERE valid is TRUE;
-- 14024 valid paths

--non-valid paths
DROP TABLE IF EXISTS sharks_non_valid_3;
CREATE TEMPORARY TABLE sharks_non_valid_3 AS
SELECT * FROM sharks_non_valid_1 WHERE valid is FALSE;
-- 233 non-valid paths

--fix non valid
DROP TABLE IF EXISTS sharks_non_valid_fix;
CREATE TEMPORARY TABLE sharks_non_valid_fix AS
SELECT *,(ST_ISVALIDDETAIL(geom)).*,ST_GEOMETRYTYPE(geom)
FROM (SELECT id_no,(ST_DUMP(ST_MAKEVALID(geom))).* FROM sharks_non_valid_3) tf
ORDER BY id_no,path;
--233

--check fixed
SELECT DISTINCT valid,st_geometrytype FROM sharks_non_valid_fix;
--all fixed

--merge valid/non-valid
DROP TABLE IF EXISTS sharks_validated1;
CREATE TEMPORARY TABLE sharks_validated1 AS
SELECT * FROM sharks_non_valid_2
UNION ALL
SELECT * FROM sharks_non_valid_fix;
--14257

--collect/dump validated
DROP TABLE IF EXISTS sharks_validated2;
CREATE TEMPORARY TABLE sharks_validated2 AS
SELECT *,(ST_ISVALIDDETAIL(geom)).*,ST_GEOMETRYTYPE(geom) FROM 
(SELECT id_no,(ST_DUMP(geom)).* FROM
(SELECT id_no,ST_COLLECT(geom) geom FROM sharks_validated1
GROUP BY id_no ORDER BY id_no) a) b;
--14257

--merge all; final step
DROP TABLE IF EXISTS sharks_valid;
CREATE TEMPORARY TABLE sharks_valid AS
SELECT * FROM sharks_valid_1
UNION ALL
SELECT * FROM sharks_validated2
ORDER BY id_no,path;
-- 283381

--CREATE SINGLE GEOM TABLE
DROP TABLE IF EXISTS spatial_tables.geom_sharks_fixed;
CREATE TABLE spatial_tables.geom_sharks_fixed AS
SELECT * FROM sharks_valid;

--CREATE MULTI GEOM TABLE
DROP TABLE IF EXISTS spatial_tables.geom_sharks_2;
CREATE TABLE spatial_tables.geom_sharks_2 AS
SELECT id_no,ST_MULTI(ST_COLLECT(geom)) geom
FROM  spatial_tables.geom_sharks_fixed
GROUP BY id_no
ORDER BY id_no;
ALTER TABLE spatial_tables.geom_sharks_2 ADD PRIMARY KEY (id_no);
CREATE INDEX ON spatial_tables.geom_sharks_2 USING GIST(geom);
