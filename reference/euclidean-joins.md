# Fuzzy joins for Euclidean distance using Locality Sensitive Hashing

Fuzzy joins for Euclidean distance using Locality Sensitive Hashing

## Usage

``` r
euclidean_anti_join(
  a,
  b,
  by = NULL,
  threshold = 1,
  n_bands = 30,
  band_width = 5,
  r = 0.5,
  progress = FALSE,
  nthread = NULL
)

euclidean_inner_join(
  a,
  b,
  by = NULL,
  threshold = 1,
  n_bands = 30,
  band_width = 5,
  r = 0.5,
  progress = FALSE,
  nthread = NULL
)

euclidean_left_join(
  a,
  b,
  by = NULL,
  threshold = 1,
  n_bands = 30,
  band_width = 5,
  r = 0.5,
  progress = FALSE,
  nthread = NULL
)

euclidean_right_join(
  a,
  b,
  by = NULL,
  threshold = 1,
  n_bands = 30,
  band_width = 5,
  r = 0.5,
  progress = FALSE,
  nthread = NULL
)

euclidean_full_join(
  a,
  b,
  by = NULL,
  threshold = 1,
  n_bands = 30,
  band_width = 5,
  r = 0.5,
  progress = FALSE,
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

- threshold:

  The distance threshold below which units should be considered a match.
  Note that contrary to Jaccard joins, this value is about the distance
  and not the similarity. Therefore, a lower value means a higher
  similarity.

- n_bands:

  The number of bands used in the minihash algorithm (default is 40).
  Use this in conjunction with the `band_width` to determine the
  performance of the hashing. The default settings are for a (.2, .8,
  .001, .999)-sensitive hash i.e. that pairs with a similarity of less
  than .2 have a \>.1% chance of being compared, while pairs with a
  similarity of greater than .8 have a \>99.9% chance of being compared.

- band_width:

  The length of each band used in the minihashing algorithm (default
  is 8) Use this in conjunction with the `n_bands` to determine the
  performance of the hashing. The default settings are for a (.2, .8,
  .001, .999)-sensitive hash i.e. that pairs with a similarity of less
  than .2 have a \>.1% chance of being compared, while pairs with a
  similarity of greater than .8 have a \>99.9% chance of being compared.

- r:

  Hyperparameter used to govern the sensitivity of the locality
  sensitive hash. Corresponds to the width of the hash bucket in the LSH
  algorithm. Increasing values of `r` mean more hash collisions and
  higher sensitivity (fewer false-negatives) at the cost of lower
  specificity (more false-positives and longer run time). For more
  information, see the description in
  [doi:10.1145/997817.997857](https://doi.org/10.1145/997817.997857) .

- progress:

  Set to `TRUE` to print progress.

- nthread:

  Maximum number of threads to use. If `NULL` (default), Rayon's global
  thread pool is used, which typically uses all logical CPU cores
  available.

## Value

A tibble fuzzily-joined on the basis of the variables in `by.` Tries to
adhere to the same standards as the dplyr-joins, and uses the same
logical joining patterns (i.e. inner-join joins and keeps only
observations in both datasets).

## References

Datar, Mayur, Nicole Immorlica, Pitor Indyk, and Vahab Mirrokni.
"Locality-Sensitive Hashing Scheme Based on p-Stable Distributions" SCG
'04: Proceedings of the twentieth annual symposium on Computational
geometry (2004): 253-262

## Examples

``` r
n <- 10

# Build two matrices that have close values
X_1 <- matrix(c(seq(0, 1, 1 / (n - 1)), seq(0, 1, 1 / (n - 1))), nrow = n)
X_2 <- X_1 + .0000001

X_1 <- as.data.frame(X_1)
X_2 <- as.data.frame(X_2)

X_1$id_1 <- 1:n
X_2$id_2 <- 1:n

# only keep observations that have a match
euclidean_inner_join(X_1, X_2, by = c("V1", "V2"), threshold = .00005)
#> # A tibble: 10 × 6
#>     V1.x  V2.x  id_1      V1.y      V2.y  id_2
#>    <dbl> <dbl> <int>     <dbl>     <dbl> <int>
#>  1 0.444 0.444     5 0.444     0.444         5
#>  2 0.556 0.556     6 0.556     0.556         6
#>  3 0.111 0.111     2 0.111     0.111         2
#>  4 0.667 0.667     7 0.667     0.667         7
#>  5 1     1        10 1.00      1.00         10
#>  6 0     0         1 0.0000001 0.0000001     1
#>  7 0.333 0.333     4 0.333     0.333         4
#>  8 0.889 0.889     9 0.889     0.889         9
#>  9 0.222 0.222     3 0.222     0.222         3
#> 10 0.778 0.778     8 0.778     0.778         8

# keep all observations from X_1, regardless of whether they have a match
euclidean_inner_join(X_1, X_2, by = c("V1", "V2"), threshold = .00005)
#> # A tibble: 10 × 6
#>     V1.x  V2.x  id_1      V1.y      V2.y  id_2
#>    <dbl> <dbl> <int>     <dbl>     <dbl> <int>
#>  1 0.778 0.778     8 0.778     0.778         8
#>  2 0     0         1 0.0000001 0.0000001     1
#>  3 0.556 0.556     6 0.556     0.556         6
#>  4 0.222 0.222     3 0.222     0.222         3
#>  5 0.889 0.889     9 0.889     0.889         9
#>  6 1     1        10 1.00      1.00         10
#>  7 0.667 0.667     7 0.667     0.667         7
#>  8 0.333 0.333     4 0.333     0.333         4
#>  9 0.111 0.111     2 0.111     0.111         2
#> 10 0.444 0.444     5 0.444     0.444         5
```
