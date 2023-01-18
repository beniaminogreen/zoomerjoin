
# zoomerjoin

INSANELY, BLAZINGLY FAST fuzzy joins in R. Implimented using
[MinHash](https://en.wikipedia.org/wiki/MinHash), such that each record
does not have to be compared to all other records when matching. This
results in matches that return orders of magnitude faster than other
matching packages.

# Installation

## Installing Rust:

You must have [Rust](https://www.rust-lang.org/tools/install) installed
to compile this package. The rust website provides an excellent
installation script that has never caused me any issues.

On Linux, you can install Rust with:

``` sh
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

On Windows, I use the rust installation wizard, found
[here](https://forge.rust-lang.org/infra/other-installation-methods.html).

## Installing Package from Github:

Once you install rust, you should be able to install the package with:

``` r
devtools::install_github("beniaminogreen/zoomerjoin")
```

# Usage:

The package provides the following functions, which are designed to be
near to drop-ins for the corresponding dplyr/fuzzyjoin commands:

- `lhs_left_join()`
- `lhs_right_join()`
- `lhs_inner_join()`
- `lhs_full_join()`
- `lhs_anti_join()`

Here’s a snippet showing off how to use the `lhs_left_join()` command:

``` r
head(corpus_1)
```

    ## # A tibble: 6 × 2
    ##         a field                                         
    ##     <dbl> <chr>                                         
    ## 1 1183377 united capital markets inc                    
    ## 2  327131 hammond collier & wade livingstone association
    ## 3 1091506 schirmer suter & gaw                          
    ## 4  269074 la auto dealers                               
    ## 5  538813 michael alexander bldg contractor             
    ## 6  398102 yales industrial trucks

``` r
head(corpus_2)
```

    ## # A tibble: 6 × 2
    ##         b field                           
    ##     <dbl> <chr>                           
    ## 1  671142 dreggors bill & irene           
    ## 2  658722 employment history bureau       
    ## 3 1057120 dlm partners                    
    ## 4   68355 law offices of john yzurdiaga   
    ## 5  360522 priority promotions             
    ## 6  800597 al kruse for minnesota house 21a

``` r
joined_df <- lhs_inner_join(corpus_1, corpus_2, n_gram_width=6, n_bands=20, band_width=5)
```

    ## Joining by 'field'

``` r
head(joined_df)
```

    ## # A tibble: 6 × 4
    ##         a field.x                                 b field.y                     
    ##     <dbl> <chr>                               <dbl> <chr>                       
    ## 1  559852 lighthouse resources ltd           559852 lighthouse resources ltd    
    ## 2 1244771 new york building                 1244771 new york building           
    ## 3 1160697 bollinger lach & associates inc   1160697 bollinger lach & associates…
    ## 4 1320749 colon diaz, bethsaida             1320749 colon diaz, bethsaida       
    ## 5  954308 latino builders industry assoc     954308 latino builders industry as…
    ## 6  223226 american acadamy of otolaryngolgy  223226 american acadamy of otolary…

## Limiting the Number of Threads:

To constrain the number of cores the program uses, you can set the
`RAYON_NUM_THREADS` variable before running the search. At present, this
variable is read at the construction of the multithreading thread pool,
and so must be set once each R session. In a future version, I’ll work
to include a fix so that the number of threads can be included in an
argument to the `lhs_join` functions.

Here’s an example of how to set the function to run on an single core in
R:

``` r
Sys.setenv(RAYON_NUM_THREADS=1)
```
