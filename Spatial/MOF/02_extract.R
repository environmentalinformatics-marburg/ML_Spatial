rm(list=ls())
library(raster)
library(sf)

mainpath <- "/home/hanna/Documents/Projects/SpatialCV/MOF/"
datapath <- paste0(mainpath,"/data")
rasterpath <- paste0(datapath,"/raster")
vectorpath <- paste0(datapath,"/vector")
modelpath <- paste0(datapath,"/modeldat")


predictors <- stack(paste0(rasterpath,"/predictors.grd"))
training_sf <- shapefile(paste0(vectorpath,"/lcc_training_areas_20180126.shp"))
training_sf$ID <- 1:nrow(training_sf)
training_df <- extract(predictors,training_sf,df=TRUE)
training_df <- merge(training_df,training_sf,by.x="ID",by.y="ID")

save(training_df,file=paste0(modelpath,"/modeldata.RData"))
