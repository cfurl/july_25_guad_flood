library(tidyverse)

# write csvs to parquet
library(arrow)


  
  i =   "C:\\texas_mpe\\july_flood_no_git\\st4_1hr_2025070100_2024070423_tex.txt"
  
  ddd <- read_csv(i) %>%
    pivot_longer(!1:5, names_to = "time", values_to = "rain_mm") %>%
    mutate(time = ymd_h(str_sub(time,2,11))) %>%
    mutate (year = year(time), month = month(time), day = day(time), hour = hour(time)) %>%
    mutate(month_day = paste0(month,"_",day)) %>%
    relocate(rain_mm, .after = last_col()) 
  
  month_parq <- "C:\\texas_mpe\\july_flood_no_git\\st4_parq_tex"
  
  ddd |>
    group_by(year,month) |>
    write_dataset(path = month_parq,
                  format = "parquet")
  
  rm(list=ls())
  gc()

