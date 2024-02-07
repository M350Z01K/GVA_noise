library(sf)
library(raster)
library(readr)



can = st_read("data/swissBOUNDARIES3D_1_5_TLM_KANTONSGEBIET.shp")
statpop = readr::read_delim("data/ag-b-00.03-vz2022statpop/STATPOP2022.csv", delim = ";", escape_double = FALSE, trim_ws = TRUE)
road_noise = raster("data/STRASSENLAERM_Nacht/StrassenLaerm_Nacht_LV95.tif")

save(can, statpop, road_noise, file = "data.RData")

