--------------------------------------------------------------------
-- mammals cid x lc92 x lc 22 -- 13mil records per 2.5mil id_no combinations
--------------------------------------------------------------------
SELECT * FROM aoh.mammals_2024_lc_92_22_input LIMIT 1;
SELECT COUNT(*) FROM aoh.mammals_2024_lc_92_22_input; --13.427.521
SELECT DISTINCT cid_sp FROM aoh.mammals_2024_lc_92_22_input; --2.500.880
--------------------------------------------------------------------
CREATE TABLE aoh.mammals_2024_lc_92_22 AS
SELECT cid_sp,lc92 lc_code_92,lc22 lc_code_22,CASE WHEN lc92!=lc22 THEN TRUE ELSE FALSE END lcc,mq/1000000 sqkm
FROM aoh.mammals_2024_lc_92_22_input
ORDER BY cid_sp,lc_code_92,lc_code_22;
--------------------------------------------------------------------
-- mammals cid x cep cid x lc92 x lc 22 -- 16mil records per 2.5mil id_no combinations 
--------------------------------------------------------------------
SELECT * FROM aoh.mammals_2024_cep_26_lc_92_22_input LIMIT 1;
SELECT COUNT(*) FROM aoh.mammals_2024_cep_26_lc_92_22_input; --16166944
SELECT DISTINCT cid_sp FROM aoh.mammals_2024_cep_26_lc_92_22_input; --2500880
--------------------------------------------------------------------
CREATE TABLE aoh.mammals_2024_cep_26_lc_92_22 AS
SELECT cid_sp,cid cid_cep,lc92 lc_code_92,lc22 lc_code_22,CASE WHEN lc92!=lc22 THEN TRUE ELSE FALSE END lcc,mq/1000000 sqkm
FROM aoh.mammals_2024_cep_26_lc_92_22_input
ORDER BY cid_sp,cid_cep,lc_code_92,lc_code_22;
--------------------------------------------------------------------
-- pure list cid,mammals (array of id_no); 2.5mil id_no combinations
SELECT * FROM aoh.mammals_2024_atts LIMIT 1;
SELECT COUNT(*) FROM aoh.mammals_2024_atts; --2500880
SELECT DISTINCT cid FROM aoh.mammals_2024_atts;--2500880

--------------------------------------------------------------------
-- complete list qid,cid,mammals (array of id_no),sqkm;
--259mil of qid/cid/id_no combination
--2.9mil qid/cid combinations
--2.5mil id_no combinations
SELECT * FROM aoh.mammals LIMIT 1;
SELECT COUNT(*) FROM aoh.mammals;--2995035
SELECT DISTINCT cid FROM aoh.mammals;--25008800
DROP TABLE IF EXISTS mammals;CREATE TEMPORARY TABLE mammals AS
SELECT qid,cid,UNNEST(id_no) id_no FROM aoh.mammals ORDER BY qid,cid,id_no;
SELECT COUNT(*) FROM mammals;--259815217
SELECT COUNT(*) FROM (SELECT DISTINCT qid,cid FROM mammals) a;--2995035
SELECT DISTINCT cid FROM mammals --2500880
SELECT DISTINCT id_no FROM mammals; --5835 species
--------------------------------------------------------------------
--SPECIES LIST 2023
--complete list of species with all attributes, including range_sqkm
SELECT * FROM aoh.mammals_2023 ORDER BY id_no DESC--5828
-------------------------------------------------------------------------
SELECT * FROM aoh.crosswalks;
CREATE TEMPORARY TABLE crosswalks_clean AS
SELECT DISTINCT
  id,
  "iucn - code"::text iucn_code,
  "iucn - habitat description"::text iucn_habitat_description,
  SPLIT_PART("iucn - code",'.',1)::integer AS hl1,
  COALESCE(NULLIF(SPLIT_PART("iucn - code",'.',2), '')::integer, 0) AS hl2,
  COALESCE(NULLIF(SPLIT_PART("iucn - code",'.',3), '')::integer, 0) AS hl3,
  CASE WHEN "esa cci – code" ILIKE '%NA' THEN 0 ELSE "esa cci – code"::integer END esa_cci_code,
  "esa cci – habitat description"::text esa_cci_description
FROM aoh.crosswalks
ORDER BY hl1, hl2, hl3,esa_cci_code;
DROP TABLE aoh.crosswalks;
CREATE TABLE aoh.crosswalks AS SELECT * FROM crosswalks_clean;
ALTER TABLE aoh.crosswalks ADD PRIMARY KEY(id);
----------------------------------------------------------------------------------
DROP TABLE IF EXISTS aoh.species_habitats_lc_crosswalk;CREATE TABLE aoh.species_habitats_lc_crosswalk AS
WITH
a AS (SELECT id_no,UNNEST(habitats) iucn_code FROM aoh.mammals_2023 WHERE ecosystems && '{terrestrial}' ORDER BY iucn_code)
SELECT DISTINCT id_no,iucn_code,esa_cci_code FROM a JOIN aoh.crosswalks b USING(iucn_code)
ORDER BY id_no,iucn_code,esa_cci_code;
----------------------------------------------------------------------------------
DROP TABLE IF EXISTS aoh.species_lc_crosswalk;CREATE TABLE aoh.species_lc_crosswalk AS
SELECT DISTINCT id_no,esa_cci_code lc_code FROM aoh.species_habitats_lc_crosswalk ORDER BY id_no,lc_code;
----------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS aoh.mammals_2024_cep_26_lc_92_22_input
(
    cid_sp bigint,
	cid integer,
    lc92 integer,
    lc22 integer,
    mq double precision
);
COMMENT ON TABLE aoh.mammals_2024_cep_26_lc_92_22_input
    IS 'mammals cid x cep cid 2026 x lc92 x lc 22 -- 13mil records per 2.5mil id_no combinations ';
