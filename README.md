# Filter/Annotate by Speed
MoveApps

Github repository: *github.com/movestore/SegmentData-bySpeed*

## Description
Location data are filtered by a user-defined threshold speed. The speed can be ground speed or between-location calculated speed, both in m/s. Depending on the selection of "above" or "below" threshold, the locations with speeds above or below the threshold are selected. Selecting "above" might indicate "migration" locations, "below" stands for more sedentary or resting locations.

## Documentation
Depending on the selected speed option (ground speed or between-location speed), this App uses GPS ground speed or calculates for each animal the inter-location speed of each pair of successive locations. If ground speed is not availabe in the input data set or if ground speed is NA (not available) between-location speed is used for all or the respective locations (and a warning is added in the logs of the App). Note that it is necessary that ground speed of the data is provided in the unit m/s, as else the data do not fit together. If you want to filter with other units, have a look at the "Adapt/Filter Unrealistic Values" App.

Mean speed of incoming and outgoing movement is calculated. If inter-location speed is requested and the user selected to filter for "above" threshold locations, all locations from and to which the threshold speed is exceeded are selected and returned as output data set. In that case with filtering for "below" threshold locations, all locations from and to which the speed falls below the threshold speed are selected and returned as output data set. For ground speed the actual speeds of each location are used. For locations with ground speed NA (not available), inter-location speed is estimated to the respective location as the arithmetic mean of the incoming and outgoing movement steps of the location.

If selecting "annotate" then all data are returned, with the additional column "speed_class", where entries of "high" indicate speed above the threshold and "low" speed below the threshold.

### Input data
move2 location object

### Output data
move2 location object

### Artefacts
`speed_artefact.pdf`: multi-layer histogramme of the distributions of speed for each animal in the input data set. A cut-off horizontal line represents your provided threshold speed.

### Settings
**Type of speed (`speedoption`):** Selection of (GPS) ground speed or between-location speed for segmentation/filtering. Default is between-location speed (`step`).

**Threshold movement speed for segmentation (`thrspeed`):** Threshold speed that the selected segments/locations need to exceed or fall below for selection (as e.g. migration/resting). Unit: m/s. Example: 1. Default is NULL (retun all data).

**Annotate only or direction of filtering (`direc`):** Radiobuttons to select either direction of the data selection or only data anootation. If "above" is selected then only locations with speeds above the threshold speed are selected, if "below" is selected than locations with speeds below the threshold are selected, if "annotate" then all data are returned with an additional column "speed_class". The default here is "annotate".

### Most common errors
If you repeatedly encounter erroneous behaviour of the App please make an issue [here](https://github.com/movestore/SegmentData-bySpeed/issues).

### Null or error handling:
**Setting `speedoption`:** Only two option are possible here with a fixed default, no NULL or errors expected.

**Setting `thrspeed`:** If no threshold speed is defined (NULL) the complete data set will be returned with a warning.

**Setting `direc`:** only three viable option possible.

**Data:** If there are no locations of the required minimum speed in the data set the output data will be empty (NULL), likely leading to an error.
