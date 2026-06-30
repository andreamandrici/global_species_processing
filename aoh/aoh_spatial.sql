--SPATIAL

SELECT * FROM species_2025.dopa_species WHERE binomial IN ('Canis lupus','Ursus arctos','Lynx lynx','Lynx pardinus','Felis silvestris');
SELECT * FROM species_2025.dopa_species WHERE binomial IN ('Felis silvestris');--id_no: 181049859 -- v_range_sqkm = 1423734
SELECT qid,cid FROM species_2025_mammals.h_flat WHERE mammals && '{181049859}'-- 35782 records
SELECT DISTINCT qid FROM species_2025_mammals.h_flat WHERE mammals && '{181049859}'-- 401 records
SELECT DISTINCT cid FROM species_2025_mammals.h_flat WHERE mammals && '{181049859}'-- 30325 records

------------------------------------------------------------------------------------------------------
-- GRASS (reclass rules)
SELECT DISTINCT cid||' = 1'FROM aoh.mammals_2024_atts WHERE mammals && '{181049859}';

SELECT DISTINCT lc_code||' = 1' FROM aoh.species_lc_crosswalk WHERE id_no IN (181049859);

SELECT
    ST_XMin(ST_Extent(geom)) AS xmin,
    ST_YMin(ST_Extent(geom)) AS ymin,
    ST_XMax(ST_Extent(geom)) AS xmax,
    ST_YMax(ST_Extent(geom)) AS ymax
FROM species_2025_mammals.h_flat WHERE mammals && '{181049859}'; ---8.774999999999993	34.983333333333334	49.227777777777774	52.75555555555555
--53 34 50 -9

SELECT DISTINCT cid||' = 1' FROM cep_data_202601.cep_index WHERE is_marine IS FALSE

---------------------------------------------------------------------------------------------------------
-- POSTGIS

DROP TABLE IF EXISTS aoh.felis_silvestris_range_2025;CREATE TABLE aoh.felis_silvestris_range_2025 AS
SELECT qid,181049859 id_no,ST_UNARYUNION(ST_COLLECT(geom)) geom,SUM(sqkm)sqkm
FROM species_2025_mammals.h_flat
WHERE mammals && '{181049859}'-- 35782 records
GROUP BY qid,id_no;
CREATE INDEX ON aoh.felis_silvestris_range_2025 USING GIST(geom);

SELECT * FROM aoh.felis_silvestris_aoh_2022 LIMIT 1

CREATE INDEX ON aoh.lc_2022_v USING GIST(geom);

DROP TABLE IF EXISTS aoh.felis_silvestris_aoh_2022_1;CREATE TABLE aoh.felis_silvestris_aoh_2022_1 AS
SELECT a.qid,1 habitat,a.geom
FROM aoh.lc_2022_v a,aoh.felis_silvestris_range_2025 b
WHERE a.qid IN (SELECT DISTINCT qid FROM species_2025_mammals.h_flat WHERE mammals && '{181049859}')
AND lc_code IN (SELECT DISTINCT lc_code FROM aoh.species_lc_crosswalk WHERE id_no IN (181049859))
AND ST_INTERSECTS(a.geom,b.geom);
CREATE INDEX ON aoh.felis_silvestris_aoh_2022_1 USING GIST(geom);

DROP TABLE IF EXISTS aoh.felis_silvestris_aoh_2022_2;CREATE TABLE aoh.felis_silvestris_aoh_2022_2 AS
SELECT qid,habitat,ST_UNARYUNION(ST_COLLECT(geom)) geom
FROM aoh.felis_silvestris_aoh_2022_1 GROUP BY qid,habitat;
CREATE INDEX ON aoh.felis_silvestris_aoh_2022_2 USING GIST(geom);

DROP TABLE IF EXISTS aoh.felis_silvestris_aoh_2022_3;CREATE TABLE aoh.felis_silvestris_aoh_2022_3 AS
SELECT qid,habitat,ST_INTERSECTION(a.geom,b.geom) geom
FROM aoh.felis_silvestris_aoh_2022_2 a JOIN aoh.felis_silvestris_range_2025 b USING (qid)
WHERE ST_INTERSECTS(a.geom,b.geom);
CREATE INDEX ON aoh.felis_silvestris_aoh_2022_3 USING GIST(geom);
