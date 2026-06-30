### AOH (Area of Habitat)

Developing a workflow for the systematic production of Area of Habitat (AOH)–derived metrics for terrestrial species, based on existing biodiversity and environmental datasets.

The approach is designed as a standardized transformation layer between IUCN Red List species data and downstream biodiversity indicators, with the aim of generating consistent and reproducible outputs across large numbers of species.

The workflow relies exclusively on existing data sources and established scientific products, including IUCN Red List species and habitat information, global land cover datasets (e.g. ESA Copernicus), and published habitat crosswalks (e.g. Santini et al., Lumbierres et al., Jung et al.), together with indicator frameworks developed by Juffe-Bignoli et al.

#### Quantitative approach

##### Global

A quantitative, non–spatially explicit AOH workflow is easily implementable within the standard DOPA pipeline.

Mammal species ranges (~5,800 species in IUCN Redlist 2024, each represented by a unique identifier: id_no) are flattened into a 300 m (10 arcsec) raster, tiled at 1-degree resolution, where each pixel (CID, up to ~2.5M unique identifiers) encodes combinations of species IDs (id_no).

This raster is intersected in GRASS GIS (using r.stats) with ESA Land Cover rasters for 1992 and 2022 at matching resolution, producing per-CID statistics of land cover extent and change over time.

Using the Santini et al. (2019) crosswalk, land cover classes are converted into IUCN habitat classes. Species-specific habitat preferences (filtered to terrestrial species only) from the IUCN Red List database are then applied by unnesting CID–species relationships and selecting only relevant habitat classes.

For each species (id_no), total range area is computed, along with AOH in 1992 and 2022, AOH gain/loss between the two years, and the proportion of AOH (in 2022) relative to total range extent.

Preliminary code is available in [Area of Habitat (AOH) code](./aoh/aoh.sql).

Preliminary results are available [Species 2024 AOH](./aoh/species_2024_range_aoh_92_22.csv).

##### Country/Protection

In addition, the same r.stats approach is applied by integrating the CEP 2026 raster (GISCO 2024 1:1M + GISCO EEZ). This allows the statistics to be aggregated not only at species level, but also by country and within protected areas.

#### Spatial

##### Mapping

A coarse spatial representation of the phenomenon can be obtained relatively quickly by selecting, for each id_no, the land cover classes (vector polygons in PostGIS) intersecting the species range and filtering them according to the selected habitats and crosswalk tables.

##### Spatially explicit model

A fully spatially explicit model is also feasible, but it presents major constraints:

Binary remapping: each species would need to be reconstructed as an individual binary layer from the flattened land cover–intersected dataset (raster or vector), thereby losing the single-run efficiency enabled by the current flattening approach.

![Felis silvestris 2022 AOH](./aoh/felis_silvestris_aoh_22.png).

Fully vector-based implementation: even if used only as an intermediate processing step, the workflow would generate several billion records, requiring a substantially more powerful and dedicated computing infrastructure than is currently available.
