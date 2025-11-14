# Calculate Hamming distance of two character vectors

Calculate Hamming distance of two character vectors

## Usage

``` r
hamming_distance(a, b, nthread = NULL)
```

## Arguments

- a:

  the first character vector

- b:

  the first character vector

- nthread:

  Maximum number of threads to use. If `NULL` (default), Rayon's global
  thread pool is used, which typically uses all logical CPU cores
  available.

## Value

a vector of hamming similarities of the strings

## Examples

``` r
hamming_distance(
  c("ACGTCGATGACGTGATGCGTAGCGTA", "ACGTCGATGTGCTCTCGTCGATCTAC"),
  c("ACGTCGACGACGTGATGCGCAGCGTA", "ACGTCGATGGGGTCTCGTCGATCTAC")
)
#> [1] 2 2
```
