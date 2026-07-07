library(GeoPressureR)
library(ggplot2)
library(plotly)
id = "CP007"

# geopressuretemplate_tag(id)
load_interim(id)

path <- as.data.frame(config::get("tag_set_map", id)$known)
names(path) <- c("stap_id", "lat", "lon")


pp <- pressurepath_create(tag, path, variable = c("altitude", "surface_pressure", "total_precipitation", "temperature_2m"), era5_dataset = "single-levels")
plot_pressurepath(pp)

pp2 <- pressurepath_create(tag, path, variable = c("altitude", "surface_pressure", "total_precipitation", "temperature_2m"), era5_dataset = "both")
plot_pressurepath(pp2)


  ggplot() +
    geom_line(data = pp, aes(x = date, y = altitude), color = "blue") +
    geom_line(data = pp2, aes(x = date, y = altitude), color = "red", linetype = "dashed") 



# remove era5 ouliera
# pp <- pp[pp$altitude >= 0 & !is.na(pp$altitude), ]


plot_pressurepath(pp, "altitude") 

save(
    list = c("tag", "param", "pp"),
    file = glue::glue("./data/interim/{id}.Rdata")
  )


plot_tag_actogram(tag)

tag2 <- tag_create(id)|> tag_label()
tag2$stap$duration <- stap2duration(tag2$stap)
tag2$stap$cat = "short"
long <- which(tag2$stap$duration > 30)
tag2$stap$cat[long[c(1,3,5)]] <- "low"
tag2$stap$cat[long[c(2,4)]] <- "high"

tag$acceleration

mat <- GeoPressureR::ts2mat(tag$acceleration)






km <- kmeans(pp$altitude, centers = 3)$centers
km

pp |> 
  ggplot(aes(x = altitude)) +
  geom_histogram(binwidth = 10) +
  geom_vline(xintercept = km, color = "red")


library(dplyr)
library(plotly)

# --- Altitude plot ---
p1 <- plot_ly(pp, x = ~date, y = ~surface_pressure, type = 'scatter', mode = 'lines',
              name = 'Altitude', line = list(color = '#8B4513'))  # warm brown

# --- Temperature plot (daily mean + smooth) ---
pp_temp <- pp %>%
  mutate(day = as.Date(date)) %>%
  group_by(day) %>%
  summarise(daily_mean = mean(temperature_2m-273.15, na.rm = TRUE)) %>%
  mutate(smooth = fitted(loess(daily_mean ~ as.numeric(day), span = 0.2)))

p2 <- plot_ly(pp_temp, x = ~day, y = ~daily_mean, type = 'scatter', mode = 'markers',
              name = 'Daily temperature', marker = list(color = '#E64B35', size = 5, opacity = 0.6)) %>%
  add_trace(y = ~smooth, mode = 'lines', line = list(color = '#E64B35', width = 2),
            name = 'Smoothed')

# --- Precipitation plot (daily sum as bar) ---
pp_prec <- pp %>%
  mutate(day = as.Date(date)) %>%
  group_by(day) %>%
  summarise(daily_sum = sum(total_precipitation, na.rm = TRUE))

p3 <- plot_ly(pp_prec, x = ~day, y = ~daily_sum, type = 'bar',
              name = 'Daily precipitation', marker = list(color = '#4DBBD5', line = list(color = '#2A7FA1', width = 1)))

# --- Combine vertically ---
subplot(p1, p2, p3, nrows = 3, shareX = TRUE, titleY = TRUE) %>%
  layout(showlegend = FALSE)



library(ggplot2)
library(dplyr)
library(tidyr)

# Combine mat with tag2$stap category
# Assume mat is a list with $value (matrix), $day (vector), $time (vector)
df_mat <- as.data.frame(t(mat$value))
colnames(df_mat) <- mat$time
df_mat$day <- mat$day

# Join with tag2$stap category based on day
tag_dates <- tag2$stap %>%
  select(stap_id, start, end, cat) %>%
  mutate(
    start = as.Date(start),
    end   = as.Date(end)
  )

df_long <- df_mat %>%
  pivot_longer(-day, names_to = "time", values_to = "activity") %>%
  mutate(day = as.Date(day)) %>%
  rowwise() %>%
  mutate(
    cat = tag_dates$cat[which(day >= tag_dates$start & day <= tag_dates$end)[1]]
  ) %>%
  ungroup() %>%
  filter(cat %in% c("low", "high"))

# Aggregate mean per time of day for low/high
df_mean <- df_long %>%
  group_by(time, cat) %>%
  summarise(mean_activity = mean(activity, na.rm = TRUE), .groups = "drop")

# Plot
ggplot(df_long, aes(x = time, y = activity, color = cat)) +
  # geom_jitter(width = 0.2, height = 0, alpha = 0.3) +  # scatter
  geom_line(data = df_mean, aes(y = mean_activity, group = cat), size = 1) +  # mean fitted
  theme_minimal() +
  labs(x = "Time of day", y = "Activity", color = "Category") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
