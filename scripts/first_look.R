library(arrow)
library(dplyr)
library(tictoc)
library(sf)
library(janitor)
library(magick)
library(ggplot2)
library(units)


# identify the root folder of your parquet files
month_parq <- "C:\\texas_mpe\\july_flood_no_git\\st4_parq_tex"


# establish your connection, this is the time to see your file system schema and make any adjustments
tx_rain <- open_dataset(month_parq)
nrow(tx_rain)

# have a query space and don't collect yet
sum_rain_query <- tx_rain %>%
  filter(year==2025) %>%
  group_by (grib_id) %>%
  summarize(
    sum_rain = sum(rain_mm, na.rm=TRUE)
  ) %>%
  arrange(desc(sum_rain))

# collect the query when you are ready (grouped and summed over 120 million rows in under three minutes)
tic()
sum_rain_collect <- collect(sum_rain_query)
toc()


      # have a query space and don't collect yet
      sum_rain_query <- tx_rain %>%
        filter(year==2025 & grib_id == 184385) 
        
      
      # collect the query when you are ready (grouped and summed over 120 million rows in under three minutes)
      tic()
      max_rad <- collect(sum_rain_query)
      toc()     
      write_csv(max_rad,paste0("C:\\texas_mpe\\july_flood_no_git\\max_rad_bin.csv"))      
      
      