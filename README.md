# Segment Data by Speed
MoveApps

Github repository: *github.com/movestore/SegmentData-bySpeed*

## Description
Movement data are segmented by a use-defined threshold speed. Depending on the selection of "above" or "below" threshold, the locations with speeds above or below the threshold are selected. Selecting "above" might indicate "Migration" locations, "below" stands for more sedentary or resting locations.

## Documentation
This App calculates for each animal the inter-location speed of each pair of successive locations. If the user selected to filter for "above" threshold locations, all locations from and to which the threshold speed is exceeded are selected and returned as output data set. If the user selected to filter for "below" threshold locations, all locations from and to which the speed falls below the threshold speed are selected and returned as output data set.

### Input data
moveStack in Movebank format

### Output data
moveStack in Movebank format

### Artefacts
`speed_artefact.pdf`: multi-layer histogramme of the distributions of speed for each animal in the input data set. A cut-off horizontal line represents your provided threshold speed.

### Parameters 
`thrspeed`: Threshold speed that the selected segments (positions from and to which the segment goes) need to exceed or fall below for selection (as e.g. migration/resting). Unit: m/s. Example: 1.

`direc`: Radiobuttons to select direction of the threshold selection. If "above" is selected then only locations with speeds above the threshold speed are selected, if "below" is selected than locations with speeds below the threshold are selected. The default here is "above".

### Null or error handling:
**Parameter `thrspeed`:** If no threshol speed is defined the complete data set will be returned.

**Parameter `direc`:** If by some conicidence the user manages to provide NULL or a non-defined direction, the full data set is returned with a warning. However, the default is set to "above".

**Data:** If there are no locations of the required minimum speed in the data set the output data will be emplty (NULL), likely leading to an error.