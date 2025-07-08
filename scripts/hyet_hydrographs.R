library(tidyverse)
library(patchwork)
library(RColorBrewer)

# First panel: 3 lines
flow <- read_csv("./scripts/gage_data.csv") |>
  mutate(cdt = force_tz(ymd_hms(paste(date, time)), tzone = "America/Chicago")) |>
  relocate(cdt, .before = everything())

# Second panel: 2 lines
hyet <- read_csv("./scripts/hyet_data.csv")|>
  mutate(cdt = with_tz(time,"America/Chicago")) |>
  select(-1)|>
  relocate(cdt, .before = everything())|>
  filter(rain_type == "hunt basin avg cumulative" | rain_type =="max radar bin cumulative")

#hyet_cdt <- hyet 

# RdYlBu with 3 colors for panel 1, 2 for panel 2
# Full 11-color diverging palette
all_colors <- brewer.pal(11, "RdYlBu")

# Remove the middle (yellowish) color
custom_colors <- all_colors[c(1:4, 7:11)]  # Skips index 5 and 6 (the yellow center)

# Assign subset (e.g., 3 colors from red to blue, no yellow)
my_colors <- custom_colors[c(1, 4, 8)]  # Adjust indexes to taste


x_limits_flow <- force_tz(ymd_hm(c("2025-07-03 20:00", "2025-07-05 12:00")), tzone = "America/Chicago")
x_limits_hyet <- force_tz(ymd_hm(c("2025-07-03 20:00", "2025-07-04 18:00")), tzone = "America/Chicago")

# Panel 1 Plot
p1 <- ggplot(flow, aes(x = cdt, y = height, color = gage_name)) +
  geom_line(size = 1) +
  scale_color_manual(values = my_colors,
                     labels = c("Guad at Comfort", "Guad at Hunt", "Guad at Spring Branch")) +
  labs(y = "River Stage (ft)", x = NULL) +
  scale_x_datetime(
    limits = x_limits_flow,
    expand = c(0, 0),
    date_breaks = "12 hours",
    date_labels = "%b %d\n%H:%M"
  ) +
  theme_bw() +
  theme(panel.grid.major = element_line(color = "gray80"),
        panel.grid.minor = element_line(color = "gray90"))

# Panel 2 Plot
p2 <- ggplot(hyet, aes(x = cdt, y = rain_in, color = graph_name)) +
  geom_line(size = 1) +
  scale_color_manual(values = my_colors,
                     labels = c("Basin avg pcp Hunt", "Pcp at max radar bin")) +
  labs(y = "Cumulative Precip (in)", x = NULL) +
  scale_x_datetime(
    limits = x_limits_hyet,
    expand = c(0, 0),
    date_breaks = "6 hours",
    date_labels = "%b %d\n%H:%M"
  ) +
  theme_bw() +
  theme(panel.grid.major = element_line(color = "gray80"),
        panel.grid.minor = element_line(color = "gray90"))

p1 <- p1 + theme(
  legend.position = c(0.99, 1),
  legend.justification = c("right", "top"),
  legend.background = element_blank(),
  legend.title = element_blank()
)

p2 <- p2 + theme(
  legend.position = c(0.98, 0.15),
  legend.justification = c("right", "top"),
  legend.background = element_blank(),
  legend.title = element_blank()
)

final_plot<-p1 + p2   # stack vertically, combine legends

ggsave(
  filename = "flood_plot_linkedin.png",
  plot = final_plot,
  width = 2000,
  height = 2000,
  units = "px",
  dpi = 300,
  bg = "white"  # ensures transparent legends don’t render weird
)


