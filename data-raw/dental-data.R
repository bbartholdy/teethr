# download data

mb11_calculus <- readr::read_csv("https://zenodo.org/record/8061483/files/calculus_full.csv?download=1")
mb11_caries <- readr::read_csv("https://zenodo.org/record/8061483/files/caries.csv?download=1")

usethis::use_data(mb11_calculus, overwrite = T)
usethis::use_data(mb11_caries, overwrite = T)
