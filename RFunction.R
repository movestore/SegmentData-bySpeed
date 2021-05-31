library('move')
library('foreach')
library('ggplot2')

rFunction <- function(data, thrspeed=NULL, direc="above")
{
  if (is.null(thrspeed)) 
  {
    logger.info("You have not selected a threshold speed. Please change. Here returning full data set.")
    result <- data
  } else
  {
    logger.info(paste("You have selected to segment for positions with speed", direc, thrspeed,"m/s"))
    
    data.split <- move::split(data)
    
    if (direc=="above")
    {
      segm <- foreach(datai = data.split) %do% {
        print(namesIndiv(datai))
        ix <- which(speed(datai)>thrspeed)
        datai[sort(unique(c(ix,ix+1))),]
      }
      names (segm) <- names(data.split)
      
      segm_nozero <- segm[unlist(lapply(segm, length) > 0)] #remove list elements of length 0
      if (length(segm_nozero)==0) 
      {
        logger.info("Your output file contains no positions. Return NULL.")
        result <- NULL
      } else result <- moveStack(segm_nozero)
    } else if (direc=="below")
    {
      segm <- foreach(datai = data.split) %do% {
        print(namesIndiv(datai))
        ix <- which(speed(datai)<=thrspeed)
        datai[sort(unique(c(ix,ix+1))),]
      }
      names (segm) <- names(data.split)
      
      segm_nozero <- segm[unlist(lapply(segm, length) > 0)] #remove list elements of length 0
      if (length(segm_nozero)==0) 
      {
        logger.info("Your output file contains no positions. Return NULL.")
        result <- NULL
      } else result <- moveStack(segm_nozero)
    } else 
    {
      logger.info("Your indication of direction was not correct. Returning full data set.")
      result <- data
    }
  }
  
  #Artefakt, plot speed histogram with cut-off
  data.split.nn <- data.split[unlist(lapply(data.split,length)>1)] # take out individuals with only one position, else speed error
  
  hist.tab <- foreach(datai = data.split.nn, .combine=rbind) %do% {
    data.frame("speed"=speed(datai),"id"=namesIndiv(datai))
  }

  speed.plot <- ggplot(hist.tab, aes(x = speed, fill = id)) +
    geom_histogram(position = "identity", alpha = 0.2, bins = 100) +
    geom_vline(xintercept = thrspeed,lty=2) +
    ggtitle("Histogram of the (between-location) speeds with selected threshold")
  
  pdf(paste0(Sys.getenv(x = "APP_ARTIFACTS_DIR", "/tmp/"), "speed_artefakt.pdf"))
  #pdf("speed_artefakt.pdf")
  print(speed.plot)
  dev.off() 
  
  result
}


