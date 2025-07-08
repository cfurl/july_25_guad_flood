library(sf)
library(janitor)
library(arrow)
library(tictoc)
library(tidyverse)
library(ggspatial)

#for bin map 
map <- sf::read_sf("./gis/usgs_dissolved.shp")
streams <- read_sf("./gis/streams_recharge.shp")
lakes <- read_sf("./gis/reservoirs.shp")
tx_rain <- arrow::open_dataset("C:/texas_mpe/july_flood_no_git/st4_parq_eaa")
guad<-read_sf("./gis/usgs_basins.shp")|>filter(Name_Desc=="Guadalupe Basin")

sum_rain_query <- tx_rain %>%
  filter(year==2025) %>%
  group_by (grib_id) %>%
  summarize(
    sum_rain = sum(rain_mm, na.rm=TRUE)) %>%
  arrange(desc(sum_rain))

tic()
sum_rain_collect <- collect(sum_rain_query)
toc()

map_rain <- map|>
  left_join(sum_rain_collect, by = "grib_id")|>
  mutate(cubic_m_precip = bin_area * sum_rain * 0.001)|>
  mutate(sum_rain_in = sum_rain/25.4)


####FUNCTION####
plot_bin_map<-function(
    title = 'Edwards Aquifer Recharge Zone',
    subtitle= NA,
    font = "Open Sans",
    map_rain = NA,
    map_streams = NA, 
    map_lakes = NA,
    pal_water='black',
    pal_title='white',
    pal_subtitle='white',
    pal_outline='black',
    pal_bin_outline='black',
    pal_legend_text='white',
    #pal_legend = 'YlGnBu',
    pal_legend = 'RdYlBu',
    bin_alpha = 0.7,
    map_type='cartodark'
){
  
  bbox <- st_bbox(c(
   # xmin = -100.85,
    xmin = -100.60,
    ymin = 29.0, 
    #xmax = -97.75, 
    xmax = -97.80,
    ymax = 30.47
  ), crs = 4326)
  
  coord_sys<-3857
  
  # Convert bbox to an sf object for ggplot compatibility
  bbox_sf <- st_as_sfc(bbox)
  
  bbox_transformed <- st_transform(bbox_sf, crs = coord_sys)
  
  outline<-map|>summarise(geometry = st_union(geometry))|>  st_cast("MULTILINESTRING")  
  
  title_pos <- st_sfc(st_point(c(-100.5, 30.43)), crs = 4326)|>st_transform(point, crs = 3857)
  title_pos<-as.data.frame(st_coordinates(title_pos))
  subtitle_pos <- st_sfc(st_point(c(-100.5, 30.43-0.085)), crs = 4326)|>st_transform(point, crs = 3857)
  subtitle_pos<-as.data.frame(st_coordinates(subtitle_pos))
  
  
  plot<-ggplot()+
    annotation_map_tile(
      type = map_type,  # Use the "Carto Light" basemap
      zoom = 9  # Adjust zoom level as needed
    )+
    annotate(geom="text",x= title_pos$X,y=title_pos$Y,label=title,size=8,hjust=0, color = pal_title, family=font, fontface='bold')+
    annotate(geom="text",x= subtitle_pos$X,y=subtitle_pos$Y,label=subtitle,size=5,hjust=0, color = pal_subtitle, family=font)+
    geom_sf(data=map_rain, mapping=aes(fill=sum_rain_in),color=pal_bin_outline, alpha=bin_alpha)+
    geom_sf(data = outline|>st_transform(crs = coord_sys), color = pal_outline, linewidth = 0.4) +  
    geom_sf(data=guad|>st_transform(crs = coord_sys),fill=NA, color="salmon", linewidth = 0.9)+
    geom_sf(data=map_lakes|>st_transform(crs = coord_sys), fill= pal_water, color= pal_water, linewidth = 0.2)+
    geom_sf(data=map_streams|>st_transform(crs = coord_sys), color= pal_water)+
    scale_fill_fermenter(
      palette = pal_legend, 
      #breaks = c(2,6,seq(from=25, to=175, by=25)),  # Customize bins
      #breaks = c(10,25,37,seq(from=50, to=550, by=50)),  # Customize bins
      breaks = c(0.5,1,2,3,seq(from= 4, to=12, by=2)),  # Customize bins
      #breaks = c(seq(from=50, to=550, by=50)),  # Customize bins
     # direction = 1,  # Normal order for YlOrRd
      direction = -1,  # Normal order for YlOrRd
      name = "Rainfall (in)"  # Legend title
    ) +
    guides(
      fill = guide_colorbar(
        title.position = "top",
        title.vjust = 0.1 
      )
    )+
    coord_sf(
      xlim = c(st_bbox(bbox_transformed)["xmin"], st_bbox(bbox_transformed)["xmax"]),
      ylim = c(st_bbox(bbox_transformed)["ymin"], st_bbox(bbox_transformed)["ymax"])
    ) +
    theme_void()+
    theme(
      text = element_text(family=font),
      legend.position = "inside",
      legend.position.inside = c(0.75,0.1),  
      legend.direction = "horizontal", 
      legend.margin = margin(t = 0, r = 10, b = 0, l = 10),
      legend.title = element_text(size = 10, face='bold', color=pal_legend_text), 
      legend.text = element_text(size = 9, color=pal_legend_text),  
      legend.key.width = unit(2.5, "cm"), 
      legend.key.height = unit(0.5, "cm")  
    )
  
  return(plot)
}


bin_map_light<-plot_bin_map(subtitle= "September 2015 Precipitation. STG4 QPE BIN 4km.",
                            map_rain = map_rain,
                            map_streams = streams,
                            map_lakes = lakes,
                            pal_water='#697984',
                            #pal_water = '#2C6690',
                            pal_title='black',
                            # pal_legend = 'YlOrRd',
                            bin_alpha = 0.9,
                            pal_subtitle='black',
                            pal_outline="#697984",
                            pal_bin_outline='white',
                            pal_legend_text='black',
                            map_type='cartolight')



#bin_map_light

#dark mode
bin_map_dark<-plot_bin_map(title = 'Precipitation Across Texas Hill Country July 3-4, 2025',
                           subtitle= "STG4 QPE BIN 4km. Guadalupe Basin outlined",
                           font = "Open Sans",
                           map_rain = map_rain,
                           map_streams = streams,
                           map_lakes = lakes,
                           pal_water='black',
                           pal_title='white',
                           pal_subtitle='white',
                           pal_outline='black',
                           pal_legend = 'YlGnBu',
                           pal_bin_outline='black',
                           pal_legend_text='white',
                           map_type='cartodark')

bin_map_dark

#ggsave("./bin_map_dark_wide_paul.png",bin_map_dark, width = 12, height = 9, units="in", dpi=900)
#ggsave("./bin_map_dark_square.png",bin_map_dark, width = 9, height = 9, units="in", dpi=650)