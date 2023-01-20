
# ZoomerJoin

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

``` r
join_out <- lhs_inner_join(corpus_1, corpus_2, n_gram_width=6, n_bands=20, band_width=5)
```

    ## Joining by 'field'

``` r
print(join_out)
```

    ## # A tibble: 2,330 × 4
    ##         a field.x                                       b field.y               
    ##     <dbl> <chr>                                     <dbl> <chr>                 
    ##  1  74133 hoover bax & slovacek l.l.p.             961035 hoover bax & slovacek…
    ##  2 493915 primeline insurance & financial service  940445 primeline insurance &…
    ##  3  53050 law office of randall h. erben           953497 law office of randall…
    ##  4 455311 sontera medical management group inc     935457 sontera medical manag…
    ##  5  55015 munsch hardt kopf & harr pc              946193 munsch hardt kopf & h…
    ##  6  87659 fidelity sw good govt comm               876034 fidelity sw good govt…
    ##  7  66790 pac of winstead sechrest & minick,       845903 pac of winstead sechr…
    ##  8  63393 pac of winstead sechrest & minick p. c.  943136 pac of winstead sechr…
    ##  9 161610 food & commercial workers local 23      1049976 food & commercial wor…
    ## 10  78539 belton k johnson interests              1038746 belton k johnson inte…
    ## # … with 2,320 more rows

## Benchmarks:

Here’s a quick and dirty benchmark showing the performance of this
package realative to the default standard, `fuzzyjoin`:

![](README_files/figure-gfm/unnamed-chunk-3-1.png)<!-- -->

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
