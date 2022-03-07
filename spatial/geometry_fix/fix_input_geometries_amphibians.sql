-- CHECK AMPHIBIANS
SELECT DISTINCT valid,st_geometrytype FROM spatial_tables.geom_amphibians;
-- non valid geoms exists

-- count total
SELECT COUNT(*) FROM spatial_tables.geom_amphibians;
-- 136094 total geoms (id_no,path)

--extract id_no whith valid geoms only
DROP TABLE IF EXISTS amphibians_valid_1;
CREATE TEMPORARY TABLE amphibians_valid_1 AS
SELECT * FROM spatial_tables.geom_amphibians
WHERE id_no NOT IN (SELECT DISTINCT id_no FROM spatial_tables.geom_amphibians WHERE valid IS false)
ORDER BY id_no,path;
-- 136074 id_no with valid paths

--extract id_no whith some non valid paths
DROP TABLE IF EXISTS amphibians_non_valid_1;
CREATE TEMPORARY TABLE amphibians_non_valid_1 AS
SELECT * FROM spatial_tables.geom_amphibians
WHERE id_no IN (SELECT DISTINCT id_no FROM spatial_tables.geom_amphibians WHERE valid IS false)
ORDER BY id_no,path;
-- 20 id_no with valid/non-valid paths

--split valid/non-valid geoms from non-valid subset
--valid paths
DROP TABLE IF EXISTS amphibians_non_valid_2;
CREATE TEMPORARY TABLE amphibians_non_valid_2 AS
SELECT * FROM amphibians_non_valid_1 WHERE valid is TRUE;
-- 16 valid paths
--non-valid paths
DROP TABLE IF EXISTS amphibians_non_valid_3;
CREATE TEMPORARY TABLE amphibians_non_valid_3 AS
SELECT * FROM amphibians_non_valid_1 WHERE valid is FALSE;
-- 4 non-valid paths

--fix non valid
DROP TABLE IF EXISTS amphibians_non_valid_fix;
CREATE TEMPORARY TABLE amphibians_non_valid_fix AS
SELECT *,(ST_ISVALIDDETAIL(geom)).*,ST_GEOMETRYTYPE(geom)
FROM (SELECT id_no,(ST_DUMP(ST_MAKEVALID(geom))).* FROM amphibians_non_valid_3) tf
ORDER BY id_no,path;
--4

--merge valid/non-valid
DROP TABLE IF EXISTS amphibians_validated1;
CREATE TEMPORARY TABLE amphibians_validated1 AS
SELECT * FROM amphibians_non_valid_2
UNION ALL
SELECT * FROM amphibians_non_valid_fix;
--20

--collect/dump validated
DROP TABLE IF EXISTS amphibians_validated2;
CREATE TEMPORARY TABLE amphibians_validated2 AS
SELECT *,(ST_ISVALIDDETAIL(geom)).*,ST_GEOMETRYTYPE(geom) FROM 
(SELECT id_no,(ST_DUMP(geom)).* FROM
(SELECT id_no,ST_COLLECT(geom) geom FROM amphibians_validated1
GROUP BY id_no ORDER BY id_no) a) b;
--20

--merge all; final step
DROP TABLE IF EXISTS amphibians_valid;
CREATE TEMPORARY TABLE amphibians_valid AS
SELECT * FROM amphibians_valid_1
UNION ALL
SELECT * FROM amphibians_validated2
ORDER BY id_no,path;
-- 136094

--CREATE SINGLE GEOM TABLE
DROP TABLE IF EXISTS spatial_tables.geom_amphibians_fixed;
CREATE TABLE spatial_tables.geom_amphibians_fixed AS
SELECT * FROM amphibians_valid;

--CREATE MULTI GEOM TABLE
DROP TABLE IF EXISTS spatial_tables.geom_amphibians_2;
CREATE TABLE spatial_tables.geom_amphibians_2 AS
SELECT id_no,ST_MULTI(ST_COLLECT(geom)) geom
FROM  spatial_tables.geom_amphibians_fixed
GROUP BY id_no
ORDER BY id_no;
ALTER TABLE spatial_tables.geom_amphibians_2 ADD PRIMARY KEY (id_no);
CREATE INDEX ON spatial_tables.geom_amphibians_2 USING GIST(geom);



