-------------------------------------------------------------------
-- spatial list  -------------------------------------------------------
-------------------------------------------------------------------
DROP TABLE IF EXISTS species_spatial_list;CREATE TEMPORARY TABLE species_spatial_list AS
SELECT DISTINCT 1 o,'corals' taxon,id_no FROM species_2026.spatial_corals
UNION
SELECT DISTINCT 2 o,'sharks' taxon,id_no FROM species_2026.spatial_sharks
UNION
SELECT DISTINCT 3 o,'amphibians' taxon,id_no FROM species_2026.spatial_amphibians
UNION
SELECT DISTINCT 4 o,'reptiles' taxon,id_no FROM species_2026.spatial_reptiles
UNION
SELECT DISTINCT 5 o,'birds' taxon,id_no FROM species_2026.spatial_birds
UNION
SELECT DISTINCT 6 o,'mammals' taxon,id_no FROM species_2026.spatial_mammals
ORDER BY o,taxon,id_no;
SELECT * FROM species_spatial_list;
-------------------------------------------------------------------
-- endemics -------------------------------------------------------
-------------------------------------------------------------------
DROP TABLE IF EXISTS endemics;
CREATE TEMPORARY TABLE endemics AS
SELECT DISTINCT
internaltaxonid::integer id_no,scientificname,TRUE endemic
FROM species_2026_input_data_original.nsp_endemics
ORDER BY id_no;
SELECT * FROM endemics;
-------------------------------------------------------------------
-- TAXONOMY -------------------------------------------------------
-------------------------------------------------------------------
DROP TABLE IF EXISTS mt_taxonomy;
CREATE TEMPORARY TABLE mt_taxonomy AS
SELECT b.o,b.taxon,a.*,c.endemic
FROM (
	SELECT DISTINCT
	internaltaxonid::bigint id_no,
	INITCAP(phylumname::text) AS phylum,	
	INITCAP(classname::text) AS class,
	INITCAP(ordername::text) AS order_,
	INITCAP(familyname::text) AS family,
	genusname::text AS genus,
	scientificname::text AS binomial
FROM species_2026_input_data_original.nsp_taxonomy) a
JOIN species_spatial_list b USING(id_no)
LEFT JOIN endemics c USING(id_no)
ORDER BY id_no;
SELECT * FROM mt_taxonomy;
-------------------------------------------------------------------
-- ECOSYSTEMS -----------------------------------------------------
-------------------------------------------------------------------
DROP TABLE IF EXISTS lt_ecosystems;
CREATE TEMPORARY TABLE lt_ecosystems AS
WITH
a AS (SELECT DISTINCT internaltaxonid::bigint id_no,LOWER(systems)::text systems
	  FROM species_2026_input_data_original.nsp_assessments
	  WHERE internaltaxonid::bigint IN (SELECT id_no FROM species_spatial_list)
	  ORDER BY id_no),
b AS (SELECT id_no,UNNEST(STRING_TO_ARRAY(systems::text,'|')) systems FROM a ORDER BY id_no),
c AS (SELECT id_no,CASE WHEN systems = 'freshwater (=inland waters)' THEN 'freshwater' ELSE systems END systems FROM b ORDER BY id_no),
d AS (SELECT *,CASE systems WHEN 'marine' THEN 1 WHEN 'terrestrial' THEN 2 WHEN 'freshwater' THEN 3 END system_order FROM c ORDER BY id_no,system_order)
SELECT id_no,ARRAY_AGG (systems) ecosystems FROM d GROUP BY id_no ORDER BY id_no;
SELECT * FROM lt_ecosystems;

