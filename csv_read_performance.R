
# Experiments in reading CSVs fast
# Conclusion: never, ever use read.csv() - see for yourself below

library(data.table)

# On my machine, fread is ~ 9x faster

system.time(data <- read.csv("data/2015_status_data.csv", stringsAsFactors = FALSE))
system.time(data <- fread("data/2015_status_data.csv", stringsAsFactors = FALSE))