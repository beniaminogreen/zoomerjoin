# Fuzzy String Grouping Using Minhashing

Performs fuzzy string grouping in which similar strings are assigned to
the same group. Uses the `cluster_fast_greedy()` community detection
algorithm from the `igraph` package to create the groups. Must have
igraph installed in order to use this function.

## Usage

``` r
jaccard_string_group(
  string,
  n_gram_width = 2,
  n_bands = 45,
  band_width = 8,
  threshold = 0.7,
  progress = FALSE,
  nthread = NULL
)
```

## Arguments

- string:

  a character you wish to perform entity resolution on.

- n_gram_width:

  the length of the n_grams used in calculating the jaccard similarity.
  For best performance, I set this large enough that the chance any
  string has a specific n_gram is low (i.e. `n_gram_width` = 2 or 3 when
  matching on first names, 5 or 6 when matching on entire sentences).

- n_bands:

  the number of bands used in the minihash algorithm (default is 40).
  Use this in conjunction with the `band_width` to determine the
  performance of the hashing. The default settings are for a
  (.2,.8,.001,.999)-sensitive hash i.e. that pairs with a similarity of
  less than .2 have a \>.1% chance of being compared, while pairs with a
  similarity of greater than .8 have a \>99.9% chance of being compared.

- band_width:

  the length of each band used in the minihashing algorithm (default
  is 8) Use this in conjunction with the `n_bands` to determine the
  performance of the hashing. The default settings are for a
  (.2,.8,.001,.999)-sensitive hash i.e. that pairs with a similarity of
  less than .2 have a \>.1% chance of being compared, while pairs with a
  similarity of greater than .8 have a \>99.9% chance of being compared.

- threshold:

  the jaccard similarity threshold above which two strings should be
  considered a match (default is .95). The similarity is euqal to 1

  - the jaccard distance between the two strings, so 1 implies the
    strings are identical, while a similarity of zero implies the
    strings are completely dissimilar.

- progress:

  set to true to report progress of the algorithm

- nthread:

  Maximum number of threads to use. If `NULL` (default), Rayon's global
  thread pool is used, which typically uses all logical CPU cores
  available.

## Value

a string vector storing the group of each element in the original input
strings. The input vector is grouped so that similar strings belong to
the same group, which is given a standardized name.

## Examples

``` r
string <- c(
  "beniamino", "jack", "benjamin", "beniamin",
  "jacky", "giacomo", "gaicomo"
)
jaccard_string_group(string, threshold = .2, n_bands = 90, n_gram_width = 1)
#> Loading required namespace: igraph
#> [1] "beniamino" "jack"      "beniamino" "beniamino" "jack"      "giacomo"  
#> [7] "giacomo"  
```
