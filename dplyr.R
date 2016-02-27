
# dplyr from scratch
# note that this is all from the official dplyr documentation 
# https://cran.rstudio.com/web/packages/dplyr/vignettes/introduction.html

library(dplyr)
library(data.table)

# first how do we get the data? data.table or data.frame?

station_data <- fread("data/2015_station_data.csv", stringsAsFactors = FALSE)
class(station_data) # note that data.table inherits from data.frame

# use the nycflights13 dataset

library(nycflights13)
dim(flights)
head(flights)
class(flights) # note that it is a tbl_df <- tbl <- data.frame
str(flights)

# note schema:

#year month day dep_time dep_delay arr_time arr_delay carrier tailnum
#(int)(int)(int)(int)(dbl)(int)(dbl)(chr)(chr)
#1 2013 1 1 517 2 830 11 UA N14228
#2 2013 1 1 533 4 850 20 UA N24211
#3 2013 1 1 542 2 923 33 AA N619AA
#4 2013 1 1 544 - 1 1004 - 18 B6 N804JB
#5 2013 1 1 554 - 6 812 - 25 DL N668DN
#6 2013 1 1 554 - 4 740 12 UA N39463

# filter() - select a subset of rows in the data frame
# select all flights on jan 1 

jan1 <- filter(flights, month == 1, day == 1)
dim(jan1) # note that there are 842 flights

# note that the comma in filter implies a logical AND operation
# you can also use | to indicate a logical OR operation

janfeb <- filter(flights, month == 1 | month == 2)
dim(janfeb) # note a lot more flights - 51995

# arrange() - how you can sort columns

flights_ordered_by_date <- arrange(flights, year, month, day)
flights_ordered_by_delay_desc <- arrange(flights, desc(arr_delay))

# select() - select only the columns you want

flight_dates_and_tailnum <- select(flights, year, month, day, tailnum)
flight_dates_and_tail_num <- select(flights, year, month, day, tail_num = tailnum) # note column rename

# rename() - rename a selected column

rename(flight_dates_and_tailnum, flight_year = year)

# distinct() - select unique values of a column

unique_planes <- distinct(select(flights, tailnum))
unique_routes <- distinct(select(flights, origin, dest))

# mutate() - create a new column based on values of existing columns. strange name.

flight_speed <- mutate(flights, speed = distance / air_time * 60) # mph

# transmute() - create a dataframe that only contains new variables

gains <- transmute(flights, gain = arr_delay - dep_delay)

# summarize() - collapse a dataframe into exactly 1 row

summarize(flights, delay = mean(dep_delay, na.rm = TRUE)) # note remove NAs

# sample_n() - downsample rows randomly to a set with n rows

flights_10 <- sample_n(flights, 10) # only want 10 flights
dim(flights_10)

# sample_frac() - downsample rows to a fraction 

flights_10_percent <- sample_frac(flights, 0.10)
dim(flights_10_percent)

# Commonalities

# 1. First argument is always a data frame
# 2. Parameters describe actions done in context of data frame
# 3. Result is always a new data frame

# These comonalities allow for *chaining* of operations 

# Grouped Operations - above operators apply to /groups/

by_tailnum <- group_by(flights, tailnum)

# This is the interesting case. Note the use of aggregate functions n() and mean()
# Lots of other useful aggregate functions min(), max(), sum(), sd(), median()
# n() - count of number of values in aggregate
# n_distinct() - count of number of unique values in aggregate
# first(x), last(x), nth(x, n) - pick the first, last, slice

delay <- summarize(by_tailnum,
    count = n(),
    dist = mean(distance, na.rm = TRUE),
    delay = mean(arr_delay, na.rm = TRUE))

delay <- filter(delay, count > 20, dist < 2000)

# TODO: understand difference between ggvis and ggplot2

library(ggplot2)
ggplot(delay, aes(dist, delay)) +
  geom_point(aes(size = count), alpha = 1 / 2) +
  geom_smooth() +
  scale_size_area()

# Compute the number of distinct planes and flights for each destination

a1 <- group_by(flights, dest)
a2 <- summarize(a1, planes = n_distinct(tailnum), flights = n())

# Now rewrite the above using the pipe operator

flights_to_destination_summary <- group_by(flights, dest) %>%
  summarize(planes = n_distinct(tailnum), flights = n())

# Fluent style

flights_to_destination_summary <- flights %>%
    group_by(dest) %>%
    summarize(
        planes = n_distinct(tailnum),
        flights = n()
    )
