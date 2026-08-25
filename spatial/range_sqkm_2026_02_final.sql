

CREATE TEMPORARY TABLE
species_ranges AS
SELECT 1 o,* FROM species_2026.corals_ranges_by_species
UNION
SELECT 2 o,* FROM species_2026.sharks_ranges_by_species
UNION
SELECT 3 o,* FROM species_2026.amphibians_ranges_by_species
UNION
SELECT 4 o,* FROM species_2026.reptiles_ranges_by_species
UNION
SELECT 5 o,* FROM species_2026.birds_ranges_by_species
UNION
SELECT 6 o,* FROM species_2026.mammals_ranges_by_species
ORDER BY o,id_no;

UPDATE species_2026.dopa_species SET range_sqkm = b.range_sqkm FROM species_ranges b WHERE dopa_species.id_no=b.id_no;

SELECT * FROM species_2026.dopa_species WHERE range_sqkm is NULL;

DROP TABLE IF EXISTS species_2026.corals_ranges_by_species;
DROP TABLE IF EXISTS species_2026.sharks_ranges_by_species;
DROP TABLE IF EXISTS species_2026.amphibians_ranges_by_species;
DROP TABLE IF EXISTS species_2026.reptiles_ranges_by_species;
DROP TABLE IF EXISTS species_2026.birds_ranges_by_species;
DROP TABLE IF EXISTS species_2026.mammals_ranges_by_species;
