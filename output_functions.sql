-- CREATES FINAL OUTPUT TABLE ------------------------------------------------
DROP TABLE IF EXISTS species.mt_species_output CASCADE;
CREATE TABLE species.mt_species_output AS
SELECT
a.id_no,
a.class,
a.order_,
a.family,
a.genus,
a.binomial,
a.category,
c.threatened,
h.ecosystems,
e.habitats,
b.country,
b.n_country,
b.endemic,
j.stresses,
d.threats,
g.research_needed,
f.conservation_needed,
i.usetrade
FROM species.mt_attributes a
LEFT JOIN species.dt_species_country_endemics b USING(id_no)
LEFT JOIN species.dt_species_threatened c USING(id_no)
LEFT JOIN species.dt_species_threats d USING(id_no)
LEFT JOIN species.dt_species_habitats e USING(id_no)
LEFT JOIN species.dt_species_conservation_needed f USING(id_no)
LEFT JOIN species.dt_species_research_needed g USING(id_no)
JOIN species.dt_species_ecosystems h USING(id_no)
LEFT JOIN species.dt_species_usetrade i USING(id_no)
LEFT JOIN species.dt_species_stresses j USING(id_no)
ORDER BY a.id_no;

-- CREATES FINAL FUNCTIONS ---------------------------------------------

