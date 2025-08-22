# my goal here is to develop median/avg/percentile rainfall amounts basin averaged for each day of the year.
# I am going to do this for the whole record although there is some early stuff I don't fully trust, I don't have
# a great reason to discard it until I do a forma analysis.

library(arrow)
library(dplyr)
library(tictoc)
library(sf)
library(units)
library(tidyverse)

# start with your arrow query:

# identify the root folder of your parquet files
eaa_parq <- "C:\\texas_mpe\\july_flood_no_git\\st4_parq_eaa"

# establish your connection, this is the time to see your file system schema and make any adjustments
eaa_rain <- open_dataset(eaa_parq)

# set your shapefile of interest and solve for basin area
a <- ("hunt_poly_hrap_clip.shp")
map <- read_sf(paste0("C:\\texas_mpe\\july_flood_no_git\\gis\\",a)) |>
    st_drop_geometry()


eaa_query <- eaa_rain %>%
  filter(year == 2025) 

#tic() 
eaa_collect <- collect (eaa_query)   
#toc()

hunt_filter <- left_join(map,eaa_collect, by = c("grib_id","hrap_x","hrap_y" ))

write_csv(hunt_filter,"C:\\texas_mpe\\july_flood\\hatim\\hunt_basin_hourly_precip_7-1_7-4-25.csv")



  