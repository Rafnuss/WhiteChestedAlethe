// --- Parameters ---
var point = ee.Geometry.Point([37.81061, -7.016224]);  // lon, lat
var start = ee.Date('1995-01-01');
var end = ee.Date('2025-01-01');

// --- ERA5-Land daily total precipitation ---
var dataset = ee.ImageCollection('ECMWF/ERA5_LAND/DAILY_AGGR')
    .filterDate(start, end)
    .select('total_precipitation_sum');

// --- Add day-of-year and extract precipitation at the point ---
var ts = dataset.map(function (img) {
    var val = img.reduceRegion({
        reducer: ee.Reducer.mean(),
        geometry: point,
        scale: 11100,
        bestEffort: true
    }).get('total_precipitation_sum');
    return ee.Feature(null, {
        doy: img.date().getRelative('day', 'year'),
        precip: ee.Number(val).multiply(1000) // convert m -> mm
    });
});

// --- Compute mean by day-of-year across all years ---
var climatology = ts.reduceColumns({
    selectors: ['doy', 'precip'],
    reducer: ee.Reducer.mean().group({
        groupField: 0,  // doy
        groupName: 'doy'
    })
}).get('groups');

// --- Convert to FeatureCollection for charting ---
climatology = ee.FeatureCollection(
    ee.List(climatology).map(function (el) {
        el = ee.Dictionary(el);
        return ee.Feature(null, {
            doy: el.get('doy'),
            precip: el.get('mean')
        });
    })
);

// --- Plot ---
print(ui.Chart.feature.byFeature(climatology, 'doy', 'precip')
    .setOptions({
        title: 'Daily Climatological Mean Precipitation (1995–2025)',
        hAxis: { title: 'Day of Year' },
        vAxis: { title: 'Precipitation (mm/day)' },
        lineWidth: 2,
        pointSize: 0
    })
);