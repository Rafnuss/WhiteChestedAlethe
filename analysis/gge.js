// Define the center point
var point = ee.Geometry.Point([37.81061, -7.016224]);

// Create a 100km buffer around the point (50000m radius for circle)
var buffer = point.buffer(30000);

// Add the buffer to the map
Map.centerObject(buffer, 10);
Map.addLayer(buffer, { color: 'gray', strokeWidth: 2 }, 'Study Area (100km)', false);

// Load SRTM Digital Elevation Model
var dem = ee.Image('USGS/SRTMGL1_003');

// Clip DEM to the buffer area
var demClipped = dem.clip(buffer);

// Display the DEM
Map.addLayer(demClipped, {
    min: 0,
    max: 3000,
    palette: ['blue', 'green', 'yellow', 'orange', 'red']
}, 'Elevation', false);

// Define contour levels
var contours = [260, 400, 1515, 1750];
var colors = ['#FFD700', '#FF6B35', '#00B4D8', '#9D4EDD']; // Gold, Coral, Cyan, Purple
var names = ['260m Contour', '400m Contour', '1515m Contour', '1750m Contour'];

// Create contour lines for each level
for (var i = 0; i < contours.length; i++) {
    var elevation = contours[i];
    var color = colors[i];
    var name = names[i];

    // Create contour by finding pixels at the specified elevation
    // Using a small range to create the contour line
    var contour = demClipped.gt(elevation - 10).and(demClipped.lt(elevation + 10));

    // Convert to vector
    var contourVector = contour.selfMask().reduceToVectors({
        geometry: buffer,
        scale: 30,
        geometryType: 'polygon',
        eightConnected: false,
        maxPixels: 1e10
    });

    // Display the contour line
    Map.addLayer(contourVector, { color: color }, name, true);
}

// Add the center point
Map.addLayer(point, { color: 'black' }, 'Center Point');

// Print information
print('Study area created with 100km diameter');
print('Contour levels: 400m (Red), 800m (Green), 1800m (Blue)');