-------------------------------------------------------------------
-- ELEVATION RANGES -----------------------------------------------------
-------------------------------------------------------------------
CREATE TEMPORARY TABLE mt_elevationranges AS
WITH
a AS (
    SELECT DISTINCT
        internaltaxonid::bigint AS id_no,
        NULLIF(elevationlower_limit, '')::numeric AS elevation_lower,
        NULLIF(elevationupper_limit, '')::numeric AS elevation_upper
    FROM species_2026_input_data_original.nsp_all_other_fields
    WHERE internaltaxonid::bigint IN (
        SELECT id_no
        FROM species_spatial_list
    )
)
SELECT *
FROM a
ORDER BY id_no;
SELECT * FROM mt_elevationranges;
-------------------------------------------------------------------
-- CATEGORIES -----------------------------------------------------
-------------------------------------------------------------------
DROP TABLE IF EXISTS category1;
CREATE TEMPORARY TABLE category1 AS
SELECT DISTINCT
internaltaxonid::bigint id_no,redlistcategory::text
FROM species_2026_input_data_original.nsp_assessments
WHERE internaltaxonid::bigint IN (SELECT id_no FROM species_spatial_list)
ORDER BY id_no;
SELECT * FROM category1;
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
SELECT * FROM category2;
-- lt_table -------------------------------------------------------
DROP TABLE IF EXISTS lt_category CASCADE;
CREATE TEMPORARY TABLE lt_category AS
SELECT DISTINCT id_no,code,threatened FROM category2 ORDER BY id_no;
SELECT * FROM lt_category;
-- mt_table -------------------------------------------------------
DROP TABLE IF EXISTS mt_category CASCADE;
CREATE TEMPORARY TABLE mt_category AS
SELECT DISTINCT code,name,threatened FROM category2 ORDER BY code;
SELECT * FROM mt_category;
-------------------------------------------------------------------
-- COUNTRIES ------------------------------------------------------
-------------------------------------------------------------------
DROP TABLE IF EXISTS country_1;
CREATE TEMPORARY TABLE country_1 AS
WITH a AS (
SELECT DISTINCT internaltaxonid::bigint id_no,code::text,name::text
FROM species_2026_input_data_original.nsp_countries
WHERE internaltaxonid::bigint IN (SELECT DISTINCT id_no FROM species_spatial_list)
AND presence::text IN ('Extant')
AND origin::text IN ('Native','Reintroduced','Assisted Colonisation')
-- seasonality can be null, and is a very week field
AND (seasonality IS NULL OR seasonality ILIKE '%Resident%' OR seasonality ILIKE '%Breeding Season%' OR seasonality ILIKE '%Non-Breeding Season%')
ORDER BY internaltaxonid::bigint,code)
SELECT * FROM a;
SELECT * FROM country_1;

-- lt_table -------------------------------------------------------
DROP TABLE IF EXISTS lt_country;
CREATE TEMPORARY TABLE lt_country AS
WITH
a AS (SELECT id_no,ARRAY_AGG(DISTINCT code ORDER BY code) code FROM country_1 GROUP BY id_no ORDER BY id_no),
b AS (SELECT *,CARDINALITY(code) FROM a ORDER BY CARDINALITY(code))
SELECT * FROM b
ORDER BY id_no,code;
SELECT * FROM lt_country;
-- mt_table -------------------------------------------------------
DROP TABLE IF EXISTS mt_country CASCADE;
CREATE TEMPORARY TABLE mt_country AS
SELECT DISTINCT code,name FROM country_1 ORDER BY code;
SELECT * FROM mt_country;
-------------------------------------------------------------------
-- CONSERVATION NEEDED --------------------------------------------
-------------------------------------------------------------------
DROP TABLE IF EXISTS conservation_needed CASCADE; 
CREATE TEMPORARY TABLE conservation_needed AS
SELECT DISTINCT internaltaxonid::bigint id_no,code::text,name::text
FROM species_2026_input_data_original.nsp_conservation_needed
WHERE internaltaxonid::bigint IN (SELECT DISTINCT id_no FROM species_spatial_list)
ORDER BY internaltaxonid::bigint,code;
SELECT * FROM conservation_needed;
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
SELECT * FROM lt_conservation_needed;
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
SELECT * FROM mt_conservation_needed;
-------------------------------------------------------------------
-- HABITATS -------------------------------------------------------
-------------------------------------------------------------------
-- HABITATS NOW INCLUDE SUITABLE, WHICH IS GIVEN BY FIELDS SUITABILITY AND MAJORIMPORTANCE, BUT DOES NOT CONSIDER SEASON;
-- SUITABILITY YES = 1
-- SUITABILIY YES AND MAJORIMPORTANCE YES = 2
-- IF IMPORTANCE IS DIFFERENTE WITHIN SEASONS,MAX IS TAKEN
DROP TABLE IF EXISTS habitats CASCADE; 
CREATE TEMPORARY TABLE habitats AS
SELECT DISTINCT internaltaxonid::bigint id_no,code::text,name::text,majorimportance::text,season::text,suitability::text
FROM species_2026_input_data_original.nsp_habitats
WHERE internaltaxonid::bigint IN (SELECT DISTINCT id_no FROM species_spatial_list)
ORDER BY internaltaxonid::bigint,code;
SELECT DISTINCT majorimportance,season,suitability FROM habitats;
-- lt_table -------------------------------------------------------
DROP TABLE IF EXISTS lt_habitats CASCADE; 
CREATE TEMPORARY TABLE lt_habitats AS
WITH
a AS (
    SELECT
        id_no,
        code,
        MAX(
            CASE
                WHEN suitability = 'Suitable'
                 AND majorimportance = 'Yes' THEN 2
                WHEN suitability = 'Suitable'
                 AND majorimportance IS DISTINCT FROM 'Yes' THEN 1
                ELSE 0
            END
        ) AS suitable
    FROM habitats
    GROUP BY id_no, code
),
b AS (
    SELECT
        id_no,
        ARRAY_AGG(code ORDER BY code) AS habitats,
        ARRAY_AGG(suitable ORDER BY code) AS suitable
    FROM a
    GROUP BY id_no
)
SELECT *
FROM b
ORDER BY id_no;
SELECT * FROM lt_habitats;
-- mt_table -------------------------------------------------------
DROP TABLE IF EXISTS mt_habitats CASCADE; 
CREATE TEMPORARY TABLE mt_habitats AS
WITH
a AS (
    SELECT DISTINCT
        code,
        name
    FROM habitats
),
b AS (
    SELECT
        split_part(code::text, '.', 1)::integer AS cl1,
        CASE
            WHEN code::text LIKE '%.%'
                THEN split_part(code::text, '.', 2)::integer
            ELSE 0
        END AS cl2,
        CASE
            WHEN code::text LIKE '%.%.%'
                THEN split_part(code::text, '.', 3)::integer
            ELSE 0
        END AS cl3,
        code,
        name
    FROM a
)
SELECT
    cl1,
    cl2,
    cl3,
    code,
    name
