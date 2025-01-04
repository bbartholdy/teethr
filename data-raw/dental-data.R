library(sf)

dental_arcade_mapping <- read_sf("inst/extdata/dental_mapping.shp")

mb11_demography <- readr::read_csv("https://zenodo.org/record/8061483/files/demography.csv?download=1") |>
  dplyr::select(id, age, sex)
mb11_calculus <- readr::read_csv("https://zenodo.org/record/8061483/files/calculus_full.csv?download=1")
mb11_caries <- readr::read_csv("https://zenodo.org/record/8061483/files/caries.csv?download=1")

usethis::use_data(dental_arcade_mapping, overwrite = TRUE)
usethis::use_data(mb11_demography, overwrite = TRUE)
usethis::use_data(mb11_calculus, overwrite = TRUE)
usethis::use_data(mb11_caries, overwrite = TRUE)
