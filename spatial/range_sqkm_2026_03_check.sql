DROP TABLE IF EXISTS species_2026.species_ranges_check_by_years;
CREATE TABLE species_2026.species_ranges_check_by_years AS
WITH
a1 AS (
	SELECT o,id_no FROM species_2026.species_ranges_previous_years
	UNION
	SELECT o,id_no FROM species_2025.dopa_species
	UNION
	SELECT o,id_no FROM species_2026.dopa_species
	),
y23 AS (SELECT o,id_no,range_sqkm ry23 FROM species_2026.species_ranges_previous_years WHERE y=2023),
y24 AS (SELECT o,id_no,range_sqkm ry24 FROM species_2026.species_ranges_previous_years WHERE y=2024),
y25 AS (SELECT o,id_no,range_sqkm ry25 FROM species_2025.dopa_species),
y26 AS (SELECT o,id_no,range_sqkm ry26 FROM species_2026.dopa_species),
tot AS (
SELECT *
FROM a1
LEFT JOIN y23 USING(o,id_no)
LEFT JOIN y24 USING(o,id_no)
LEFT JOIN y25 USING(o,id_no)
LEFT JOIN y26 USING(o,id_no)
ORDER BY o,id_no),
tot_perc AS (SELECT *,ROUND(ry26::numeric/ry25::numeric*100::numeric,2) ry_26_25_perc FROM tot)
SELECT * FROM tot_perc;
SELECT * FROM species_2026.species_ranges_check_by_years WHERE ry_26_25_perc < 90 or ry_26_25_perc > 110;
