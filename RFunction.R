library('move2')
library('units')
library('foreach')
library('ggplot2')
library('geosphere')

rFunction <- function(data, speedoption="step", thrspeed=NULL, direc="above")
{
  
  #speedx <- function(x) #input move object
  #{
  #  N <- length(x)
  #  distVincentyEllipsoid(coordinates(x))/as.numeric(difftime(timestamps(x)[-1],timestamps(x)[-N],units="secs"))
  #}
  
  if (speedoption=="ground") 
    {
    if (any(names(data) == "ground.speed" | any(names(data)=="ground_speed"))) logger.info("You have selected to use ground speed for you data selection. This variable existis in your data. However, in case there are locations where ground.speed is NA, distance based speed is estimated (averaged speed from previous location and speed to next location) for the respective steps.") else 
      {
      logger.info("You have selected to use ground speed for your data selection/annotation. However, this variable does not existis in your input data set. Therefore, the calculations are performed using distance based speed estimates (averaged speed from previous location and speed to next location).")
      speedoption <- "step" #
      print(speedoption)
      }
    
    } else logger.info("You have selected to use distance based speed (distance to previous or next location/duration from previous or next location) for your data selection. Note that ground speed at the locations can differ, especially if data resolution is low.")
  
  if (is.null(thrspeed)) 
  {
    logger.info("You have not selected a threshold speed. Please change. Here returning full data set.")
    result <- data
  } else
  {
    if(direc != "annotate") logger.info(paste("You have selected to filter for positions with speed", direc, thrspeed,"m/s")) else logger.info("You have selected to annotate your data with the attribute `speed_class`, indicating if the location is `high` (speed above threshold) or `low` (speed below/equal to threshold).")
    
    thrspeed <- units::set_units(thrspeed,m/s)
    
    data.split <- split(data,mt_track_id(data))
    
    if (direc=="above")
    {
      segm <- foreach(datai = data.split) %do% {
        logger.info(unique(mt_track_id(datai)))
        if (speedoption=="step")
        {
          ix <- which(units::set_units(mt_speed(datai),m/s)>thrspeed)
          dataix <- datai[sort(unique(c(ix,ix+1))),]
        } else
        {
          if (any(names(data) == "ground.speed")) gsi <- units::set_units(datai$ground.speed,m/s) else gsi <- units::set_units(datai$ground_speed,m/s) #if none of those names exist speedoption has been set to "step" above
          
          if (any(is.na(gsi)))
          {
            ixna <- which(is.na(gsi))
            if (1 %in% ixna) 
              {
              gsi[1] <- units::set_units(mt_speed(datai),m/s)[1]
              ixna <- ixna[-1]
              }
            leni <- nrow(datai)
            if (leni %in% ixna)
              {
              gsi[leni] <- units::set_units(mt_speed(datai),m/s)[leni-1]
              ixna <- ixna[-nrow(ixna)]
              }
            if (nrow(ixna)>0)
            {
              gsi[ixna] <- (units::set_units(mt_speed(datai),m/s)[ixna-1]+units::set_units(mt_speed(datai),m/s)[ixna])/2 #average speed of before and after movement
            }
          }
          dataix <- datai[which(gsi>thrspeed),]
        }
      return(dataix)
      }
      names (segm) <- names(data.split)
      
      result <- mt_stack(segm,.track_combine="rename")
      if (dim(result)[1]== 0)
      {
        logger.info("Your output file contains no positions. Return NULL.")
        result <- NULL
      }

    } else if (direc=="below")
    {
      segm <- foreach(datai = data.split) %do% {
        logger.info(unique(mt_track_id(datai)))
        if (speedoption=="step")
        {
          ix <- which(units::set_units(mt_speed(datai),m/s)<=thrspeed)
          dataix <- datai[sort(unique(c(ix,ix+1))),]
        } else
        {
          if (any(names(data) == "ground.speed")) gsi <- units::set_units(datai$ground.speed,m/s) else gsi <- units::set_units(datai$ground_speed,m/s)
          if (any(is.na(gsi)))
          {
            ixna <- which(is.na(gsi))
            if (1 %in% ixna) 
            {
              gsi[1] <- units::set_units(mt_speed(datai),m/s)[1]
              ixna <- ixna[-1]
            }
            leni <- nrow(datai)
            if (leni %in% ixna)
            {
              gsi[leni] <- units::set_units(mt_speed(datai),m/s)[leni-1]
              ixna <- ixna[-length(ixna)]
            }
            if (length(ixna)>0)
            {
              gsi[ixna] <- (units::set_units(mt_speed(datai),m/s)[ixna-1]+units::set_units(mt_speed(datai),m/s)[ixna])/2 #average speed of before and after movement
            }
          }
          dataix <- datai[which(gsi<=thrspeed),]
        }
        return(dataix)
      }
      names (segm) <- names(data.split)
      
      result <- mt_stack(segm,.track_combine="rename")
      if (dim(result)[1]== 0)
      {
        logger.info("Your output file contains no positions. Return NULL.")
        result <- NULL
      }
      
    } else if (direc=="annotate")
    {
      if (speedoption=="step")
      {
        ix <- which(units::set_units(mt_speed(data),m/s)<=thrspeed)
        data$speed_class <- NA
        data$speed_class[ix] <- "low"
        data$speed_class[-ix] <- "high"
      } else
      {
        if (any(names(data) == "ground.speed")) gsi <- units::set_units(data$ground.speed,m/s) else gsi <- units::set_units(data$ground_speed,m/s)
        ix <- which (gsi<=thrspeed)
        data$speed_class <- NA
        data$speed_class[ix] <- "low"
        data$speed_class[-ix] <- "high"
      }
      result <- data
      logger.info("Your full data set has been annotated with `speed_class`.")
      
    } else
    {
      logger.info("Your indication of direction was not correct. Returning full data set.")
      result <- data
    }
  }
  
  #Artefakt, plot speed histogram with cut-off
  data.split.nn <- data.split[unlist(lapply(data.split,nrow)>1)] # take out individuals with only one position, else speed error
  
  if (speedoption=="step") 
    {
    hist.tab <- foreach(datai = data.split.nn, .combine=rbind) %do% {
    data.frame("speed"=units::set_units(mt_speed(datai),m/s),"id"=unique(mt_track_id(datai)))
      }
    } else
    {
      hist.tab <- foreach(datai = data.split.nn, .combine=rbind) %do% {
        if (any(names(datai) == "ground.speed")) data.frame("speed"=datai$ground.speed,"id"=unique(mt_track_id(datai))) else data.frame("speed"=datai$ground_speed,"id"=unique(mt_track_id(datai)))
      }
    }

  if (!is.null(hist.tab))
  {
    speed.plot <- ggplot(hist.tab, aes(x = speed, fill = id)) +
      geom_histogram(position = "identity", alpha = 0.2, bins = 100) +
      geom_vline(xintercept = thrspeed,lty=2) +
      ggtitle("Histogram of the speeds with selected threshold (unit m/s)")
    
    pdf(appArtifactPath("speed_artefakt.pdf"))
    print(speed.plot)
    dev.off() 
  }

  return(result)
}


