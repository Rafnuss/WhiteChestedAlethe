# Load required packages
library(terra)
library(sf)
library(elevatr)

id = "CP007"

# Coordinates (decimal degrees)
known_lat <- config::get("tag_set_map", id)$known$known_lat
known_lon <- config::get("tag_set_map", id)$known$known_lon

# Center point as sf
pt <- st_sf(geometry = st_sfc(st_point(c(known_lon, known_lat)), crs = 4326))

# Create 100x100 km bounding box (50 km buffer)
pt_utm <- st_transform(pt, 32737)
extent_utm <- st_buffer(pt_utm, 50000)
extent_wgs84 <- st_transform(extent_utm, 4326)

# ✅ get DEM
dem <- get_elev_raster(locations = extent_wgs84, z = 12, clip = "locations")

# Save to GeoTIFF
terra::writeRaster(dem, "data/dem_100km.tif", overwrite = TRUE)

# Open to check
plot(dem)