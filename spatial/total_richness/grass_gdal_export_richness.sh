r.out.gdal input=richness_total@PERMANENT output=/data/swap/richness_total.tif format=GTiff createopt="COMPRESS=LZW,PREDICTOR=2" &
r.out.gdal input=threatened_richness_total@PERMANENT output=/data/swap/threatened_richness_total.tif format=GTiff createopt="COMPRESS=LZW,PREDICTOR=2" &
r.out.gdal input=endemic_richness_total@PERMANENT output=/data/swap/endemic_richness_total.tif format=GTiff createopt="COMPRESS=LZW,PREDICTOR=2" &
r.out.gdal input=threatened_endemic_richness_total@PERMANENT output=/data/swap/threatened_endemic_richness_total.tif format=GTiff createopt="COMPRESS=LZW,PREDICTOR=2" &
