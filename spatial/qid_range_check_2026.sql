DROP TABLE IF EXISTS selected_species_range_qid;
CREATE TEMPORARY TABLE selected_species_range_qid AS
WITH 
a AS (
SELECT * FROM species_2026_mammals.mammals_qid_check WHERE lost_qids > 100
UNION
SELECT * FROM species_2026_reptiles.reptiles_qid_check WHERE lost_qids > 100
)
SELECT o,id_no,lost_qids,ry23,ry24,ry25,ry26,
ROUND((ry26::numeric/ry25::numeric*100::numeric),2) c25,
ROUND((ry26::numeric/ry24::numeric*100::numeric),2) c24,
ROUND((ry26::numeric/ry23::numeric*100::numeric),2) c23
FROM species_2026.species_ranges_check_by_years JOIN a USING(id_no)
ORDER BY o,lost_qids DESC,id_no ;
SELECT * FROM selected_species_range_qid;
