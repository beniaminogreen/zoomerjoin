# Find Probability of Match Based on Similarity

Find Probability of Match Based on Similarity

## Usage

``` r
euclidean_probability(distance, n_bands, band_width, r)
```

## Arguments

- distance:

  the euclidian distance between the two vectors you want to compare.

- n_bands:

  The number of LSH bands used in hashing.

- band_width:

  The number of hashes in each band.

- r:

  the "r" hyperparameter used to govern the sensitivity of the hash.

## Value

a decimal number giving the proability that the two items will be
returned as a candidate pair from the minihash algorithm.
