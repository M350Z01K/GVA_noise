library(sf)
library(ggplot2)
library(raster)
library(prettymapr)

# make sure we are working in the right directory
setwd('C:/Users/hheri/Projects/GVA_noise/')

# import canton shapefiles
can = st_read("data/swissBOUNDARIES3D_1_5_TLM_KANTONSGEBIET.shp")

# create a subset of polygons to clip according to canton of interest
gva = subset(can, KANTONSNUM == 25)
gva = st_transform(gva, st_crs("EPSG:2056"))


# read the file, get the relevant variables, transform it to sf, clip it to the canton of interest
statpop = readr::read_delim("data/ag-b-00.03-vz2022statpop/STATPOP2022.csv", delim = ";", escape_double = FALSE, trim_ws = TRUE)
statpop = statpop[, c("B22BTOT", # whole population
                      "B22BWTOT", # female population
                      "B22BMTOT", # male population
                      "B22B12", # foreigner population
                      "B22B11", # swiss nationals population
                      "E_KOORD", "N_KOORD")]
statpop = st_as_sf(x=statpop, coords = c("E_KOORD", "N_KOORD"))
statpop = st_set_crs(statpop, st_crs("EPSG:2056"))
statpop = st_filter(statpop, gva$geometry)

# bim! we got a nice dataframe to work with
statpop_df = data.frame(st_drop_geometry(statpop), st_coordinates(statpop))


# import road traffic noise

road_noise = raster("data/STRASSENLAERM_Nacht/StrassenLaerm_Nacht_LV95.tif")

# get only the geneva area
road_noise = crop(road_noise, gva)


# plot the data
xy = SpatialPoints(st_coordinates(statpop$geometry))
plot(road_noise)
plot(xy, add = T, pch = ".")


# extract the noise estimates at the statpop coordinates
road_noise = raster::extract(road_noise, xy)
road_noise = data.frame(road_noise,
                        xy, 
                        stringsAsFactors = F)
road_noise = st_as_sf(x=road_noise, coords = c("X", "Y"))
road_noise = st_set_crs(road_noise, st_crs("EPSG:2056"))
road_noise_df = data.frame(st_drop_geometry(road_noise),
                           st_coordinates(road_noise)) 


# merge with the statpop data
road_noise_df = merge(road_noise_df, statpop_df, by = c('X', 'Y'))

# recoding of the statpop data
colnames(road_noise_df) = dplyr::recode(colnames(road_noise_df),
                                        "B22BTOT" = 'pop_tot',
                                        "B22BWTOT" = 'pop_females',
                                        "B22BMTOT" = 'pop_males',
                                        "B22B12" = 'pop_foreigners',
                                        "B22B11" = 'pop_swiss')


# and aggregate to get number of exposed by noise levels
# TODO get conversion factor Lday -> Lden (table 2a Brink et al.) +8.3dB (Lnight,b -> Lden,b)
road_noise_geneva = aggregate(road_noise_df[, c('pop_tot', 'pop_females', 'pop_males', 'pop_foreigners', 'pop_swiss')], by = list(road_night = road_noise_df$road_noise), FUN = sum)
road_noise_geneva[, "Lden"] = road_noise_geneva[, "road_night"]+8.3


# get categories
road_noise_geneva[, 'exposure_groups'] = cut(road_noise_geneva[,"Lden"] , breaks=c(0,45,50, 55, 60, 65, 70, Inf))


# aggregate
road_noise_geneva_agg = aggregate(road_noise_geneva[, c('pop_tot', 'pop_females', 'pop_males', 'pop_foreigners', 'pop_swiss')], by = list(exp_group = road_noise_geneva$exposure_groups), FUN = sum)

# calculate the proportion of exposed for each category
road_noise_geneva_agg[c('prop_females', "prop_males", "prop_foreigners", "prop_swiss")] = apply(road_noise_geneva_agg[, c("pop_females", "pop_males", "pop_foreigners", "pop_swiss")], 2, function(x) (x/road_noise_geneva_agg$pop_tot)*100)


# reshape
road_noise_geneva_agg = tidyr::gather(road_noise_geneva_agg[, -grep('pop', colnames(road_noise_geneva_agg))], cat, prop,  prop_females:prop_swiss)
road_noise_geneva_agg$cat = factor(road_noise_geneva_agg$cat, levels = c('prop_females', "prop_males", "prop_foreigners", "prop_swiss"))


# plot

bp = ggplot(road_noise_geneva_agg, aes(fill=cat, y=prop, x=exp_group)) + 
      geom_bar(position="dodge", stat="identity") +
      xlab('Noise level [dB]') +
      ylab('Proportion exposed [%]')+
      theme_bw()

# TODO
# analysis was focusing on the canton... 
# run the same by municipalities































