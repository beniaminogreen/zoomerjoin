# Calculate Jaccard Similarity of two character vectors

Calculate Jaccard Similarity of two character vectors

## Usage

``` r
jaccard_similarity(a, b, ngram_width = 2, nthread = NULL)
```

## Arguments

- a:

  the first character vector

- b:

  the first character vector

- ngram_width:

  the length of the shingles / ngrams used in the similarity calculation

- nthread:

  Maximum number of threads to use. If `NULL` (default), Rayon's global
  thread pool is used, which typically uses all logical CPU cores
  available.

## Value

a vector of jaccard similarities of the strings

## Examples

``` r
jaccard_similarity(
  c("the quick brown fox", "jumped over the lazy dog"),
  c("the quck bron fx", "jumped over hte lazy dog")
)
#> [1] 0.5714286 0.7692308
```
