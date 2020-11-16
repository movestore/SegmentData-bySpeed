# Segment Data by Speed
MoveApps

Github repository: *github.com/movestore/SegmentData-bySpeed*

## Description
Movement data are segmented in such a way as only the positions from which movement fulfills a user-defined minimum speed are selected. This is an easy way to define "Migration".

## Documentation
This App calculates for each animal the inter-location speed of each pair of successive locations. Based on those speeds, all locations from which the (user provided) minimum speed is met or exceeded are selected and returned as output data set.

### Input data
moveStack in Movebank format

### Output data
moveStack in Movebank format

### Artefacts
`speed_artefact.pdf`: multi-layer histogramme of the distributions of speed for each animal in the input data set. A cut-off horizontal line represents your provided minimum speed.

### Parameters 
`minspeed`: Minimum speed that the selected segments (positions from which the segment starts) need for selection (as e.g. migration). Unit: m/s. Example: 1.

### Null or error handling:
**Parameter `minspeed`:** If no minimum speed is defined the complete data set will be returned.

**Data:** If there are no locations of the required minimum speed in the data set the output data will be emplty (NULL), likely leading to an error.