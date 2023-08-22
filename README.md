
<!-- README.md is generated from README.Rmd. Please edit that file -->

# teethr

<!-- badges: start -->

[![R-CMD-check](https://github.com/bbartholdy/teethr/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/bbartholdy/teethr/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

The goal of teethr (pronounced teether) is to provide a set of tools to
calculate dental indices, such as caries ratio, and calculus index, and
facilitate visualisation of data related to dental diseases.

## Installation

You can install the development version of teethr like so:

``` r
devtools::install_github("bbartholdy/teethr")
```

## Example

First, dental data are combined with demographic data and converted to
long format with `dental_longer()`. `dental_longer()` also adds
information on tooth type and position that can be used to calculate
tooth- and position-specific indices.

``` r
library(teethr)
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union

mb11_calculus_long <- mb11_calculus %>% 
  dental_longer(-id, rm_char = "t", names_sep = "_") %>% # make longer all columns except 'id'
  inner_join(mb11_demography, by = "id") # combine with age and sex
mb11_calculus_long
#> # A tibble: 3,936 × 12
#>    id    tooth surface score region  position  side  class  type  quadrant age  
#>    <chr> <chr> <chr>   <dbl> <chr>   <chr>     <chr> <chr>  <chr> <chr>    <chr>
#>  1 MB131 11    bucc        0 maxilla anterior  right incis… i1    UA       ma   
#>  2 MB131 11    lin         0 maxilla anterior  right incis… i1    UA       ma   
#>  3 MB131 11    ip          1 maxilla anterior  right incis… i1    UA       ma   
#>  4 MB131 12    bucc        0 maxilla anterior  right incis… i2    UA       ma   
#>  5 MB131 12    lin         0 maxilla anterior  right incis… i2    UA       ma   
#>  6 MB131 12    ip          1 maxilla anterior  right incis… i2    UA       ma   
#>  7 MB131 13    bucc        0 maxilla anterior  right canine c     UA       ma   
#>  8 MB131 13    lin         0 maxilla anterior  right canine c     UA       ma   
#>  9 MB131 13    ip          0 maxilla anterior  right canine c     UA       ma   
#> 10 MB131 14    bucc        1 maxilla posterior right premo… pm1   UP       ma   
#> # ℹ 3,926 more rows
#> # ℹ 1 more variable: sex <chr>
```

The long-format data can be used to calculate indices, such as the
dental calculus index using the `calculus_index()` function. The
function also provides the number of surfaces scored, number of teeth,
and sum of scores for verification. The original method recommends
grouping the dentition by quadrant to obtain four indices. This can be
done for the whole sample,

``` r
mb11_calculus_long %>%
  group_by(quadrant) %>% 
  calculus_index()
#> previously defined groups (quadrant) were used. If that was not expected, use `ungroup()` on the data frame before using the function.
#> # A tibble: 4 × 4
#>   quadrant     n score_sum index
#>   <chr>    <int>     <dbl> <dbl>
#> 1 LA         632       631 0.998
#> 2 LP         857       513 0.599
#> 3 UA         554       308 0.556
#> 4 UP         813       541 0.665
```

or by sex,

``` r
mb11_calculus_long %>%
  # groups can also be added directly to calculus_index()
  calculus_index(sex, quadrant) %>% 
  select(sex, quadrant, index) # remove unnecessary outputs
#> previously defined groups (sex,quadrant) were used. If that was not expected, use `ungroup()` on the data frame before using the function.
#> # A tibble: 16 × 3
#>    sex   quadrant  index
#>    <chr> <chr>     <dbl>
#>  1 f     LA       0.778 
#>  2 f     LP       0.345 
#>  3 f     UA       0.0556
#>  4 f     UP       0.5   
#>  5 m     LA       1.01  
#>  6 m     LP       0.582 
#>  7 m     UA       0.545 
#>  8 m     UP       0.630 
#>  9 pf    LA       0.667 
#> 10 pf    LP       0.667 
#> 11 pf    UA       0.154 
#> 12 pf    UP       0.688 
#> 13 pm    LA       1.03  
#> 14 pm    LP       0.678 
#> 15 pm    UA       0.671 
#> 16 pm    UP       0.782
```

or by age and sex.

``` r
mb11_calculus_long %>%
  calculus_index(sex, age, quadrant) %>% 
  select(sex, quadrant, index) # remove unnecessary outputs
#> previously defined groups (sex,age,quadrant) were used. If that was not expected, use `ungroup()` on the data frame before using the function.
#> Warning in dental_index(., score = {: 1 rows removed because of no teeth
#> present in groupings.
#> # A tibble: 39 × 3
#>    sex   quadrant  index
#>    <chr> <chr>     <dbl>
#>  1 f     LA       0.778 
#>  2 f     LP       0.345 
#>  3 f     UA       0.0556
#>  4 f     UP       0.5   
#>  5 m     LA       0.9   
#>  6 m     LP       0.167 
#>  7 m     UA       0.167 
#>  8 m     UP       0.296 
#>  9 m     LA       0.930 
#> 10 m     LP       0.549 
#> # ℹ 29 more rows
```

``` r
library(ggplot2)
mb11_calculus_long %>% 
  calculus_index(id, age, quadrant) %>% 
  #filter(quadrant == "UP") %>% 
  ggplot(aes(x = age, y = index, fill = age)) +
    #geom_violin(aes(fill = sex)) +
    geom_boxplot(width = 0.5) +
    scale_fill_viridis_d() +
    facet_wrap(~ quadrant) +
    theme_bw()
#> previously defined groups (id,age,quadrant) were used. If that was not expected, use `ungroup()` on the data frame before using the function.
#> Warning in dental_index(., score = {: 1 rows removed because of no teeth
#> present in groupings.
```

<img src="man/figures/README-calc-plot-1.png" width="100%" />

Dental caries ratios can be calculated using the `caries_ratio`
function.

``` r
mb11_caries_long <- mb11_caries %>% 
  dental_longer(-id, rm_char = "t")

mb11_caries_long %>% 
  group_by(type) %>% 
  caries_ratio(.no_lesion = "none", .lesion_sep = ";")
#> previously defined groups (type) were used. If that was not expected, use `ungroup()` on the data frame before using the function.
#> # A tibble: 8 × 4
#>   type      n count  ratio
#>   <chr> <int> <int>  <dbl>
#> 1 c       143    17 0.119 
#> 2 i1      125    10 0.08  
#> 3 i2      132     9 0.0682
#> 4 m1      120    35 0.292 
#> 5 m2      105    37 0.352 
#> 6 m3       90    25 0.278 
#> 7 pm1     141    15 0.106 
#> 8 pm2     112    19 0.170
```

The package also facilitates working with the {tidyverse}.

``` r
# count number of teeth per individual
mb11_caries_long %>% 
  remove_missing(vars = "score") %>% 
  count(id)
#> Warning: Removed 362 rows containing missing values.
#> # A tibble: 41 × 2
#>    id        n
#>    <chr> <int>
#>  1 MB107    24
#>  2 MB116    20
#>  3 MB117    21
#>  4 MB120    29
#>  5 MB121    27
#>  6 MB131    24
#>  7 MB158    29
#>  8 MB163    24
#>  9 MB18     29
#> 10 MB180    24
#> # ℹ 31 more rows
```
