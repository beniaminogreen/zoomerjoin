# Find Probability of Match Based on Similarity

This is a port of the
[lsh_probability](https://docs.ropensci.org/textreuse/reference/lsh_probability.html)
function from the
[textreuse](https://cran.r-project.org/package=textreuse) package, with
arguments changed to reflect the hyperparameters in this package. It
gives the probability that two strings of jaccard similarity
`similarity` will be matched, given the chosen bandwidth and number of
bands.

## Usage

``` r
jaccard_probability(similarity, n_bands, band_width)
```

## Arguments

- similarity:

  the similarity of the two strings you want to compare

- n_bands:

  The number of LSH bands used in hashing.

- band_width:

  The number of hashes in each band.

## Value

a decimal number giving the probability that the two items will be
returned as a candidate pair from the minhash algorithm.

## Examples

``` r
# Find the probability two pairs will be matched given they have a
# jaccard_similarity of .8, band width of 5, and 50 bands:
jaccard_probability(.8, n_bands = 50, band_width = 5)
#> [1] 1
```
