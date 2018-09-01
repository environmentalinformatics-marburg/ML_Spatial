rm(list=ls())
library(caret)
library(CAST)
library(parallel)
library(doParallel)
library(randomForest)
library(raster)

mainpath <- "/mnt/sd19007/users/hmeyer/SpatialCV_MOF/modeldat/"
datapath <- paste0(mainpath,"/data")
rasterpath <- paste0(datapath,"/raster")
vectorpath <- paste0(datapath,"/vector")
modelpath <- paste0(datapath,"/modeldat")

modeldata <- get(load(paste0(modelpath,"/modeldata.RData")))

subset <- createDataPartition(modeldata$ID,p=0.5,list=FALSE)
modeldata <- modeldata[subset[,1],]
predictors <- c("aerial","vvi","tgi","dem","slope","aspect",
                paste0("dist_",
                       c("topleft","bottomleft","bottomright","topright","center")))

folds <- CreateSpacetimeFolds(modeldata,spacevar="ID")

ctrl_random <- trainControl(method="cv",savePredictions = TRUE,returnResamp = "all")
ctrl_LLO <- trainControl(method="cv",savePredictions = TRUE,returnResamp = "all",
                         index=folds$index)
tuneGrid <- expand.grid(mtry = 2)

cl <- makeCluster(10)
registerDoParallel(cl)
model_random <- train(modeldata[,predictors],modeldata$Type,
               method="rf",tuneLength = 1,
               importance=TRUE,tuneGrid = tuneGrid,
               trControl = ctrl_random)
save(model_random,file=paste0(modelpath,"/model_random.RData"))
rm(model_random)
gc()

model_LLO <- train(modeldata[,predictors],modeldata$Type,
                      method="rf",tuneLength = 1,
                      importance=TRUE,tuneGrid = tuneGrid,
                      trControl = ctrl_LLO)
save(model_LLO,file=paste0(modelpath,"/model_LLO.RData"))
rm(model_LLO)
gc()

ffsmodel_LLO <- ffs(modeldata[,predictors],modeldata$Type,
                   method="rf",tuneLength = 1,
                   importance = TRUE,tuneGrid = tuneGrid,
                   trControl = ctrl_LLO)

save(ffsmodel_LLO,file=paste0(modelpath,"/ffsmodel_LLO.RData"))

stopCluster(cl)