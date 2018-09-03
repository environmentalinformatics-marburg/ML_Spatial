rm(list=ls())
library(raster)
library(sf)

mainpath <- "/home/hanna/Documents/Projects/SpatialCV/MOF/"
datapath <- paste0(mainpath,"/data")
rasterpath <- paste0(datapath,"/raster")
vectorpath <- paste0(datapath,"/vector")
modelpath <- paste0(datapath,"/modeldat")



predictors <- stack(paste0(rasterpath,"/predictors.grd"))
prediction <- predict(predictors,model_random)


cols <- data.frame("Type_en"=c("Beech","Douglas fir","Field","Grassland","Larch",      
                               "Oak","Road","Settlement","Spruce","Water"),
                   "col"=c("forestgreen", "darkslategray", "beige","yellowgreen",
                           "gold4","darkgreen","grey","white","khaki4",
                           "blue"))
spplot(prediction,maxpixels=99999,
       col.regions=as.character(cols$col))

writeRaster(prediction,paste0(rasterpath,"/model_random.grd"),overwrite=TRUE)

plot(varImp(model_LLO))
