library(tidyverse)

# transform texas csvs to eaa csvs
eaa_grib_ids <- read_csv("C:\\texas_mpe\\arrow\\csv_rain\\eaa_grib_ids_buffered.csv")



i =   "C:\\texas_mpe\\july_flood_no_git\\st4_1hr_2025070100_2024070423_tex.txt"
  
  
  
  ddd <- read_csv(i)
  
  f<-left_join(eaa_grib_ids,ddd, by="grib_id") |>
    relocate(grib_id, .after = center_lat)
  
  
  write_csv(f, file = paste0("C:\\texas_mpe\\july_flood_no_git\\st4_1hr_2025070100_2024070423_eaa.txt"))
  



# write csvs to parquet
library(arrow)


  i =   "C:\\texas_mpe\\july_flood_no_git\\st4_1hr_2025070100_2024070423_eaa.txt"
  
  ddd <- read_csv(i) %>%
    pivot_longer(!1:5, names_to = "time", values_to = "rain_mm") %>%
    mutate(time = ymd_h(str_sub(time,2,11))) %>%
    mutate (year = year(time), month = month(time), day = day(time), hour = hour(time)) %>%
    mutate(month_day = paste0(month,"_",day)) %>%
    relocate(rain_mm, .after = last_col()) 
  
  month_parq <- "C:\\texas_mpe\\july_flood_no_git\\st4_parq_eaa"
  
  ddd |>
    group_by(year,month) |>
    write_dataset(path = month_parq,
                  format = "parquet")
  
  rm(list=ls())
  gc()
