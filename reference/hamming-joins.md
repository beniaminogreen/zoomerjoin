# Fuzzy joins for Hamming distance using Locality Sensitive Hashing

Find similar rows between two tables using the hamming distance. The
hamming distance is equal to the number characters two strings differ
by, or is equal to infinity if two strings are of different lengths

## Usage

``` r
hamming_inner_join(
  a,
  b,
  by = NULL,
  n_bands = 100,
  band_width = 8,
  threshold = 2,
  progress = FALSE,
  clean = FALSE,
  similarity_column = NULL,
  nthread = NULL
)

hamming_anti_join(
  a,
  b,
  by = NULL,
  n_bands = 100,
  band_width = 100,
  threshold = 2,
  progress = FALSE,
  clean = FALSE,
  similarity_column = NULL,
  nthread = NULL
)

hamming_left_join(
  a,
  b,
  by = NULL,
  n_bands = 100,
  band_width = 100,
  threshold = 2,
  progress = FALSE,
  clean = FALSE,
  similarity_column = NULL,
  nthread = NULL
)

hamming_right_join(
  a,
  b,
  by = NULL,
  n_bands = 100,
  band_width = 100,
  threshold = 2,
  progress = FALSE,
  clean = FALSE,
  similarity_column = NULL,
  nthread = NULL
)

hamming_full_join(
  a,
  b,
  by = NULL,
  n_bands = 100,
  band_width = 100,
  threshold = 2,
  progress = FALSE,
  clean = FALSE,
  similarity_column = NULL,
  nthread = NULL
)
```

## Arguments

- a, b:

  The two dataframes to join.

- by:

  A named vector indicating which columns to join on. Format should be
  the same as dplyr:
  `by = c("column_name_in_df_a" = "column_name_in_df_b")`, but two
  columns must be specified in each dataset (x column and y column).
  Specification made with
  [`dplyr::join_by()`](https://dplyr.tidyverse.org/reference/join_by.html)
  are also accepted.

- n_bands:

  The number of bands used in the locality sensitive hashing algorithm
  (default is 100). Use this in conjunction with the `band_width` to
  determine the performance of the hashing. Generally speaking, a higher
  number of bands leads to greater recall at the cost of higher runtime.

- band_width:

  The length of each band used in the minihashing algorithm (default is
  8). Use this in conjunction with the `n_bands` to determine the
  performance of the hashing. Generally speaking a wider number of bands
  decreases the number of false positives, decreasing runtime at the
  cost of lower sensitivity (true matches are less likely to be found).

- threshold:

  The Hamming distance threshold below which two strings should be
  considered a match. A distance of zero corresponds to complete
  equality between strings, while a distance of 'x' between two strings
  means that 'x' substitutions must be made to transform one string into
  the other.

- progress:

  Set to `TRUE` to print progress.

- clean:

  Should the strings that you fuzzy join on be cleaned (coerced to
  lower-case, stripped of punctuation and spaces)? Default is `FALSE`.

- similarity_column:

  An optional character vector. If provided, the data frame will contain
  a column with this name giving the Hamming distance between the two
  fields. Extra column will not be present if anti-joining.

- nthread:

  Maximum number of threads to use. If `NULL` (default), Rayon's global
  thread pool is used, which typically uses all logical CPU cores
  available.

## Value

A tibble fuzzily-joined on the basis of the variables in `by.` Tries to
adhere to the same standards as the dplyr-joins, and uses the same
logical joining patterns (i.e. inner-join joins and keeps only
observations in both datasets).

## Examples

``` r
if (requireNamespace("babynames", quietly = TRUE)) {
  baby_names <- data.frame(
    name = tolower(unique(babynames::babynames$name))[1:500]
  )

  baby_names_mispelled <- data.frame(
    name_mispelled = gsub("[aeiouy]", "x", baby_names$name)
  )

  hamming_inner_join(
    baby_names,
    baby_names_mispelled,
    by = c("name" = "name_mispelled"),
    threshold = 3,
    n_bands = 150,
    band_width = 10,
    clean = FALSE
  )

  hamming_left_join(
    baby_names,
    baby_names_mispelled,
    by = c("name" = "name_mispelled"),
    threshold = 3,
    n_bands = 150,
    band_width = 10
  )
}
#> # A tibble: 2,746 × 2
#>    name    name_mispelled
#>    <chr>   <chr>         
#>  1 liza    lxtx          
#>  2 velma   vxlmx         
#>  3 fay     xlx           
#>  4 margret mxrgrxt       
#>  5 ruth    xttx          
#>  6 ada     lxx           
#>  7 lena    txnx          
#>  8 ada     nxn           
#>  9 zoe     xvx           
#> 10 ida     lxx           
#> # ℹ 2,736 more rows
```
