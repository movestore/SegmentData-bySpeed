library('move')
library('foreach')
library('ggplot2')
library('geosphere')

rFunction <- function(data, speedoption="step", thrspeed=NULL, direc="above")
{
  
  speedx <- function(x) #input move object
  {
    N <- length(x)
    distVincentyEllipsoid(coordinates(x))/as.numeric(difftime(timestamps(x)[-1],timestamps(x)[-N],units="secs"))
  }
  
  if (speedoption=="ground") 
    {
    logger.info("You have selected to use ground.speed for you data selection. For locations where ground.speed is NA, distance based speed is estimated (averaged speed from previous locaiton and speed to next location).")
    names(data) <- make.names(names(data),allow_=FALSE)
    } else logger.info("You have selected to use distance based speed (distance to previous or next location/duration from previous or next location) for your data selection. Note that ground speed at the locations can differ, especially if data resolution is low.")
  
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
        logger.info(namesIndiv(datai))
        if (speedoption=="step")
        {
          ix <- which(speedx(datai)>thrspeed)
          dataix <- datai[sort(unique(c(ix,ix+1))),]
        } else
        {
          gsi <- datai$ground.speed
          if (any(is.na(gsi)))
          {
            ixna <- which(is.na(gsi))
            if (1 %in% ixna) 
              {
              gsi[1] <- speedx(datai)[1]
              ixna <- ixna[-1]
              }
            leni <- length(datai)
            if (leni %in% ixna)
              {
              gsi[leni] <- speedx(datai)[leni-1]
              ixna <- ixna[-length(ixna)]
              }
            if (length(ixna)>0)
            {
              gsi[ixna] <- (speedx(datai)[ixna-1]+speedx(datai)[ixna])/2 #average speed of before and after movement
            }
          }
          dataix <- datai[which(gsi>thrspeed)]
        }
      return(dataix)
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
        logger.info(namesIndiv(datai))
        if (speedoption=="step")
        {
          ix <- which(speedx(datai)<=thrspeed)
          dataix <- datai[sort(unique(c(ix,ix+1))),]
        } else
        {
          gsi <- datai$ground.speed
          if (any(is.na(gsi)))
          {
            ixna <- which(is.na(gsi))
            if (1 %in% ixna) 
            {
              gsi[1] <- speedx(datai)[1]
              ixna <- ixna[-1]
            }
            leni <- length(datai)
            if (leni %in% ixna)
            {
              gsi[leni] <- speedx(datai)[leni-1]
              ixna <- ixna[-length(ixna)]
            }
            if (length(ixna)>0)
            {
              gsi[ixna] <- (speedx(datai)[ixna-1]+speedx(datai)[ixna])/2 #average speed of before and after movement
            }
          }
          dataix <- datai[which(gsi<=thrspeed)]
        }
        return(dataix)
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
  
  if (speedoption=="step") 
    {
    hist.tab <- foreach(datai = data.split.nn, .combine=rbind) %do% {
    data.frame("speed"=speedx(datai),"id"=namesIndiv(datai))
      }
    } else
    {
      hist.tab <- foreach(datai = data.split.nn, .combine=rbind) %do% {
        data.frame("speed"=datai$ground.speed,"id"=namesIndiv(datai))
      }
    }

  speed.plot <- ggplot(hist.tab, aes(x = speed, fill = id)) +
    geom_histogram(position = "identity", alpha = 0.2, bins = 100) +
    geom_vline(xintercept = thrspeed,lty=2) +
    ggtitle("Histogram of the speeds with selected threshold")
  
  pdf(paste0(Sys.getenv(x = "APP_ARTIFACTS_DIR", "/tmp/"), "speed_artefakt.pdf"))
  #pdf("speed_artefakt.pdf")
  print(speed.plot)
  dev.off() 
  
  result
}


