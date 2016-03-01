# This sample uses data from the Pronto data challenge that can be found here:
# https://s3.amazonaws.com/pronto-data/open_data_year_one.zip

# To run this sample, download and unzip the contents of the file to a data
# subdirectory in this project. The .gitignore in this project is set to
# ignore everything in this directory already.

# Load the pronto dataset into a dataframe

library(data.table)

station_data <- fread("data/2015_station_data.csv", stringsAsFactors = FALSE)
trip_data <- fread("data/2015_trip_data.csv", stringsAsFactors = FALSE)
status_data <- fread("data/2015_status_data.csv", stringsAsFactors = FALSE)
weather_data <- fread("data/2015_weather_data.csv", stringsAsFactors = FALSE)

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

# Trip data has information about birth year of rider and the type of pass that they have

library(ggvis)

# Compute the ages of riders 

current_year = as.numeric(format(Sys.Date(), "%Y"))
trip_data$age = current_year - trip_data$birthyear

trip_data %>%
    ggvis( ~ age) %>%
    layer_histograms(width = input_slider(1, 10, step = 1, label = "Bin Width"),
                   center = 35,
                   fill := "#E74C3C") %>%
    add_axis("x", title = "Age") %>%
    add_axis("y", title = "Count")

# Plot trips per day for short term vs. long term pass holders

library(dplyr)
trip_data$departure_date <- as.Date(trip_data$starttime, "%m/%d/%Y %H:%M")
zz1 <- trip_data %>% group_by(trip_id, departure_date)