----------------------------------------------------------------------------------
CREATE TEMPORARY TABLE proc1 AS
SELECT * FROM aoh.mammals_2024_lc_92_22 a JOIN aoh.mammals_2024_atts b ON a.cid_sp=b.cid;

SELECT * FROM proc1 LIMIT 1

CREATE TEMPORARY TABLE proc2 AS --1105227938 - 4 min - 5835 id_no
SELECT cid_sp,UNNEST(mammals) id_no,lc_code_92,lc_code_22,lcc,sqkm FROM proc1;

CREATE TEMPORARY TABLE proc3 AS --1094259230
SELECT * FROM proc2 WHERE id_no IN (SELECT DISTINCT id_no FROM aoh.species_lc_crosswalk)
---------------------------------------------------------
CREATE TABLE aoh.mammals_2024_id_no_lc_92_22 AS--17 min 31 secs. 1094259230
SELECT * FROM proc3
ORDER BY cid_sp,id_no,lc_code_92,lc_code_22;
---------------------------------------------------------
CREATE TABLE aoh.mammals_2024_id_no_r_range AS
SELECT id_no,SUM(sqkm) r_range_sqkm FROM aoh.mammals_2024_id_no_lc_92_22 GROUP BY id_no ORDER BY id_no;

DROP TABLE IF EXISTS aoh.mammals_2024_id_no_aoh_92;CREATE TABLE aoh.mammals_2024_id_no_aoh_92 AS
SELECT
id_no,SUM(sqkm) aoh_92_sqkm
FROM aoh.mammals_2024_id_no_lc_92_22 a
JOIN (SELECT id_no,lc_code lc_code_92 FROM aoh.species_lc_crosswalk) b USING(id_no,lc_code_92)
GROUP BY id_no ORDER BY id_no;

DROP TABLE IF EXISTS aoh.mammals_2024_id_no_aoh_22;CREATE TABLE aoh.mammals_2024_id_no_aoh_22 AS
SELECT
id_no,SUM(sqkm) aoh_22_sqkm
FROM aoh.mammals_2024_id_no_lc_92_22 a
JOIN (SELECT id_no,lc_code lc_code_22 FROM aoh.species_lc_crosswalk) b USING(id_no,lc_code_22)
GROUP BY id_no ORDER BY id_no;

DROP TABLE IF EXISTS aoh.mammals_2024_id_no_range_aoh_92_22;CREATE TABLE aoh.mammals_2024_id_no_range_aoh_92_22 AS
WITH
a AS (
SELECT id_no,order_,family,genus,binomial,endemic,range_sqkm v_range_sqkm,r_range_sqkm,aoh_92_sqkm,aoh_22_sqkm,ecosystems,category,threatened,habitats
FROM aoh.mammals_2023 a
JOIN aoh.mammals_2024_id_no_r_range b USING(id_no)
JOIN aoh.mammals_2024_id_no_aoh_92 c USING(id_no)
JOIN aoh.mammals_2024_id_no_aoh_22 d USING(id_no))
SELECT id_no,order_,family,genus,binomial,endemic,v_range_sqkm,r_range_sqkm,aoh_92_sqkm,aoh_22_sqkm,
aoh_22_sqkm/r_range_sqkm*100 aoh_perc_range,
(aoh_22_sqkm - aoh_92_sqkm)/NULLIF(aoh_92_sqkm,0) aoh_gain_loss_perc,
ecosystems,category,threatened,habitats FROM a
ORDER BY id_no;

SELECT *
FROM aoh.mammals_2024_id_no_range_aoh_92_22
WHERE binomial IN ('Ursus arctos','Canis lupus','Lynx lynx','Lynx pardinus','Felis silvestris');


--------------------------------------------
DROP TABLE IF EXISTS selected_species;CREATE TEMPORARY TABLE selected_species AS
SELECT * FROM aoh.mammals_2024_id_no_lc_92_22 WHERE id_no IN (3746,12519,12520,41688,181049859) AND lcc IS TRUE;

SELECT * FROM selected_species LIMIT 10

SELECT * FROM aoh.species_habitats_lc_crosswalk;

DROP TABLE IF EXISTS selected_species_lc_habitats_92_22;CREATE TEMPORARY TABLE selected_species_lc_habitats_92_22 AS
SELECT DISTINCT 
id_no,iucn_code_92,iucn_code_22,sqkm
FROM selected_species a
LEFT JOIN (SELECT id_no,esa_cci_code lc_code_92,iucn_code iucn_code_92 FROM aoh.species_habitats_lc_crosswalk) b USING(id_no,lc_code_92)
LEFT JOIN (SELECT id_no,esa_cci_code lc_code_22,iucn_code iucn_code_22 FROM aoh.species_habitats_lc_crosswalk) c USING(id_no,lc_code_22)
ORDER BY id_no,iucn_code_92,iucn_code_22;

SELECT * FROM selected_species_lc_habitats_92_22 LIMIT 10;
SELECT id_no,iucn_code_92,iucn_code_22,SUM(sqkm) sqkm FROM selected_species_lc_habitats_92_22
GROUP BY id_no,iucn_code_92,iucn_code_22 ORDER BY id_no,iucn_code_92,iucn_code_22