FROM b
ORDER BY cl1, cl2, cl3;
SELECT * FROM mt_habitats;
--------------------------------------------------------------------
--THE UNNEST IS THE FOLLOWING
--------------------------------------------------------------------
SELECT
    l.id_no,
    u.code,
    u.suitable,
    m.name,
    m.cl1,
    m.cl2,
    m.cl3
FROM lt_habitats l
CROSS JOIN LATERAL
    unnest(l.habitats, l.suitable) AS u(code, suitable)
LEFT JOIN mt_habitats m
    ON m.code = u.code
ORDER BY l.id_no, m.cl1, m.cl2, m.cl3;
-------------------------------------------------------------------
-- RESEARCH NEEDED ------------------------------------------------
-------------------------------------------------------------------
DROP TABLE IF EXISTS research_needed CASCADE; 
CREATE TEMPORARY TABLE research_needed AS
SELECT DISTINCT internaltaxonid::bigint id_no,code::text,name::text
FROM species_2026_input_data_original.nsp_research_needed
WHERE internaltaxonid::bigint IN (SELECT DISTINCT id_no FROM species_spatial_list)
ORDER BY internaltaxonid::bigint,code;
SELECT * FROM research_needed;
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
SELECT * FROM lt_research_needed;
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
SELECT * FROM mt_research_needed;
-------------------------------------------------------------------
-- STRESSES -------------------------------------------------------
-------------------------------------------------------------------
DROP TABLE IF EXISTS stresses CASCADE; 
CREATE TEMPORARY TABLE stresses AS
WITH
a AS (
SELECT DISTINCT internaltaxonid::bigint id_no,stresscode::text,stressname::text
FROM species_2026_input_data_original.nsp_threats
WHERE internaltaxonid::bigint IN (SELECT DISTINCT id_no FROM species_spatial_list)
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
SELECT * FROM stresses;
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
SELECT * FROM lt_stresses;
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
SELECT * FROM mt_stresses;
-------------------------------------------------------------------
-- THREATS --------------------------------------------------------
-------------------------------------------------------------------
DROP TABLE IF EXISTS threats CASCADE; 
CREATE TEMPORARY TABLE threats AS
SELECT DISTINCT internaltaxonid::bigint id_no,code::text,name::text
FROM species_2026_input_data_original.nsp_threats
WHERE internaltaxonid::bigint IN (SELECT DISTINCT id_no FROM species_spatial_list)
ORDER BY internaltaxonid::bigint,code;
SELECT * FROM threats;
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
SELECT * FROM lt_threats;
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
SELECT * FROM mt_threats;
-------------------------------------------------------------------
-- USETRADE -------------------------------------------------------
-------------------------------------------------------------------
DROP TABLE IF EXISTS usetrade CASCADE; 
CREATE TEMPORARY TABLE usetrade AS
SELECT DISTINCT internaltaxonid::bigint id_no,code::text,name::text
FROM species_2026_input_data_original.nsp_usetrade
WHERE internaltaxonid::bigint IN (SELECT DISTINCT id_no FROM species_spatial_list)
ORDER BY internaltaxonid::bigint,code;
SELECT * FROM usetrade;
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
SELECT * FROM lt_usetrade;
-- mt_table -------------------------------------------------------
DROP TABLE IF EXISTS mt_usetrade CASCADE; 
CREATE TEMPORARY TABLE mt_usetrade AS
SELECT DISTINCT code::integer,name FROM usetrade
ORDER BY code,name;
SELECT * FROM mt_usetrade;
-------------------------------------------------------------------
-- OUTPUTS --------------------------------------------------------
-------------------------------------------------------------------
-- main output table ----------------------------------------------
DROP TABLE IF EXISTS species_2026.dopa_species CASCADE;
CREATE TABLE species_2026.dopa_species AS
SELECT 
a.*,
NULL::double precision range_sqkm,
NULL::double precision aoh_sqkm,
NULL::double precision prot_range_sqkm,
NULL::double precision prot_aoh_sqkm,
b.ecosystems,
c.code category,
c.threatened,
d.code country,
d.cardinality country_n,
e.conservation_needed,
f.habitats,f.suitable habitats_suitable,l.elevation_lower,l.elevation_upper,
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
LEFT JOIN mt_elevationranges l USING(id_no)
ORDER BY o,id_no;
SELECT * FROM species_2026.dopa_species;
-- ancillary tables -----------------------------------------------
DROP TABLE IF EXISTS species_2026.class_species_category CASCADE;
CREATE TABLE species_2026.class_species_category AS
SELECT * FROM mt_category ORDER BY code;

DROP TABLE IF EXISTS species_2026.class_species_conservation_needed CASCADE;
CREATE TABLE species_2026.class_species_conservation_needed AS
SELECT * FROM mt_conservation_needed ORDER BY code;

DROP TABLE IF EXISTS species_2026.class_species_habitat CASCADE;
CREATE TABLE species_2026.class_species_habitat AS
SELECT * FROM mt_habitats ORDER BY code;

DROP TABLE IF EXISTS species_2026.class_species_research_needed CASCADE;
CREATE TABLE species_2026.class_species_research_needed AS
SELECT * FROM mt_research_needed ORDER BY code;

DROP TABLE IF EXISTS species_2026.class_species_stress CASCADE;
CREATE TABLE species_2026.class_species_stress AS
SELECT * FROM mt_stresses ORDER BY code;

DROP TABLE IF EXISTS species_2026.class_species_threat CASCADE;
CREATE TABLE species_2026.class_species_threat AS
SELECT * FROM mt_threats ORDER BY code;

DROP TABLE IF EXISTS species_2026.class_species_usetrade CASCADE;
CREATE TABLE species_2026.class_species_usetrade AS
SELECT * FROM mt_usetrade ORDER BY code;

DROP TABLE IF EXISTS species_2026.class_species_country CASCADE;
CREATE TABLE species_2026.class_species_country AS
SELECT * FROM mt_country ORDER BY code;

------------------------------------------------------------------------------------------
--CLEAN spatial if missing in attributes. NONE DELETED
------------------------------------------------------------------------------------------
DELETE FROM species_2026.spatial_corals
WHERE id_no NOT IN (SELECT id_no FROM species_2026.dopa_species WHERE taxon = 'corals');

DELETE FROM species_2026.spatial_sharks
WHERE id_no NOT IN (SELECT id_no FROM species_2026.dopa_species WHERE taxon = 'sharks');

DELETE FROM species_2026.spatial_amphibians
WHERE id_no NOT IN (SELECT id_no FROM species_2026.dopa_species WHERE taxon = 'amphibians');

DELETE FROM species_2026.spatial_reptiles
WHERE id_no NOT IN (SELECT id_no FROM species_2026.dopa_species WHERE taxon = 'reptiles');

DELETE FROM species_2026.spatial_birds
WHERE id_no NOT IN (SELECT id_no FROM species_2026.dopa_species WHERE taxon = 'birds');

DELETE FROM species_2026.spatial_mammals
WHERE id_no NOT IN (SELECT id_no FROM species_2026.dopa_species WHERE taxon = 'mammals');



