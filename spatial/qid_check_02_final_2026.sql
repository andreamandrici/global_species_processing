SELECT * FROM species_2026.dopa_species WHERE binomial ='Puffinus puffinus';
SELECT * FROM species_2026.species_ranges_check_by_years WHERE id_no=22698226;

SELECT * FROM species_2026_corals.corals_qid_check WHERE lost_qids > 0 ORDER BY lost_qids DESC;
SELECT * FROM species_2026_sharks.sharks_qid_check WHERE lost_qids > 0 ORDER BY lost_qids DESC;
SELECT * FROM species_2026_amphibians.amphibians_qid_check WHERE lost_qids > 0 ORDER BY lost_qids DESC;
SELECT * FROM species_2026_reptiles.reptiles_qid_check WHERE lost_qids > 0 ORDER BY lost_qids DESC;
SELECT * FROM species_2026_mammals.mammals_qid_check WHERE lost_qids > 0 ORDER BY lost_qids DESC;

SELECT * FROM species_2026.species_ranges_check_by_years WHERE id_no=6494
SELECT * FROM species_2026_reptiles.reptiles_qid_check WHERE id_no=6494 --20195
SELECT DISTINCT fid id_no,qid FROM species_2026_reptiles.b_clip_reptiles WHERE fid=6494 --18086
SELECT DISTINCT fid id_no,qid FROM species_2026_reptiles.c_raster_reptiles WHERE fid=6494 --18086
SELECT DISTINCT fid id_no,qid FROM species_2026_reptiles.da_tiled_reptiles WHERE fid=6494 --18083
SELECT DISTINCT fid id_no,qid FROM species_2026_reptiles.dc_tiled_all WHERE fid=6494 --18083
SELECT DISTINCT qid FROM species_2026_reptiles.h_flat WHERE reptiles && '{6494}' --18083
