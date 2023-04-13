
# zoomerjoin

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![Codecov test
coverage](https://codecov.io/gh/beniaminogreen/zoomerjoin/branch/main/graph/badge.svg)](https://app.codecov.io/gh/beniaminogreen/zoomerjoin?branch=main)
<!-- badges: end -->

zoomerjoin is an R package that empowers you to fuzzy-join massive
datasets rapidly, and with little memory consumption. Its backbone is a
high-performance implementation of
[MinHash](https://en.wikipedia.org/wiki/MinHash), an algorithm which
shortcuts the expensive computational step of comparing all possible
pairings of records between the two datasets. In practice, this means
zoomerjoin can fuzzily-join datasets days, or even years faster than
other matching packages. zoomerjoin has been used in-production to join
datasets of hundreds of millions of names in a few hours.

The package also wraps the
[kdtree](https://docs.rs/kdtree/latest/kdtree/) Rust crate to provide
blazingly fast spatial joins.

#### Installation

------------------------------------------------------------------------

##### Installing Rust:

You must have [Rust](https://www.rust-lang.org/tools/install) installed
to compile this package. After the package is compiled, Rust is no
longer required, and can be safely uninstalled.

To install Rust on windows, you can use the Rust installation wizard,
found
[here](https://forge.rust-lang.org/infra/other-installation-methods.html).
On Linux or MacOs, you can install Rust with:

``` sh
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

##### Installing Package from Github:

Once you have rust installed Rust, you should be able to install the
package with the `install_github` function from the `devtools` package:

``` r
#install.packages("devtools")
devtools::install_github("beniaminogreen/zoomerjoin")
```

### Usage:

The flagship feature of zoomerjoins are the lsh_join family of
functions, which are designed to be near drop-ins for the corresponding
dplyr/fuzzyjoin commands:

- `lsh_left_join()`
- `lsh_right_join()`
- `lsh_inner_join()`
- `lsh_full_join()`

Here’s a snippet showing off how to use the `lhs_inner_join()` merge two
datasets of political donors in the [Database on Ideology, Money in
Politics, and Elections (DIME)](https://data.stanford.edu/dime).

I start with two corpuses I would like to combine, `corpus_1`:

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

Both corpuses have an observation ID column, and a donor name column. We
would like to join the two datasets on the donor names column, but the
two can’t be directly joined because of misspellings. Because of this,
we will use the lsh_inner_join function to fuzzily join the two on the
donor name column.

``` r
start_time <- Sys.time()
join_out <- lsh_inner_join(corpus_1, corpus_2, n_gram_width=6, n_bands=20, band_width=6)
```

    ## Joining by 'field'

``` r
print(Sys.time() - start_time)
```

    ## Time difference of 9.075234 secs

``` r
print(join_out)
```

    ## # A tibble: 178,204 × 4
    ##         a field.x                                        b field.y              
    ##     <dbl> <chr>                                      <dbl> <chr>                
    ##  1 445604 strange & downing pc                      934593 strange & downing pc…
    ##  2 301868 top side construction inc                 889906 top side construction
    ##  3  88848 plumbers & pipefitters local 34          1097220 plumbers & pipefitte…
    ##  4  88832 powell county republican central cmte    1103454 niob county republic…
    ##  5 109775 gordon anderson for state representative 1130996 keven anderson for s…
    ##  6  32856 law office of janet mccullar pc           864917 law office of janet …
    ##  7 415258 vep enterprises inc                      1077077 aep enterprises inc  
    ##  8 121588 steelworkers local 5                      934842 steelworkers local 7…
    ##  9 227160 schultz engineering services inc         1209811 schultz engineering …
    ## 10 317814 j h design group                          972630 hh design group      
    ## # … with 178,194 more rows

ZoomerJoin finds and joins on the matching rows in just a few seconds.

## References:

Bonica, Adam. 2016. Database on Ideology, Money in Politics, and
Elections: Public version 2.0 \[Computer file\]. Stanford, CA: Stanford
University Libraries.

Jure Leskovec, Anand Rajaraman, and Jeffrey David Ullman. 2014. Mining
of Massive Datasets (2nd. ed.). Cambridge University Press, USA.

Broder, Andrei Z. (1997), “On the resemblance and containment of
documents”, Compression and Complexity of Sequences: Proceedings.
Positano, Salerno, Italy
