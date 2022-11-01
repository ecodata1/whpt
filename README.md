
<!-- README.md is generated from README.Rmd. Please edit that file -->

# whpt

The goal of `whpt` package is to predict WHPT scores, and assess them
against the expected class. This shows if a WHPT score is consistent
with what is expected at a given location.

## Installation

Install the development version from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("ecodata1/whpt")
```

### Example

To run the prediction and check the consistency:

``` r

library(whpt)
library(dplyr)
whpts(demo_data)
#> # A tibble: 5 × 3
#>   sample_id        question        response          
#>   <chr>            <chr>           <chr>             
#> 1 457   2022-10-25 Reference ASPT  7.27              
#> 2 457   2022-10-25 Reference NTAXA 19.03             
#> 3 457   2022-10-25 assessment      As expected       
#> 4 457   2022-10-25 driver          neither           
#> 5 457   2022-10-25 action          No action required
```

### Predict

To run a prediction, only need “GIS” and date variables (but you can
have extra variables and doesn’t matter what order or upper /lower
case:)

``` r
# Select only the variables needed to run a prediction:
data <- demo_data
names(data) <- tolower(names(data))
 data <- select(
    data,
    sample_id,
    date_taken,
    ngr,
    altitude,
    d_f_source,
    logaltbar,
    log_area,
    disch_cat,
    slope,
    chalk,
    clay,
    hardrock,
    limestone,
    peat)

whpt_predict(data)
#> # A tibble: 2 × 3
#> # Groups:   index [2]
#>   sample_id        index           predicted_response
#>   <chr>            <chr>                        <dbl>
#> 1 457   2022-10-25 Reference ASPT                7.27
#> 2 457   2022-10-25 Reference NTAXA              19.0
```

### Predict and Assess

To run a prediction and then assess consistency:

``` r

predictions <- whpt_predict(demo_data)
data <- merge(demo_data, predictions, by.x =  "sample_id", by.y = "sample_id")
consistency(data)
#> # A tibble: 3 × 3
#>   sample_id        assessment value             
#>   <chr>            <chr>      <chr>             
#> 1 457   2022-10-25 assessment As expected       
#> 2 457   2022-10-25 driver     neither           
#> 3 457   2022-10-25 action     No action required
```
