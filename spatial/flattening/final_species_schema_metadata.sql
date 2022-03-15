---------------------------------------------------
-- COUNT RESULTS
---------------------------------------------------
DROP TABLE IF EXISTS taxa_richness;CREATE TEMPORARY TABLE taxa_richness AS
SELECT
1 ord,
'corals' taxon,
MAX(corals_richness) max_richness,
MAX(corals_threatened_richness) max_threatened_richness,
MAX(corals_endemic_richness) max_endemic_richness,
MAX(corals_threatened_endemic_richness) max_threatened_endemic_richness
FROM species_2022_all_taxa.corals_attributes
UNION
SELECT
2 ord,
'sharks' taxon,
MAX(sharks_richness) max_richness,
MAX(sharks_threatened_richness) max_threatened_richness,
MAX(sharks_endemic_richness) max_endemic_richness,
MAX(sharks_threatened_endemic_richness) max_threatened_endemic_richness
FROM species_2022_all_taxa.sharks_attributes
UNION
SELECT
3 ord,
'amphibians' taxon,
MAX(amphibians_richness) max_richness,
MAX(amphibians_threatened_richness) max_threatened_richness,
MAX(amphibians_endemic_richness) max_endemic_richness,
MAX(amphibians_threatened_endemic_richness) max_threatened_endemic_richness
FROM species_2022_all_taxa.amphibians_attributes
UNION
SELECT
4 ord,
'birds' taxon,
MAX(birds_richness) max_richness,
MAX(birds_threatened_richness) max_threatened_richness,
MAX(birds_endemic_richness) max_endemic_richness,
MAX(birds_threatened_endemic_richness) max_threatened_endemic_richness
FROM species_2022_all_taxa.birds_attributes
UNION
SELECT
5 ord,
'mammals' taxon,
MAX(mammals_richness) max_richness,
MAX(mammals_threatened_richness) max_threatened_richness,
MAX(mammals_endemic_richness) max_endemic_richness,
MAX(mammals_threatened_endemic_richness) max_threatened_endemic_richness
FROM species_2022_all_taxa.mammals_attributes
order by ord;


DROP TABLE IF EXISTS list_input_corals;CREATE TEMPORARY TABLE list_input_corals AS
SELECT a.id_no FROM dopa.dopa_species a
WHERE a.class IN ('Hydrozoa','Anthozoa');
DROP TABLE IF EXISTS list_processed_corals;CREATE TEMPORARY TABLE list_processed_corals AS
SELECT DISTINCT(UNNEST(corals)) id_no, 1::bool p FROM species_2022_all_taxa.corals_attributes ORDER BY id_no;
DROP TABLE IF EXISTS list_final_corals;CREATE TEMPORARY TABLE list_final_corals AS
SELECT * FROM list_input_corals a
LEFT JOIN list_processed_corals b USING (id_no);
DROP TABLE IF EXISTS count_input_corals;CREATE TEMPORARY TABLE count_input_corals AS
SELECT 1 ord,COUNT(*) inputs FROM list_final_corals;
DROP TABLE IF EXISTS count_processed_corals;CREATE TEMPORARY TABLE count_processed_corals AS
SELECT 1 ord,COUNT(*) processed FROM list_final_corals WHERE p IS TRUE;
DROP TABLE IF EXISTS list_missing_corals;CREATE TEMPORARY TABLE list_missing_corals AS
SELECT 1 ord,ARRAY_AGG(DISTINCT id_no ORDER BY id_no) missing FROM list_final_corals WHERE p IS NOT TRUE;
DROP TABLE IF EXISTS final_corals;CREATE TEMPORARY TABLE final_corals AS
SELECT * FROM count_input_corals
LEFT JOIN count_processed_corals USING(ord)
LEFT JOIN list_missing_corals USING(ord);

DROP TABLE IF EXISTS list_input_sharks;CREATE TEMPORARY TABLE list_input_sharks AS
SELECT a.id_no FROM dopa.dopa_species a
WHERE a.class IN ('Chondrichthyes');
DROP TABLE IF EXISTS list_processed_sharks;CREATE TEMPORARY TABLE list_processed_sharks AS
SELECT DISTINCT(UNNEST(sharks)) id_no, 2::bool p FROM species_2022_all_taxa.sharks_attributes ORDER BY id_no;
DROP TABLE IF EXISTS list_final_sharks;CREATE TEMPORARY TABLE list_final_sharks AS
SELECT * FROM list_input_sharks a
LEFT JOIN list_processed_sharks b USING (id_no);
DROP TABLE IF EXISTS count_input_sharks;CREATE TEMPORARY TABLE count_input_sharks AS
SELECT 2 ord,COUNT(*) inputs FROM list_final_sharks;
DROP TABLE IF EXISTS count_processed_sharks;CREATE TEMPORARY TABLE count_processed_sharks AS
SELECT 2 ord,COUNT(*) processed FROM list_final_sharks WHERE p IS TRUE;
DROP TABLE IF EXISTS list_missing_sharks;CREATE TEMPORARY TABLE list_missing_sharks AS
SELECT 2 ord,ARRAY_AGG(DISTINCT id_no ORDER BY id_no) missing FROM list_final_sharks WHERE p IS NOT TRUE;
DROP TABLE IF EXISTS final_sharks;CREATE TEMPORARY TABLE final_sharks AS
SELECT * FROM count_input_sharks
LEFT JOIN count_processed_sharks USING(ord)
LEFT JOIN list_missing_sharks USING(ord);

