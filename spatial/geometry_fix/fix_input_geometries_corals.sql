-- CHECK CORALS
SELECT DISTINCT valid,st_geometrytype FROM spatial_tables.geom_corals;
-- no non-valid geoms

-- count total
SELECT COUNT(*) FROM spatial_tables.geom_corals;
-- 29244 total geoms (id_no,path)

--CREATE MULTI GEOM TABLE
DROP TABLE IF EXISTS spatial_tables.geom_corals_2;
CREATE TABLE spatial_tables.geom_corals_2 AS
SELECT id_no,ST_MULTI(ST_COLLECT(geom)) geom
FROM  spatial_tables.geom_corals
GROUP BY id_no
ORDER BY id_no;
ALTER TABLE spatial_tables.geom_corals_2 ADD PRIMARY KEY (id_no);
CREATE INDEX ON spatial_tables.geom_corals_2 USING GIST(geom);



