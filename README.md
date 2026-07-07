# White-chested Alethe GeoLocator Data Package

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.21209234.svg)](https://doi.org/10.5281/zenodo.21209234)

## Start here

- [Paper PDF](resources/Seasonal%20altitudinal%20migration%20of%20White-chested%20Alethe%20Chamaetylas%20fuelleborni%20in%20Tanzania%20documented%20with%20a%20barometric%20pressure%20logger.pdf)
- [Notes PDF](resources/notes.pdf)

## Description

This GeoLocator Data Package contains the raw data from a single barometric pressure logger deployed on a White-chested Alethe (*Chamaetylas fuelleborni*) in Kimboza Forest Reserve, Tanzania.

The dataset accompanies Jensen & Werema (2025), which documented seasonal altitudinal migration between lowland and montane forests in the Uluguru Mountains.

As the study focused on local elevational movements, no GeoPressureR analysis was performed and this package contains raw logger data only.

## Data

- `data/raw-tag/CP007/`: raw logger file
- `data/tag-label/`: labelled logger data
- `data/tags.csv`: tag metadata
- `data/observations.csv`: deployment and retrieval observations

## Data Package

The GeoLocator Data Package can be generated from this repository with:

```r
source("analysis/20-datapackage.R")
```

## Reference

Jensen, F. P., & Werema, C. (2025). Seasonal altitudinal migration of White-chested Alethe (*Chamaetylas fuelleborni*) in Tanzania documented with a barometric pressure logger. *Ostrich*, 96(1), 69-73. <https://doi.org/10.2989/00306525.2025.2481468>

_This repository was generated based on [GeoPressureTemplate (v1.3)](https://github.com/Rafnuss/GeoPressureTemplate)._
