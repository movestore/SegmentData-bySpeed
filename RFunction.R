library('move')
library('foreach')

rFunction <- function(data, minspeed=NULL)
{
  if (is.null(minspeed)) 
  {
    logger.info("You have not selected a minimum speed. Please change. Return full data set.")
    result <- data
  } else
  {
    logger.info(paste0("You have selected to segment for positions/tracks with speed > ",minspeed,"m/s"))
    
    data.split <- move::split(data)
    segm <- foreach(datai = data.split) %do% {
      print(namesIndiv(datai))
      if (!is.null(minspeed)) datai[speed(datai)>minspeed,] else datai
    }
    names (segm) <- names(data.split)
    
    segm_nozero <- segm[unlist(lapply(segm, length) > 0)] #remove list elements of length 0
    if (length(segm_nozero)==0) 
    {
      logger.info("Your output file contains no positions. Return NULL.")
      result <- NULL
    } else result <- moveStack(segm_nozero) #this gives timestamp error if empty list
  }
  result
}