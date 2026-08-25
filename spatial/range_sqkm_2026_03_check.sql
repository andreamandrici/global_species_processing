WITH
a AS (SELECT o,id_no,taxon,binomial,range_sqkm range25 FROM species_2025.dopa_species),
b AS (SELECT o,id_no,taxon,binomial,range_sqkm range26 FROM species_2026.dopa_species),
c AS (SELECT * FROM a FULL OUTER JOIN b USING(o,id_no,taxon,binomial) ORDER BY o,id_no),
d AS (SELECT *,ROUND(range25::numeric/range26::numeric*100::numeric,2) rr FROM c)
SELECT * FROM d WHERE rr < 90 or rr > 100
