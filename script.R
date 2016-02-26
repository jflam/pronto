# Load the pronto dataset into a dataframe

station_data <- read.csv("data/2015_station_data.csv", stringsAsFactors = FALSE)
trip_data <- read.csv("data/2015_trip_data.csv", stringsAsFactors = FALSE)
status_data <- read.csv("data/2015_status_data.csv", stringsAsFactors = FALSE)
weather_data <- read.csv("data/2015_weather_data.csv", stringsAsFactors = FALSE)

# How big is this data?

dim(station_data)
dim(trip_data)
dim(status_data)
dim(weather_data)

# Explore the station data

library(DT)
datatable(station_data)

# Now let's compute the importance of a station by calculating 
# the number of trips departing from a station

library(plyr)

station_departures <- ddply(trip_data, .(from_station_id), "nrow")
names(station_departures)[2] <- "departures"

station_arrivals <- ddply(trip_data, .(to_station_id), "nrow")
names(station_arrivals)[2] <- "arrivals"

# Now merge

stations_with_departures <- merge(station_data, station_departures, by.x = "terminal", by.y = "from_station_id")
stations <- merge(stations_with_departures, station_arrivals, by.x = "terminal", by.y = "to_station_id")
stations$note = sprintf("%s: D:%i, A:%i", stations$terminal, stations$departures, stations$arrivals)

# Now let's look at a map of all of the station data points

library(leaflet)
m <- leaflet(data = stations) %>%
         addTiles() %>%
         addCircles( ~ long, ~ lat, popup = ~note, radius = ~departures / 50, stroke = FALSE, fillOpacity = 0.5) %>%
         addCircles( ~ long, ~ lat, popup = ~note, radius = ~arrivals / 50, color = "F30", fillOpacity = 0.5)
m
