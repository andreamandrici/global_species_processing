-------------------------------------------------------------------
-- OUTPUT SCHEMA --------------------------------------------------
-------------------------------------------------------------------
DROP SCHEMA IF EXISTS output_schema CASCADE;
CREATE SCHEMA output_schema;
-------------------------------------------------------------------
-- TAXONOMY -------------------------------------------------------
-------------------------------------------------------------------
DROP TABLE IF EXISTS mt_taxonomy;
CREATE TEMPORARY TABLE mt_taxonomy AS
SELECT a.*,b.endemic
FROM (
	SELECT DISTINCT
	internaltaxonid::bigint id_no,
	INITCAP(phylumname::text) AS phylum,	
	INITCAP(classname::text) AS class,
	INITCAP(ordername::text) AS order_,
	INITCAP(familyname::text) AS family,
	genusname::text AS genus,
	scientificname::text AS binomial
FROM import_tables.non_spatial_taxonomy) a
JOIN import_tables.all_species_list b USING(id_no)
ORDER BY id_no;
-------------------------------------------------------------------
-- ECOSYSTEMS -----------------------------------------------------
-------------------------------------------------------------------
DROP TABLE IF EXISTS lt_ecosystems;
CREATE TEMPORARY TABLE lt_ecosystems AS
WITH
a AS (SELECT DISTINCT internaltaxonid::bigint id_no,LOWER(systems)::text systems
	  FROM import_tables.non_spatial_assessments
	  WHERE internaltaxonid::bigint IN (SELECT id_no FROM import_tables.all_species_list)
	  ORDER BY id_no),
b AS (SELECT id_no,UNNEST(STRING_TO_ARRAY(systems::text,'|')) systems FROM a ORDER BY id_no),
c AS (SELECT id_no,CASE WHEN systems = 'freshwater (=inland waters)' THEN 'freshwater' ELSE systems END systems FROM b ORDER BY id_no),
d AS (SELECT *,CASE systems WHEN 'marine' THEN 1 WHEN 'terrestrial' THEN 2 WHEN 'freshwater' THEN 3 END system_order FROM c ORDER BY id_no,system_order)
SELECT id_no,ARRAY_AGG (systems) ecosystems FROM d GROUP BY id_no ORDER BY id_no;
-------------------------------------------------------------------
-- CATEGORIES -----------------------------------------------------
-------------------------------------------------------------------
DROP TABLE IF EXISTS category1;
CREATE TEMPORARY TABLE category1 AS
SELECT DISTINCT
internaltaxonid::bigint id_no,redlistcategory::text
FROM import_tables.non_spatial_assessments
WHERE internaltaxonid::bigint IN (SELECT id_no FROM import_tables.all_species_list)
ORDER BY id_no;

