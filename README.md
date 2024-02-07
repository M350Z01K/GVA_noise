# GVA_noise
Road traffic noise exposure assessment of the population in canton Geneva

## Get the original data

The file `data.Rdata` already contains the data needed to perform the analysis. Nevertheless, the original data can be fetched from its source as follows:

- [shapefile containing the administrative borders](https://data.geo.admin.ch/ch.swisstopo.swissboundaries3d/swissboundaries3d_2024-01/swissboundaries3d_2024-01_2056_5728.shp.zip)
- [population layer](https://dam-api.bfs.admin.ch/hub/api/dam/assets/27965868/master)
- [nighttime road traffic noise layer](https://data.geo.admin.ch/ch.bafu.laerm-strassenlaerm_nacht/data.zip)

## Which operations does the R script perform?

The R script [`geneva_road_noise.Rmd`](https://github.com/M350Z01K/GVA_noise/blob/main/geneva_road_noise.Rmd) performs the following operations:

- import the shapefile of the swiss cantonal borders
- subset the cantonal borders to the canton of interest (Geneva) that will be used as mask for cropping
- import the statpop point data and convert it into a sf object
- crop the statpop point data to the region of interest (Geneva)
- import the noise raster data
- crop the noise raster data to the region of interest (Geneva)
- extract the noise exposure estimates at the statpop points
- merge the noise exposure estimates with the statpop point data
- convert Lnight noise exposure metric to Lden
- create exposure categories in 5dB steps from 45 to 70dB
- calculate the proportion of females, males, swiss nationals, and foreigners by exposure groups
- plot the results using ggplot
