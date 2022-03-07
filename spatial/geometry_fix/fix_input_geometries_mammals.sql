-- CHECK mammals
SELECT DISTINCT valid,st_geometrytype FROM spatial_tables.geom_mammals;
-- non valid geoms exists

-- count total
SELECT COUNT(*) FROM spatial_tables.geom_mammals;
-- 115651 total geoms (id_no,path)

--extract id_no whith valid geoms only
DROP TABLE IF EXISTS mammals_valid_1;
CREATE TEMPORARY TABLE mammals_valid_1 AS
SELECT * FROM spatial_tables.geom_mammals
WHERE id_no NOT IN (SELECT DISTINCT id_no FROM spatial_tables.geom_mammals WHERE valid IS false)
ORDER BY id_no,path;
-- 91722 id_no with valid paths

--extract id_no whith some non valid paths
DROP TABLE IF EXISTS mammals_non_valid_1;
CREATE TEMPORARY TABLE mammals_non_valid_1 AS
SELECT * FROM spatial_tables.geom_mammals
WHERE id_no IN (SELECT DISTINCT id_no FROM spatial_tables.geom_mammals WHERE valid IS false)
ORDER BY id_no,path;
-- 23929 id_no with valid/non-valid paths

--split valid/non-valid geoms from non-valid subset
--valid paths
DROP TABLE IF EXISTS mammals_non_valid_2;
CREATE TEMPORARY TABLE mammals_non_valid_2 AS
SELECT * FROM mammals_non_valid_1 WHERE valid is TRUE;
-- 23901 valid paths

--non-valid paths
DROP TABLE IF EXISTS mammals_non_valid_3;
CREATE TEMPORARY TABLE mammals_non_valid_3 AS
SELECT * FROM mammals_non_valid_1 WHERE valid is FALSE;
-- 28 non-valid paths

--fix non valid
DROP TABLE IF EXISTS mammals_non_valid_fix;
CREATE TEMPORARY TABLE mammals_non_valid_fix AS
SELECT *,(ST_ISVALIDDETAIL(geom)).*,ST_GEOMETRYTYPE(geom)
FROM (SELECT id_no,(ST_DUMP(ST_MAKEVALID(geom))).* FROM mammals_non_valid_3) tf
ORDER BY id_no,path;
--28

--check fixed
SELECT DISTINCT valid,st_geometrytype FROM mammals_non_valid_fix;
--all fixed

--merge valid/non-valid
DROP TABLE IF EXISTS mammals_validated1;
CREATE TEMPORARY TABLE mammals_validated1 AS
SELECT * FROM mammals_non_valid_2
UNION ALL
SELECT * FROM mammals_non_valid_fix;
--23929

--collect/dump validated
DROP TABLE IF EXISTS mammals_validated2;
CREATE TEMPORARY TABLE mammals_validated2 AS
SELECT *,(ST_ISVALIDDETAIL(geom)).*,ST_GEOMETRYTYPE(geom) FROM 
(SELECT id_no,(ST_DUMP(geom)).* FROM
(SELECT id_no,ST_COLLECT(geom) geom FROM mammals_validated1
GROUP BY id_no ORDER BY id_no) a) b;
--23929

--merge all; final step
DROP TABLE IF EXISTS mammals_valid;
CREATE TEMPORARY TABLE mammals_valid AS
SELECT * FROM mammals_valid_1
UNION ALL
SELECT * FROM mammals_validated2
ORDER BY id_no,path;
-- 115651

--CREATE SINGLE GEOM TABLE
DROP TABLE IF EXISTS spatial_tables.geom_mammals_fixed;
CREATE TABLE spatial_tables.geom_mammals_fixed AS
SELECT * FROM mammals_valid;

--CREATE MULTI GEOM TABLE
DROP TABLE IF EXISTS spatial_tables.geom_mammals_2;
CREATE TABLE spatial_tables.geom_mammals_2 AS
SELECT id_no,ST_MULTI(ST_COLLECT(geom)) geom
FROM  spatial_tables.geom_mammals_fixed
GROUP BY id_no
ORDER BY id_no;
ALTER TABLE spatial_tables.geom_mammals_2 ADD PRIMARY KEY (id_no);
CREATE INDEX ON spatial_tables.geom_mammals_2 USING GIST(geom);
