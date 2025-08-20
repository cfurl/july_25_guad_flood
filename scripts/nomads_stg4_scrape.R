library(tidyverse)
library(dplyr)
library(stringr)
library(rvest)

# stg4 at
# https://nomads.ncep.noaa.gov/pub/data/nccf/com/pcpanl/prod/

# make a character list of the dates you're interested in scraping

date_char <- c("20250705", "20250706", "20250707", "20250708","20250709", "20250710", "20250711", "20250712", "20250713", "20250714", "20250715")

for (i in 1:11){


# read nomads stg4 html page using date from utc_time()
stg4_http_page<-read_html(paste0("https://nomads.ncep.noaa.gov/pub/data/nccf/com/pcpanl/prod/pcpanl.",date_char[i],"/"))


# find only files that end with .grb2 and have 'conus' somewhere in the string
grib2_available <- stg4_http_page %>%
  html_elements("a") %>%
  html_text() %>%
  str_subset("conus") %>%
  str_subset("01h.grb2$") 

for (j in 1:length(grib2_available)) {

# create path to download
source_path<-paste0("https://nomads.ncep.noaa.gov/pub/data/nccf/com/pcpanl/prod/pcpanl.",date_char[i],"//",grib2_available[j])


# create download destination
destination_path<-paste0("C:/texas_mpe/grib2_manual_scrape", "/",grib2_available[j])

#download the file  
#download.file (source_path,destination_path,method = "libcurl")  #libcurl betrayed me, threw bad gribs....
download.file (source_path,destination_path,method = "curl")

} # close inner loop controlling hourly grib2 download

} # close outer loop controlling date