DROP TABLE IF EXISTS list_input_amphibians;CREATE TEMPORARY TABLE list_input_amphibians AS
SELECT a.id_no FROM dopa.dopa_species a
WHERE a.class IN ('Amphibia');
DROP TABLE IF EXISTS list_processed_amphibians;CREATE TEMPORARY TABLE list_processed_amphibians AS
SELECT DISTINCT(UNNEST(amphibians)) id_no, 1::bool p FROM species_2022_all_taxa.amphibians_attributes ORDER BY id_no;
DROP TABLE IF EXISTS list_final_amphibians;CREATE TEMPORARY TABLE list_final_amphibians AS
SELECT * FROM list_input_amphibians a
LEFT JOIN list_processed_amphibians b USING (id_no);
DROP TABLE IF EXISTS count_input_amphibians;CREATE TEMPORARY TABLE count_input_amphibians AS
SELECT 3 ord,COUNT(*) inputs FROM list_final_amphibians;
DROP TABLE IF EXISTS count_processed_amphibians;CREATE TEMPORARY TABLE count_processed_amphibians AS
SELECT 3 ord,COUNT(*) processed FROM list_final_amphibians WHERE p IS TRUE;
DROP TABLE IF EXISTS list_missing_amphibians;CREATE TEMPORARY TABLE list_missing_amphibians AS
SELECT 3 ord,ARRAY_AGG(DISTINCT id_no ORDER BY id_no) missing FROM list_final_amphibians WHERE p IS NOT TRUE;
DROP TABLE IF EXISTS final_amphibians;CREATE TEMPORARY TABLE final_amphibians AS
SELECT * FROM count_input_amphibians
LEFT JOIN count_processed_amphibians USING(ord)
LEFT JOIN list_missing_amphibians USING(ord);

DROP TABLE IF EXISTS list_input_birds;CREATE TEMPORARY TABLE list_input_birds AS
SELECT a.id_no FROM dopa.dopa_species a
WHERE a.class IN ('Aves');
DROP TABLE IF EXISTS list_processed_birds;CREATE TEMPORARY TABLE list_processed_birds AS
SELECT DISTINCT(UNNEST(birds)) id_no, 1::bool p FROM species_2022_all_taxa.birds_attributes ORDER BY id_no;
DROP TABLE IF EXISTS list_final_birds;CREATE TEMPORARY TABLE list_final_birds AS
SELECT * FROM list_input_birds a
LEFT JOIN list_processed_birds b USING (id_no);
DROP TABLE IF EXISTS count_input_birds;CREATE TEMPORARY TABLE count_input_birds AS
SELECT 4 ord,COUNT(*) inputs FROM list_final_birds;
DROP TABLE IF EXISTS count_processed_birds;CREATE TEMPORARY TABLE count_processed_birds AS
SELECT 4 ord,COUNT(*) processed FROM list_final_birds WHERE p IS TRUE;
DROP TABLE IF EXISTS list_missing_birds;CREATE TEMPORARY TABLE list_missing_birds AS
SELECT 4 ord,ARRAY_AGG(DISTINCT id_no ORDER BY id_no) missing FROM list_final_birds WHERE p IS NOT TRUE;
DROP TABLE IF EXISTS final_birds;CREATE TEMPORARY TABLE final_birds AS
SELECT * FROM count_input_birds
LEFT JOIN count_processed_birds USING(ord)
LEFT JOIN list_missing_birds USING(ord);

DROP TABLE IF EXISTS list_input_mammals;CREATE TEMPORARY TABLE list_input_mammals AS
SELECT a.id_no FROM dopa.dopa_species a
WHERE a.class IN ('Mammalia');
DROP TABLE IF EXISTS list_processed_mammals;CREATE TEMPORARY TABLE list_processed_mammals AS
SELECT DISTINCT(UNNEST(mammals)) id_no, 1::bool p FROM species_2022_all_taxa.mammals_attributes ORDER BY id_no;
DROP TABLE IF EXISTS list_final_mammals;CREATE TEMPORARY TABLE list_final_mammals AS
SELECT * FROM list_input_mammals a
LEFT JOIN list_processed_mammals b USING (id_no);
DROP TABLE IF EXISTS count_input_mammals;CREATE TEMPORARY TABLE count_input_mammals AS
SELECT 5 ord,COUNT(*) inputs FROM list_final_mammals;
DROP TABLE IF EXISTS count_processed_mammals;CREATE TEMPORARY TABLE count_processed_mammals AS
SELECT 5 ord,COUNT(*) processed FROM list_final_mammals WHERE p IS TRUE;
DROP TABLE IF EXISTS list_missing_mammals;CREATE TEMPORARY TABLE list_missing_mammals AS
SELECT 5 ord,ARRAY_AGG(DISTINCT id_no ORDER BY id_no) missing FROM list_final_mammals WHERE p IS NOT TRUE;
DROP TABLE IF EXISTS final_mammals;CREATE TEMPORARY TABLE final_mammals AS
SELECT * FROM count_input_mammals
LEFT JOIN count_processed_mammals USING(ord)
LEFT JOIN list_missing_mammals USING(ord);


