
# ZoomerJoin [![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)

<img src='logo.png' align="right" height="250">

INSANELY, BLAZINGLY FAST fuzzy joins in R. Implimented using
[MinHash](https://en.wikipedia.org/wiki/MinHash) to cut down on the
number of comparisons that need to be made in calculating matches. This
results in matches that return orders of magnitude faster than other
matches.

### Installation

------------------------------------------------------------------------

#### Installing Rust:

You must have [Rust](https://www.rust-lang.org/tools/install) installed
to compile this package. The rust website provides an excellent
installation script that has never caused me any issues.

On Linux or MacOs, you can install Rust with:

``` sh
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

On Windows, I use the rust installation wizard, found
[here](https://forge.rust-lang.org/infra/other-installation-methods.html).

#### Installing Package from Github:

Once you install Rust, you should be able to install the package with:

``` r
devtools::install_github("beniaminogreen/zoomerjoin")
```

## Usage:

------------------------------------------------------------------------

The package provides the following functions, which are designed to be
near to drop-ins for the corresponding dplyr/fuzzyjoin commands:

- `lsh_left_join()`
- `lsh_right_join()`
- `lsh_inner_join()`
- `lsh_full_join()`
- `lsh_anti_join()`

Here’s a snippet showing off how to use the `lhs_left_join()` command:

I start with two corpses I would like to combine, `corpus_1`:

``` r
corpus_1
```

    ## # A tibble: 500,000 × 2
    ##        a field                                                                  
    ##    <dbl> <chr>                                                                  
    ##  1     1 ufwa cope committee                                                    
    ##  2     2 committee to re elect charles e. bennett                               
    ##  3     3 montana democratic party non federal account                           
    ##  4     4 mississippi power & light company management political action and educ…
    ##  5     5 napus pac for postmasters                                              
    ##  6     6 aminoil good government fund                                           
    ##  7     7 national women's political caucus of california                        
    ##  8     8 minnesota gun owners' political victory fund                           
    ##  9     9 metropolitan detroit afl cio cope committee                            
    ## 10    10 carpenters legislative improvement committee united brotherhood of car…
    ## # … with 499,990 more rows

And `corpus_2`:

``` r
corpus_2
```

    ## # A tibble: 500,000 × 2
    ##         b field                               
    ##     <dbl> <chr>                               
    ##  1 832471 avrp studios inc                    
    ##  2 832472 avrd design                         
    ##  3 832473 avenales cattle co                  
    ##  4 832474 auto dealers of michigan political a
    ##  5 832475 atty & counselor at law             
    ##  6 832476 at&t united way                     
    ##  7 832477 ashland food & liquors              
    ##  8 832478 arvance turkey ranch inc            
    ##  9 832479 arizona federation of teachers      
    ## 10 832480 arianas restaurant                  
    ## # … with 499,990 more rows

The two Corpuses can’t be directly joined because of misspellings. This
means we must use the fuzzy-matching capabilities of zoomerjoin:

``` r
start_time <- Sys.time()
join_out <- lsh_inner_join(corpus_1, corpus_2, n_gram_width=6, n_bands=20, band_width=6)
```

    ## Joining by 'field'

``` r
print(Sys.time() - start_time)
```

    ## Time difference of 12.00186 secs

``` r
print(join_out)
```

    ## # A tibble: 2,534 × 4
    ##         a field.x                                                      b field.y
    ##     <dbl> <chr>                                                    <dbl> <chr>  
    ##  1  53424 american electric power company committee for responsi… 9.96e5 americ…
    ##  2 384673 technology association of americas                      8.50e5 techno…
    ##  3 134700 asl consulting engineers                                9.57e5 kasl c…
    ##  4  97923 harris county conservative congressional campaign       9.63e5 harris…
    ##  5 265571 akin gump strauss hauer & feld                          8.87e5 akin g…
    ##  6  81870 vilma luna political fund                               8.89e5 vilma …
    ##  7 220063 51st senate district democratic farmer labor party      1.00e6 61st s…
    ##  8 213688 aransas corpus christi pilots                           8.54e5 aransa…
    ##  9 118069 fayette county republican women                         9.22e5 fayett…
    ## 10 177258 mintz levin cohn ferris glovsky & popeo                 1.25e6 mintz …
    ## # … with 2,524 more rows

ZoomerJoin finds and joins on the matching rows in just a few seconds.
