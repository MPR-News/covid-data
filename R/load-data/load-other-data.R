library(tidyverse)
library(sf)
library(here)

cdc <- read_csv(paste0("https://data.cdc.gov/resource/unsk-b7fc.csv?$$app_token=", cdc_token, "&location=MN"))

county_map <- read_sf(here("shapefiles/mn_counties/mn_counties.shp"))

zip_map <- read_sf(here("shapefiles/mn_zips/mn_zips.shp"))