DROP TABLE IF EXISTS category2;
CREATE TEMPORARY TABLE category2 AS
SELECT
id_no,
CASE redlistcategory
WHEN 'Extinct' THEN 'EX'::text
WHEN 'Extinct in the Wild' THEN 'EW'::text
WHEN 'Critically Endangered' THEN 'CR'::text
WHEN 'Endangered' THEN 'EN'::text
WHEN 'Vulnerable' THEN 'VU'::text
WHEN 'Extinct in the Wild' THEN 'EW'::text
WHEN 'Near Threatened' THEN 'NT'::text
WHEN 'Least Concern' THEN 'LC'::text
WHEN 'Data Deficient' THEN 'DD'::text
WHEN 'Lower Risk/conservation dependent' THEN 'LR/cd'::text
WHEN 'Lower Risk/near threatened' THEN 'LR/nt'::text
WHEN 'Regionally Extinct' THEN 'rEX'::text
WHEN 'Not Applicable' THEN 'NA'::text
ELSE NULL::text
END AS code,
redlistcategory AS name,
CASE redlistcategory
WHEN 'Critically Endangered' THEN TRUE
WHEN 'Endangered' THEN TRUE 
WHEN 'Vulnerable' THEN TRUE
END AS threatened
FROM category1
ORDER BY id_no,code;
-- lt_table -------------------------------------------------------
DROP TABLE IF EXISTS lt_category CASCADE;
CREATE TEMPORARY TABLE lt_category AS
SELECT DISTINCT id_no,code,threatened FROM category2 ORDER BY id_no;
-- mt_table -------------------------------------------------------
DROP TABLE IF EXISTS mt_category CASCADE;
CREATE TEMPORARY TABLE mt_category AS
SELECT DISTINCT code,name FROM category2 ORDER BY code;
-------------------------------------------------------------------
-- COUNTRIES ------------------------------------------------------
-------------------------------------------------------------------
DROP TABLE IF EXISTS lt_country;
CREATE TEMPORARY TABLE lt_country AS
WITH a AS (
SELECT DISTINCT internaltaxonid::bigint id_no,code::text
FROM import_tables.non_spatial_countries
WHERE internaltaxonid::bigint IN (SELECT DISTINCT id_no FROM import_tables.all_species_list)
AND presence::text IN ('Extant')
AND origin::text IN ('Native','Reintroduced','Assisted Colonisation')
-- seasonality can be null, and is a very week field
AND (seasonality IS NULL OR seasonality ILIKE '%Resident%' OR seasonality ILIKE '%Breeding Season%' OR seasonality ILIKE '%Non-Breeding Season%')
ORDER BY internaltaxonid::bigint,code),
b AS (SELECT id_no,ARRAY_AGG(DISTINCT code ORDER BY code) code FROM a GROUP BY id_no ORDER BY id_no),
c AS (SELECT *,CARDINALITY(code) FROM b ORDER BY CARDINALITY(code))
SELECT * FROM c
ORDER BY id_no,code;
-------------------------------------------------------------------
-- CONSERVATION NEEDED --------------------------------------------
-------------------------------------------------------------------
DROP TABLE IF EXISTS conservation_needed CASCADE; 
CREATE TEMPORARY TABLE conservation_needed AS
SELECT DISTINCT internaltaxonid::bigint id_no,code::text,name::text
FROM import_tables.non_spatial_conservation_needed
WHERE internaltaxonid::bigint IN (SELECT DISTINCT id_no FROM import_tables.all_species_list)
ORDER BY internaltaxonid::bigint,code;
-- lt_table -------------------------------------------------------
DROP TABLE IF EXISTS lt_conservation_needed CASCADE; 
CREATE TEMPORARY TABLE lt_conservation_needed AS
WITH
a AS (
SELECT DISTINCT
id_no,
code
FROM conservation_needed
ORDER BY id_no,code),
b AS (
SELECT id_no,ARRAY_AGG(DISTINCT code ORDER BY code)conservation_needed
FROM a
GROUP BY id_no
ORDER BY id_no)
SELECT DISTINCT * FROM b ORDER BY id_no,conservation_needed;
-- mt_table -------------------------------------------------------
DROP TABLE IF EXISTS mt_conservation_needed CASCADE; 
CREATE TEMPORARY TABLE mt_conservation_needed AS
WITH
a AS (
SELECT DISTINCT
code, name
FROM conservation_needed
ORDER BY code
),
b AS (
SELECT (split_part((a.code)::text, '.'::text, 1))::integer AS cl1,
(split_part((a.code)::text, '.'::text, 2))::integer AS cl2,
CASE
WHEN ((a.code)::text ~~ '%.%.%'::text) THEN (split_part((a.code)::text, '.'::text, 3))::integer
ELSE 0
END AS cl3,
a.code,
a.name
FROM a
),
conservation_needed AS (
SELECT
b.cl1,
b.cl2,
b.cl3,
b.code::text,
b.name::text
FROM b
ORDER BY b.cl1, b.cl2, b.cl3
)
SELECT
cl1,
cl2,
cl3,
code,
name
FROM conservation_needed
ORDER BY cl1, cl2, cl3;
-------------------------------------------------------------------
-- HABITATS -------------------------------------------------------
-------------------------------------------------------------------
DROP TABLE IF EXISTS habitats CASCADE; 
CREATE TEMPORARY TABLE habitats AS
SELECT DISTINCT internaltaxonid::bigint id_no,code::text,name::text
FROM import_tables.non_spatial_habitats
WHERE internaltaxonid::bigint IN (SELECT DISTINCT id_no FROM import_tables.all_species_list)
ORDER BY internaltaxonid::bigint,code;
-- lt_table -------------------------------------------------------
DROP TABLE IF EXISTS lt_habitats CASCADE; 
CREATE TEMPORARY TABLE lt_habitats AS
WITH
a AS (
SELECT DISTINCT
id_no,
code
FROM habitats
ORDER BY id_no,code
),
b AS (SELECT id_no,ARRAY_AGG(DISTINCT code ORDER BY code) habitats
FROM a
GROUP by id_no
ORDER BY id_no)
SELECT DISTINCT * FROM b ORDER BY id_no,habitats;
-- mt_table -------------------------------------------------------
DROP TABLE IF EXISTS mt_habitats CASCADE; 
CREATE TEMPORARY TABLE mt_habitats AS
WITH
a AS (
SELECT DISTINCT
code,name
FROM habitats
ORDER BY code
),
b AS (
SELECT (split_part((a.code)::text, '.'::text, 1))::integer AS cl1,
CASE
WHEN ((a.code)::text ~~ '%.%'::text) THEN (split_part((a.code)::text, '.'::text, 2))::integer
ELSE 0
END AS cl2,
CASE
WHEN ((a.code)::text ~~ '%.%.%'::text) THEN (split_part((a.code)::text, '.'::text, 3))::integer
ELSE 0
END AS cl3,
a.code,
a.name
FROM a
),
habitats AS (
SELECT
b.cl1,
b.cl2,
b.cl3,
b.code,
b.name
FROM b
ORDER BY b.cl1, b.cl2, b.cl3
)
SELECT
cl1,
cl2,
cl3,
code,
name
FROM habitats
ORDER BY cl1,cl2,cl3;
-------------------------------------------------------------------
-- RESEARCH NEEDED ------------------------------------------------
-------------------------------------------------------------------
DROP TABLE IF EXISTS research_needed CASCADE; 
CREATE TEMPORARY TABLE research_needed AS
SELECT DISTINCT internaltaxonid::bigint id_no,code::text,name::text
FROM import_tables.non_spatial_research_needed
WHERE internaltaxonid::bigint IN (SELECT DISTINCT id_no FROM import_tables.all_species_list)
ORDER BY internaltaxonid::bigint,code;
-- lt_table -------------------------------------------------------
DROP TABLE IF EXISTS lt_research_needed CASCADE; 
CREATE TEMPORARY TABLE lt_research_needed AS
WITH
a AS (
SELECT DISTINCT
id_no,
code
FROM research_needed
ORDER BY id_no,code
),
b AS (SELECT id_no,ARRAY_AGG(DISTINCT code ORDER BY code) research_needed
FROM a
GROUP by id_no
ORDER BY id_no)
SELECT DISTINCT * FROM b ORDER BY id_no,research_needed;
-- mt_table -------------------------------------------------------
DROP TABLE IF EXISTS mt_research_needed CASCADE; 
CREATE TEMPORARY TABLE mt_research_needed AS
WITH
a AS (
SELECT DISTINCT
code,name
FROM research_needed
ORDER BY code
),
b AS (
SELECT (split_part((a.code)::text, '.'::text, 1))::integer AS cl1,
CASE
WHEN ((a.code)::text ~~ '%.%'::text) THEN (split_part((a.code)::text, '.'::text, 2))::integer
ELSE 0
END AS cl2,
CASE
WHEN ((a.code)::text ~~ '%.%.%'::text) THEN (split_part((a.code)::text, '.'::text, 3))::integer
ELSE 0
END AS cl3,
a.code,
a.name
FROM a
),
research_needed AS (
SELECT
b.cl1,
b.cl2,
b.cl3,
b.code,
b.name
FROM b
ORDER BY b.cl1, b.cl2, b.cl3
)
SELECT
cl1,
cl2,
cl3,
code,
name
FROM research_needed
ORDER BY cl1,cl2,cl3;
-------------------------------------------------------------------
-- STRESSES -------------------------------------------------------
-------------------------------------------------------------------
DROP TABLE IF EXISTS stresses CASCADE; 
CREATE TEMPORARY TABLE stresses AS
WITH
a AS (
SELECT DISTINCT internaltaxonid::bigint id_no,stresscode::text,stressname::text
FROM import_tables.non_spatial_threats
WHERE internaltaxonid::bigint IN (SELECT DISTINCT id_no FROM import_tables.all_species_list)
ORDER BY internaltaxonid::bigint,stresscode),
b AS (
SELECT DISTINCT
id_no,
string_to_array((a.stresscode)::text, '|'::text) AS stresscode,
string_to_array((a.stressname)::text, '|'::text) AS stressname
FROM a
ORDER BY id_no,stresscode,stressname
)
SELECT DISTINCT
id_no,
u.code,
u.name
FROM b,
LATERAL UNNEST(b.stresscode,b.stressname) WITH ORDINALITY u(code, name, ordinality)
ORDER BY id_no,u.code;
-- lt_table -------------------------------------------------------
DROP TABLE IF EXISTS lt_stresses CASCADE; 
CREATE TEMPORARY TABLE lt_stresses AS
WITH
a AS (
SELECT DISTINCT
id_no,
code
FROM stresses
ORDER BY id_no,code
),
b AS (SELECT id_no,ARRAY_AGG(DISTINCT code ORDER BY code) stresses
FROM a
GROUP by id_no
ORDER BY id_no)
SELECT DISTINCT * FROM b ORDER BY id_no,stresses;
-- mt_table -------------------------------------------------------
DROP TABLE IF EXISTS mt_stresses CASCADE; 
CREATE TEMPORARY TABLE mt_stresses AS
WITH
a AS (
SELECT DISTINCT
code,name
FROM stresses
ORDER BY code,name),
b AS (
SELECT
(split_part(a.code, '.'::text, 1))::integer AS cl1,
CASE
WHEN (a.code ~~ '%.%'::text) THEN (split_part(a.code, '.'::text, 2))::integer
ELSE 0
END AS cl2,
CASE
WHEN (a.code ~~ '%.%.%'::text) THEN (split_part(a.code, '.'::text, 3))::integer
ELSE 0
END AS cl3,
a.code,
a.name
FROM a
),
stress AS (
SELECT
b.cl1,
b.cl2,
b.cl3,
b.code,
b.name
FROM b
ORDER BY b.cl1, b.cl2, b.cl3
)
SELECT
cl1,
cl2,
cl3,
code,
name
FROM stress
ORDER BY cl1,cl2,cl3;
-------------------------------------------------------------------
-- THREATS --------------------------------------------------------
-------------------------------------------------------------------
DROP TABLE IF EXISTS threats CASCADE; 
CREATE TEMPORARY TABLE threats AS
SELECT DISTINCT internaltaxonid::bigint id_no,code::text,name::text
FROM import_tables.non_spatial_threats
WHERE internaltaxonid::bigint IN (SELECT DISTINCT id_no FROM import_tables.all_species_list)
ORDER BY internaltaxonid::bigint,code;
-- lt_table -------------------------------------------------------
DROP TABLE IF EXISTS lt_threats CASCADE; 
CREATE TEMPORARY TABLE lt_threats AS
WITH
a AS (
SELECT DISTINCT
id_no,
code
FROM threats
ORDER BY id_no,code
),
b AS (SELECT id_no,ARRAY_AGG(DISTINCT code ORDER BY code) threats
FROM a
GROUP by id_no
ORDER BY id_no)
SELECT DISTINCT * FROM b ORDER BY id_no,threats;
-- mt_table -------------------------------------------------------
DROP TABLE IF EXISTS mt_threats CASCADE; 
CREATE TEMPORARY TABLE mt_threats AS
WITH
a AS (
SELECT DISTINCT
code,name
FROM threats
ORDER BY code
),
b AS (
SELECT (split_part((a.code)::text, '.'::text, 1))::integer AS cl1,
CASE
WHEN ((a.code)::text ~~ '%.%'::text) THEN (split_part((a.code)::text, '.'::text, 2))::integer
ELSE 0
END AS cl2,
CASE
WHEN ((a.code)::text ~~ '%.%.%'::text) THEN (split_part((a.code)::text, '.'::text, 3))::integer
ELSE 0
END AS cl3,
a.code,
a.name
FROM a
),
threats AS (
SELECT
b.cl1,
b.cl2,
b.cl3,
b.code,
b.name
FROM b
ORDER BY b.cl1, b.cl2, b.cl3
)
SELECT
cl1,
cl2,
cl3,
code,
name
FROM threats
ORDER BY cl1,cl2,cl3;
-------------------------------------------------------------------
-- USETRADE -------------------------------------------------------
-------------------------------------------------------------------
DROP TABLE IF EXISTS usetrade CASCADE; 
CREATE TEMPORARY TABLE usetrade AS
SELECT DISTINCT internaltaxonid::bigint id_no,code::text,name::text
FROM import_tables.non_spatial_usetrade
WHERE internaltaxonid::bigint IN (SELECT DISTINCT id_no FROM import_tables.all_species_list)
ORDER BY internaltaxonid::bigint,code;
-- lt_table -------------------------------------------------------
DROP TABLE IF EXISTS lt_usetrade CASCADE; 
CREATE TEMPORARY TABLE lt_usetrade AS
WITH
a AS (
SELECT DISTINCT
id_no,
code::integer
FROM usetrade
ORDER BY id_no,code
),
b AS (SELECT id_no,ARRAY_AGG(DISTINCT code ORDER BY code) usetrade
FROM a
GROUP by id_no
ORDER BY id_no)
SELECT DISTINCT * FROM b ORDER BY id_no,usetrade;
-- mt_table -------------------------------------------------------
DROP TABLE IF EXISTS mt_usetrade CASCADE; 
CREATE TEMPORARY TABLE mt_usetrade AS
SELECT DISTINCT code::integer,name FROM usetrade
ORDER BY code,name;
-------------------------------------------------------------------
-- OUTPUTS --------------------------------------------------------
-------------------------------------------------------------------
-- main output table ----------------------------------------------
DROP TABLE IF EXISTS output_schema.dopa_species CASCADE;
CREATE TABLE output_schema.dopa_species AS
SELECT 
a.*,
b.ecosystems,
c.code category,
c.threatened,
d.code country,
d.cardinality country_n,
e.conservation_needed,
f.habitats,
g.research_needed,
h.stresses,
j.threats,
k.usetrade
FROM  mt_taxonomy a
LEFT JOIN lt_ecosystems b USING(id_no)
LEFT JOIN lt_category c USING(id_no)
LEFT JOIN lt_country d USING(id_no)
LEFT JOIN lt_conservation_needed e USING(id_no)
LEFT JOIN lt_habitats f USING(id_no)
LEFT JOIN lt_research_needed g USING(id_no)
LEFT JOIN lt_stresses h USING(id_no)
LEFT JOIN lt_threats j USING(id_no)
LEFT JOIN lt_usetrade k USING(id_no)
ORDER BY id_no;
-- ancillary tables -----------------------------------------------
DROP TABLE IF EXISTS output_schema.class_species_category CASCADE;
CREATE TABLE output_schema.class_species_category AS
SELECT * FROM category2 ORDER BY code;

DROP TABLE IF EXISTS output_schema.class_species_conservation_needed CASCADE;
CREATE TABLE output_schema.class_species_conservation_needed AS
SELECT * FROM mt_conservation_needed ORDER BY code;

DROP TABLE IF EXISTS output_schema.class_species_habitats CASCADE;
CREATE TABLE output_schema.class_species_habitats AS
SELECT * FROM mt_habitats ORDER BY code;

DROP TABLE IF EXISTS output_schema.class_species_research_needed CASCADE;
CREATE TABLE output_schema.class_species_research_needed AS
SELECT * FROM mt_research_needed ORDER BY code;

DROP TABLE IF EXISTS output_schema.class_species_stresses CASCADE;
CREATE TABLE output_schema.class_species_stresses AS
SELECT * FROM mt_stresses ORDER BY code;

DROP TABLE IF EXISTS output_schema.class_species_threats CASCADE;
CREATE TABLE output_schema.class_species_threats AS
SELECT * FROM mt_threats ORDER BY code;

DROP TABLE IF EXISTS output_schema.class_species_usetrade CASCADE;
CREATE TABLE output_schema.class_species_usetrade AS
SELECT * FROM mt_usetrade ORDER BY code;
