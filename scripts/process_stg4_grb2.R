### Take radar files out of grb2 and place into .txt files

# load libraries
library("tidyverse")

#generate list of raw GRIB2 MPE files that you want to de-GRIB
grib2_list<-list.files("C:\\july_25\\stg4\\raw_gribs")

# loop
for (i in grib2_list) {
  
 
  # pull single file out of raw folder place in wgrib folder
  file.copy(from = paste0("C:\\july_25\\stg4\\raw_gribs//", i),
            to=paste0("C://grib//wgrib2//", i))
  
  # wgrib it into a text file
  setwd("C://grib//wgrib2")
  system(paste0("wgrib2.exe ",i, " -csv ",i,".txt"))
  
  # pull the de gribbed text file out and place in processed folder named appropriately
  file.copy(from = paste0("C://grib//wgrib2//",i,".txt"),
            to=paste0("C://july_25//stg4//degribbed_2_text//", i,'.txt'))
  

# remove GRIB1 file and dump file from the wgrib executable area
file.remove(paste0("C://grib//wgrib2//",i,".txt"))
file.remove(paste0("C://grib//wgrib2//",i))
}


### Trim text into lat, lon, timestamp, rainfall amt.  Keep in whole CONUS 

raw_grib2_text<-list.files("C:\\july_25\\stg4\\degribbed_2_text",full.names=FALSE)

for (h in raw_grib2_text) {
  
  read_csv(paste0("C:\\july_25\\stg4\\degribbed_2_text\\",h),
           col_names=c("x1","x2","x3","x4","center_lon","center_lat",h)) %>%
    select(-x1,-x2,-x3,-x4) %>%
    write_csv(paste0("C:\\july_25\\stg4\\stg4_conus_trimmed\\",h))
   rm(list=ls()) 
  gc()
  
}  


### next let's clip this to Texas and assign GRIB, hrap_x, and hrap_y

g2<-list.files("C:\\july_25\\stg4\\stg4_conus_trimmed")
g2_tx_clip<-read_csv("C:\\july_25\\gis\\hrap\\texas_buffer_spatial_join.csv")

for (m in g2) {
  
  # m<-"st4_conus.2022010101.01h.grb2.txt"
  
  ee<-read_csv(paste0("C:\\july_25\\stg4\\stg4_conus_trimmed\\",m)) 
  
  bb<-left_join(g2_tx_clip,ee,by=NULL)
  
  write_csv(bb,paste0("C:\\july_25\\stg4\\stg4_processed_texas\\",m))
  
  ff<- bb %>% summarise(nacount=sum(is.na(.)))
  
  cc  <- bb %>%  summarise(n=n())
  
  qa<-bind_cols(ff,cc,m)
  
  colnames(qa)<-(c("nas","rowcount","timestamp"))
  
  write_csv(qa,"C:\\july_25\\stg4\\qa.csv",append=TRUE,col_names = FALSE)
  
}







