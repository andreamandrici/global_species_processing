## Species selection

The atomic taxonomic unit is the species (information related to subspecies, subpopulations, island populations is included in the main species ranges).
In general, spatial tables (both from IUCN and Birdlife) contribute only with the geometry, while all the attributes are provided by IUCN non-spatial tables.

All the harmonization process is scripted in [harmonization.sql](./harmonization.sql).

For version 2021, there are 25879 non-redundant species coming from spatial tables (IUCN+Birdlife), 26533 coming from non-spatial tables (IUCN), and the intersection of the two groups returns 25867 species (there are 12 spatial objects discarded: 16208224, 16369383, 16370739, 16378423, 16381144, 16674437, 156206333, 157011948, 181208820, 189865869, 198785664, 198787290. All subpopulations of cetaceans, included in the main species ranges).
Of the 11195  endemic species, 10663 intersect the spatial and non-spatial dataset.
