
# zoomerjoin [![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)

INSANELY, BLAZINGLY FAST fuzzy joins in R. Implimented using
[MinHash](https://en.wikipedia.org/wiki/MinHash) to cut down on the
number of comparisons that need to be made in calculating matches. This
results in matches that return orders of magnitude faster than other
matches.

#### Installation

------------------------------------------------------------------------

##### Installing Rust:

You must have [Rust](https://www.rust-lang.org/tools/install) installed
to compile this package. The rust website provides an excellent
installation script that has never caused me any issues.

On Linux or MacOs, you can install Rust with:

``` sh
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

On Windows, I use the rust installation wizard, found
[here](https://forge.rust-lang.org/infra/other-installation-methods.html).

##### Installing Package from Github:

Once you install Rust, you should be able to install the package with:

``` r
devtools::install_github("beniaminogreen/zoomerjoin")
```

### Usage:

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

    ## Time difference of 11.82046 secs

``` r
print(join_out)
```

    ## # A tibble: 2,534 × 4
    ##         a field.x                                                      b field.y
    ##     <dbl> <chr>                                                    <dbl> <chr>  
    ##  1  67535 eye pac of the texas opthamological assoc.              8.36e5 eye pa…
    ##  2  51776 california applicants attorneys assoc                   8.58e5 califo…
    ##  3  52678 public employees union local 1                          9.40e5 public…
    ##  4 117867 friends of jodie laubenberg                             8.81e5 friend…
    ##  5   6482 texas league of conservation voters political committee 8.91e5 texas …
    ##  6  62881 targetcitizen s multistate forum                        8.92e5 target…
    ##  7 262538 busch entertainment corp                                9.91e5 busch …
    ##  8  53285 texas state assoc. of fire fighters action committee    8.64e5 texas …
    ##  9 116016 sheet metal workers local 359                           1.21e6 sheet …
    ## 10  39440 eastern investigational servic                          1.05e6 easter…
    ## # … with 2,524 more rows

ZoomerJoin finds and joins on the matching rows in just a few seconds.