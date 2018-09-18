rm(list=ls())
library(raster)
library(sf)
library(caret)
library(randomForest)


mainpath <- "/home/hanna/Documents/Projects/SpatialCV/MOF/"
datapath <- paste0(mainpath,"/data")
rasterpath <- paste0(datapath,"/raster")
vectorpath <- paste0(datapath,"/vector")
modelpath <- paste0(datapath,"/modeldat")
vispath <- paste0(mainpath,"/visualizations")

model_random <- get(load(paste0(modelpath,"/model_random.RData")))
model_LLO <- get(load(paste0(modelpath,"/model_LLO.RData")))
model_ffs_LLO <- get(load(paste0(modelpath,"/ffsmodel_LLO_final.RData")))
model_ffs_random <- get(load(paste0(modelpath,"/FFS_random_final.RData")))

modeldata <- get(load(paste0(modelpath,"/modeldata.RData")))


################################################################################
#Plot Varimp
################################################################################
varimps <- varImp(model_random)

cairo_pdf(paste0(vispath,"/varimp.pdf"), width=8,height=9)
plot(varimps,col="black",top=ncol(model_random$trainingData)-1,
     par.settings =list(strip.background=list(col="grey")))
dev.off()

cairo_pdf(paste0(vispath,"/varimp_full.pdf"), width=6,height=5)
varImpPlot(model_random$finalModel,col="black",main="",scale=T,type=1)
dev.off()

################################################################################
#Compare
################################################################################
kia_LLO <- model_LLO$resample$Kappa
boxplot(kia_random,kia_LLO)



##############################valid global
ffspreds <- ffsmodel_LLO$LLO_final$pred[
  ffsmodel_LLO$LLO_final$pred$mtry==ffsmodel_LLO$LLO_final$bestTune$mtry,]

fullmodelpreds <- model_LLO$pred[
  model_LLO$pred$mtry==model_LLO$bestTune$mtry,]


ffstable <- table(ffspreds$pred,ffspreds$obs)
sum(diag(ffstable))/sum(ffstable)
kia_ffs <-kstat(ffspreds$pred,ffspreds$obs)


fullmodeltable <- table(fullmodelpreds$pred,fullmodelpreds$obs)
sum(diag(fullmodeltable))/sum(fullmodeltable)
kia_full <-kstat(fullmodelpreds$pred,fullmodelpreds$obs)
