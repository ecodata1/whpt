
<!-- README.md is generated from README.Rmd. Please edit that file -->

# whpt

The goal of `whpt` package is to predict whpt scores, and assess them
against the expected class. This shows if a whpt score is consistent
with what is expected at a given location.

## Installation

And the development version from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("ecodata1/whpt")
```

## Example

To run the prediction and check the consistency:

``` r
library(whpt)
whpts(demo_data)
#> # A tibble: 6 × 3
#>   sample_id assessment value             
#>   <chr>     <chr>      <chr>             
#> 1 1         assessment As expected       
#> 2 1         driver     ntaxa             
#> 3 1         action     No action required
#> 4 2         assessment As expected       
#> 5 2         driver     neither           
#> 6 2         action     No action required
```

To run only a prediction

``` r
whpt_predict(demo_data)
#> # A tibble: 4 × 3
#> # Groups:   index [2]
#>   sample_id index           predicted_response
#>       <dbl> <chr>                        <dbl>
#> 1         1 Reference ASPT                7.14
#> 2         2 Reference ASPT                7.08
#> 3         1 Reference NTAXA              19.7 
#> 4         2 Reference NTAXA              19.0
```

To run a prediction and then assess consistency:

``` r
predictions <- whpt_predict(demo_data)
data <- merge(demo_data, predictions,by.x =  "sample_id", by.y = "sample_id")
consistency(data)
#> # A tibble: 6 × 3
#>   sample_id assessment value             
#>   <chr>     <chr>      <chr>             
#> 1 1         assessment As expected       
#> 2 1         driver     ntaxa             
#> 3 1         action     No action required
#> 4 2         assessment As expected       
#> 5 2         driver     neither           
#> 6 2         action     No action required
```