-------FN_GET_LIST_SPECIES_OUTPUT---------------------------------------
DROP FUNCTION IF EXISTS species.get_list_species_output(bigint, text, text, text, text, text, text, boolean, text, text, text, boolean, text, text, text, text, text);
CREATE OR REPLACE FUNCTION species.get_list_species_output(
a_id_no bigint DEFAULT NULL::bigint,
b_class text DEFAULT NULL::text,
c_order text DEFAULT NULL::text,
d_family text DEFAULT NULL::text,
e_genus text DEFAULT NULL::text,
f_binomial text DEFAULT NULL::text,
g_category text DEFAULT NULL::text,
h_threatened bool DEFAULT NULL::bool,
i_ecosystems text DEFAULT NULL::text,
j_habitats text DEFAULT NULL::text,
k_country text DEFAULT NULL::text,
l_endemic bool DEFAULT NULL::bool,
m_stresses text DEFAULT NULL::text,
n_threats text DEFAULT NULL::text,
o_research_needed text DEFAULT NULL::text,
p_conservation_needed text DEFAULT NULL::text,
q_usetrade text DEFAULT NULL::text
)
RETURNS SETOF species.mt_species_output
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
mg_category text := (SELECT ARRAY_TO_STRING(ARRAY_AGG(''''||a||''''),',') FROM (SELECT a FROM regexp_split_to_table(UPPER(g_category), ',') AS a) tb);
mi_ecosystems text := (SELECT ARRAY_TO_STRING(ARRAY_AGG(''''||a||''''),',') FROM (SELECT a FROM regexp_split_to_table(LOWER(i_ecosystems), ',') AS a) tb);
mj_habitats text := (SELECT ARRAY_TO_STRING(ARRAY_AGG(''''||a||''''),',') FROM (SELECT a FROM regexp_split_to_table(j_habitats, ',') AS a) tb);
mk_country text := (SELECT ARRAY_TO_STRING(ARRAY_AGG(''''||a||''''),',') FROM (SELECT a FROM regexp_split_to_table(UPPER(k_country), ',') AS a) tb);
mm_stresses text := (SELECT ARRAY_TO_STRING(ARRAY_AGG(''''||a||''''),',') FROM (SELECT a FROM regexp_split_to_table(m_stresses, ',') AS a) tb);
mn_threats text := (SELECT ARRAY_TO_STRING(ARRAY_AGG(''''||a||''''),',') FROM (SELECT a FROM regexp_split_to_table(n_threats, ',') AS a) tb);
mo_research_needed text := (SELECT ARRAY_TO_STRING(ARRAY_AGG(''''||a||''''),',') FROM (SELECT a FROM regexp_split_to_table(o_research_needed, ',') AS a) tb);
mp_conservation_needed text := (SELECT ARRAY_TO_STRING(ARRAY_AGG(''''||a||''''),',') FROM (SELECT a FROM regexp_split_to_table(p_conservation_needed, ',') AS a) tb);
mq_usetrade text := (SELECT ARRAY_TO_STRING(ARRAY_AGG(a),',') FROM (SELECT a FROM regexp_split_to_table(q_usetrade, ',') AS a) tb);

sql TEXT;
BEGIN

sql :='
SELECT * FROM species.mt_species_output
WHERE id_no IS NOT NULL';
IF a_id_no IS NOT NULL THEN sql := sql || ' AND id_no = '||a_id_no||' '; END IF;
IF b_class IS NOT NULL THEN sql := sql || ' AND class ILIKE '''||b_class||'%'' '; END IF;
IF c_order IS NOT NULL THEN sql := sql || ' AND order_ ILIKE '''||c_order||'%'' '; END IF;
IF d_family IS NOT NULL THEN sql := sql || ' AND family ILIKE '''||d_family||'%'' '; END IF;
IF e_genus IS NOT NULL THEN sql := sql || ' AND genus ILIKE '''||e_genus||'%'' '; END IF;
IF f_binomial IS NOT NULL THEN sql := sql || ' AND binomial ILIKE '''||f_binomial||'%''  '; END IF;
IF g_category IS NOT NULL THEN sql := sql || ' AND category IN ('||mg_category||') '; END IF;
IF h_threatened IS NOT NULL THEN sql := sql || ' AND threatened IS '||h_threatened||' '; END IF;
IF i_ecosystems IS NOT NULL THEN sql := sql || ' AND ARRAY['||mi_ecosystems||'] && ecosystems  '; END IF;
IF j_habitats IS NOT NULL THEN sql := sql || ' AND ARRAY['||mj_habitats||'] && habitats  '; END IF;
IF k_country IS NOT NULL THEN sql := sql || ' AND ARRAY['||mk_country||'] && country  '; END IF;
IF l_endemic IS NOT NULL THEN sql := sql || ' AND endemic IS '||l_endemic||' '; END IF;
IF m_stresses IS NOT NULL THEN sql := sql || ' AND ARRAY['||mm_stresses||'] && stresses  '; END IF;
IF n_threats IS NOT NULL THEN sql := sql || ' AND ARRAY['||mn_threats||'] && threats  '; END IF;
IF o_research_needed IS NOT NULL THEN sql := sql || ' AND ARRAY['||mo_research_needed||'] && research_needed  '; END IF;
IF p_conservation_needed IS NOT NULL THEN sql := sql || ' AND ARRAY['||mp_conservation_needed||'] && conservation_needed  '; END IF;
IF q_usetrade IS NOT NULL THEN sql := sql || ' AND ARRAY['||mq_usetrade||']::integer[] && usetrade  '; END IF;


sql := sql || ' ORDER BY id_no;';
RETURN QUERY EXECUTE sql;
END;
$BODY$;
COMMENT ON FUNCTION species.get_list_species_output(bigint, text, text, text, text, text, text, boolean, text, text, text, boolean, text, text, text, text, text)
IS '
Shows all species direct and relate attributes.
Input parameters are:
- a_id_no bigint (default: NULL): filters by one single species id 
- b_class text (default: NULL): filters by class. Is not case sensitive, and accepts partial values (eg: ''MAMMALIA'', ''Mammalia'' or ''mamm'' are all valid)
- c_order text (default: NULL): filters by order. Is not case sensitive, and accepts partial values (eg: ''CARNIVORA'', ''Carnivora'' or ''carn'' are all valid)
- d_family text (default: NULL): filters by family. Is not case sensitive, and accepts partial values (eg: ''CANIDAE'', ''Canidae'' or ''can'' are all valid)
- e_genus text (default: NULL): filters by genus. Is not case sensitive, and accepts partial values (eg: ''CANIS'', ''Canis'' or ''can'' are all valid)
- f_binomial text (default: NULL): filters by species. Is not case sensitive, and accepts partial values (eg: ''Canis lupus'', ''canis lupus'' or ''canis lup'' are all valid)
- g_category text (default: NULL): filters by IUCN category. Is not case sensitive, and accepts single values or lists (eg: ''CR'',''Vu'' or ''CR,vu'' are all valid). The service "get_list_categories" returns the list of used categories
- h_threatened boolean (default: NULL): filters by threatened species (Critically Endangered, Endangered and Vulnerable IUCN categories). Is not case sensitive (eg: TRUE or false are both valid)
- i_ecosystems text (default: NULL): filters by ecosystem (marine, terrestrial, freshwater). Is not case sensitive, accepts single values or lists and uses overlap operator (eg: ''marine'',''Terrestrial'' or ''terrestrial,Freshwater'' are all valid; ''marine'' returns {marine},{marine,terrestrial},etc...; ''marine,terrestrial'' returns: {marine},{terrestrial},{marine,terrestrial},etc...)
- j_habitats text (default: NULL): filters by habitat code. Accepts single values or lists and uses overlap operator (eg: ''1.6'' or ''1.6,14.4'' are both valid; ''1.6'' returns: {1.6},{1.6,1.14},etc...; ''1.6,1.14'' returns: {1.6},{1.14},{1.6,1.14},etc...). The service "get_list_habitats" returns the code/names pairs for used habitats
- k_country text (default: NULL): filters by country code. Is not case sensitive, accepts single values or lists and uses overlap operator (eg: ''IT'', ''fr'' or ''It,FR'' are all valid; ''IT'' returns: {IT},{IT,FR},etc...; ''IT,FR'' returns: {IT},{FR},{IT,FR},etc...). The service "get_list_countries" returns the code/names pairs for used countries
- l_endemic boolean (default: NULL): filters by threatened species (n_country=1). Is not case sensitive (eg: TRUE or false are both valid)
- m_stresses text (default: NULL): filters by stress code. Accepts single values or lists and uses overlap operator (eg: ''1.2'' or ''1.2,2.1'' are both valid; ''1.2'' returns: {1.2},{1.2,2.1},etc...; ''1.2,2.1'' returns: {1.2},{2.1},{1.2,2.1},etc...). The service "get_list_stresses" returns the code/names pairs for used stresses
- n_threats text (default: NULL): filters by threat code. Accepts single values or lists and uses overlap operator (eg: ''1.2'' or ''1.2,2.1'' are both valid; ''1.2'' returns: {1.2},{1.2,2.1},etc...; ''1.2,2.1'' returns: {1.2},{2.1},{1.2,2.1},etc...). The service "get_list_threats" returns the code/names pairs for used threats
- o_research_needed text (default: NULL): filters by research needed code. Accepts single values or lists and uses overlap operator (eg: ''1.2'' or ''1.2,2.1'' are both valid; ''1.2'' returns: {1.2},{1.2,2.1},etc...; ''1.2,2.1'' returns: {1.2},{2.1},{1.2,2.1},etc...). The service "get_list_research_needed" returns the code/names pairs for used research needed
- p_conservation_needed text (default: NULL): filters by conservation needed code. Accepts single values or lists and uses overlap operator (eg: ''1.2'' or ''1.2,2.1'' are both valid; ''1.2'' returns: {1.2},{1.2,2.1},etc...; ''1.2,2.1'' returns: {1.2},{2.1},{1.2,2.1},etc...). The service "get_list_conservation_needed" returns the code/names pairs for used conservation needed
- q_usetrade text (default: NULL): filters by usetrade code. Accepts single values or lists and uses overlap operator (eg: ''1'' or ''15'' are both valid; ''1'' returns: {1},{1,15},etc...; ''1,15'' returns: {1},{15},{1,15},etc...). The service "get_list_usetrade" returns the code/names pairs for used usetrade
Output parameters are:
- id_no bigint
- class text
- order_ text
- family text
- genus text
- binomial text
- category text
- threatened boolean
- ecosystems text[]
- habitats text[]
- country text[]
- n_country integer
- endemic boolean
- stresses text[]
- threats text[]
- research_needed text[]
- conservation_needed text[]
- usetrade integer[]
';

-------FN_GET_LIST_SPECIES_OUTPUT---------------------------------------
CREATE OR REPLACE FUNCTION species.get_single_species_output(
	a_id_no bigint DEFAULT NULL::bigint)
    RETURNS TABLE(id_no bigint, class text, order_ text, family text, genus text, binomial text, category text, threatened boolean, n_country integer, endemic boolean, ecosystems text, habitat_code text, habitat_name text, country_code text, country_name text, stress_code text, stress_name text, threat_code text, threat_name text, research_needed_code text, research_needed_name text, conservation_needed_code text, conservation_needed_name text, usetrade_code integer, usetrade_name text) 
    LANGUAGE 'plpgsql'    
AS $BODY$
DECLARE
sql TEXT;
BEGIN
sql := '
WITH
a AS (
SELECT
id_no,class,order_,family,genus,binomial,category,threatened,n_country,endemic,t.*
FROM species.mt_species_output, UNNEST(ecosystems,habitats,country,stresses,threats,research_needed,conservation_needed,usetrade) t(ecosystems,habitats,country,stresses,threats,research_needed,conservation_needed,usetrade)';
IF a_id_no IS NOT NULL THEN sql := sql || ' WHERE id_no = '||a_id_no||' ';
ELSE	sql := sql || ' WHERE id_no = 219 ';
END IF;
sql := sql || '
)
SELECT
a.id_no,a.class,a.order_,a.family,a.genus,a.binomial,a.category,a.threatened,a.n_country,a.endemic,a.ecosystems,
b.code habitat_code,b.name habitat_name,
c.code country_code,c.name country_name,
d.code stress_code,d.name stress_name,
e.code threat_code,e.name threat_name,
f.code research_needed_code,f.name research_needed_name,
g.code conservation_needed_code,g.name conservation_needed_name,
h.code usetrade_code,h.name usetrade_name
FROM a
LEFT JOIN species.mt_habitats b ON a.habitats=b.code
LEFT JOIN species.mt_countries c ON a.country=c.code
LEFT JOIN species.mt_stresses d ON a.stresses=d.code
LEFT JOIN species.mt_threats e ON a.threats=e.code
LEFT JOIN species.mt_research_needed f ON a.research_needed=f.code
LEFT JOIN species.mt_conservation_needed g ON a.conservation_needed=g.code
LEFT JOIN species.mt_usetrade h ON a.usetrade=h.code
ORDER BY ecosystems,habitat_code,country_code,stress_code,threat_code,research_needed_code,conservation_needed_code,usetrade_code
;';
RETURN QUERY EXECUTE sql;
END;
$BODY$;

ALTER FUNCTION species.get_single_species_output(bigint)
    OWNER TO h05ibex;

COMMENT ON FUNCTION species.get_single_species_output(bigint)
    IS 'Shows for a single species direct and related detailed attributes';
    
-------FN_GET_LIST_CATEGORIES--------------------------------
CREATE OR REPLACE FUNCTION species.get_list_categories()
RETURNS SETOF species.mt_categories
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
RETURN QUERY EXECUTE 'SELECT * FROM species.mt_categories;';
END;
$BODY$;
COMMENT ON FUNCTION species.get_list_categories() IS 'Shows list of EXISTING categories';


-------FN_GET_LIST_CONSERVATION_NEEDED--------------------------------
CREATE OR REPLACE FUNCTION species.get_list_conservation_needed()
RETURNS SETOF species.mt_conservation_needed
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
RETURN QUERY EXECUTE 'SELECT * FROM species.mt_conservation_needed;';
END;
$BODY$;
COMMENT ON FUNCTION species.get_list_conservation_needed() IS 'Shows list of EXISTING conservation needed';

-------FN_GET_LIST_COUNTRIES --------------------------------
CREATE OR REPLACE FUNCTION species.get_list_countries()
RETURNS SETOF species.mt_countries
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
RETURN QUERY EXECUTE 'SELECT * FROM species.mt_countries;';
END;
$BODY$;
COMMENT ON FUNCTION species.get_list_countries() IS 'Shows list of EXISTING countries';

-------FN_GET_LIST_HABITATS --------------------------------
CREATE OR REPLACE FUNCTION species.get_list_habitats()
RETURNS SETOF species.mt_habitats
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
RETURN QUERY EXECUTE 'SELECT * FROM species.mt_habitats;';
END;
$BODY$;
COMMENT ON FUNCTION species.get_list_habitats() IS 'Shows list of EXISTING habitats;';

-------FN_GET_LIST_RESEARCH_NEEDED--------------------------------
CREATE OR REPLACE FUNCTION species.get_list_research_needed()
RETURNS SETOF species.mt_research_needed
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
RETURN QUERY EXECUTE 'SELECT * FROM species.mt_research_needed;';
END;
$BODY$;
COMMENT ON FUNCTION species.get_list_research_needed() IS 'Shows list of EXISTING research needed';


-------FN_GET_LIST_STRESSES--------------------------------
CREATE OR REPLACE FUNCTION species.get_list_stresses()
RETURNS SETOF species.mt_stresses
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
RETURN QUERY EXECUTE 'SELECT * FROM species.mt_stresses;';
END;
$BODY$;
COMMENT ON FUNCTION species.get_list_stresses() IS 'Shows list of EXISTING stresses';

-------FN_GET_LIST_THREATS--------------------------------
CREATE OR REPLACE FUNCTION species.get_list_threats()
RETURNS SETOF species.mt_threats
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
RETURN QUERY EXECUTE 'SELECT * FROM species.mt_threats;';
END;
$BODY$;
COMMENT ON FUNCTION species.get_list_threats() IS 'Shows list of EXISTING threats';

-------FN_GET_LIST_USETRADE--------------------------------
CREATE OR REPLACE FUNCTION species.get_list_usetrade()
RETURNS SETOF species.mt_usetrade
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
RETURN QUERY EXECUTE 'SELECT * FROM species.mt_usetrade;';
END;
$BODY$;
COMMENT ON FUNCTION species.get_list_usetrade() IS 'Shows list of EXISTING uses and trades';


--------- GRANTS FOR DOPA REST -------------------------------------------------------------
GRANT USAGE ON SCHEMA species TO h05ibexro;
GRANT SELECT ON ALL TABLES IN SCHEMA species TO h05ibexro;
