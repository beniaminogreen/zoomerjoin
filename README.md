
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
    ##       a field                                                                   
    ##   <dbl> <chr>                                                                   
    ## 1     1 ufwa cope committee                                                     
    ## 2     2 committee to re elect charles e. bennett                                
    ## 3     3 montana democratic party non federal account                            
    ## 4     4 mississippi power & light company management political action and educa…
    ## 5     5 napus pac for postmasters                                               
    ## 6     6 aminoil good government fund

``` r
head(corpus_2)
```

    ## # A tibble: 6 × 2
    ##        b field                               
    ##    <dbl> <chr>                               
    ## 1 832471 avrp studios inc                    
    ## 2 832472 avrd design                         
    ## 3 832473 avenales cattle co                  
    ## 4 832474 auto dealers of michigan political a
    ## 5 832475 atty & counselor at law             
    ## 6 832476 at&t united way

``` r
joined_df <- lhs_inner_join(corpus_1, corpus_2, n_gram_width=6, n_bands=20, band_width=5)
```

    ## Joining by 'field'

``` r
head(joined_df)
```

    ## # A tibble: 6 × 4
    ##        a field.x                                               b field.y        
    ##    <dbl> <chr>                                             <dbl> <chr>          
    ## 1 145220 hammonds management trust                        921070 hammonds manag…
    ## 2  63059 scott douglas & mcconnico llp,                  1209507 scott douglas …
    ## 3  35391 craig doyal campaign fund                        983950 craig doyal ca…
    ## 4 223794 union pacific coporation fund for effective gov  854351 union pacific …
    ## 5 223616 verizon good government club                     844021 verizon good g…
    ## 6  52279 coats rose yale ryman & lee p.c.                 986054 coats rose yal…

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
