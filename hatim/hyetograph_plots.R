library(tidyverse)
library(ggplot2)
library(lubridate)

hyet <- read_csv("./hatim/hyetograph_data.csv")

start_utc <- ymd_hms("2025-07-03 18:00:00", tz = "UTC")
end_utc   <- ymd_hms("2025-07-04 18:00:00", tz = "UTC")

  
hourly_max_bin <- ggplot(hyet |> filter(rain_type == "max radar bin hourly"),
                          aes(x = time, y = rain_mm, linetype = "Hourly rainfall (mm)")) +
  geom_line(linewidth = 0.9, color = "black", na.rm = TRUE) +
  geom_point(color = "black", na.rm = TRUE) +
  scale_linetype_manual(values = "solid", name = NULL) +  # legend title off; label comes from legend_label
  scale_x_datetime(limits = c(start_utc, end_utc),
                   date_breaks = "6 hours", date_labels = "%m/%d %H:%M") +
  labs(
    x = NULL,
    y = "Rain (mm)",
    title = "Precipitation at maximum stg4 radar bin"
  ) +
  theme_bw(base_size = 12) +
  theme(
    panel.grid.major = element_line(color = "grey80", linewidth = 0.35),
    panel.grid.minor = element_line(color = "grey90", linewidth = 0.25),
    legend.position = c(0.03, 0.97),                 # top-left inside
    legend.justification = c(0, 1),
    legend.background = element_rect(fill = "white", color = "grey20"),
    legend.key = element_blank()
  )

############################

cumulative_math <- hyet |>
                  filter(rain_type == "max radar bin hourly") |>
                  filter (time >= start_utc & time <= end_utc) |>
                  mutate (cumulative = cumsum(rain_mm))


cumulative_max_bin <- ggplot(cumulative_math,
                          aes(x = time, y = cumulative, linetype = "Cumulative rainfall (mm)")) +
  geom_line(linewidth = 0.9, color = "black", na.rm = TRUE) +
  geom_point(color = "black", na.rm = TRUE) +
  scale_linetype_manual(values = "solid", name = NULL) +  # legend title off; label comes from legend_label
  scale_x_datetime(limits = c(start_utc, end_utc),
                   date_breaks = "6 hours", date_labels = "%m/%d %H:%M") +
  labs(
    x = NULL,
    y = "Rain (mm)",
    title = "Cumulative precipitation at maximum stg4 radar bin"
  ) +
  theme_bw(base_size = 12) +
  theme(
    panel.grid.major = element_line(color = "grey80", linewidth = 0.35),
    panel.grid.minor = element_line(color = "grey90", linewidth = 0.25),
    legend.position = c(0.03, 0.97),                 # top-left inside
    legend.justification = c(0, 1),
    legend.background = element_rect(fill = "white", color = "grey20"),
    legend.key = element_blank()
  )

### basin scale

cumulative_hunt_basin <- ggplot(hyet |> filter(rain_type == "hunt basin avg cumulative"),
                         aes(x = time, y = rain_mm, linetype = "Cumulative rainfall (mm)")) +
  geom_line(linewidth = 0.9, color = "black", na.rm = TRUE) +
  geom_point(color = "black", na.rm = TRUE) +
  scale_linetype_manual(values = "solid", name = NULL) +  # legend title off; label comes from legend_label
  scale_x_datetime(limits = c(start_utc, end_utc),
                   date_breaks = "6 hours", date_labels = "%m/%d %H:%M") +
  labs(
    x = NULL,
    y = "Rain (mm)",
    title = "Cumulative precipitation Hunt drainage basin"
  ) +
  theme_bw(base_size = 12) +
  theme(
    panel.grid.major = element_line(color = "grey80", linewidth = 0.35),
    panel.grid.minor = element_line(color = "grey90", linewidth = 0.25),
    legend.position = c(0.03, 0.97),                 # top-left inside
    legend.justification = c(0, 1),
    legend.background = element_rect(fill = "white", color = "grey20"),
    legend.key = element_blank()
  )









