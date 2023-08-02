
# zoomerjoin <img src='man/figures/logo.png' align="right" height="139" />

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![Codecov test
coverage](https://codecov.io/gh/beniaminogreen/zoomerjoin/branch/main/graph/badge.svg)](https://app.codecov.io/gh/beniaminogreen/zoomerjoin?branch=main)
<!-- badges: end -->

zoomerjoin is an R package that empowers you to fuzzy-join massive
datasets rapidly, and with little memory consumption. It is powered by
high-performance implementations of [Locality Sensitive
Hashing](https://en.wikipedia.org/wiki/Locality-sensitive_hashing), an
algorithm that finds the matches records between two datasets without
having to compare all possible pairs of observations. In practice, this
means zoomerjoin can fuzzily-join datasets days, or even years faster
than other matching packages. zoomerjoin has been used in-production to
join datasets of hundreds of millions of names in a few hours.

## Installation

------------------------------------------------------------------------

### Preliminaries - Installing Rust:

You must have the [Rust
compiler](https://www.rust-lang.org/tools/install) installed to compile
this package. After the package is compiled, Rust is no longer required,
and can be safely uninstalled.

To install Rust on windows, you can use the Rust installation wizard,
found
[here](https://forge.rust-lang.org/infra/other-installation-methods.html).
On Linux or MacOs, you can install Rust with:

``` sh
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

### Installing Package from Github:

Once you have rust installed Rust, you should be able to install the
package with the `install_github` function from the `devtools` package,
or with the `pkg_install` function from the `pak` package.

``` r
## Install with devtools
# install.packages("devtools")
devtools::install_github("beniaminogreen/zoomerjoin")

## Install with pak
# install.packages("pak")
pak::pkg_install("beniaminogreen/zoomerjoin")
```

## Loading The Package

Once the package is installed, you can load it into memory as usual by
typing:

``` r
library(zoomerjoin)
```

### Usage:

The flagship feature of zoomerjoins are the jaccard_join and euclidean
family of functions, which are designed to be near drop-ins for the
corresponding dplyr/fuzzyjoin commands:

- `jaccard_left_join()`
- `jaccard_right_join()`
- `jaccard_inner_join()`
- `jaccard_full_join()`
- `euclidean_left_join`
- `euclidean_right_join`
- `euclidean_inner_join`
- `euclidean_full_join`

The `jaccard_join` family of functions provide fast fuzzy-joins for
strings using the Jaccard distance while the `euclidean_join` family
provides fuzzy-joins for points or vectors using the Euclidean distance.

#### Example: Joining rows of the Database on Ideology, Money in Politics, and Elections

(DIME)

Here’s a snippet showing off how to use the `lhs_inner_join()` merge two
datasets of political donors in the [Database on Ideology, Money in
Politics, and Elections (DIME)](https://data.stanford.edu/dime). You can
see a more detailed example of this vignette in the [introductory
vignette](https://beniaminogreen.github.io/zoomerjoin/articles/guided_tour.html).

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
    ## # ℹ 499,990 more rows

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
    ## # ℹ 499,990 more rows

Both corpuses have an observation ID column, and a donor name column. We
would like to join the two datasets on the donor names column, but the
two can’t be directly joined because of misspellings. Because of this,
we will use the jaccard_inner_join function to fuzzily join the two on
the donor name column.

Importantly, Locality Sensitive Hashing is a [probabilistic
algorithm](https://en.wikipedia.org/wiki/Randomized_algorithm), so it
may fail to identify some matches by random chance. I adjust the
hyperparameters `n_bands` and `band_width` until the chance of true
matches being dropped is negligible. By default, the package will issue
a warning if the chance of a true match being discovered is less than
95%. You can use the `jaccard_probability` and
`jaccard_hyper_grid_search` to help understand the probability any true
matches will be discarded by the algorithm.

More details and a more thorough description of how to tune the
hyperparameters can be can be found in the [guided tour
vignette](https://beniaminogreen.github.io/zoomerjoin/articles/guided_tour.html).

``` r
start_time <- Sys.time()
join_out <- jaccard_inner_join(corpus_1, corpus_2, n_gram_width=6, n_bands=20, band_width=6)
```

    ## Warning in jaccard_join(a, b, mode = "inner", by = by, salt_by = block_by, : A pair of records at the threshold (0.7) have only a 92% chance of being compared.
    ## Please consider changing `n_bands` and `band_width`.

    ## Joining by 'field'

``` r
print(Sys.time() - start_time)
```

    ## Time difference of 10.06169 secs

``` r
print(join_out)
```

    ## # A tibble: 186,691 × 4
    ##         a field.x                                                      b field.y
    ##     <dbl> <chr>                                                    <dbl> <chr>  
    ##  1 406569 west jersey optometric society                          1.20e6 south …
    ##  2 302206 solutions inc                                           1.21e6 r-solu…
    ##  3 254858 g f thomas investments lp                               1.19e6 thomas…
    ##  4 362272 olive construction management inc                       1.16e6 cb con…
    ##  5 237140 fernandez liquors inc                                   9.68e5 fernan…
    ##  6  31191 anson county democratic party                           8.64e5 slo co…
    ##  7 366593 lcg investment co lp                                    1.24e6 p2 inv…
    ##  8  57768 united food and commercial workers international union… 8.89e5 united…
    ##  9 408887 wdc enterprises inc                                     1.23e6 plc en…
    ## 10 483822 r energy management co                                  1.00e6 acp en…
    ## # ℹ 186,681 more rows

ZoomerJoin finds and joins on the matching rows in just a few seconds.

# Acknowledgments:

The Zoomerjoin was made using [this SQL join
illustration](https://commons.wikimedia.org/wiki/File:SQL_Join_-_08_A_Cross_Join_B.svg)
by [Germanx](https://commons.wikimedia.org/wiki/User:GermanX) and [this
speed limit
sign](https://commons.wikimedia.org/wiki/File:Speed_limit_75_sign.svg)
from the Federal Highway Administration - MUTCD.

## References:

Bonica, Adam. 2016. Database on Ideology, Money in Politics, and
Elections: Public version 2.0 \[Computer file\]. Stanford, CA: Stanford
University Libraries.

Jure Leskovec, Anand Rajaraman, and Jeffrey David Ullman. 2014. Mining
of Massive Datasets (2nd. ed.). Cambridge University Press, USA.

Broder, Andrei Z. (1997), “On the resemblance and containment of
documents”, Compression and Complexity of Sequences: Proceedings.
Positano, Salerno, Italy
