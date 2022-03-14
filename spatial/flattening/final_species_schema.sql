---------------------------------------------------
-- CREATE SCHEMA
---------------------------------------------------
DROP SCHEMA IF EXISTS species_2022_all_taxa CASCADE;CREATE SCHEMA species_2022_all_taxa;
---------------------------------------------------
-- COPY corals GEOMS
---------------------------------------------------
SELECT *
INTO species_2022_all_taxa.corals_flat
FROM species_2022_corals.h_flat
ORDER BY qid,cid;
ALTER TABLE species_2022_all_taxa.corals_flat ADD PRIMARY KEY(qid,cid);
CREATE INDEX ON species_2022_all_taxa.corals_flat USING btree(qid ASC NULLS LAST);
CREATE INDEX ON species_2022_all_taxa.corals_flat USING btree(cid ASC NULLS LAST);
CREATE INDEX ON species_2022_all_taxa.corals_flat USING gin(corals);
CREATE INDEX ON species_2022_all_taxa.corals_flat USING GIST(geom);
---------------------------------------------------
-- COPY corals ATTRIBUTES
SELECT *
INTO species_2022_all_taxa.corals_attributes
FROM species_2022_corals.raster_output_attributes
ORDER BY cid;
ALTER TABLE species_2022_all_taxa.corals_attributes ADD PRIMARY KEY(cid);
CREATE INDEX ON species_2022_all_taxa.corals_attributes USING gin(corals);
CREATE INDEX ON species_2022_all_taxa.corals_attributes USING gin(corals_threatened_endemic);
CREATE INDEX ON species_2022_all_taxa.corals_attributes USING gin(corals_threatened);
CREATE INDEX ON species_2022_all_taxa.corals_attributes USING gin(corals_endemic);
---------------------------------------------------
-- COPY SHARKS GEOMS
---------------------------------------------------
SELECT *
INTO species_2022_all_taxa.sharks_flat
FROM species_2022_sharks.h_flat
ORDER BY qid,cid;
ALTER TABLE species_2022_all_taxa.sharks_flat ADD PRIMARY KEY(qid,cid);
CREATE INDEX ON species_2022_all_taxa.sharks_flat USING btree(qid ASC NULLS LAST);
CREATE INDEX ON species_2022_all_taxa.sharks_flat USING btree(cid ASC NULLS LAST);
CREATE INDEX ON species_2022_all_taxa.sharks_flat USING gin(sharks);
CREATE INDEX ON species_2022_all_taxa.sharks_flat USING GIST(geom);
---------------------------------------------------
-- COPY SHARKS ATTRIBUTES
SELECT *
INTO species_2022_all_taxa.sharks_attributes
FROM species_2022_sharks.raster_output_attributes
ORDER BY cid;
ALTER TABLE species_2022_all_taxa.sharks_attributes ADD PRIMARY KEY(cid);
CREATE INDEX ON species_2022_all_taxa.sharks_attributes USING gin(sharks);
CREATE INDEX ON species_2022_all_taxa.sharks_attributes USING gin(sharks_threatened_endemic);
CREATE INDEX ON species_2022_all_taxa.sharks_attributes USING gin(sharks_threatened);
CREATE INDEX ON species_2022_all_taxa.sharks_attributes USING gin(sharks_endemic);
---------------------------------------------------
-- COPY AMPHIBIANS GEOMS
---------------------------------------------------
SELECT *
INTO species_2022_all_taxa.amphibians_flat
FROM species_2022_amphibians.h_flat
ORDER BY qid,cid;
ALTER TABLE species_2022_all_taxa.amphibians_flat ADD PRIMARY KEY(qid,cid);
CREATE INDEX ON species_2022_all_taxa.amphibians_flat USING btree(qid ASC NULLS LAST);
CREATE INDEX ON species_2022_all_taxa.amphibians_flat USING btree(cid ASC NULLS LAST);
CREATE INDEX ON species_2022_all_taxa.amphibians_flat USING gin(amphibians);
CREATE INDEX ON species_2022_all_taxa.amphibians_flat USING GIST(geom);
---------------------------------------------------
-- COPY AMPHIBIANS ATTRIBUTES
SELECT *
INTO species_2022_all_taxa.amphibians_attributes
FROM species_2022_amphibians.raster_output_attributes
ORDER BY cid;
ALTER TABLE species_2022_all_taxa.amphibians_attributes ADD PRIMARY KEY(cid);
CREATE INDEX ON species_2022_all_taxa.amphibians_attributes USING gin(amphibians);
CREATE INDEX ON species_2022_all_taxa.amphibians_attributes USING gin(amphibians_threatened_endemic);
CREATE INDEX ON species_2022_all_taxa.amphibians_attributes USING gin(amphibians_threatened);
CREATE INDEX ON species_2022_all_taxa.amphibians_attributes USING gin(amphibians_endemic);
---------------------------------------------------
-- COPY MAMMALS GEOMS
---------------------------------------------------
SELECT *
INTO species_2022_all_taxa.mammals_flat
FROM species_2022_mammals.h_flat
ORDER BY qid,cid;
ALTER TABLE species_2022_all_taxa.mammals_flat ADD PRIMARY KEY(qid,cid);
CREATE INDEX ON species_2022_all_taxa.mammals_flat USING btree(qid ASC NULLS LAST);
CREATE INDEX ON species_2022_all_taxa.mammals_flat USING btree(cid ASC NULLS LAST);
CREATE INDEX ON species_2022_all_taxa.mammals_flat USING gin(mammals);
CREATE INDEX ON species_2022_all_taxa.mammals_flat USING GIST(geom);
---------------------------------------------------
-- COPY MAMMALS ATTRIBUTES
SELECT *
INTO species_2022_all_taxa.mammals_attributes
FROM species_2022_mammals.raster_output_attributes
ORDER BY cid;
ALTER TABLE species_2022_all_taxa.mammals_attributes ADD PRIMARY KEY(cid);
CREATE INDEX ON species_2022_all_taxa.mammals_attributes USING gin(mammals);
CREATE INDEX ON species_2022_all_taxa.mammals_attributes USING gin(mammals_threatened_endemic);
CREATE INDEX ON species_2022_all_taxa.mammals_attributes USING gin(mammals_threatened);
CREATE INDEX ON species_2022_all_taxa.mammals_attributes USING gin(mammals_endemic);
---------------------------------------------------
-- COPY birds GEOMS
---------------------------------------------------
SELECT *
INTO species_2022_all_taxa.birds_flat
FROM species_2022_birds.h_flat
ORDER BY qid,cid;
ALTER TABLE species_2022_all_taxa.birds_flat ADD PRIMARY KEY(qid,cid);
CREATE INDEX ON species_2022_all_taxa.birds_flat USING btree(qid ASC NULLS LAST);
CREATE INDEX ON species_2022_all_taxa.birds_flat USING btree(cid ASC NULLS LAST);
CREATE INDEX ON species_2022_all_taxa.birds_flat USING gin(birds);
CREATE INDEX ON species_2022_all_taxa.birds_flat USING GIST(geom);
---------------------------------------------------
-- COPY birds ATTRIBUTES
SELECT *
INTO species_2022_all_taxa.birds_attributes
FROM species_2022_birds.raster_output_attributes
ORDER BY cid;
ALTER TABLE species_2022_all_taxa.birds_attributes ADD PRIMARY KEY(cid);
CREATE INDEX ON species_2022_all_taxa.birds_attributes USING gin(birds);
CREATE INDEX ON species_2022_all_taxa.birds_attributes USING gin(birds_threatened_endemic);
CREATE INDEX ON species_2022_all_taxa.birds_attributes USING gin(birds_threatened);
CREATE INDEX ON species_2022_all_taxa.birds_attributes USING gin(birds_endemic);
---------------------------------------------------

---------------------------------------------------
-- COUNT RESULTS
---------------------------------------------------
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
