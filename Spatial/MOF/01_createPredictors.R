rm(list=ls())
library(raster)
mainpath <- "/home/hanna/Documents/Projects/SpatialCV/MOF/"
datapath <- paste0(mainpath,"/data")
rasterpath <- paste0(datapath,"/raster")

aerial <- stack(paste0(rasterpath,"/geonode_ortho_muf_1m.tif"))
names(aerial) <- c("blue","green","red")
dem <- raster(paste0(rasterpath,"/geonode_lidar_dem_01m.tif"))
names(dem) <- "dem"
vvi <- raster(paste0(rasterpath,"/geonode_ortho_muf_vvi.tif"))
names(vvi) <- "vvi"
tgi <- raster(paste0(rasterpath,"/geonode_ortho_muf_tgi.tif"))
names(tgi) <- "tgi"
########## Terrain based predictors
dem <- resample(dem,aerial)
slope <- terrain(dem,opt="slope")
aspect <- terrain(dem,opt="aspect")

########## Distance based predictors
corners <- extent(aerial)
spp <- SpatialPoints(matrix(c(corners[1],corners[4],
                   corners[1],corners[3],
                   corners[2],corners[3],
                   corners[2],corners[4],
                   (corners[2]+corners[1])/2, 
                   (corners[3]+corners[4])/2),ncol=2,byrow=T))
distances <- list()
for (i in 1:5){
distances[[i]] <- distanceFromPoints(aerial[[1]], spp[i,]) 
}
distances <- stack(distances)
lat <- distances[[1]]
lon <- distances[[1]]
values(lat)<- coordinates(lat)[,1]
values(lon)<- coordinates(lon)[,2]

names(distances)<- paste0("dist_",c("topleft","bottomleft","bottomright","topright","center"))
distances$lat <- lat
distances$lon <- lon

########## Merge predictors

predictors <- stack(aerial,vvi,tgi,distances,dem,slope,aspect)
writeRaster(predictors,paste0(rasterpath,"/predictors.grd"),overwrite=TRUE)
