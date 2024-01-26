
# zoomerjoin <img src='man/figures/logo.png' align="right" height="139" />

<!-- badges: start -->

[![DOI](https://joss.theoj.org/papers/10.21105/joss.05693/status.svg)](https://doi.org/10.21105/joss.05693)
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
join datasets of hundreds of millions of names or vectors in a matter of
hours.

## Installation

### Installing from CRAN:

You can install from the CRAN as you would with any other package.
Please be aware that you will have to have Cargo (the rust toolchain and
compiler) installed to build the package from source.

``` r
install.packages(zoomerjoin)
```

### Installing from R-Universe:

This package is distributed using
[r-universe](https://r-universe.dev/search/), which provides
pre-compiled binaries for common operating systems and recent versions
of R. To install with r-universe, you can use the following command in
R:

``` r
install.packages(
  'zoomerjoin',
  repos = c('https://beniaminogreen.r-universe.dev', getOption("repos"))
)
```

### Installing Rust

If your operating system or version of R is not installed, you must have
the [Rust compiler](https://www.rust-lang.org/tools/install) installed
to compile this package from sources. After the package is compiled,
Rust is no longer required, and can be safely uninstalled.

#### Installing Rust on Linux or Mac:

To install Rust on Linux or Mac, you can simply run the following
snippet in your terminal.

``` sh
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

#### Installing Rust on Windows:

To install Rust on windows, you can use the Rust installation wizard,
`rustup-init.exe`, found [at this
site](https://forge.rust-lang.org/infra/other-installation-methods.html).
Depending on your version of Windows, you may see an error that looks
something like this:

    error: toolchain 'stable-x86_64-pc-windows-gnu' is not installed

In this case, you should run
`rustup install stable-x86_64-pc_windows-gnu` to install the missing
toolchain. If you’re missing another toolchain, simply type this in the
place of `stable-x86_64-pc_windows-gnu` in the command above.

### Installing Package from Github:

Once you have rust installed Rust, you should be able to install the
package with either the install.packages function as above, or using the
`install_github` function from the `devtools` package or with the
`pkg_install` function from the `pak` package.

``` r
## Install with devtools
# install.packages("devtools")
devtools::install_github("beniaminogreen/zoomerjoin")

## Install with pak
# install.packages("pak")
pak::pkg_install("beniaminogreen/zoomerjoin")
```

### Loading The Package

Once the package is installed, you can load it into memory as usual by
typing:

``` r
library(zoomerjoin)
```

## Usage:

The flagship feature of zoomerjoins are the jaccard_join and euclidean
family of functions, which are designed to be near drop-ins for the
corresponding dplyr/fuzzyjoin commands:

- `jaccard_left_join()`
- `jaccard_right_join()`
- `jaccard_inner_join()`
- `jaccard_full_join()`
- `euclidean_left_join()`
- `euclidean_right_join()`
- `euclidean_inner_join()`
- `euclidean_full_join()`

The `jaccard_join` family of functions provide fast fuzzy-joins for
strings using the Jaccard distance while the `euclidean_join` family
provides fuzzy-joins for points or vectors using the Euclidean distance.

### Example: Joining rows of the Database on Ideology, Money in Politics, and Elections

(DIME)

Here’s a snippet showing off how to use the `jaccard_inner_join()` merge
two lists of political donors in the [Database on Ideology, Money in
Politics, and Elections (DIME)](https://data.stanford.edu/dime). You can
see a more detailed example of this vignette in the [introductory
vignette](https://beniamino.org/zoomerjoin/articles/guided_tour.html).

I start with two corpuses I would like to combine, `corpus_1`:

``` r
corpus_1 <- dime_data %>%
    head(500)
names(corpus_1) <- c("a", "field")
corpus_1
```

    ## # A tibble: 500 × 2
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
    ## # ℹ 490 more rows

And `corpus_2`:

``` r
corpus_2 <- dime_data %>%
    tail(500)
names(corpus_2) <- c("b", "field")
corpus_2
```

    ## # A tibble: 500 × 2
    ##        b field                                                                  
    ##    <dbl> <chr>                                                                  
    ##  1   501 citizens for derwinski                                                 
    ##  2   502 progressive victory fund greater washington americans for democratic a…
    ##  3   503 ingham county democratic party federal campaign fund                   
    ##  4   504 committee for a stronger future                                        
    ##  5   505 atoka country supper committee                                         
    ##  6   506 friends of democracy pac inc                                           
    ##  7   507 baypac                                                                 
    ##  8   508 international brotherhood of electrical workers local union 278 cope/p…
    ##  9   509 louisville & jefferson county republican executive committee           
    ## 10   510 democratic party of virginia                                           
    ## # ℹ 490 more rows

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
vignette](https://beniamino.org/zoomerjoin/articles/guided_tour.html).

``` r
set.seed(1)
start_time <- Sys.time()
join_out <- jaccard_inner_join(corpus_1, corpus_2, n_gram_width=6, n_bands=20, band_width=6)
```

    ## Warning in jaccard_join(a, b, mode = "inner", by = by, salt_by = block_by, : A pair of records at the threshold (0.7) have only a 92% chance of being compared.
    ## Please consider changing `n_bands` and `band_width`.

    ## Joining by 'field'

``` r
print(Sys.time() - start_time)
```

    ## Time difference of 0.01455116 secs

``` r
print(join_out)
```

    ## # A tibble: 19 × 4
    ##        a field.x                                                      b field.y 
    ##    <dbl> <chr>                                                    <dbl> <chr>   
    ##  1   216 kent county republican finance committee                   607 lake co…
    ##  2   238 4th congressional district democratic party                518 16th co…
    ##  3   292 bill bradley for u s senate '84                            913 bill br…
    ##  4   378 guarini for congress 1982                                  606 guarini…
    ##  5   232 republican county committee of chester county              710 republi…
    ##  6   387 committee to re elect congressman staton                   805 committ…
    ##  7   122 tarrant county republican victory fund                     761 lake co…
    ##  8   378 guarini for congress 1982                                  883 guarini…
    ##  9   238 4th congressional district democratic party                792 8th con…
    ## 10    88 scheuer for congress 1980                                  667 scheuer…
    ## 11    45 dole for senate committee                                  623 riegle …
    ## 12    87 kentucky state democratic central executive committee      639 arizona…
    ## 13   319 7th congressional district democratic party of wisconsin   792 8th con…
    ## 14   478 united democrats for better government                     642 democra…
    ## 15   163 davies county republican executive committee               852 warren …
    ## 16   230 pipefitters local union 524                                998 pipefit…
    ## 17   216 kent county republican finance committee                   719 harford…
    ## 18   302 americans for good government inc                          910 america…
    ## 19    35 solarz for congress 82                                     671 solarz …

Zoomerjoin is able to quickly find the matching columns without
comparing all pairs of records. This saves more and more time as the
size of each list increases, so it can scale to join datasets with
millions or hundreds of millions of rows.

# Contributing

Thanks for your interest in contributing to Zoomerjoin!

I am using a gitub-centric workflow to manage the package; You can file
a bug report, request a new feature, or ask a question about the package
by [filing an issue on the issues
page](https://github.com/beniaminogreen/zoomerjoin/issues), where you
will also find a range of templates to help you out. If you’d like to
make changes to the code, you can write and file a [pull
request](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/about-pull-requests)
on [this page](https://github.com/beniaminogreen/zoomerjoin/pulls). I’ll
try to respond to all of these in a timely manner (within a week)
although occasionally I may take longer to respond to a complicated
question or issue.

Please also be aware of the [contributor code of
conduct](https://github.com/beniaminogreen/zoomerjoin/blob/main/CONTRIBUTING.md)
for contributing to the repository.

## Acknowledgments:

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
