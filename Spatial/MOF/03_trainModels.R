rm(list=ls())
library(caret)
library(CAST)
library(parallel)
library(doParallel)
library(randomForest)
library(raster)

mainpath <- "/mnt/sd19007/users/hmeyer/SpatialCV_MOF/"
#mainpath <- "/home/hanna/Documents/Projects/SpatialCV/MOF/"
datapath <- paste0(mainpath,"/data")
rasterpath <- paste0(datapath,"/raster")
vectorpath <- paste0(datapath,"/vector")
modelpath <- paste0(datapath,"/modeldat")

models <- c("random","LLO","FFS_LLO","RFE_LLO","FFS_random")
ncores <- 20

modeldata <- get(load(paste0(modelpath,"/modeldata.RData")))

################################################################################
#define predictors and response, make subset
################################################################################
set.seed(100)
subset <- createDataPartition(modeldata$ID,p=0.75,list=FALSE)
modeldata <- modeldata[subset[,1],]
predictors <- c("red","green","blue","vvi","tgi","dem","slope","aspect",
                "lat","lon","ngrdi","gli","pca","pca_3_sd","pca_5_sd","pca_9_sd",
                paste0("dist_",
                       c("topleft","bottomleft","bottomright","topright","center")))
modeldata <- modeldata[complete.cases(modeldata[,which(names(modeldata)%in%predictors)]),]

modeldata$Type <- factor(modeldata$Type)
################################################################################
# define CV and tuning settings
################################################################################
k <- length(unique(modeldata$spatialBlock))
set.seed(100)
folds <- CreateSpacetimeFolds(modeldata,spacevar="spatialBlock",k=k)

ctrl_random <- trainControl(method="cv",savePredictions = TRUE,returnResamp = "final",
                            number=k)
ctrl_LLO <- trainControl(method="cv",savePredictions = TRUE,returnResamp = "final",
                         index=folds$index)
tuneGrid_ffs <- expand.grid(mtry = 2)
tuneGrid <- expand.grid(mtry = seq(2,10,2))
################################################################################
#Train models
################################################################################
cl <- makeCluster(ncores)
registerDoParallel(cl)
if (any(models=="random")){
  set.seed(100)
  model_random <- train(modeldata[,which(names(modeldata)%in%predictors)],
                        modeldata$Type,
                        method="rf",metric="Kappa",
                        importance=TRUE,tuneGrid = tuneGrid,
                        trControl = ctrl_random)
  save(model_random,file=paste0(modelpath,"/model_random.RData"))
  rm(model_random)
  gc()
}
if (any(models=="LLO")){
  set.seed(100)
  model_LLO <- train(modeldata[,which(names(modeldata)%in%predictors)],
                     modeldata$Type,
                     method="rf",metric="Kappa",
                     importance=TRUE,tuneGrid = tuneGrid,
                     trControl = ctrl_LLO)
  save(model_LLO,file=paste0(modelpath,"/model_LLO.RData"))
  rm(model_LLO)
  gc()
}

if (any(models=="FFS_LLO")){
  set.seed(100)
  ffsmodel_LLO <- ffs(modeldata[,which(names(modeldata)%in%predictors)],
                      modeldata$Type,
                      method="rf",metric="Kappa",
                      tuneGrid = tuneGrid_ffs,
                      trControl = ctrl_LLO)
  
  save(ffsmodel_LLO,file=paste0(modelpath,"/ffsmodel_LLO.RData"))
}

if (any(models=="FFS_random")){
  set.seed(100)
  FFS_random <- ffs(modeldata[,which(names(modeldata)%in%predictors)],
                    modeldata$Type,
                    method="rf",metric="Kappa",
                    tuneGrid = tuneGrid_ffs,
                    trControl = ctrl_random)
  
  save(FFS_random,file=paste0(modelpath,"/FFS_random.RData"))
}


if (any(models=="RFE_LLO")){
  set.seed(100)
  rfemodel_LLO <- rfe(modeldata[,which(names(modeldata)%in%predictors)],
                      modeldata$Type,
                      sizes = 2:length(predictors),
                      method="rf",metric="Kappa",
                      tuneGrid = tuneGrid,
                      trControl = ctrl_LLO)
  
  save(rfemodel_LLO,file=paste0(modelpath,"/rfemodel_LLO.RData"))
}


stopCluster(cl)
warnings()