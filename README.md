
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
n <- 50000
corpus_1 <- read_csv("bonica.csv")  %>%
    sample_n(n)
```

    ## New names:
    ## Rows: 1332470 Columns: 2
    ## ── Column specification
    ## ──────────────────────────────────────────────────────── Delimiter: "," chr
    ## (1): x dbl (1): ...1
    ## ℹ Use `spec()` to retrieve the full column specification for this data. ℹ
    ## Specify the column types or set `show_col_types = FALSE` to quiet this message.
    ## • `` -> `...1`

``` r
names(corpus_1) <- c("a", "field")
corpus_2 <- read_csv("bonica.csv")  %>%
    sample_n(n)
```

    ## New names:
    ## Rows: 1332470 Columns: 2
    ## ── Column specification
    ## ──────────────────────────────────────────────────────── Delimiter: "," chr
    ## (1): x dbl (1): ...1
    ## ℹ Use `spec()` to retrieve the full column specification for this data. ℹ
    ## Specify the column types or set `show_col_types = FALSE` to quiet this message.
    ## • `` -> `...1`

``` r
names(corpus_2) <- c("b", "field")

head(corpus_1)
```

    ## # A tibble: 6 × 2
    ##         a field                                     
    ##     <dbl> <chr>                                     
    ## 1  549441 mark duncan center township constable     
    ## 2   65564 tom eliot fisch architecture and interiors
    ## 3  462251 sharper image photo                       
    ## 4 1280437 america channel llc pac; the              
    ## 5  999136 afghan food & paper inc                   
    ## 6 1106742 herkimer county womens republican club

``` r
head(corpus_2)
```

    ## # A tibble: 6 × 2
    ##         b field                                          
    ##     <dbl> <chr>                                          
    ## 1  362007 owen henry for mayor                           
    ## 2  234043 great american realty of guy lombardo blvd, llc
    ## 3 1206495 shepherd williams & associates                 
    ## 4 1023477 van rafelghem, louis j brig gen                
    ## 5  724566 citizens for d anna                            
    ## 6  128812 marvin childers for state representative

``` r
joined_df <- lhs_inner_join(corpus_1, corpus_2, n_gram_width=6, n_bands=20, band_width=5)
```

    ## Joining by 'field'

``` r
head(joined_df)
```

    ## # A tibble: 6 × 4
    ##         a field.x                             b field.y                      
    ##     <dbl> <chr>                           <dbl> <chr>                        
    ## 1  509459 painters sun country chrysler  509459 painters sun country chrysler
    ## 2  991953 bny mellon asset management    991953 bny mellon asset management  
    ## 3  645652 first value homes inc          645652 first value homes inc        
    ## 4  333221 ga assoc of convience stores   333221 ga assoc of convience stores 
    ## 5  462871 sglp lc                        462871 sglp lc                      
    ## 6 1259033 mcculloch resesarch & polling 1259033 mcculloch resesarch & polling

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