DROP TABLE IF EXISTS final_species;CREATE TEMPORARY TABLE final_species AS
SELECT * FROM final_corals
UNION
SELECT * FROM final_sharks
UNION
SELECT * FROM final_amphibians
UNION
SELECT * FROM final_birds
UNION
SELECT * FROM final_mammals
ORDER BY ord;

DROP TABLE IF EXISTS count_combinations;CREATE TEMPORARY TABLE count_combinations AS
SELECT 1 ord,COUNT(*) combinations FROM species_2022_all_taxa.corals_attributes
UNION
SELECT 2 ord,COUNT(*) combinations FROM species_2022_all_taxa.sharks_attributes
UNION
SELECT 3 ord,COUNT(*) combinations FROM species_2022_all_taxa.amphibians_attributes
UNION
SELECT 4 ord,COUNT(*) combinations FROM species_2022_all_taxa.birds_attributes
UNION
SELECT 5 ord,COUNT(*) combinations FROM species_2022_all_taxa.mammals_attributes
ORDER BY ord;

DROP TABLE IF EXISTS count_rows;CREATE TEMPORARY TABLE count_rows AS
SELECT 1 ord,COUNT(*) nrows FROM species_2022_all_taxa.corals_flat
UNION
SELECT 2 ord,COUNT(*) nrows FROM species_2022_all_taxa.sharks_flat
UNION
SELECT 3 ord,COUNT(*) nrows FROM species_2022_all_taxa.amphibians_flat
UNION
SELECT 4 ord,COUNT(*) nrows FROM species_2022_all_taxa.birds_flat
UNION
SELECT 5 ord,COUNT(*) nrows FROM species_2022_all_taxa.mammals_flat
ORDER BY ord;

DROP TABLE IF EXISTS size_geoms;CREATE TEMPORARY TABLE size_geoms AS
SELECT 1 ord,pg_size_pretty( pg_total_relation_size('species_2022_all_taxa.corals_flat')) sgeom
UNION
SELECT 2 ord,pg_size_pretty( pg_total_relation_size('species_2022_all_taxa.sharks_flat')) sgeom
UNION
SELECT 3 ord,pg_size_pretty( pg_total_relation_size('species_2022_all_taxa.amphibians_flat')) sgeom
UNION
SELECT 4 ord,pg_size_pretty( pg_total_relation_size('species_2022_all_taxa.birds_flat')) sgeom
UNION
SELECT 5 ord,pg_size_pretty( pg_total_relation_size('species_2022_all_taxa.mammals_flat')) sgeom;

DROP TABLE IF EXISTS size_attributes;CREATE TEMPORARY TABLE size_attributes AS
SELECT 1 ord,pg_size_pretty( pg_total_relation_size('species_2022_all_taxa.corals_attributes')) satt
UNION
SELECT 2 ord,pg_size_pretty( pg_total_relation_size('species_2022_all_taxa.sharks_attributes')) satt
UNION
SELECT 3 ord,pg_size_pretty( pg_total_relation_size('species_2022_all_taxa.amphibians_attributes')) satt
UNION
SELECT 4 ord,pg_size_pretty( pg_total_relation_size('species_2022_all_taxa.birds_attributes')) satt
UNION
SELECT 5 ord,pg_size_pretty( pg_total_relation_size('species_2022_all_taxa.mammals_attributes')) satt;


DROP TABLE IF EXISTS aggregated_results;CREATE TEMPORARY TABLE aggregated_results AS
SELECT ord,taxon,inputs,processed,missing,combinations,max_richness,max_threatened_richness,max_endemic_richness,max_threatened_endemic_richness,nrows,sgeom,satt
FROM final_species
JOIN taxa_richness USING(ord)
JOIN count_combinations USING(ord)
JOIN count_rows USING(ord)
JOIN size_geoms USING(ord)
JOIN size_attributes USING(ord)
ORDER BY ord;

DROP TABLE IF EXISTS species_2022_all_taxa.metadata;CREATE TABLE species_2022_all_taxa.metadata AS
SELECT * FROM aggregated_results;
