library(ggvis)
library(dplyr)
library(data.table)

trip_data <- fread("data/2015_trip_data.csv", stringsAsFactors = FALSE)
current_year = as.numeric(format(Sys.Date(), "%Y"))

# applying my mad new dplyr skillz

trips_per_day <-
trip_data %>%
    mutate(
        departure_date = as.Date(starttime, "%m/%d/%Y %H:%M")
    ) %>%
    group_by(departure_date) %>%
    summarize(count = n()) %>%
    select(departure_date, count)

trips_by_age <-
trip_data %>%
    mutate(
        departure_date = as.Date(starttime, "%m/%d/%Y %H:%M"),
        age = current_year - birthyear
    ) %>%
    group_by(departure_date) %>%
    summarize(count = n()) %>%
    select(departure_date, age, count)

trips_by_day_of_week <-
trip_data %>%
    mutate(
        departure_date = as.Date(starttime, "%m/%d/%Y %H:%M"),
        weekday = weekdays(departure_date)
    ) %>%
    select(weekday) %>%
    group_by(weekday) %>%
    summarize(count = n())

# Now plot trips per day using dygraphs which has a nice feature for interactive plots
# dygraphs doesn't really do histograms though, so we need ggvis for that

library(dygraphs)
dygraph(trips_per_day, main = "Trips per day") %>%
  dyAxis("x", drawGrid = FALSE) %>%
  dySeries("count", label = "a") %>%
  dyRangeSelector()

library(DT)
datatable(as.data.frame(trips_per_day))
datatable(as.data.frame(trips_by_day_of_week))

trips_by_day_of_week %>%
    ggvis( ~ weekday, ~count) %>%
    layer_bars(fill := "#008000") %>%
    add_axis("x", title = "Day of week") %>%
    add_axis("y", title = "Count")
    
trip_data %>%
    ggvis( ~ age) %>%
    layer_histograms(width = input_slider(1, 10, step = 1, label = "Bin Width"),
                   center = 35,
                   fill := "#E74C3C") %>%
    add_axis("x", title = "Age") %>%
    add_axis("y", title = "Count")