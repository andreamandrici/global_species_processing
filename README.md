# GLOBAL SPECIES PROCESSING
# Complete workflow for species import, pre- and post-processing.

## Sources

+  [IUCN Red List of Threatened Species](https://www.iucnredlist.org/search). IUCN, Version 2021-2 (published on 20210904). **Non-spatial** attributes (**only species selected, no subspecies or subpopulations selected**) for:
   +  Reef-forming Corals (_Hydrozoa_ and _Anthozoa_)
   +  Sharks, rays and chimaeras (_Chondrichthyes_)    
   +  Amphibians
   +  Birds
   +  Mammals.

Downloaded on 20210906.


+  [IUCN Red List of Threatened Species Spatial Data](https://www.iucnredlist.org/resources/spatial-data-download).  IUCN, Version 2021-2 (published on 20210904). **Spatial** data for:
   +  Reef-forming Corals (_Hydrozoa_ and _Anthozoa_)
   +  Sharks, rays and chimaeras (_Chondrichthyes_)
   +  Amphibians
   +  Mammals.

Downloaded on 20210906.

+  [BirdLife's species distribution data](http://datazone.birdlife.org/species/requestdis). BirdLife International, Version 2020-v1. Spatial and non-spatial tables for Birds.

Received on 20201217.

## Pre-Processing

Spatial and non-spatial data are available as foreign tables pointing at external files (shp, gdb, csv, xlsx) files in different schemas.
Each foreign table is converted to real table (geometric or non-geometric) inside the schema **species_2021** using [this sql script](./species_2020_preprocessing.sql), with following parameters (where they apply):

`WHERE presence IN (1,2) AND origin IN (1,2) AND seasonal IN (1,2,3)`

which will include: **Extant** and **Probably Extant** (IUCN will discontinue this code); **Native** and **Reintroduced**; **Resident**, **Breeding Season** and **Non-breeding Season**.

## BIRDLIFE tables
Spatial and non-spatial data for **birds** are available as foreign tables pointing at gdb file in schema **species_birdlife_201903**, and they contain the fields (relevants in **bold**):
