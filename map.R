library(tidyverse)
library(ggmap)
library(leaflet)
library(dplyr)

# filter entries of only asian countries
aapi_countries <- aapicountries$asian_country
aapi_only1 <- lpr_usa_counties_2018_top_200_d[grepl(paste(aapi_countries, collapse="|"), lpr_usa_counties_2018_top_200_d$Country.of.Birth), ]

# create data frame of county and state
aapicountries_residence <- aapi_only1[, c("County.of.Residence", "State.of.Residence")]
# data frame of country of origin
aapicountries_origin <- aapi_only1[, c("Country.of.Birth")]

# find unique counties of residence
unique_aapi_residence <- unique(aapicountries_residence[,c("County.of.Residence", "State.of.Residence")])
# find unique nations of origin
unique_aapi_origin <- data.frame( unique( aapi_only1 [, c ("Country.of.Birth") ] ) )

# create data frame with county appended to 
unique_aapi_counties <- data.frame(paste(unique_aapi_residence$County.of.Residence, "County, ", unique_aapi_residence$State.of.Residence ))

# register_google(key = "")

# use Google API to geolocate
county_plus_coordinates <- mutate_geocode(unique_aapi_counties, Counties)
birth_plus_coordinates <- mutate_geocode(unique_aapi_origin, Country.of.Birth) 


# create new column in main aapi lpr200 file
aapi_only1$County.State <- paste(aapi_only1$County.of.Residence, "County, ", aapi_only1$State.of.Residence )

# merge counties and main aapi file
temp_finalsheet <- subset ( data.frame ( merge( city_coordinates, aapi_only1, by = c( 'County.State') ) ), select = -c(State.of.Residence, County.of.Residence) )

col_order <- c("County.State", "lon", "lat", "Country.of.Birth", "origin.lon", "origin.lat", "Major.Class.of.Admission", "Admissions")
finalsheet <- ( merge( temp_finalsheet, birth_plus_coordinates, by = c( 'Country.of.Birth') ) )
finalsheet %>% select(County.State, lon, lat, Major.Class.of.Admission, Admissions, Country.of.Birth, origin.lon, origin.lat)